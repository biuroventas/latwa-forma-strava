# Konfiguracja łączenia kont (Zapisz postępy)

Modal „Zapisz postępy” pojawia się po dodaniu 5 posiłków przez użytkownika anonimowego.
Umożliwia połączenie konta z Apple, Google lub emailem.

## Supabase

1. **Manual Linking** – włącz w: Authentication → Providers → (u dołu) **Enable manual linking**
2. **Apple** – włącz provider Apple, skonfiguruj Services ID i klucz (.p8)
3. **Google** – włącz provider Google, dodaj Web Client ID i Secret z Google Cloud Console
4. **Email** – domyślnie włączone, `updateUser` wysyła link weryfikacyjny

## Apple (Sign in with Apple)

- Potrzebne tylko na iOS/macOS
- W Apple Developer: App ID z capability „Sign in with Apple”
- W Supabase: Authentication → Providers → Apple – uzupełnij Services ID i secret

## Google

1. **Google Cloud Console** → APIs & Services → Credentials
2. Utwórz **OAuth 2.0 Client ID** (typ: Web application) – używany przez Supabase
3. Opcjonalnie: Client ID dla iOS/Android do natywnego logowania
4. **W pliku .env** dodaj:

   ```
   GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
   ```

   (ten sam Web Client ID co w Supabase)

5. W Supabase: Authentication → Providers → Google – wklej Client ID i Secret

## Email

Bez dodatkowej konfiguracji. Użytkownik podaje adres → Supabase wysyła link weryfikacyjny.
Po kliknięciu w link konto anonimowe zostaje połączone z emailem.

### Logowanie przez email („Mam już konto” – magic link)

Klienty e-mail otwierają link w wbudowanej przeglądarce, która nie obsługuje schematu `latwaforma://`, więc używamy strony przekierowującej HTTPS.

1. **Hostuj stronę przekierowania** (`web/auth_redirect/index.html`):
   - Skopiuj folder `web/auth_redirect/` do repozytorium GitHub Pages (np. `latwa-forma-strava`)
   - W strukturze repo: `auth_redirect/index.html` → URL: `https://biuroventas.github.io/latwa-forma-strava/auth_redirect/`

2. **W pliku .env** dodaj:
   ```
   EMAIL_AUTH_REDIRECT_URL=https://biuroventas.github.io/latwa-forma-strava/auth_redirect/
   ```

3. **Redirect URLs** – w Supabase: Authentication → URL Configuration → Redirect URLs dodaj:
   - `latwaforma://auth/callback`
   - `latwaforma://**`
   - `https://biuroventas.github.io/latwa-forma-strava/auth_redirect/` (lub Twój adres)

4. **Email provider** – Authentication → Providers → Email musi być włączony

5. **Limit wysyłki** – plan darmowy Supabase ma limit ~4 maili/godzinę (wbudowany mailer)

6. **Spam** – link może trafić do folderu spam; zalecaj użytkownikom sprawdzenie

7. **Custom SMTP** – w produkcji skonfiguruj własny SMTP (Authentication → Email Templates → SMTP)
