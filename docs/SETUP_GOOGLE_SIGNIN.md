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
     - `https://tslsayftpegpliihfmyg.supabase.co` (URL Twojego projektu Supabase)
     - `http://localhost` (na potrzeby testów lokalnych)
   - **Authorized redirect URIs** – dodaj:
     - `https://tslsayftpegpliihfmyg.supabase.co/auth/v1/callback`
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
5. **Authentication** → **URL Configuration** → **Redirect URLs**
   - Dodaj: `latwaforma://auth/callback`  
   - (bez tego po zalogowaniu Google zamiast powrotu do app będzie błąd / czarny ekran)
6. **Authentication** → **Providers** (strona z listą providerów)
   - Włącz **Allow manual linking** – opcja obok „Allow anonymous sign-ins”
   - Konieczne do łączenia konta anonimowego z Google
7. **Save**

---

## Krok 3: Plik .env

1. Otwórz plik `.env` w głównym folderze projektu
2. Znajdź linię `GOOGLE_WEB_CLIENT_ID=`
3. Wklej Client ID (ten sam co w Supabase):
   ```
   GOOGLE_WEB_CLIENT_ID=123456789-xxx.apps.googleusercontent.com
   ```

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
- Sprawdź, czy plik `.env` zawiera prawidłowy Client ID
- Zrestartuj aplikację po zmianie `.env`

### „Error 10” / „DEVELOPER_ERROR” (Android)
- Dodaj **SHA-1** projektu w Google Cloud Console:
  - `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`
  - Skopiuj SHA-1 do Google Cloud → Credentials → Twój OAuth client → Android

### Błąd na iOS (natywny flow)
- Dla natywnego logowania: w Google Cloud utwórz **OAuth Client ID** typu **iOS**
  - Bundle ID: `com.latwaforma.latwaForma`
  - Skopiuj iOS Client ID i zaktualizuj w `ios/Runner/Info.plist` URL scheme na `com.googleusercontent.apps.XXX` (odwrócony iOS Client ID)
- Obecnie używany jest scheme z Web Client ID – jeśli nie działa, dodaj iOS client

### Czarny ekran po zalogowaniu Google
- Upewnij się, że w Supabase **Authentication → URL Configuration → Redirect URLs** masz: `latwaforma://auth/callback`
- Bez tego przekierowanie po OAuth nie wróci do aplikacji prawidłowo

### „Manual linking is disabled” / Łączenie kont wymaga włączenia
- W Supabase: **Authentication** → **Providers**
- Włącz **Allow manual linking** (obok „Allow anonymous sign-ins”) – wymagana do łączenia konta anonimowego z Google

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
   - W **Authorized JavaScript origins** jest: `https://tslsayftpegpliihfmyg.supabase.co`

4. **Zapisz** zmiany w Google Cloud i odczekaj 1–2 minuty, potem spróbuj ponownie „Zaloguj przez Google” w aplikacji.
