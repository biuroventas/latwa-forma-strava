# Integracja Google Sign-In – krok po kroku

**Flow:** Najpierw logowanie natywne (w aplikacji). Przy błędzie użytkownik ma opcję „Spróbuj przez przeglądarkę”.

## Krok 1: Google Cloud Console

1. Otwórz **[console.cloud.google.com](https://console.cloud.google.com)** i zaloguj się
2. Utwórz nowy projekt lub wybierz istniejący (np. „Latwa Forma”)
3. W menu ☰ przejdź do **APIs & Services** → **Credentials** (OAuth i klucze API)
4. Kliknij **+ CREATE CREDENTIALS** → **OAuth client ID**
5. Jeśli pojawi się ekran OAuth consent screen:

   - **User Type**: External → **Create**
   - Wypełnij: App name (np. „Łatwa Forma”), User support email, Developer contact
   - Scopes: domyślne (email, profile, openid) wystarczą
   - **Save and Continue** → Test users (opcjonalnie) → **Save**

6. Wróć do **Create OAuth client ID**:

   - **Application type**: **Web application**
   - **Name**: np. „Latwa Forma Web”
   - **Authorized JavaScript origins** – dodaj:
     - `https://TWOJ_REF.supabase.co` (URL projektu Supabase, np. `https://tslsayftpegpliihfmyg.supabase.co`)
     - `http://localhost` (testy lokalne)
     - Dla produkcji web: `https://latwaforma.pl`
   - **Authorized redirect URIs** – dodaj **dokładnie** (bez ukośnika na końcu):
     - `https://TWOJ_REF.supabase.co/auth/v1/callback`  
       (np. `https://tslsayftpegpliihfmyg.supabase.co/auth/v1/callback` – zamień na ref swojego projektu)
   - **Create**

7. Skopiuj:

   - **Client ID** (np. `123456789-xxx.apps.googleusercontent.com`)
   - **Client secret** (kliknij ikonę kopiowania)

---

## Krok 2: Supabase Dashboard

1. Otwórz **[Supabase Dashboard](https://supabase.com/dashboard)** → Twój projekt
2. **Authentication** → **Providers** → **Google**
3. Włącz provider (toggle **Enabled**)
4. Wklej:

   - **Client ID** – ten sam co z Google Cloud
   - **Client Secret** – ten sam co z Google Cloud

5. **Authentication** → **URL Configuration** → **Redirect URLs** – dodaj:

   - `latwaforma://auth/callback` (mobile – bez tego po zalogowaniu Google: błąd / czarny ekran)
   - `https://latwaforma.pl` (produkcja web)
   - **Dla localhost (Chrome):** adres **ze slashem**, np. `http://localhost:8080/`. Uruchom aplikację z ustalonym portem: `flutter run -d chrome --web-port=8080`, potem w Supabase dodaj dokładnie `http://localhost:8080/`. Otwieraj stronę pod tym samym adresem i loguj w **tej samej karcie**. Bez tego na localhost pojawi się „Logowanie Google nie powiodło się”.

6. Wróć do **Authentication** → **Providers** i przy Google włącz **Allow manual linking** (obok „Allow anonymous sign-ins”) – wymagane do łączenia konta anonimowego z Google.
7. **Save**

---

## Krok 3: Plik .env (opcjonalnie)

Aplikacja korzysta z Client ID/Secret ustawionych w Supabase (Krok 2). Jeśli w projekcie używasz zmiennej `GOOGLE_WEB_CLIENT_ID` (np. w skryptach lub przyszłej integracji):

1. Otwórz plik `.env` w głównym folderze projektu (oraz `env.production` przy deployu web – aplikacja ładuje z niego zmienne na webie).
2. Dodaj lub uzupełnij linię (ten sam Client ID co w Supabase):

   ```text
   GOOGLE_WEB_CLIENT_ID=123456789-xxx.apps.googleusercontent.com
   ```

3. Po zmianie `.env` zrestartuj aplikację.

---

## Krok 4: Testowanie

1. Uruchom aplikację: `flutter run`
2. Zaloguj się anonimowo (Welcome → Zaczynamy → Onboarding)
3. Dodaj 5 posiłków (ręcznie lub z listy)
4. Powinien pojawić się modal „Zapisz postępy”
5. Kliknij **Kontynuuj z Google** → wybierz konto Google
6. Konto anonimowe zostanie połączone z kontem Google

---

## Rozwiązywanie problemów

### „Skonfiguruj GOOGLE_WEB_CLIENT_ID w pliku .env”

- Sprawdź, czy `.env` (lub `env.production` przy buildzie web) zawiera prawidłowy Client ID
- Zrestartuj aplikację po zmianie pliku env

### „Error 10” / „DEVELOPER_ERROR” (Android)

- Dodaj **SHA-1** projektu w Google Cloud Console:
  - `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`
  - Skopiuj SHA-1 do Google Cloud → Credentials → Twój OAuth client → Android

### Błąd na iOS (natywny flow)

- Dla natywnego logowania: w Google Cloud utwórz **OAuth Client ID** typu **iOS**
  - Bundle ID: `com.latwaforma.latwaForma`
  - Skopiuj iOS Client ID i zaktualizuj w `ios/Runner/Info.plist` URL scheme na `com.googleusercontent.apps.XXX` (odwrócony iOS Client ID)
- Obecnie używany jest scheme z Web Client ID – jeśli nie działa, dodaj iOS client

### „Code verifier could not be found in local storage” (web)

Ten błąd pojawia się po powrocie z Google, gdy Supabase nie znajdzie w przeglądarce wcześniej zapisanego `code_verifier` (PKCE). **localStorage jest rozdzielony per origin** – np. `https://latwaforma.pl` i `https://www.latwaforma.pl` to dwa różne originy.

**Co zrobić:**

1. **Jeden adres produkcyjny**  
   Użyj wyłącznie **https://latwaforma.pl** (bez www). W Supabase **Site URL** ustaw: `https://latwaforma.pl`.

2. **Przekierowanie www → bez www**  
   W Netlify (Domain settings) ustaw przekierowanie 301: `https://www.latwaforma.pl` → `https://latwaforma.pl`. Dzięki temu użytkownik zawsze ląduje na tej samej domenie, a zapisany przed przekierowaniem do Google `code_verifier` będzie w tym samym localStorage po powrocie.

3. **Logowanie w tej samej karcie**  
   Nie otwieraj logowania Google w nowym oknie – używaj pełnego przekierowania w tej samej karcie.

W **Redirect URLs** w Supabase możesz mieć zarówno `https://latwaforma.pl` jak i `https://www.latwaforma.pl` (dla ewentualnych linków), ale **cały flow (klik „Zaloguj” → Google → powrót) musi odbywać się na jednym originie** (np. zawsze `latwaforma.pl`).

### Czarny ekran po zalogowaniu Google

- Upewnij się, że w Supabase **Authentication → URL Configuration → Redirect URLs** masz: `latwaforma://auth/callback`
- Bez tego przekierowanie po OAuth nie wróci do aplikacji prawidłowo

### „Manual linking is disabled” / Łączenie kont wymaga włączenia

- W Supabase: **Authentication** → **Providers**
- Włącz **Allow manual linking** (obok „Allow anonymous sign-ins”) – wymagana do łączenia konta anonimowego z Google

### Błąd 500 „Unexpected failure” na stronie callback Supabase (Chrome / flutter run)

Po zalogowaniu w Google przeglądarka wraca na `...supabase.co/auth/v1/callback?...` i widzisz JSON:  
`{"code":500,"error_code":"unexpected_failure","msg":"Unexpected failure, please check server logs for more information"}`.

To błąd **po stronie Supabase** w momencie wymiany kodu od Google na sesję. Co zrobić:

1. **Sprawdź logi w Supabase**  
   W [Supabase Dashboard](https://supabase.com/dashboard) → Twój projekt → **Logs** (lewe menu) → **Auth** lub **API**.  
   Odszukaj wpis z czasu logowania i przeczytaj dokładny błąd (np. „invalid client”, „token exchange failed”, „redirect_uri mismatch”). To wskazuje konkretną przyczynę.

2. **Google: typ klienta i dane**  
   - W [Google Cloud Console](https://console.cloud.google.com) → **APIs & Services** → **Credentials** używasz klienta typu **Web application** (nie Android/iOS).  
   - **Client ID** i **Client secret** z tego klienta są **identycznie** wklejone w Supabase: **Authentication** → **Providers** → **Google**.  
   - W **Authorized redirect URIs** jest **dokładnie**:  
     `https://tslsayftpegpliihfmyg.supabase.co/auth/v1/callback`  
     (zamień na swój ref projektu, bez ukośnika na końcu).

3. **Testy na localhost (flutter run -d chrome)**  
   Aplikacja przekazuje Supabase adres powrotu np. `http://localhost:12345` (port zależy od Fluttera).  
   W Supabase: **Authentication** → **URL Configuration** → **Redirect URLs** dodaj:  
   `http://localhost`  
   lub konkretny port, np. `http://localhost:12345`.  
   Bez tego po udanym callbacku Supabase może nie przekierować z powrotem do aplikacji (lub w skrajnych przypadkach przyczyniać się do błędów po stronie Auth).

4. **Zapisz** zmiany w Google i Supabase, odczekaj 1–2 minuty i spróbuj zalogować się przez Google jeszcze raz.  
   Jeśli 500 się powtarza, **koniecznie** sprawdź logi Auth w Supabase – tam będzie dokładna przyczyna (np. błąd konfiguracji providera lub błąd wewnętrzny Supabase).

### Błąd 400 w Safari: „The server cannot process the request because it is malformed”

Google zwraca 400, gdy **Authorized redirect URI** w Google Cloud nie zgadza się z adresem, na który Supabase wysyła użytkownika po logowaniu.

**Co zrobić:**

1. **Sprawdź adres Supabase**  
   W pliku `.env` masz linię `SUPABASE_URL=...`.  
   Redirect URI ma postać:  
   `https://TWOJ_REF.supabase.co/auth/v1/callback`  
   (bez ukośnika na końcu).

2. **W Google Cloud Console**

   - Wejdź na [console.cloud.google.com](https://console.cloud.google.com) → **APIs & Services** → **Credentials**
   - Otwórz klienta OAuth 2.0 typu **Web application** (ten, którego Client ID jest w Supabase)
   - W **Authorized redirect URIs** musi być **dokładnie**:
     - `https://tslsayftpegpliihfmyg.supabase.co/auth/v1/callback`  
       (jeśli Twój `SUPABASE_URL` to `https://tslsayftpegpliihfmyg.supabase.co`)

3. **Upewnij się, że:**

   - Nie ma literówki w adresie
   - To **https**, nie http
   - **Brak** ukośnika na końcu (`/callback`, nie `/callback/`)
   - W **Authorized JavaScript origins** jest m.in. adres Twojego projektu Supabase (np. `https://TWOJ_REF.supabase.co`)

4. **Zapisz** zmiany w Google Cloud i odczekaj 1–2 minuty, potem spróbuj ponownie „Zaloguj przez Google” w aplikacji.

### „Przejdź do aplikacji” pokazuje domenę Supabase zamiast „Łatwa Forma”

Google bierze nazwę z **ekranu zgody OAuth**. Żeby zamiast `tslsayftpegpliihfmyg.supabase.co` pokazywała się **„Łatwa Forma”**, ustaw to w Google Cloud (interfejs po polsku):

1. Wejdź na **[console.cloud.google.com](https://console.cloud.google.com)** i wybierz ten sam projekt, w którym masz klienta OAuth dla Supabase.
2. W menu ☰ (w lewym górnym rogu): **Interfejsy API i usługi** → **Ekran wyświetlania zgody OAuth** (nie „Dane logowania”).
3. Kliknij **EDYTUJ APLIKACJĘ** (lub uzupełnij ekran zgody, jeśli jeszcze go nie kończyłeś).
4. W polu **Nazwa aplikacji** wpisz: **Łatwa Forma**.
5. (Opcjonalnie) **Logo aplikacji** – możesz dodać ikonę aplikacji.
6. Uzupełnij **Adres e-mail pomocy technicznej** i **Informacje kontaktowe deweloperów**, jeśli są wymagane.
7. Zapisz: **Zapisz i kontynuuj** → **Wróć do pulpitu nawigacyjnego**.

Po zapisaniu przy następnym logowaniu przez Google zamiast domeny Supabase powinna się pokazywać nazwa **„Łatwa Forma”** (zmiana może być widoczna po kilku minutach lub po wylogowaniu i ponownym wejściu w wybór konta).
