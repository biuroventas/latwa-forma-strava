# Mapowanie produktów IAP (Play Console + App Store Connect + RevenueCat)

Skopiuj te ID 1:1 – muszą być identyczne we wszystkich trzech panelach.

| Display name (PL) | Product ID | Period | Price (PLN) | Typ |
| --- | --- | --- | --- | --- |
| Premium miesięcznie | `premium_monthly` | P1M | 69,99 | subskrypcja auto-renew |
| Premium rocznie | `premium_yearly` | P1Y | 194,99 | subskrypcja auto-renew |
| Premium rok jednorazowo | `premium_yearly_once` | 12 mies. | 194,99 | IAP bez odnawiania (mobile) / Stripe one-time BLIK (web) |

## RevenueCat

- Entitlement identifier: `premium`
- Offering identifier: `default` (ustaw jako Current)
- Packages: Monthly → `premium_monthly`, Annual → `premium_yearly`, Custom `yearly_once` → `premium_yearly_once`
- App User ID = Supabase `auth.uid` (via `Purchases.logIn`)

## Web (Stripe) i mobile (IAP) – te same kwoty

| Plan | Stripe price env | Live Price ID | Mobile IAP | UI |
| --- | --- | --- | --- | --- |
| monthly | `STRIPE_PREMIUM_PRICE_MONTHLY` | `price_1UFqAvIcJLshME2Q7OPXrHwg` | `premium_monthly` | 69,99 zł |
| yearly | `STRIPE_PREMIUM_PRICE_YEARLY` | `price_1UFqCmIcJLshME2QdLinxdn8` | `premium_yearly` | 194,99 zł |
| yearly_once | `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME` | `price_1UFqD5IcJLshME2QDWobcZUS` | `premium_yearly_once` | 194,99 zł |

Produkt Stripe Live: `prod_VGMujakJdfq3p3` (Łatwa Forma Premium).

Na webie `yearly_once` = tylko BLIK (Stripe). W aplikacji ze sklepu = zakup jednorazowy przez Apple/Google (BLIK w apce ze sklepu jest niedozwolony).

## StoreKit lokalnie

Plik: `ios/Runner/StoreKitConfiguration.storekit` – podłącz w Xcode (Scheme → Run → Options → StoreKit Configuration).
