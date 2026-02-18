# Łatwa Forma – latwaforma.pl, wdrożenie web i wymagania Garmin

Architektura zgodna z **PLAN_INFRASTRUKTURY.md**: landing pod **latwaforma.pl**, aplikacja web pod **app.latwaforma.pl**, API pod **api.latwaforma.pl**, poczta **@latwaforma.pl**.

---

## Architektura (skrót)

| Adres | Zawartość |
|-------|-----------|
| **latwaforma.pl**, **www.latwaforma.pl** | Landing (strona główna + polityka prywatności + regulamin) |
| **app.latwaforma.pl** | Aplikacja web (Flutter) – to samo co aplikacja mobilna, w przeglądarce |
| **api.latwaforma.pl** | Backend (Supabase) – opcjonalna domena własna |
| **Poczta** | kontakt@latwaforma.pl, support@latwaforma.pl, norbert@latwaforma.pl |

Szczegóły DNS, hostingu, maili, ENV i skalowania: **docs/PLAN_INFRASTRUKTURY.md**.

---

## Czego potrzebujesz (domena, hosting, e-mail)

| Co | Po co |
|----|--------|
| **Domena latwaforma.pl** | Rejestrator: OVH (zgodnie z planem). Wymagana przez Garmin. |
| **Hosting landing + poczta** | Np. WebH – landing (latwaforma.pl, www) + skrzynki @latwaforma.pl. |
| **Hosting aplikacji web** | Vercel, Firebase Hosting lub Netlify – deploy Flutter Web pod **app.latwaforma.pl**. |
| **E-mail @latwaforma.pl** | kontakt@, support@, norbert@ – wymagane przez Garmin (wniosek z tego samego domeny). |

---

## Krok 1. Domena i DNS (OVH)

1. Wykup **latwaforma.pl** w OVH.
2. W panelu DNS ustaw rekordy według **PLAN_INFRASTRUKTURY.md**:
   - **A** dla latwaforma.pl i www → IP hostingu WebH (landing).
   - **CNAME** app → cel z Vercel/Firebase/Netlify.
   - **CNAME** api → gdy używasz custom domain Supabase (lub później VPS).
   - **MX** i **TXT** (SPF, DKIM, DMARC) dla poczty.

---

## Krok 2. Landing (latwaforma.pl, www)

- **Hosting:** WebH (lub inny) – główny katalog strony (np. `public_html`).
- **Pliki do wgrania:**
  - **index.html** – strona główna: nazwa „Łatwa Forma”, krótki opis, przycisk **„Otwórz aplikację”** → `https://app.latwaforma.pl`, oraz linki: **Polityka prywatności** → `https://latwaforma.pl/polityka-prywatnosci.html`, **Regulamin** → `https://latwaforma.pl/regulamin.html`.
  - **polityka-prywatnosci.html** – skopiuj z **web/polityka-prywatnosci.html** (lub ze **strava_redirect/privacy-pl.html**) i wgraj na hosting.
  - **regulamin.html** – skopiuj z **web/regulamin.html** (lub ze **strava_redirect/terms-pl.html**) i wgraj.

Dzięki temu **Garmin** ma „valid website” (latwaforma.pl) z linkiem do polityki **w tej samej domenie** (latwaforma.pl/polityka-prywatnosci.html).

---

## Krok 3. Aplikacja web (app.latwaforma.pl)

1. W projekcie Flutter: **`flutter build web`**.
2. Zawartość **build/web** wgraj na Vercel / Firebase Hosting / Netlify (np. przez repozytorium: build command `flutter build web`, output `build/web`).
3. W panelu hostingu dodaj domenę **app.latwaforma.pl**; w OVH ustaw **CNAME app** na adres podany przez hosting.
4. SPA (odświeżanie, deep linki) – Vercel/Netlify/Firebase obsługują to domyślnie.

W aplikacji (Profil) linki „Polityka prywatności” i „Regulamin” powinny prowadzić na **latwaforma.pl** (landing), np.:
- `https://latwaforma.pl/polityka-prywatnosci.html`
- `https://latwaforma.pl/regulamin.html`

Ustaw je w **lib/core/constants/app_constants.dart** (`privacyPolicyUrl`, `termsUrl`).

---

## Krok 4. Backend (Supabase) i api.latwaforma.pl

- **Supabase:** Projekt produkcyjny; Auth, baza, Storage, Edge Functions – bez zmian.
- **Redirect URLs (Auth):** Dodaj `https://app.latwaforma.pl`, `https://app.latwaforma.pl/**`, `https://latwaforma.pl`, `https://latwaforma.pl/**` (oraz deep linki dla aplikacji mobilnej).
- **api.latwaforma.pl:** Opcjonalnie – custom domain w Supabase (Dashboard / dokumentacja). Jeśli skonfigurujesz: w aplikacji (prod) ustaw `SUPABASE_URL=https://api.latwaforma.pl`. Jeśli nie – zostaw `https://<PROJECT_REF>.supabase.co`.

---

## Krok 5. Poczta i SPF/DKIM/DMARC

- Skrzynki **kontakt@**, **support@**, **norbert@latwaforma.pl** w panelu WebH (lub innego hostingu poczty).
- W DNS (OVH) dodaj rekordy **MX** oraz **TXT** (SPF, DKIM, DMARC) według instrukcji hostingu – szczegóły w **PLAN_INFRASTRUKTURY.md**.

---

## Krok 6. Wymagania Garmin – checklist

| Wymóg Garmin | Jak spełniasz |
|--------------|----------------|
| **Valid website representing the company** | **latwaforma.pl** (landing) z nazwą Łatwa Forma / firmą. |
| **Privacy policy, same domain, link on homepage** | Polityka pod **latwaforma.pl/polityka-prywatnosci.html**; na stronie głównej (landing) link „Polityka prywatności”. |
| **Externally accessible** | Strona i polityka dostępne bez logowania. |
| **Contact email, same domain** | W wniosku podaj **norbert@latwaforma.pl** lub **kontakt@latwaforma.pl** (nie gmail). |
| **Legal authority** | W treści: reprezentujesz firmę (np. „I am the owner / sole proprietor and have legal authority to represent the company”). |
| **No personal use** | Aplikacja dla użytkowników (śledzenie kalorii, integracja Garmin), nie do użytku osobistego. |

---

## Krok 7. Po wdrożeniu – adresy w aplikacji

W **lib/core/constants/app_constants.dart** (build prod):

- `privacyPolicyUrl` = `https://latwaforma.pl/polityka-prywatnosci.html`
- `termsUrl` = `https://latwaforma.pl/regulamin.html`

**Supabase Auth:** Site URL np. `https://app.latwaforma.pl`; Redirect URLs jak wyżej.

**Stripe (Edge Functions):** STRIPE_SUCCESS_URL / STRIPE_CANCEL_URL np. `https://app.latwaforma.pl/#/premium-success` i `https://app.latwaforma.pl/#/premium-cancel`.

---

## Podsumowanie

- **Landing** = latwaforma.pl (strona + polityka + regulamin) – hosting WebH.
- **Aplikacja web** = app.latwaforma.pl – Flutter build na Vercel/Firebase/Netlify.
- **API** = Supabase; opcjonalnie api.latwaforma.pl (custom domain).
- **Poczta** = @latwaforma.pl (WebH) + SPF/DKIM/DMARC w DNS.
- **Garmin** = strona latwaforma.pl, polityka na tej samej domenie, kontakt @latwaforma.pl.

Pełny plan DNS, ENV, SSL i skalowania: **docs/PLAN_INFRASTRUKTURY.md**.
