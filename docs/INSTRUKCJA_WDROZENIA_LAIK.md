# Wdrożenie Łatwa Forma – instrukcja krok po kroku (dla laika)

Instrukcja w **dokładnej kolejności**. Każdy krok mówi: **gdzie wejść**, **co kliknąć**, **co wpisać**, **co skopiować**. Trzymaj się kolejności – kolejne kroki zależą od poprzednich.

---

## Stan wdrożenia (aktualny)

| Co | Status |
|----|--------|
| **Domena latwaforma.pl** | W OVH (transfer w toku lub zakończony) |
| **Hosting** | **OVH** hosting-perso (latwafe.cluster121.hosting.ovh.net) – **gotowy** |
| **Landing na OVH** | **Wgrany** – 5 plików w katalogu **www** (index.html, polityka-prywatnosci.html, regulamin.html, privacy.html, terms.html). Instrukcja: **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**. |
| **Co dalej** | SSL w OVH, poczta @latwaforma.pl, Supabase (Auth), deploy app.latwaforma.pl, app_constants + Stripe – poniżej i w **docs/OVH_CO_DALEJ.md**. |

---

## Zanim zaczniesz – co musisz mieć

- Komputer z projektem Łatwa Forma (w Cursor / na dysku).
- Konto w Supabase (projekt aplikacji – może być ten sam co do testów).
- Dostęp do Stripe (klucze, ceny, webhook – jak w docs/STRIPE.md).
- Około 1–2 godziny na pierwsze wdrożenie.

---

# CZĘŚĆ 1: Domena latwaforma.pl

## Krok 1.1. Wejście na OVH i wyszukanie domeny

1. Otwórz przeglądarkę i wejdź na **https://www.ovh.pl**
2. Kliknij **„Domeny”** (w menu u góry) lub wyszukaj **„Domeny”**.
3. W polu wyszukiwania domen wpisz: **latwaforma.pl**
4. Kliknij **„Sprawdź”** lub **„Szukaj”**.

## Krok 1.2. Wykupienie domeny

1. Jeśli **latwaforma.pl** jest dostępna (zielony ptaszek / „Dostępna”), kliknij **„Zamów”** lub **„Dodaj do koszyka”**.
2. Wybierz **okres** (np. 1 rok) – zaznacz opcję.
3. Przejdź do **koszyka** i **„Złóż zamówienie”**.
4. Zaloguj się lub **załóż konto OVH** (e-mail, hasło, dane).
5. Wypełnij **dane do rejestracji domeny**:
   - **Właściciel domeny:** np. VENTAS NORBERT WRÓBLEWSKI (lub Twoja firma), adres, NIP jeśli masz.
   - Zapisz dokładnie to, co wpisujesz – Garmin wymaga spójnej nazwy firmy.
6. Opłać zamówienie (karta / przelew).
7. Zapisz **login i hasło do panelu OVH** – będą potrzebne w kolejnych krokach.

**Gotowe:** Masz domenę **latwaforma.pl**. Często aktywacja trwa kilka minut do kilku godzin.

---

# CZĘŚĆ 2: Hosting (landing + poczta) – OVH

## Krok 2.1. Hosting OVH (już masz)

- Panel: **https://www.ovh.com/manager/** → **Hosting** → **latwaforma.pl** (latwafe).
- Landing wgrany – instrukcja wgrania: **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md** (FileZilla, katalog **www**, 5 plików).

## Krok 2.2. Założenie skrzynek e-mail (OVH)

1. W panelu OVH: **Hosting** → **latwaforma.pl** (latwafe).
2. Szukaj sekcji **„Poczta”** / **„E-mail”** / **„Konta e-mail”**.
3. **Dodaj skrzynki** w domenie **latwaforma.pl**: **contact@latwaforma.pl** oraz **norbert.wroblewski@latwaforma.pl**. Dla każdej ustaw hasło i zapisz.
4. OVH może pokazać **rekordy MX i TXT (SPF/DKIM)** – przy DNS w OVH często dodaje je sam; inaczej skopiuj je do Strefy DNS (Część 3).

---

# CZĘŚĆ 3: Ustawienie DNS w OVH

DNS łączy domenę **latwaforma.pl** z hostingiem (strona + poczta) i później z aplikacją (app.latwaforma.pl). **Gdy domena i hosting są w OVH**, rekordy A dla latwaforma.pl i www często są ustawiane automatycznie przy transferze; sprawdź w **Domeny** → **latwaforma.pl** → **Strefa DNS**.

## Krok 3.1. Wejście w zarządzanie DNS

1. Zaloguj się na **https://www.ovh.pl** → **Panel klienta**.
2. W menu po lewej wybierz **„Domeny”**.
3. Kliknij **latwaforma.pl**.
4. Przejdź do zakładki **„Strefa DNS”** / **„DNS”** / **„Zarządzaj strefą DNS”**.

## Krok 3.2. Rekord A – strona główna (landing)

1. Kliknij **„Dodaj wpis”** / **„Dodaj rekord”**.
2. **Typ:** wybierz **A**.
3. **Subdomena:** zostaw **puste** (albo wpisz `@`) – chodzi o samą **latwaforma.pl**.
4. **Cel / Wartość:** wklej **adres IP** z WebH (z Kroku 2.3).
5. Zapisz.

## Krok 3.3. Rekord A lub CNAME – www

1. **Dodaj wpis**.
2. **Typ:** **A** (jeśli WebH dał jeden IP) – **Cel:** ten sam IP co wyżej.  
   **Lub** **CNAME** – **Subdomena:** `www`, **Cel:** `latwaforma.pl` (jeśli OVH na to pozwala).
3. **Subdomena:** `www`.
4. Zapisz.

## Krok 3.4. Rekordy MX – poczta

1. **Dodaj wpis**.
2. **Typ:** **MX**.
3. **Subdomena:** puste lub `@`.
4. **Priorytet:** np. `10` (wartość z WebH, jeśli podana).
5. **Cel:** serwer pocztowy WebH (np. `mail.webh.pl`).
6. Zapisz. (Jeśli WebH ma dwa serwery MX, dodaj drugi wpis z innym priorytetem.)

## Krok 3.5. Rekordy TXT – SPF, DKIM, DMARC

Wartości **muszą** pochodzić z panelu WebH („Konfiguracja DNS poczty” / „SPF, DKIM, DMARC”). Poniżej tylko przykład.

1. **Dodaj wpis** → **Typ: TXT**.
2. **Subdomena:** puste (lub `@`). **Wartość:** np. `v=spf1 include:webh.pl ~all` (zamień na dokładną wartość z WebH). Zapisz.
3. **Dodaj wpis** → **TXT** dla **DKIM** – subdomena i wartość z WebH (często subdomena typu `default._domainkey`). Zapisz.
4. **Dodaj wpis** → **TXT** – subdomena: `_dmarc`, wartość: np. `v=DMARC1; p=none; rua=mailto:contact@latwaforma.pl`. Zapisz.

Propagacja DNS trwa zwykle **kilka minut do 24 godzin**. Rekord **app** (CNAME) dodasz w Części 6, gdy będziesz miał adres z Vercel.

---

# CZĘŚĆ 4: Wgranie landingu na WebH

Landing to strona główna latwaforma.pl (tekst „Łatwa Forma”, przycisk „Otwórz aplikację”, linki do polityki i regulaminu).

## Krok 4.1. Gdzie wgrywać pliki

1. Połączenie FTP (program **FileZilla**): host **ftp.cluster121.hosting.ovh.net**, użytkownik **latwafe**. W panelu OVH nie ma już FTP Explorera – użyj **„FTP”** (dane do FileZilli) / **„Menedżer plików”** / **„Pliki strony”**.
2. Wejdź w **główny katalog strony** (często `public_html` lub `www` lub `htdocs`). To ten folder, który „obsługuje” latwaforma.pl.

## Krok 4.2. Pliki do przygotowania na swoim komputerze

1. Otwórz folder projektu Łatwa Forma na dysku.
2. Znajdź plik: **landing_latwaforma_pl/index.html**.
3. **Skopiuj** ten plik i **zmień nazwę kopii** na **index.html** (jeśli już tak się nazywa, zostaw).
4. Znajdź plik: **web/polityka-prywatnosci.html** (albo **strava_redirect/privacy-pl.html**). Skopiuj go i upewnij się, że nazwa to **polityka-prywatnosci.html**.
5. Znajdź plik: **web/regulamin.html** (albo **strava_redirect/terms-pl.html**). Skopiuj i nazwij **regulamin.html**.

Masz **pięć plików**: **index.html**, **polityka-prywatnosci.html**, **regulamin.html**, **privacy.html**, **terms.html** (instrukcja OVH: **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**).

## Krok 4.3. Wgranie na serwer

1. W **FileZilli** (po połączeniu z OVH) przejdź po prawej do katalogu **www**, po lewej do folderu projektu – przeciągnij wszystkie 5 plików (index.html z landing_latwaforma_pl, reszta z web) na prawą stronę. Szczegóły: **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**.

## Krok 4.4. SSL (certyfikat)

1. W panelu OVH: **Hosting** → **latwaforma.pl** → zakładka **„Certyfikaty SSL”**. Znajdź / **„Certyfikat”** / **„Let’s Encrypt”**.
2. Włącz certyfikat dla **latwaforma.pl** (i ewentualnie **www.latwaforma.pl**). Zazwyczaj jeden przycisk „Aktywuj” / „Zamów”.
3. Po kilku minutach strona powinna działać jako **https://latwaforma.pl**.

## Krok 4.5. Sprawdzenie

1. W przeglądarce wpisz **https://latwaforma.pl** – powinna być strona „Łatwa Forma” z przyciskiem „Otwórz aplikację”.
2. Kliknij **„Polityka prywatności”** – powinna otworzyć się strona z polityką.
3. Kliknij **„Regulamin”** – powinna otworzyć się strona z regulaminem.

Jeśli coś nie działa, sprawdź nazwy plików (małe litery, z myślnikami) i czy są w **głównym** katalogu strony.

---

# CZĘŚĆ 5: Supabase – adresy dla aplikacji web

Aplikacja web (app.latwaforma.pl) będzie się logować przez Supabase. Trzeba dodać adresy, na które Supabase może przekierować użytkownika po logowaniu.

## Krok 5.1. Wejście w ustawienia Auth

1. Wejdź na **https://supabase.com** i zaloguj się.
2. Otwórz **swój projekt** (ten, którego używasz do Łatwej Formy).
3. W lewym menu: **Authentication** → **URL Configuration** (lub **Authentication** → **Settings** / **Configure**).

## Krok 5.2. Site URL i Redirect URLs

1. **Site URL:** ustaw na **https://app.latwaforma.pl** (bez ukośnika na końcu lub z – zależnie od dokumentacji).
2. **Redirect URLs:** w polu z listą adresów **dodaj** (po jednym w linii, jeśli tak wymaga panel):
   - `https://app.latwaforma.pl`
   - `https://app.latwaforma.pl/**`
   - `https://latwaforma.pl`
   - `https://latwaforma.pl/**`
3. Zapisz zmiany.

Na razie app.latwaforma.pl jeszcze nie działa – będzie działać po Części 6. To normalne.

---

# CZĘŚĆ 6: Aplikacja web (app.latwaforma.pl) – Vercel

Tu wgrywasz **aplikację Flutter** (to, co widać po zbudowaniu „strony” z projektu), żeby działała pod adresem **app.latwaforma.pl**.

## Krok 6.1. Zbudowanie aplikacji web na komputerze

1. Otwórz **terminal** (w Cursor: Terminal → New Terminal, albo Terminal na Macu / Wiersz poleceń na Windows).
2. Przejdź do folderu projektu (np. wpisz: `cd "Ścieżka/do/Latwa_Forma"` – swoją ścieżkę).
3. Wpisz komendę i naciśnij Enter:
   ```bash
   flutter build web
   ```
4. Poczekaj, aż build się skończy. Powinien pojawić się folder **build/web** w projekcie.

## Krok 6.2. Założenie konta Vercel i nowy projekt

1. Wejdź na **https://vercel.com**.
2. **Sign Up** / **Zarejestruj się** (np. przez GitHub – wygodnie, jeśli masz projekt w repozytorium).
3. Po zalogowaniu kliknij **„Add New…”** → **„Project”**.
4. Jeśli łączysz GitHub: wybierz **repozytorium** z projektem Łatwa Forma.  
   **Jeśli NIE masz repozytorium:** wybierz **„Upload”** / **„Deploy from local”** (jeśli Vercel to oferuje) albo najpierw wrzuć projekt na GitHub (instrukcja pomijana – zakładam, że wolisz „Upload” lub masz repo).

## Krok 6.3. Konfiguracja buildu (gdy projekt z GitHub)

1. **Framework Preset:** wybierz **„Other”** (Flutter nie jest na liście).
2. **Build Command:** wpisz: `flutter build web`
3. **Output Directory:** wpisz: `build/web`
4. **Install Command:** wpisz: `flutter pub get` (albo zostaw puste, jeśli build sam zainstaluje zależności – na Vercel może być potrzebna instalacja Flutter SDK; wtedy często używa się np. **„Deploy from local”** z gotowym folderem **build/web**).

**Uwaga:** Vercel domyślnie **nie ma** Fluttera. Dlatego często stosuje się jedną z opcji:
- **Opcja A:** Build lokalnie (`flutter build web`), a potem w Vercel: **„Import”** i wybierz **„Upload”** – wgrywasz **zawartość** folderu **build/web** (wszystkie pliki z środka) do Vercel (np. przeciągając folder).
- **Opcja B:** Użyć **Netlify** lub **Firebase Hosting** – Netlify ma „Deploy from folder”; Firebase wymaga `firebase deploy` z folderu `build/web`.

Dla **najprostszego** flow „dla laika” opiszemy **Opcję A z Vercel (upload)**.

## Krok 6.4. Deploy przez upload (Vercel)

1. Po `flutter build web` na komputerze otwórz folder **build/web** w projekcie.
2. Wejdź na **https://vercel.com** → **Add New** → **Project**.
3. Szukaj opcji **„Deploy by uploading”** / **„Upload”** (może być w dropdown przy „Import Git Repository”).  
   Jeśli jej nie ma: w Vercel wybierz **„Import Third-Party Git Repository”** i wpisz dowolny publiczny repo, w **Override** ustaw Build Command na `flutter build web` i Output na `build/web` – **ale** Vercel może nie mieć Flutter. Wtedy:
4. **Alternatywa – Netlify Drop:** Wejdź na **https://app.netlify.com/drop**. Przeciągnij **całą zawartość** folderu **build/web** (wszystkie pliki i podfoldery) w okno „Drag and drop”. Netlify wgra to i da Ci adres typu `nazwa.netlify.app`. Ten adres użyjesz w Kroku 6.5 zamiast Vercel.

## Krok 6.5. Podpięcie domeny app.latwaforma.pl

**Jeśli używasz Vercel:**
1. W projekcie Vercel wejdź w **Settings** → **Domains**.
2. Kliknij **„Add”** i wpisz: **app.latwaforma.pl**.
3. Vercel pokaże, co ustawić w DNS (np. **CNAME** dla **app** z wartością typu `cname.vercel-dns.com`). **Skopiuj** dokładnie tę wartość.

**Jeśli używasz Netlify:**
1. **Domain settings** → **Add custom domain** → wpisz **app.latwaforma.pl**.
2. Netlify wskaże rekord **CNAME**: np. **app** → `nazwa-twojej-strony.netlify.app`. Skopiuj.

## Krok 6.6. Dodanie rekordu CNAME w OVH

1. OVH → **Domeny** → **latwaforma.pl** → **Strefa DNS**.
2. **Dodaj wpis** → **Typ: CNAME**.
3. **Subdomena:** **app** (czyli app.latwaforma.pl).
4. **Cel:** wklej wartość z Vercel lub Netlify (np. `cname.vercel-dns.com` lub `xxx.netlify.app`).
5. Zapisz.

Po kilku–kilkunastu minutach **https://app.latwaforma.pl** powinno otwierać Twoją aplikację web. Jeśli nie, sprawdź CNAME i ewentualnie SSL w panelu Vercel/Netlify.

---

# CZĘŚĆ 7: Adresy w aplikacji (polityka, regulamin, Stripe)

Żeby w aplikacji (Profil) linki „Polityka prywatności” i „Regulamin” prowadziły na latwaforma.pl, a Stripe po płatności wracał na app.latwaforma.pl.

## Krok 7.1. Plik app_constants.dart

1. W projekcie Flutter otwórz plik: **lib/core/constants/app_constants.dart**.
2. Znajdź linijki z **privacyPolicyUrl** i **termsUrl**.
3. Ustaw:
   - `privacyPolicyUrl` = `'https://latwaforma.pl/polityka-prywatnosci.html'`
   - `termsUrl` = `'https://latwaforma.pl/regulamin.html'`
4. Zapisz plik.

## Krok 7.2. Stripe – adresy po płatności

1. W **Supabase** → **Edge Functions** → **Secrets** (lub w Stripe Dashboard, jeśli tam trzymasz URL-e).
2. Ustaw (lub zaktualizuj):
   - **STRIPE_SUCCESS_URL** = `https://app.latwaforma.pl/#/premium-success`
   - **STRIPE_CANCEL_URL** = `https://app.latwaforma.pl/#/premium-cancel`
3. Zapisz.  
Jeśli używasz **Stripe Dashboard** do tych pól – zmień je tam na powyższe adresy.

## Krok 7.3. Ponowny build i deploy aplikacji web

1. W terminalu w katalogu projektu wykonaj ponownie: **`flutter build web`**.
2. Zawartość **build/web** wgraj jeszcze raz na Vercel (upload) lub Netlify (przeciągnij do Drop), żeby wersja z nowymi linkami była online.

---

# CZĘŚĆ 8: Sprawdzenie końcowe

1. **https://latwaforma.pl** – strona główna, linki Polityka i Regulamin.
2. **https://app.latwaforma.pl** – aplikacja; logowanie (Google / e-mail); po zalogowaniu Profil – kliknij „Polityka prywatności” i „Regulamin” (powinny otwierać latwaforma.pl).
3. **Poczta** – wyślij testowego maila na contact@latwaforma.pl z innej skrzynki i sprawdź, czy przychodzi (oraz czy nie ląduje w spanie).
4. **Premium (Stripe)** – w aplikacji web wejdź w Premium, „Wykup Premium”, opłać testowo; po powrocie sprawdź, czy wraca na app.latwaforma.pl i czy status się odświeża.

---

# Podsumowanie kolejności

| Nr | Działanie |
|----|-----------|
| 1 | Wykup domeny latwaforma.pl w OVH |
| 2 | Hosting OVH (już masz). Założenie skrzynek contact@ i norbert.wroblewski@latwaforma.pl w OVH |
| 3 | W OVH: sprawdzenie/ustawienie DNS – rekordy A (latwaforma.pl, www), MX, TXT (SPF, DKIM, DMARC) |
| 4 | Wgranie landingu na OVH (FileZilla, 5 plików – patrz INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md), włączenie SSL |
| 5 | Supabase: Site URL i Redirect URLs (app.latwaforma.pl, latwaforma.pl) |
| 6 | Flutter: `flutter build web`; deploy buildu na Vercel/Netlify; CNAME app w OVH → app.latwaforma.pl |
| 7 | W projekcie: app_constants (polityka, regulamin), Stripe success/cancel; ponowny build i deploy web |
| 8 | Test: latwaforma.pl, app.latwaforma.pl, poczta, logowanie, Premium |

**Rekord api.latwaforma.pl** (dla Supabase) możesz pominąć na start – aplikacja może korzystać z domyślnego URL Supabase (`https://xxx.supabase.co`). Domena api przyda się później przy custom domain lub przy migracji na VPS.
