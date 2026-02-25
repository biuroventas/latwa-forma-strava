# Integracja Stripe – subskrypcja Premium

Płatność za Premium odbywa się **na stronie Stripe** (link z aplikacji). Po opłaceniu webhook aktualizuje profil użytkownika w Supabase.

> **Dla laika:** pełna instrukcja krok po kroku (co kliknąć, co skopiować, gdzie wkleić) jest w pliku **[STRIPE_KROKI_LAIK.md](STRIPE_KROKI_LAIK.md)**.

## Przepływ

1. Użytkownik w aplikacji klika **„Wykup Premium (Stripe)”**.
2. Aplikacja wywołuje Edge Function **create-checkout-session** (z tokenem JWT).
3. Funkcja tworzy w Stripe **Checkout Session**: dla planu „Rocznie (jednorazowo)” – płatność jednorazowa z **BLIK + karta**; dla „Miesięcznie” / „Rocznie” – subskrypcja (karta, Apple/Google Pay). Zwraca **URL**.
4. Aplikacja otwiera ten URL w przeglądarce (Stripe Checkout).
5. Użytkownik płaci na stronie Stripe.
6. Stripe wysyła webhook **checkout.session.completed** na **stripe-webhook**.
7. Edge Function **stripe-webhook** weryfikuje podpis, odczytuje `client_reference_id` (user_id), pobiera koniec okresu subskrypcji i aktualizuje w Supabase: `profiles.subscription_tier = 'premium'`, `profiles.subscription_expires_at = ...`.
8. Użytkownik wraca do aplikacji i odświeża profil (lub przy następnym wejściu widzi Premium).

---

## Konfiguracja Stripe

### 1. Konto i produkt

- Załóż konto: [stripe.com](https://stripe.com).
- **Produkty** → utwórz produkt „Łatwa Forma Premium” z **trzema cennikami**:
  - **69,98 PLN / miesiąc** (Recurring) → Price ID → `STRIPE_PREMIUM_PRICE_MONTHLY`.
  - **194,95 PLN / rok** (Recurring) → Price ID → `STRIPE_PREMIUM_PRICE_YEARLY`.
  - **194,95 PLN jednorazowo** (One time) → Price ID → `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME` (używane przy płatności „Rocznie jednorazowo” – **BLIK + karta**).
- **Settings → Payment methods:** włącz Cards, **BLIK** (dla płatności jednorazowej za rok), Apple Pay, Google Pay.

### 2. Klucze API

- **Developers → API keys**: skopiuj **Secret key** (np. `sk_test_...` lub `sk_live_...`).

### 3. Webhook

- **Developers → Webhooks** → **Add endpoint**.
- **URL:** `https://<PROJECT_REF>.supabase.co/functions/v1/stripe-webhook`  
  (PROJECT_REF znajdziesz w Supabase: Project Settings → API → Project URL).
- **Zdarzenia:** wybierz `checkout.session.completed`.
- Po utworzeniu wejdź w endpoint → **Signing secret** (np. `whsec_...`).

---

## Konfiguracja Supabase

### Sekrety Edge Functions

W Supabase: **Project Settings → Edge Functions → Secrets** (lub przez CLI) ustaw:

| Secret | Opis |
|--------|------|
| `STRIPE_SECRET_KEY` | Secret key z Stripe (sk_test_... / sk_live_...) |
| `STRIPE_PREMIUM_PRICE_MONTHLY` | Price ID ceny miesięcznej 69,98 PLN recurring (price_...) |
| `STRIPE_PREMIUM_PRICE_YEARLY` | Price ID ceny rocznej 194,95 PLN recurring (price_...) |
| `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME` | Price ID ceny **jednorazowej** 194,95 PLN (za rok) – płatność BLIK + karta (price_...) |
| `STRIPE_WEBHOOK_SECRET` | Signing secret z webhooka Stripe (whsec_...) |
| `STRIPE_SUCCESS_URL` | URL po udanej płatności – **użyj latwaforma.pl**: `https://latwaforma.pl/#/premium-success` (nie app.latwaforma.pl) |
| `STRIPE_CANCEL_URL` | URL po anulowaniu – **użyj latwaforma.pl**: `https://latwaforma.pl/#/premium-cancel` |

Dla kompatybilności wstecznej: jeśli ustawisz tylko `STRIPE_PREMIUM_PRICE_ID`, będzie używany jako domyślna cena (plan monthly). Plan „Rocznie (jednorazowo)” wymaga `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME`.

`SUPABASE_URL` i `SUPABASE_SERVICE_ROLE_KEY` są zwykle ustawione automatycznie dla Edge Functions.

### Deploy funkcji

**Wymagane, żeby płatność działała:** bramka Supabase domyślnie weryfikuje JWT przed wywołaniem funkcji. Gdy token jest uznawany za nieważny (np. opóźnienie, cache), bramka zwraca **401 zanim** kod funkcji się wykona – użytkownik nie może wykupić Premium. Funkcje `create-checkout-session` i `create-portal-session` same weryfikują użytkownika (`getUser(jwt)`), więc **trzeba** wyłączyć weryfikację na bramce:

```bash
supabase functions deploy create-checkout-session --no-verify-jwt
supabase functions deploy create-portal-session --no-verify-jwt
supabase functions deploy stripe-webhook --no-verify-jwt
```
**stripe-webhook** też musi być z `--no-verify-jwt` – Stripe nie wysyła tokenu JWT, tylko nagłówek `Stripe-Signature`. Bez tego w logach Stripe (Event deliveries) zobaczysz **401 ERR** przy `checkout.session.completed`.

Albo uruchom skrypt: `./scripts/deploy_stripe_functions.sh`

**Jeśli „Wykup Premium” zwraca 401:** wdróż ponownie z `--no-verify-jwt` (jak wyżej). Bez tego płatność nie będzie działać bez odświeżania strony.

---

## Testowanie

1. Użyj **kluczy testowych** Stripe (sk_test_..., price z trybu test).
2. Kartę testową: `4242 4242 4242 4242`.
3. Webhook w trybie test: Stripe może wystawić URL z tunelu (np. Stripe CLI: `stripe listen --forward-to https://.../stripe-webhook`) – wtedy użyj wyświetlonego signing secret.
4. Na produkcji ustaw klucze live i prawdziwy webhook URL.

---

## Rezygnacja z subskrypcji (Customer Portal)

Użytkownik z Premium może **zarządzać subskrypcją i zrezygnować** (miesięczną lub roczną) przez **Stripe Customer Portal**:

1. W aplikacji: ekran Premium → przycisk **„Zarządzaj subskrypcją / Rezygnuj”** (widoczny tylko gdy użytkownik ma Premium).
2. Aplikacja wywołuje Edge Function **create-portal-session** → zwraca URL portalu Stripe.
3. Użytkownik otwiera portal w przeglądarce, tam może anulować subskrypcję. Dostęp do Premium trwa do końca opłaconego okresu.

**Wymagane:**

- W **Supabase** wykonaj migrację: `database/supabase/migration_stripe_customer_id.sql` (dodaje `stripe_customer_id` do `profiles`).
- Webhook **stripe-webhook** zapisuje `stripe_customer_id` przy `checkout.session.completed`.
- Wdróż funkcję: `supabase functions deploy create-portal-session`.
- Opcjonalnie: sekret **STRIPE_PORTAL_RETURN_URL** – adres powrotu po zamknięciu portalu (domyślnie: STRIPE_SUCCESS_URL lub example.com).

---

## Pliki

- **Aplikacja:** `lib/features/subscription/screens/premium_screen.dart` – przycisk „Wykup Premium (Stripe)”, przycisk „Zarządzaj subskrypcją / Rezygnuj” (Premium), wywołania `create-checkout-session` i `create-portal-session`.
- **Edge Functions:**
  - `supabase/functions/create-checkout-session/index.ts` – tworzy Checkout Session, zwraca URL.
  - `supabase/functions/create-portal-session/index.ts` – tworzy sesję Stripe Customer Portal (zarządzanie / rezygnacja), zwraca URL.
  - `supabase/functions/stripe-webhook/index.ts` – odbiera webhook, aktualizuje `profiles` (w tym `stripe_customer_id`).

Po wdrożeniu i ustawieniu sekretów subskrypcja Stripe jest gotowa do użycia.
