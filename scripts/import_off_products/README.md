# Import produktów Open Food Facts (subset polski)

Skrypt wstawia do bazy produkty z eksportu OFF, filtrowane po **sprzedawane w Polsce** (`countries_tags` zawiera `en:poland`) i po obecności wartości odżywczych (~30 000 produktów).

**Dwie opcje:**
- **Turso** (zalecane) – duży darmowy limit, `run-turso.js`
- **Supabase** – tabela `products`, `run.js`

---

## Opcja A: Turso (zalecane)

### 1. Zainstaluj Turso CLI i utwórz bazę

```bash
# Zainstaluj: https://docs.turso.tech/cli/installation
turso auth login
turso db create latwa-forma-products
```

### 2. Utwórz tabelę

```bash
turso db shell latwa-forma-products < schema-turso.sql
```

### 3. Pobierz URL i token

```bash
turso db show latwa-forma-products --http-url
turso db tokens create latwa-forma-products
```

### 4. Import

W `.env` ustaw `TURSO_DATABASE_URL` (https://xxx.turso.io) i `TURSO_AUTH_TOKEN`, potem:

```bash
cd scripts/import_off_products
npm install
node run-turso.js
```

W aplikacji dodaj te same zmienne do env (np. `env.production` / assets): `TURSO_DATABASE_URL`, `TURSO_AUTH_TOKEN`. Wtedy wyszukiwanie i skan będą najpierw pytać Turso.

---

## Opcja B: Supabase

## Gdy plik już jest pobrany (Supabase)

```bash
cd scripts/import_off_products
cp .env.example .env   # uzupełnij SUPABASE_URL i SUPABASE_SERVICE_ROLE_KEY
node run.js
```

## Wymagania (Supabase)

- Node.js 18+
- Konto Supabase z wykonaną migracją `20250302000001_products.sql`

## Kroki (Supabase)

### 1. Pobierz eksport OFF

Pełny plik (duży, kilka GB skompresowany):

```bash
curl -L -o openfoodfacts-products.jsonl.gz https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz
```

Albo użyj innej ścieżki i podaj ją w kroku 3.

### 2. Zainstaluj zależności

W katalogu `scripts/import_off_products`:

```bash
npm install
```

### 3. Ustaw zmienne i uruchom

Użyj **klucza service_role** (nie anon), żeby import omijał RLS.

**Opcja A – plik .env (zalecane):**

```bash
cp .env.example .env
# Edytuj .env: wstaw SUPABASE_URL i SUPABASE_SERVICE_ROLE_KEY z Supabase (Settings → API)
node run.js
```

**Opcja B – zmienne w shellu:**

```bash
export SUPABASE_URL="https://twój-projekt.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="twój-service-role-key"
node run.js
```

Jeśli plik jest w innym miejscu:

```bash
node run.js /ścieżka/do/openfoodfacts-products.jsonl.gz
```

Skrypt domyślnie szuka pliku `openfoodfacts-products.jsonl.gz` w bieżącym katalogu.

### 4. Efekt

- W tabeli `products` pojawią się wiersze z `source = 'off'`.
- Istniejące kody kreskowe są aktualizowane (upsert po `barcode`).
- W konsoli: liczba wstawionych produktów (co 500) i podsumowanie.

## Uwagi

- Import może trwać długo (streamowanie dużego pliku).
- Aplikacja: gdy Turso jest skonfigurowane (TURSO_DATABASE_URL + TURSO_AUTH_TOKEN), najpierw Turso, potem Supabase (jeśli tabela products istnieje), na końcu OFF API.
