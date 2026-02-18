# OAuth – strony przekierowania

Pliki `strava-callback.html` i `garmin-callback.html` muszą być hostowane na HTTPS.

## Szybki start (GitHub Pages – za darmo)

1. Utwórz repo na GitHub (np. `latwa-forma-strava`)

2. Wrzuć pliki `strava-callback.html` i `garmin-callback.html` do gałęzi `main` (w root repo lub w folderze `docs/`)

3. W ustawieniach repo: **Settings** → **Pages** → Source: **Deploy from a branch** → Branch: `main` → Save

4. Adres strony będzie: `https://TWOJA-NAZWA.github.io/latwa-forma-strava/strava-callback.html`

5. W Strava (https://www.strava.com/settings/api):
   - **Authorization Callback Domain**: `TWOJA-NAZWA.github.io`

6. W pliku `.env` projektu:
   ```
   STRAVA_REDIRECT_URI=https://TWOJA-NAZWA.github.io/latwa-forma-strava/strava-callback.html
   GARMIN_REDIRECT_URI=https://TWOJA-NAZWA.github.io/latwa-forma-strava/garmin-callback.html
   ```

## Garmin Connect

Garmin używa tej samej domeny – w Garmin Developer Portal podaj `TWOJA-NAZWA.github.io` jako redirect domain.

## Alternatywa

Możesz hostować pliki na dowolnym hostingu (Vercel, Netlify, własna domena itd.). Ważne, żeby:
- Działał przez HTTPS
- **Authorization Callback Domain** w Strava = domena (bez https://), np. `moja-domena.pl`
