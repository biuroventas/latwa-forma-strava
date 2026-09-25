# Wgrywanie latwaforma.pl na Netlify z terminala (bez przeciągania)

Zamiast Drag and drop w przeglądarce możesz wgrać stronę jedną komendą.

---

## Jednorazowa konfiguracja

### 1. Zainstaluj Netlify CLI (jeśli nie masz)

```bash
npm install -g netlify-cli
```

(albo używasz `npx netlify-cli` bez instalacji globalnej – skrypt poniżej używa `npx`.)

### 2. Zaloguj się do Netlify

W katalogu głównym projektu:

```bash
netlify login
```

Otworzy się przeglądarka – zaloguj się do Netlify i zatwierdź dostęp. Wystarczy **raz**.

### 3. Podłącz projekt do strony „latwaforma” na Netlify

```bash
netlify link
```

- Wybierz **Create & configure a new site** albo **Use current directory with an existing Netlify site**.
- Jeśli wybierzesz istniejącą stronę: wskaż **Team**, potem stronę **latwaforma** (ta z domeną latwaforma.pl).
- Zapisze się powiązanie w folderze `.netlify`.

---

## Deploy (za każdym razem)

W katalogu głównym projektu:

```bash
npm run deploy:site
```

Albo:

```bash
bash scripts/prepare_latwaforma_pl_site.sh
npx netlify deploy --dir=dist_latwaforma_pl --prod
```

- Skrypt najpierw buduje folder `dist_latwaforma_pl` (landing + polityka + regulamin + auth_redirect).
- Potem wgrywa go na Netlify jako **production**.
- Żadnego przeciągania – wszystko z terminala.

---

## Deploy aplikacji Flutter (główna strona latwaforma.pl)

Aplikacja (Flutter web) jest budowana przez Netlify przy pushu do repozytorium (zgodnie z `netlify.toml`). Możesz też wgrać build z terminala:

```bash
bash scripts/prepare_latwaforma_pl.sh
npx netlify deploy --dir=build/web --prod --no-build
```

- `prepare_latwaforma_pl.sh` tworzy `env.production` z `.env` (w tym TURSO_*, Supabase, Garmin) i buduje Flutter web.
- `--no-build` pomija ponowny build po stronie Netlify (używasz lokalnego `build/web`).

**Ważne:** Nie anuluj deployu w panelu Netlify. Anulowany lub nieudany deploy oznacza, że na produkcji zostaje poprzednia wersja – bez nowego env (np. Turso) ani nowego kodu. Jeśli deploy się nie udał lub został anulowany, uruchom deploy jeszcze raz i poczekaj na zakończenie („Production Published”).

---

## Uwagi

- **netlify login** i **netlify link** robisz tylko raz (albo po zmianie komputera / usunięciu `.netlify`).
- Folder `.netlify` (z konfiguracją linku) warto dodać do `.gitignore`, żeby nie trafił do repozytorium.
