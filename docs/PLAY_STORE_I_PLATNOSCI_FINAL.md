# Łatwa Forma – wersja finalna: Google Play i realne płatności

Checklist przed publikacją w Google Play i włączeniem faktycznych płatności (Stripe Live).

---

## 1. Wersja i build

- W pliku **`pubspec.yaml`** ustaw `version: 1.0.0+1` (lub wyższy). Drugi numer (`+1`) to **versionCode** – zwiększaj przy każdym uploadzie do Play Console (np. 1.0.0+2, 1.0.0+3).
- Przed pierwszym wgraniem do sklepu warto ustawić np. `1.0.0+1` i nie zmieniać wersji nazwy (1.0.0) przy kolejnych poprawkach, tylko build number.

---

## 2. Podpisywanie APK/AAB (Android)

Aplikacja musi być podpisana kluczem release, żeby Google Play ją przyjął.

### Krok 2.1. Wygeneruj keystore (jednorazowo)

W terminalu (poza projektem, np. w katalogu domowym):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Podaj hasła i dane (np. imię, organizacja). Powstanie plik `upload-keystore.jks`. **Zapisz hasła w bezpiecznym miejscu** – bez nich nie zbudujesz kolejnych aktualizacji.

### Krok 2.2. Plik key.properties

W katalogu **`android/`** (obok `app/`) utwórz plik **`key.properties`** (nie commituj go do gita – jest w `.gitignore`):

```properties
storePassword=TwojeHasloDoKeystore
keyPassword=TwojeHasloDoKeystore
keyAlias=upload
storeFile=/pelna/sciezka/do/upload-keystore.jks
```

Zamiast `/pelna/sciezka/do/` podaj ścieżkę do `upload-keystore.jks` (np. na Windows: `C:/Users/Jan/upload-keystore.jks`). Możesz też umieścić keystore w katalogu `android/` i wpisać `storeFile=../upload-keystore.jks`. Szablon: **`android/key.properties.example`** – skopiuj do `key.properties` i uzupełnij.

### Krok 2.3. Build pod Play Store

```bash
flutter build appbundle --release
```

Wynik: **`build/app/outputs/bundle/release/app-release.aab`**. Ten plik wgrywasz do Google Play Console.

---

## 3. Realne płatności (Stripe Live)

Żeby użytkownicy płacili prawdziwe pieniądze (karta, BLIK), Stripe musi być w trybie **Live** i Edge Functions w Supabase muszą używać kluczy **Live**.

### Krok 3.1. Stripe – tryb Live

- Wejdź na [dashboard.stripe.com](https://dashboard.stripe.com).
- Przełącz z **„Test mode”** na **„Live”** (przełącznik u góry).
- W **Developers → API keys** skopiuj **Secret key** (zaczyna się od `sk_live_...`).
- W **Products** upewnij się, że masz produkt Premium z cenami **Live** (69,98 zł / m-c, 194,95 zł / rok, ewent. jednorazowa 194,95 zł). Skopiuj **Price ID** (price_...) dla każdej ceny.

### Krok 3.2. Webhook Stripe (Live)

- W Stripe (nadal **Live**): **Developers → Webhooks → Add endpoint**.
- **Endpoint URL:** `https://TWOJ_PROJECT_REF.supabase.co/functions/v1/stripe-webhook` (zamień TWOJ_PROJECT_REF na swój projekt Supabase).
- **Events:** zaznacz `checkout.session.completed`.
- Po zapisaniu wejdź w ten webhook → **Signing secret** → Reveal → skopiuj (`whsec_...`).

### Krok 3.3. Sekrety w Supabase

- Supabase → Twój projekt → **Edge Functions → Secrets**.
- Ustaw (lub nadpisz) **wartości Live**:

| Sekret | Wartość (Live) |
|--------|-----------------|
| `STRIPE_SECRET_KEY` | `sk_live_...` |
| `STRIPE_PREMIUM_PRICE_MONTHLY` | Price ID ceny miesięcznej (price_...) |
| `STRIPE_PREMIUM_PRICE_YEARLY` | Price ID ceny rocznej (price_...) |
| `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME` | Price ID ceny jednorazowej za rok (price_...) – BLIK/karta |
| `STRIPE_WEBHOOK_SECRET` | Signing secret z webhooka Live (whsec_...) |
| `STRIPE_SUCCESS_URL` | `https://latwaforma.pl/#/premium-success` |
| `STRIPE_CANCEL_URL` | `https://latwaforma.pl/#/premium-cancel` |

### Krok 3.4. Wdrożenie Edge Functions

Funkcje muszą być wdrożone z `--no-verify-jwt` (żeby Stripe mógł wywołać webhook i żeby checkout nie dostawał 401):

```bash
supabase functions deploy create-checkout-session --no-verify-jwt
supabase functions deploy create-portal-session --no-verify-jwt
supabase functions deploy stripe-webhook --no-verify-jwt
```

Albo użyj skryptu: **`./scripts/deploy_stripe_functions.sh`** (jeśli istnieje).

Po tych krokach płatności w aplikacji są **prawdziwe**.

---

## 4. Google Play Console – pierwsze wgranie

1. **Konto dewelopera:** [play.google.com/console](https://play.google.com/console) – opłata jednorazowa (ok. 25 USD).
2. **Utwórz aplikację** → wybierz „Aplikacja” → podaj nazwę (np. Łatwa Forma).
3. **Wypełnij wymagane sekcje:**
   - **Strona sklepu:** krótki opis (80 zn.), pełny opis, grafika (ikona 512×512, zrzuty ekranu – min. 2). Teksty gotowe w **docs/STORE_LISTING.md**.
   - **Polityka prywatności:** URL `https://latwaforma.pl/polityka-prywatnosci.html`.
   - **Bezpieczeństwo danych:** formularz w konsoli – jakie dane zbierasz (e-mail, waga, itd.) – zgodnie z polityką.
   - **Grupa aplikacji:** jeśli masz subskrypcję, zaznacz „Oferuje produkty w aplikacji” i skonfiguruj (Stripe nie wymaga integracji „Google Play Billing” – płatności idą przez Stripe).
4. **Wersja produkcyjna:** Utwórz wydanie → Wgraj **app-release.aab** (z `flutter build appbundle --release`) → Uzupełnij opis zmian → Prześlij do recenzji.

Szczegóły tekstów, zrzutów i wymagań prawnych: **docs/STORE_LISTING.md**, **docs/WYMAGANIA_PRAWNE_SKLEPY.md**.

---

## 5. Szybka lista – co masz zrobić

| # | Działanie |
|---|-----------|
| 1 | Wygeneruj keystore, utwórz `android/key.properties` (na podstawie `key.properties.example`). |
| 2 | Zbuduj AAB: `flutter build appbundle --release`. |
| 3 | Stripe: przełącz na Live, utwórz ceny Live, webhook Live, skopiuj klucze i Price ID. |
| 4 | Supabase Edge Functions → Secrets: wklej wszystkie wartości Live (STRIPE_*). |
| 5 | Wdróż funkcje Stripe: `deploy_stripe_functions.sh` lub ręcznie z `--no-verify-jwt`. |
| 6 | Play Console: konto, strona sklepu, polityka, bezpieczeństwo danych, wgraj AAB, wyślij do recenzji. |

Po tym aplikacja jest w wersji finalnej pod Google Play z możliwością faktycznych płatności przez Stripe.
