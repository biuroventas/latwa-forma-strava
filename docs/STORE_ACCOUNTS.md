# Konta sklepowe – dane robocze (ścieżka B)

Dokument wewnętrzny: co już założone / jakie ID używać.  
**Nie wklejaj tu haseł, kluczy API ani numerów kart.**

Ostatnia aktualizacja: 2026-09-15 (Stripe Live: produkt + 3 Price ID).

---

## Wspólne

| Pole | Wartość |
| --- | --- |
| Nazwa aplikacji (listing) | Łatwa Forma |
| Firma / sprzedawca | Ventas Norbert Wróblewski (JDG) |
| Konto logowania sklepów | `biuroventas@gmail.com` |
| Kontakt publiczny / strona | `contact@latwaforma.pl` (polityka, regulamin, listing) |
| Model monetyzacji | Free app + Premium (IAP / subskrypcje); web: Stripe |
| Ścieżka | **B** – mobile = RevenueCat/IAP; web = Stripe |

---

## Google Play

| Pole | Wartość |
| --- | --- |
| Konto Google (właściciel) | `biuroventas@gmail.com` |
| Nazwa dewelopera (publiczna) | VENTASOFT |
| Typ konta | Prywatne („Dla siebie”) |
| Package name (applicationId) | `com.latwaforma.latwa_forma` |
| Monetyzacja (ankieta) | Zakupy w aplikacji + Subskrypcje |
| Status (2026-09-13) | Konto utworzone; tożsamość w weryfikacji Google; do dokończenia: telefon (+ Play Console na Androidzie) |

---

## Apple

| Pole | Wartość |
| --- | --- |
| Apple ID | `biuroventas@gmail.com` |
| Program | Apple Developer Program |
| Enrolled as | Individual |
| **Team ID** | `2SC22AWL4K` |
| Team name (Xcode) | Norbert Wróblewski |
| Bundle ID (iOS) | `com.latwaforma.latwaForma` |
| Odnowienie membership | 2027-09-14 |
| Auto-renew | włączone |
| Status (2026-09-14) | Business OK. ASC IAP **Premium** gotowe: `premium_monthly` + `premium_yearly` + lokalizacja grupy PL. Status Prepare for Submission (OK do pierwszego submitu apki). **Następne:** RevenueCat lub Google Play |

W Xcode: Signing & Capabilities → Team = konto z Team ID `2SC22AWL4K` (już było `GCT6R26V84` w projekcie — po pierwszym Archive sprawdź, czy Team się zgadza z tym kontem).

---

## Produkty IAP (do utworzenia w sklepach + RevenueCat)

| Product ID | Okres | Cena docelowa PLN |
| --- | --- | --- |
| `premium_monthly` | miesiąc auto-renew | 69,99 |
| `premium_yearly` | rok auto-renew | 194,99 |
| `premium_yearly_once` | rok jednorazowo | 194,99 |

- Entitlement RevenueCat: `premium`
- Web: jednorazowo przez Stripe/BLIK; mobile: ten sam plan przez IAP sklepu

Szczegóły: [IAP_PRODUCTS.md](IAP_PRODUCTS.md), [REVENUECAT.md](REVENUECAT.md).

---

## Stripe (Live) – web Premium

Konto: Ventas Norbert Wróblewski. Produkt: **Łatwa Forma Premium** (`prod_VGMujakJdfq3p3`).  
Te Price ID wklejasz w **Supabase → Edge Functions → Secrets** (nie do `.env` Fluttera).

| Sekret Supabase | Cena | Price ID (Live) |
| --- | --- | --- |
| `STRIPE_PREMIUM_PRICE_MONTHLY` | 69,99 zł / miesiąc (recurring) | `price_1UFqAvIcJLshME2Q7OPXrHwg` |
| `STRIPE_PREMIUM_PRICE_YEARLY` | 194,99 zł / rok (recurring) | `price_1UFqCmIcJLshME2QdLinxdn8` |
| `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME` | 194,99 zł jednorazowo (BLIK) | `price_1UFqD5IcJLshME2QDWobcZUS` |

Brakuje jeszcze: `sk_live_...` (`STRIPE_SECRET_KEY`) i Live webhook signing secret (`STRIPE_WEBHOOK_SECRET`). Kluczy API tu nie zapisujemy.

---

## Następne kroki (kolejność)

1. Play: dokończyć weryfikację tożsamości / telefon / urządzenie Android.
2. App Store Connect: utworzyć app **Łatwa Forma** + Bundle ID `com.latwaforma.latwaForma`.
3. Apple Business: trader status (DSA / UE).
4. Apple: Agreements, Tax, Banking (Paid Apps) → subskrypcje IAP.
5. Play: utworzyć aplikację w konsoli + subskrypcje IAP + keystore/AAB.
6. RevenueCat + webhook Supabase + klucze w env.
