# RevenueCat + IAP (ścieżka B)

Mobile: **App Store / Google Play Billing** przez RevenueCat.  
Web (`latwaforma.pl`): **Stripe** (bez zmian).

Źródło prawdy w apce: `profiles.subscription_tier` / `subscription_expires_at` (Supabase), aktualizowane przez:

- webhook Stripe (`stripe-webhook`) – tylko web,
- webhook RevenueCat (`revenuecat-webhook`) – iOS/Android.

## Identyfikatory produktów (ustalone w projekcie)

Używaj **tych samych** ID w Play Console, App Store Connect i RevenueCat:

| Plan | Product ID | Okres |
| --- | --- | --- |
| Miesięczny | `premium_monthly` | 1 miesiąc (auto-renew) |
| Roczny (subskrypcja) | `premium_yearly` | 1 rok (auto-renew) |
| Roczny jednorazowo | `premium_yearly_once` | 12 mies. bez odnawiania |

Ceny wszędzie (PLN): **69,99** / mies., **194,99** / rok (subskrypcja i jednorazowo).  
Na **webie** jednorazowo = Stripe (BLIK + karta). W **aplikacji** ze sklepu = IAP Apple/Google (nie BLIK).

Entitlement w RevenueCat: **`premium`**.  
Offering (default): monthly + yearly + custom `yearly_once`.

## Klucze w aplikacji (env)

```
REVENUECAT_IOS_API_KEY=appl_...
REVENUECAT_ANDROID_API_KEY=goog_...
```

Nie commituj kluczy. Szablon: `.env.example`.

## Konfiguracja kont (ręcznie – dashboardy)

### 1. RevenueCat

1. Utwórz projekt „Łatwa Forma”.
2. Dodaj apps: iOS `com.latwaforma.latwaForma`, Android `com.latwaforma.latwa_forma`.
3. Wklej Shared Secret (App Store) i Service Account JSON (Play).
4. Products → zaimportuj / utwórz `premium_monthly`, `premium_yearly`, `premium_yearly_once`.
5. Entitlements → `premium` → przypisz **wszystkie trzy** produkty.
6. Offerings → Current → packages: `$rc_monthly`, `$rc_annual`, custom `yearly_once` → `premium_yearly_once`.
7. Integrations → Webhooks → URL:
   `https://<PROJECT_REF>.supabase.co/functions/v1/revenuecat-webhook`  
   Authorization header: wartość sekretu `REVENUECAT_WEBHOOK_AUTH` (Bearer).

### 2. Google Play Console

1. Utwórz aplikację / wgraj AAB (internal).
2. Monetize → Subscriptions → utwórz `premium_monthly`, `premium_yearly`.
3. Monetize → In-app products → utwórz jednorazowy `premium_yearly_once` (194,99 PLN).
4. Połącz RevenueCat (service account z uprawnieniami finansowymi).

### 3. App Store Connect

1. Agreements, Tax, Banking – Paid Apps zaakceptowane.
2. App → Subscriptions → Subscription Group „Premium”.
3. Produkty `premium_monthly`, `premium_yearly` (Auto-Renewable).
4. In-App Purchases → Non-Renewing Subscription `premium_yearly_once` (194,99 zł, 1 rok).
5. App-Specific Shared Secret → RevenueCat.

### 4. Supabase secrets

```
REVENUECAT_WEBHOOK_AUTH=<losowy-sekret>
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
```

Deploy:

```bash
supabase functions deploy revenuecat-webhook --no-verify-jwt
```

## App User ID

SDK wywołuje `Purchases.logIn(supabaseUserId)` – `app_user_id` w webhooku = `auth.users.id` = `profiles.user_id`.

## Testy

- iOS: Sandbox Apple ID / StoreKit Configuration.
- Android: license testers w Play Console.
- Po zakupie: sprawdź `profiles.subscription_tier = premium` oraz odblokowanie bramek w apce.
- „Przywróć zakupy” na ekranie Premium (mobile).
