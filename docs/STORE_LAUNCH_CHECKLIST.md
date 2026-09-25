# Checklist publikacji sklepów (ścieżka B)

Dane kont / ID: **[STORE_ACCOUNTS.md](STORE_ACCOUNTS.md)**.

Po wdrożeniu kodu IAP / RevenueCat – kroki **po Twojej stronie** (konta, dashboardy, review).

## A. Konta i produkty (Faza 0–1)

- [x] Google Play Console – konto VENTASOFT (`biuroventas@gmail.com`); package `com.latwaforma.latwa_forma` (apka w konsoli + weryfikacja tożsamości/telefon – w toku)
- [x] Apple Developer – aktywne; Team ID `2SC22AWL4K`; Individual
- [x] App Store Connect – rekord aplikacji **Łatwa Forma** (`com.latwaforma.latwaForma`); trader status (Business) jeszcze do uzupełnienia
- [ ] Paid Apps / Tax / Banking (Apple) zaakceptowane
- [ ] Subskrypcje sklepowe: `premium_monthly`, `premium_yearly` + jednorazowy `premium_yearly_once` (194,99 PLN)
- [ ] Konto RevenueCat + mapowanie produktów + entitlement `premium` + Offering Current
- [ ] Klucze `REVENUECAT_IOS_API_KEY` / `REVENUECAT_ANDROID_API_KEY` w `.env` / `env.production`
- [ ] Deploy Edge Function: `supabase functions deploy revenuecat-webhook`
- [ ] Sekret `REVENUECAT_WEBHOOK_AUTH` + URL webhooka w RevenueCat
- [ ] Supabase Auth: włączony provider **Apple** (+ Client ID / Secret z Apple)
- [ ] Redirect URLs: `latwaforma://auth/callback` w Supabase
- [ ] Polityka / regulamin na latwaforma.pl (zaktualizowane o IAP) – wdrożyć pliki z `web/`

## B. Keystore Android

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Skopiuj `android/key.properties.example` → `android/key.properties` (gitignored) i uzupełnij ścieżkę/hasła.

```bash
flutter build appbundle --release
```

## C. QA sandbox (przed review)

Na fizycznym Androidzie + iPhonie:

1. [ ] Logowanie Google + deep link powrotu
2. [ ] Logowanie Apple (iOS)
3. [ ] Dodanie posiłku, skan kodu (kamera na prawdziwym iOS), dashboard
4. [ ] Trial 24h → gate Premium
5. [ ] Zakup sandbox `premium_monthly` / `premium_yearly` / `premium_yearly_once` → `profiles.subscription_tier = premium`
6. [ ] Przywróć zakupy
7. [ ] Zarządzaj subskrypcją (link do sklepu)
8. [ ] Na webie nadal działa Stripe; w aplikacji mobilnej **brak** Stripe Checkout
9. [ ] Polityka / regulamin z Profilu
10. [ ] Usuń konto

## D. Google Play

- [ ] Store listing (patrz `docs/STORE_LISTING.md`) – **wklej disclaimer medyczny**
- [ ] Privacy policy URL: `https://latwaforma.pl/polityka-prywatnosci.html`
- [ ] Data safety + URL usuwania konta: `https://latwaforma.pl/usun-konto.html` (patrz `docs/GOOGLE_PLAY_POLICY.md`)
- [ ] Health apps declaration: Activity and fitness + Nutrition and weight management; **nie** Medical device
- [ ] Target audience: nie dzieci (13+)
- [ ] Internal testing → produkcja
- [ ] License testers: zakup testowy

## E. App Store

- [ ] `flutter build ipa --release` / Archive w Xcode
- [ ] TestFlight
- [ ] Privacy nutrition labels, age rating, subscription metadata
- [ ] App Review – podkreśl: płatności Premium wyłącznie przez IAP (brak Stripe w iOS)

## F. Klucze produkcyjne

- [ ] `OPENAI_API_KEY` w release env / Edge `ai-advice`
- [ ] Turso / Strava OK
- [ ] Garmin: production partner key **lub** ukryj w UI przed listingiem
