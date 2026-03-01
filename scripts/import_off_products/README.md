# Import produktów Open Food Facts (subset polski) do Supabase

Skrypt wstawia do tabeli `products` w Supabase produkty z eksportu OFF, filtrowane po **sprzedawane w Polsce** (`countries_tags` zawiera `en:poland`) i po obecności wartości odżywczych. Limit ~30 000 produktów, żeby zmieścić się w darmowym limicie 500 MB.

## Wymagania

- Node.js 18+
- Konto Supabase z wykonaną migracją `20250302000001_products.sql`

## Kroki

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

Użyj **klucza service_role** (nie anon), żeby import omijał RLS:

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
- Aplikacja po wdrożeniu najpierw szuka w tej tabeli, potem w OFF API.
