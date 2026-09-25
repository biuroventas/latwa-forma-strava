# Baza produktów w Turso

Turso (libSQL) jest używane jako **główne źródło katalogu produktów**, gdy jest skonfigurowane. Daje duży darmowy limit (~9 GB) i nie obciąża Supabase.

## Konfiguracja w aplikacji

Dodaj do pliku env (np. `env.production` oraz do assets dla webu – tak jak Supabase):

```
TURSO_DATABASE_URL=https://twoja-baza-org.turso.io
TURSO_AUTH_TOKEN=<token z turso db tokens create>
```

- **URL:** `turso db show <nazwa-bazy> --http-url` (musi być `https://`, bez ścieżki).
- **Token:** `turso db tokens create <nazwa-bazy>`.

Bez tych zmiennych aplikacja pomija Turso i korzysta z tabeli `products` w Supabase (jeśli istnieje), potem z OFF API.

**Deploy na latwaforma.pl:** Zmienne muszą trafić do pliku `env.production` w buildzie (skrypt `prepare_latwaforma_pl.sh` bierze je z `.env`). Jeśli deploy na Netlify został **anulowany** lub **nie powiódł się**, na produkcji nadal jest stara wersja – bez Turso w env. Wtedy wyszukiwanie nie używa Turso. Zawsze dopilnuj, żeby deploy zakończył się sukcesem („Production Published”); w razie niepowodzenia uruchom deploy ponownie.

## Tworzenie bazy i import

1. Zainstaluj [Turso CLI](https://docs.turso.tech/cli/installation), zaloguj się: `turso auth login`.
2. Utwórz bazę: `turso db create latwa-forma-products`.
3. Utwórz tabelę: `turso db shell latwa-forma-products < scripts/import_off_products/schema-turso.sql`.
4. Pobierz URL i token (jak wyżej), ustaw je w `.env` w `scripts/import_off_products`.
5. Import: `cd scripts/import_off_products && npm install && node run-turso.js` (wymaga pobranego pliku OFF – patrz README w tym katalogu).

## Kolejność źródeł w aplikacji

1. **Turso** – gdy `TURSO_DATABASE_URL` i `TURSO_AUTH_TOKEN` są ustawione.
2. **Supabase** (tabela `products`) – gdy Turso nie zwróci wyniku.
3. **Open Food Facts API** – fallback przy braku w obu bazach.
