# Deploy – Łatwa Forma

**Aplikacja web wdrażana wyłącznie na latwaforma.pl** (Netlify).  
**app.latwaforma.pl jest zapauzowany** – nie wdrażaj tam zmian; cała produkcja i aktualizacje idą na <https://latwaforma.pl>.

Deploy: `./scripts/deploy_site_netlify.sh` (buduje Flutter web + wgrywa `build/web` na Netlify).

## Garmin Connect na stronie

Żeby przycisk „Połącz z Garmin Connect” działał (bez komunikatu „Dodaj GARMIN_CLIENT_ID do env”):

- **Deploy lokalny** (`./scripts/deploy_site_netlify.sh`): w katalogu projektu musi być plik **.env** z liniami `GARMIN_CLIENT_ID=...` i (opcjonalnie) `GARMIN_CLIENT_SECRET=...`, `GARMIN_REDIRECT_URI=...`. Skrypt skopiuje je do `env.production` i do `build/web`.
- **Deploy z Gita (Netlify CI)**: w Netlify → **Site settings** → **Environment variables** dodaj zmienne **GARMIN_CLIENT_ID** oraz ewentualnie **GARMIN_CLIENT_SECRET**, **GARMIN_REDIRECT_URI**. Po zapisaniu zrób **Trigger deploy** (nowy build), żeby strona miała aktualny plik `env.production`.
