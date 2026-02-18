# Plan infrastruktury – Łatwa Forma (produkcja)

Aplikacja: Flutter (mobilna + web) + landing. Infrastruktura przygotowana pod skalowalność (tysiące użytkowników dziennie) i niskie koszty na start.

---

## Cele

| Element | Cel |
|--------|-----|
| Domena | **latwaforma.pl** (rejestrator: OVH) |
| Poczta | **kontakt@latwaforma.pl**, **support@latwaforma.pl**, **norbert@latwaforma.pl** |
| Landing | **latwaforma.pl** / **www.latwaforma.pl** |
| Backend aplikacji | **Supabase** (baza, Auth, Storage, Edge Functions) |
| API (domena własna) | **api.latwaforma.pl** → Supabase |
| Aplikacja web | **app.latwaforma.pl** → Flutter Web |
| Skalowanie | W przyszłości: api → VPS, app → CDN (Cloudflare), bez zmiany domen |

---

## Architektura

### 1. Domeny i DNS (OVH)

| Domena / subdomena | Przeznaczenie | Typ rekordu | Cel |
|-------------------|---------------|-------------|-----|
| **latwaforma.pl** | Strona główna / landing | A | IP hostingu OVH (landing + maile) |
| **www.latwaforma.pl** | Landing (z „www”) | CNAME lub A | Ten sam hosting co latwaforma.pl |
| **api.latwaforma.pl** | Backend (Supabase) | CNAME | Docelowo: Supabase custom domain lub VPS |
| **app.latwaforma.pl** | Aplikacja web (Flutter) | CNAME | Vercel / Firebase Hosting / Netlify |
| **mail.latwaforma.pl** | Panel poczty (opcjonalnie) | A lub CNAME | Serwer pocztowy OVH |

### 2. Hosting – landing + maile (OVH)

- **Landing:** pliki w katalogu **www** (index.html, polityka-prywatnosci.html, regulamin.html, privacy.html, terms.html); wgranie przez FileZilla – **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**.
- **Poczta:** skrzynki w domenie latwaforma.pl (kontakt, support, norbert) – serwer MX hostingu.
- **SSL:** certyfikat dla latwaforma.pl i www.latwaforma.pl (Let’s Encrypt w panelu lub przez hostingu).

### 3. Backend – Supabase

- **Baza:** PostgreSQL (Supabase).
- **Auth:** logowanie użytkowników (Google, e-mail).
- **Storage:** pliki (np. zdjęcia posiłków).
- **Edge Functions:** np. create-checkout-session, stripe-webhook, create-portal-session.
- **API:** dostęp przez URL projektu Supabase (np. `https://<PROJECT_REF>.supabase.co`).  
  **Domena własna api.latwaforma.pl:** Supabase oferuje custom domain / vanity subdomain (sprawdź w Dashboard → Project Settings → Custom Domain lub dokumentację). Jeśli dostępne: w DNS ustawiasz CNAME **api.latwaforma.pl** na cel podany przez Supabase; w aplikacji używasz `SUPABASE_URL=https://api.latwaforma.pl`. Jeśli nie – zostajesz przy `https://<PROJECT_REF>.supabase.co` do czasu migracji na VPS.

### 4. Aplikacja web (Flutter) – app.latwaforma.pl

- **Build:** `flutter build web` → katalog **build/web**.
- **Hosting:** Vercel, Firebase Hosting lub Netlify.
- **Domena:** W panelu (Vercel/Firebase/Netlify) dodajesz domenę **app.latwaforma.pl**. W DNS (OVH) ustawiasz **CNAME app.latwaforma.pl** na adres podany przez wybrany hosting (np. `cname.vercel-dns.com`).
- **SSL:** Obsługiwane automatycznie przez Vercel/Firebase/Netlify.

### 5. Konfiguracja DNS (OVH) – zestawienie

| Typ | Nazwa | Wartość / cel |
|-----|--------|----------------|
| **A** | @ (lub latwaforma.pl) | IP hostingu OVH (landing) |
| **A** | www | IP hostingu OVH (albo CNAME www → latwaforma.pl) |
| **CNAME** | app | adres z Vercel/Firebase/Netlify (np. xxx.vercel.app) |
| **CNAME** | api | docelowo: Supabase custom domain lub później VPS |
| **MX** | @ | serwer pocztowy OVH (według panelu OVH) |
| **TXT** | @ | SPF, DKIM, DMARC (patrz sekcja Poczta) |

Szczegółowe wartości (IP, CNAME, MX) wypełniasz według panelu OVH i Vercel/Firebase/Netlify.

### 6. Poczta – SPF, DKIM, DMARC

W panelu DNS (OVH) dodajesz rekordy **TXT** podane przez OVH (sekcja Poczta / Konfiguracja DNS). Zazwyczaj:

- **SPF:** jeden rekord TXT (wartość z panelu OVH).
- **DKIM:** jeden lub więcej rekordów TXT (nazwa i wartość z panelu poczty OVH).
- **DMARC:** rekord TXT np. `_dmarc`, wartość np. `v=DMARC1; p=none; rua=mailto:kontakt@latwaforma.pl` (dostosuj politykę i adres raportów).

Bez poprawnego SPF/DKIM/DMARC maile @latwaforma.pl mogą trafiać do spamu.

### 7. Zmienne środowiskowe (ENV)

**Środowisko deweloperskie (dev):**

- `SUPABASE_URL` = URL projektu Supabase (np. `https://<PROJECT_REF>.supabase.co`)
- `SUPABASE_ANON_KEY` = klucz anon
- (opcjonalnie) `.env` w projekcie Flutter – nie commituj kluczy; używaj tylko anon w aplikacji.

**Środowisko produkcyjne (prod):**

- W **aplikacji Flutter** (build web / mobilny):  
  `SUPABASE_URL` = `https://api.latwaforma.pl` (gdy custom domain jest skonfigurowany) **lub** `https://<PROJECT_REF>.supabase.co`.  
  `SUPABASE_ANON_KEY` = ten sam klucz anon (publiczny).
- W **Supabase → Edge Functions → Secrets:**  
  `STRIPE_*`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` itd. – bez zmian; jeśli później przejdziesz na api.latwaforma.pl, URL w aplikacji zmieniasz tylko w buildzie.
- **Redirect URLs (Supabase Auth):**  
  dodaj m.in. `https://app.latwaforma.pl`, `https://app.latwaforma.pl/**`, `https://latwaforma.pl`, `https://latwaforma.pl/**` (oraz deep linki do aplikacji mobilnej, jeśli używasz).

### 8. SSL

- **latwaforma.pl, www.latwaforma.pl:** certyfikat w panelu WebH (Let’s Encrypt).
- **app.latwaforma.pl:** automatycznie przez Vercel/Firebase/Netlify.
- **api.latwaforma.pl:** przy Supabase custom domain – przez Supabase; przy VPS – np. Let’s Encrypt (Certbot).

---

## Skalowanie w przyszłości

- **api.latwaforma.pl:** migracja z Supabase (lub Supabase custom domain) na **VPS** (np. OVH) – na VPS stawiasz reverse proxy (nginx) do Supabase lub własnej bazy. DNS CNAME api zostaje; zmieniasz tylko cel CNAME na IP/VPS.
- **app.latwaforma.pl:** przed VPS możesz wstawić **Cloudflare** (CNAME app → Cloudflare → origin do Vercel/Firebase); później możesz zmienić origin na własny serwer.
- Domeny (latwaforma.pl, app, api) i konfiguracja aplikacji mobilnej (URL API) mogą zostać bez zmian; zmienia się tylko „gdzie” wskazuje CNAME/A.

---

## Kolejność wdrożenia

1. **Domena:** Wykup latwaforma.pl w OVH.
2. **Hosting OVH:** Pakiet z miejscem na stronę i pocztą; skonfiguruj maile (kontakt, support, norbert).
3. **DNS (OVH):** A dla latwaforma.pl i www (często automatycznie); MX i TXT (SPF, DKIM, DMARC) według panelu OVH.
4. **Landing:** Wgraj na OVH przez FileZilla do katalogu **www** – **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**. Pliki: **index.html** (landing_latwaforma_pl/), **polityka-prywatnosci.html**, **regulamin.html**, **privacy.html**, **terms.html** (web/).
5. **Supabase:** Projekt produkcyjny; ewentualnie custom domain api.latwaforma.pl (Dashboard / dokumentacja); w Auth dodaj redirect URLs dla app.latwaforma.pl i latwaforma.pl.
6. **Flutter Web:** Build (`flutter build web`), deploy na Vercel/Firebase/Netlify, podpięcie domeny app.latwaforma.pl i CNAME w OVH.
7. **Aplikacja (Flutter):** W buildzie prod ustaw `SUPABASE_URL` (i ewentualnie anon key), `privacyPolicyUrl` = `https://latwaforma.pl/polityka-prywatnosci.html`, `termsUrl` = `https://latwaforma.pl/regulamin.html`.
8. **Stripe:** Success/Cancel URL np. `https://app.latwaforma.pl/#/premium-success` i `.../premium-cancel`.

---

## Powiązane dokumenty

- **INSTRUKCJA_WDROZENIA_LAIK.md** – **szczegółowa instrukcja krok po kroku dla laika** (gdzie kliknąć, co wpisać, w jakiej kolejności): domena OVH, hosting OVH, DNS, landing (wgranie: **INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**), Supabase, Flutter web na Vercel/Netlify, adresy w aplikacji.
- **INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md** – wgranie landingu na OVH (FileZilla, 5 plików, katalog www).
- **OVH_CO_DALEJ.md** – co zrobić po aktywacji hostingu OVH (FTP, poczta, SSL, dalsze kroki).
- **LATWAFORMA_PL_I_GARMIN.md** – wymagania Garmin (strona, polityka, e-mail); dostosowane do architektury z landingiem i app.latwaforma.pl.
- **WDROZENIE.md** – publikacja aplikacji (sklepy, web, Windows, Mac).
