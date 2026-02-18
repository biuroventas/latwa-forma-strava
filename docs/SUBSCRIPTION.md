# Subskrypcja Free / Premium

## Model

- **Free** – domyślny plan po rejestracji. Pełny dostęp do podstawowych funkcji z limitami.
- **Premium** – rozszerzony plan: wyższe limity i funkcje premium.

Pola w tabeli `profiles` (Supabase):

- `subscription_tier` – `'free'` lub `'premium'`
- `subscription_expires_at` – opcjonalna data wygaśnięcia (null = bez daty / lifetime)

Status Premium w aplikacji: `profile.isPremium` (tier == 'premium' i brak daty lub data w przyszłości).

### Okres próbny (24 h)

Od **pierwszego użycia** aplikacji (pierwsze wejście na dashboard po zalogowaniu) przez **24 godziny** użytkownik ma pełny dostęp do wszystkich funkcji premium (traktowany jak Premium). Po upływie 24 h, bez wykupionej subskrypcji, funkcje premium są widoczne, ale zablokowane – odblokowuje je tylko Premium.

- **Dostęp:** `hasPremiumAccessProvider` = `isPremium` **lub** (pierwsze użycie &lt; 24 h temu).
- **Zapis pierwszego użycia:** SharedPreferences, klucz `trial_start_$userId` (wartość: timestamp w ms). Ustawiany przy pierwszym odczycie (np. przy wejściu na dashboard).
- **Stała:** `lib/core/constants/trial_constants.dart` – `trialDuration = 24 h`, `trialStartPrefKeyPrefix`.

---

## Free vs Premium

| Funkcja | Free | Premium |
|--------|------|---------|
| Przeglądanie historii | Tylko dzień bieżący | Dowolny dzień |
| Makroskładniki na dashboardzie | Ukryte | Podgląd włączony |
| Porada AI | Limit dzienny (np. 10 zapytań) | Nieograniczona |
| Analiza AI posiłku (zdjęcie) | Zablokowana | Dostępna |
| Dodawanie posiłku ze składników | Zablokowane | Dostępne |
| Dodawanie posiłku „na mieście” | Zablokowane | Dostępne |
| Szybkie dodawanie w aktywnościach | Zablokowane | Dostępne |
| Udostępnianie tygodniowych statystyk | Zablokowane | Dostępne |
| Eksport do PDF | Zablokowany (dialog → Premium) | Dostępny |
| Własny cel kaloryczny (edycja profilu) | Tylko obliczony | Edycja ręczna |
| Własne makroskładniki (edycja profilu) | Tylko obliczone | Edycja ręczna |
| Integracje Strava / Garmin | Dostępne (ew. z limitami) | Bez limitów |
| Cele i wyzwania | Podstawowe | Pełny dostęp |

Stałe: `AppConstants.aiAdviceDailyLimit` (limit zapytań AI dla Free).

---

## Testowanie Premium

### W aplikacji (tryb debug)

W trybie debug na ekranie **Profil → Łatwa Forma Premium** (lub **Subskrypcja Premium**) jest przycisk **„Aktywuj Premium (test)”**. Po naciśnięciu:

1. W Supabase w `profiles` ustawiane jest `subscription_tier = 'premium'` i `subscription_expires_at = null`.
2. Odświeżany jest `profileProvider`, więc cała aplikacja od razu widzi status Premium.

Przycisk jest widoczny tylko gdy `kDebugMode == true` (build debug). W release go nie ma.

### Ręcznie w Supabase

W **Table Editor → profiles** dla danego użytkownika:

- `subscription_tier` = `premium`
- `subscription_expires_at` = `null` (lifetime) lub np. `2026-12-31 23:59:59+00` (okresowa subskrypcja)

Po zapisaniu użytkownik musi odświeżyć profil (np. przejść na inny ekran i wrócić albo zrestartować aplikację), bo profil jest cache’owany przez Riverpod.

---

## Kod

- **Provider:** `lib/core/providers/subscription_provider.dart` – `isPremiumProvider` (subskrypcja), `firstUseAtProvider` (data pierwszego użycia), `hasPremiumAccessProvider` (Premium **lub** w trialu), `isInTrialProvider` (w trialu, bez Premium).
- **Bramkowanie:** wszędzie używaj `hasPremiumAccessProvider` – w trialu i przy Premium użytkownik ma dostęp; po trialu bez Premium – bramka pokazuje dialog i przekierowanie do ekranu Premium.
- **Ekran Premium:** `lib/features/subscription/screens/premium_screen.dart` – lista benefitów, przy trialu: informacja „Okres próbny (24 h)” i pozostały czas, przycisk testowy (debug), ewentualna data ważności.
- **Bramka:** `lib/shared/widgets/premium_gate.dart` – `PremiumGate` (widget) i `checkPremiumOrNavigate()` (przed akcją premium); obie używają `hasPremiumAccessProvider`.
- **Aktualizacja tieru:** `SupabaseService().updateSubscriptionTier(userId, tier: 'premium', expiresAt: null)`.

Migracja bazy: `database/supabase/migration_subscription_tier.sql` (wykonaj w Supabase SQL Editor).

---

## Stripe (wdrożone)

Płatność za Premium przez **Stripe** (strona Checkout otwierana z aplikacji). Pełna instrukcja: **[docs/STRIPE.md](STRIPE.md)**.

- Aplikacja wywołuje Edge Function **create-checkout-session** → użytkownik płaci na stronie Stripe.
- Webhook **stripe-webhook** po `checkout.session.completed` ustawia w `profiles`: `subscription_tier = 'premium'`, `subscription_expires_at` z końca okresu subskrypcji.

Dodatkowo: przycisk testowy (debug) i ręczna edycja w Supabase nadal działają.

---

## Co dalej (rozwój subskrypcji)

1. **Płatności w aplikacji** – integracja `in_app_purchase` (Google Play / App Store) lub RevenueCat; po zakupie wywołanie Edge Function / API, które ustawi `subscription_tier` i `subscription_expires_at`.
2. **Stripe / strona WWW** – ✅ wdrożone (patrz STRIPE.md).
3. **UX** – przywracanie zakupów, wyświetlanie cennika (miesięcznie/rocznie), zarządzanie subskrypcją (link do ustawień systemowych).
4. **Logika** – okresowe sprawdzanie wygaśnięcia, powiadomienia przed końcem Premium, ewentualny okres grace.
