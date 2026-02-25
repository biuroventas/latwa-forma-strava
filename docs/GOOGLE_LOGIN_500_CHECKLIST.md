# Błąd 500 przy logowaniu Google – co sprawdzić krok po kroku

## Spacja w adresie (najczęstsza przyczyna): `invalid character " " in host name`

Jeśli w logach widzisz:  
`parse "https://latwaforma.pl ": invalid character " " in host name`  
to w adresie jest **spacja na końcu** (lub na początku). Supabase nie może sparsować takiego URL.

**Co zrobić – krok po kroku (ważne, żeby nie zostawić spacji):**

1. Wejdź na **https://supabase.com/dashboard** → swój projekt.
2. **Authentication** (lewe menu) → **URL Configuration**.
3. **Site URL:**
   - Zaznacz **całą** zawartość pola (Ctrl+A / Cmd+A) i usuń.
   - **Skopiuj z tej linii** (bez spacji) i wklej do pola:  
     `https://latwaforma.pl`  
     Albo wpisz ręcznie, **nie** dodając spacji na końcu. Sprawdź, że po „pl” nie ma kursora ani spacji.
4. **Redirect URLs:**
   - **Usuń** każdy wpis, który zawiera `latwaforma.pl` (ikona kosza / Remove).
   - Kliknij **Add URL** (lub podobnie) i w nowym polu wklej **tylko**:  
     `https://latwaforma.pl`  
     (skopiuj z powyższej linii – bez spacji). Zapisz ten wpis.
   - Dodaj też np. `http://localhost` jeśli testujesz w Chrome z `flutter run`.
   - Sprawdź **wszystkie** inne wpisy na liście – jeśli któryś wygląda na `https://latwaforma.pl` z spacją, usuń go.
5. Kliknij **Save** na dole strony.
6. **Project Settings** (ikona zębatki) → **Authentication** – jeśli jest tam osobne pole „Site URL” lub „Redirect URLs”, popraw tam to samo (bez spacji).
7. Odczekaj **1–2 minuty**, zamknij kartę z błędem 500, w aplikacji spróbuj ponownie **Zaloguj przez Google** (najlepiej w trybie incognito lub po wyczyszczeniu ciasteczek dla tej strony).

**Jak upewnić się, że nie ma spacji:** W polu **Site URL** kliknij na sam koniec (za literą „l” w „pl”). Naciśnij strzałkę w lewo – jeśli kursor skacze o dwa miejsca zamiast o jedno, za „pl” jest ukryty znak (spacja). Usuń go (Backspace) i zapisz.

---

### „Przechodzi dalej, ale zatrzymuje się na ładowaniu”

Jeśli po zalogowaniu w Google widzisz białą stronę lub JSON z błędem 500 na adresie `...supabase.co/auth/v1/callback` – to nadal **ten sam błąd**: Supabase nie może dokończyć callbacku i nie przekierowuje Cię z powrotem do aplikacji. „Ładowanie” to właśnie ta nieudana próba. Trzeba usunąć przyczynę 500 (zazwyczaj spacja w URL w Supabase, patrz wyżej) i sprawdzić **Logs → Auth**, żeby zobaczyć aktualny komunikat błędu.

---

Gdy po kliknięciu „Zaloguj przez Google” wracasz na stronę Supabase i widzisz:
`{"code":500,"error_code":"unexpected_failure","msg":"Unexpected failure, please check server logs..."}`  
– błąd występuje **po stronie Supabase** w momencie wymiany kodu od Google na sesję. Poniżej lista kontrolna.

---

## 1. Sprawdź logi w Supabase (to da konkretną przyczynę)

1. Wejdź na **https://supabase.com/dashboard** i zaloguj się.
2. Otwórz **swój projekt** (np. Latwa Forma).
3. W lewym menu: **Logs** → **Auth** (albo **API**).
4. Odśwież listę logów i **spróbuj ponownie zalogować się przez Google** w aplikacji (Chrome).
5. W logach znajdź wpis z ostatniej minuty (czas + adres zawierający `callback` lub `token`).
6. Otwórz ten wpis i skopiuj **cały komunikat błędu** (np. `invalid_client`, `redirect_uri_mismatch`, `token exchange failed` albo treść wyjątku).

**Bez tego kroku dalsze sprawdzanie jest w ciemno.** Jeśli możesz, wklej ten komunikat w odpowiedzi – wtedy da się podać dokładną poprawkę.

---

## 2. Google Cloud Console – klient OAuth

1. Wejdź na **https://console.cloud.google.com** → ten sam projekt, w którym masz OAuth.
2. **APIs & Services** → **Credentials**.
3. Otwórz klienta typu **„Web application”** (nie Android, nie iOS).  
   Jeśli go nie ma: **+ CREATE CREDENTIALS** → **OAuth client ID** → Application type: **Web application**.
4. Sprawdź:
   - **Authorized redirect URIs** – musi być **dokładnie** (zamień `tslsayftpegpliihfmyg` na swój ref z Supabase):
     - `https://tslsayftpegpliihfmyg.supabase.co/auth/v1/callback`
     - Bez spacji, bez ukośnika na końcu, tylko `https`.
   - **Authorized JavaScript origins** – powinno być m.in.:
     - `https://tslsayftpegpliihfmyg.supabase.co`
     - Dla testów lokalnych: `http://localhost` (albo `http://localhost:PORT`).
5. Skopiuj **Client ID** i **Client secret** (ikona kopiowania). Będą potrzebne w kroku 3.

---

## 3. Supabase – provider Google

1. **Supabase Dashboard** → Twój projekt → **Authentication** → **Providers**.
2. Znajdź **Google** i włącz go (toggle **Enabled**).
3. Wklej **Client ID** i **Client secret** z Google (te same co w kroku 2).  
   Żadnych spacji na początku/końcu – najlepiej wkleić i nie edytować.
4. **Save**.

---

## 4. Supabase – Redirect URLs (powrót do aplikacji)

1. W tym samym projekcie: **Authentication** → **URL Configuration**.
2. W **Redirect URLs** upewnij się, że są:
   - `http://localhost` **lub** `http://localhost:XXXX` (dla `flutter run -d chrome` – XXXX to port z terminala),
   - `https://latwaforma.pl` (produkcja).
3. **Save**.

---

## 5. Po zmianach

- Zapisz wszystko w Google i Supabase.
- Odczekaj **1–2 minuty** (cache).
- Zamknij kartę z błędem 500 i w aplikacji (Chrome) **spróbuj ponownie** „Zaloguj przez Google”.

---

## Najczęstsze przyczyny 500 w tym flow

| Co widać w logach Auth (Supabase) | Co zrobić |
|-----------------------------------|-----------|
| `invalid_client` / błąd klienta   | Sprawdź, czy w Supabase wklejony jest Client ID i **Client secret** z klienta **Web application** (kroki 2–3). |
| `redirect_uri_mismatch`          | W Google w **Authorized redirect URIs** musi być dokładnie `https://TWOJ_REF.supabase.co/auth/v1/callback`. |
| Błąd wymiany tokena / exchange    | Zwykle zły Client secret albo inny klient (np. Android zamiast Web). |
| Brak wpisu / błąd wewnętrzny      | Spróbuj na chwilę wyłączyć i ponownie włączyć provider Google w Supabase; jeśli nie pomoże – wsparcie Supabase z fragmentem logu. |

Jeśli po przejściu listy błąd 500 nadal się pojawia, **koniecznie** zrób krok 1 i wklej tutaj **dokładny komunikat z logów Auth** – wtedy można wskazać konkretną przyczynę.
