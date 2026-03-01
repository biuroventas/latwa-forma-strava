# Plan: Wielka polska baza produktów w Latwa Forma

Cel: mieć bazę produktów **co najmniej tak dobrą jak Fitatu**, a w dłuższej perspektywie **lepszą** – przy użyciu darmowych źródeł i własnego rozwoju.

---

## 1. Jak się do tego zabrać (podejście)

1. **Nie zastępować od razu** – zostawić Open Food Facts przy skanowaniu kodu, dodać **wyszukiwanie po nazwie** (OFF ma full-text search).
2. **Własna baza w Supabase** – stopniowo: import produktów z OFF (eksport CSV/JSONL), potrawy z restauracji, produkty dodawane przez użytkowników.
3. **Jednolity interfejs w aplikacji** – „Szukaj produktu” łączy wyniki z OFF + (później) z własnej bazy; po wyborze produktu ten sam flow co przy kodzie kreskowym (waga → dodaj do posiłków).

---

## 2. Darmowe możliwości

### 2.1 Open Food Facts (już używane)

- **Obecnie:** tylko `getProductByBarcode` (kod kreskowy).
- **Darmowo:**  
  - **Wyszukiwanie po nazwie** – API v1: `https://world.openfoodfacts.org/cgi/search.pl?search_terms=...&action=process&json=1&page_size=20`.  
  - Limit ~10 zapytań/minutę – w aplikacji: debounce wyszukiwania, cache wyników, ewentualnie backend-proxy z cache’em.
- **Polska:** pl.openfoodfacts.org ma ~24 tys. produktów; **world** ma znacznie więcej (produkty międzynarodowe dostępne w PL).  
- **Rozwój:**  
  - Zachęcać użytkowników do dodawania brakujących produktów w OFF (link w aplikacji).  
  - **Import bazy OFF do siebie** – tak, możesz. Wtedy nie ma limitów zapytań (wszystko z Twojej bazy). Szczegóły poniżej w sekcji **2.1.1**.

### 2.1.1 Import bazy Open Food Facts do siebie (brak limitu zapytań)

**Tak – możesz zaimportować całą bazę OFF do własnej bazy.** Dane są na licencji ODbL, dozwolone do pobrania i ponownego użycia.

**Gdzie pobrać (eksporty aktualizowane co noc):**

| Źródło | Format | Uwagi |
|--------|--------|--------|
| `https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz` | JSONL (gzip) | Jedna linia = jeden produkt (JSON). Najwygodniejsze do streamowania i importu do Supabase. |
| `https://static.openfoodfacts.org/data/openfoodfacts-mongodbdump.gz` | MongoDB dump | Pełna baza; do odtworzenia MongoDB, ewentualnie konwersja do CSV/JSONL. |
| Hugging Face: `openfoodfacts/openfoodfacts-jsonl-export` | JSONL | Ten sam zestaw danych, alternatywne mirror. |
| Strona OFF → Data → CSV exports | CSV | Mniejsze pliki, np. tylko produkty z wartościami odżywczymi. |

**Rozmiar:** pełna baza world to **dziesiątki GB** (skompresowana kilka GB). W praktyce warto:

- **Opcja A – filtr po stronie OFF/eksportu:** sprawdzić, czy OFF udostępnia mniejsze eksporty (np. „products with nutrition”, „by country”). Często są CSV z wybranymi polami.
- **Opcja B – pobrać JSONL i filtrować przy imporcie:** streamować `openfoodfacts-products.jsonl.gz`, czytać linia po linii, zostawiać tylko produkty z wypełnionymi `nutriments` (oraz opcjonalnie `countries_tags` zawierające Poland lub `lang` pl). Zapis do tabeli Supabase `products`. Jednorazowy skrypt (Node/Deno/Python) na serwerze lub lokalnie; potem okresowy re-import (np. co tydzień/miesiąc).

**Flow po imporcie:**

1. Tabela w Supabase (np. `products`) z polami: `barcode`, `name`, `name_pl`, `brand`, `calories_per_100g`, `protein_g`, `fat_g`, `carbs_g`, `image_url`, `source='off'`, itd.
2. W aplikacji: **wyszukiwanie** najpierw w Supabase (full-text lub `ilike`), bez limitów. Skan kodu → szukaj po `barcode` w Supabase; jeśli brak – fallback na żywo do OFF API (limit tylko przy braku w Twojej bazie).
3. Opcjonalnie: przy każdym udanym pobraniu z OFF (skan lub search) dopisywać produkt do Supabase jako cache – baza rośnie „organicznie”.

**Podsumowanie:** import OFF do własnej bazy jest dozwolony i usuwa problem limitu zapytań; najprościej zacząć od JSONL + skrypt filtrujący (np. tylko z wartościami odżywczymi / tylko Polska) i importu do Supabase.

---

### 2.2 Własna baza w Supabase (darmowy tier)

- Tabela `products`:  
  `id`, `barcode`, `name`, `name_pl`, `brand`, `calories_per_100g`, `protein_g`, `fat_g`, `carbs_g`, `source` (off / user / restaurant), `country`, `image_url`, `created_at`, itd.
- **Źródła danych:**  
  - Import z OFF (dump/eksport).  
  - **Potrawy z restauracji** – ręcznie lub z publicznych PDF/CSV (np. McDonald’s nutrition CSV na GitHubie, KFC PL – PDF z wartościami odżywczymi).  
  - **Produkty dodane przez użytkowników** – crowdsourcing (np. „Dodaj produkt do bazy” po skanowaniu gdy OFF nie ma).
- RLS: odczyt dla wszystkich, zapis (dodawanie produktów) dla zalogowanych; opcjonalnie moderacja (flag `verified`).

### 2.3 Restauracje („jak Fitatu”)

- Fitatu ma McDonald’s, KFC, Subway, Pizza Hut, Starbucks itd.  
- **Darmowo:**  
  - Oficjalne PDF z wartościami odżywczymi (np. KFC PL).  
  - Publiczne CSV/datasets (np. McDonald’s menu nutrition na GitHubie).  
  - Ręczne uzupełnienie kilku sieci na start.  
- W aplikacji: osobna „kategoria” lub tag `source=restaurant`, np. **„Na mieście”** rozszerzyć o listę „McDonald’s”, „KFC” z konkretnymi daniami z bazy (zamiast tylko szacunków jak teraz).

### 2.4 Czego unikać na start

- Płatne API (np. Macros.Menu) – dopiero gdy będzie budżet i wyraźna potrzeba.  
- Skrobanie stron sklepów – problemy prawne i techniczne; lepiej OFF + własna baza + restauracje z oficjalnych źródeł.

---

## 3. Jak to rozwijać (fazy)

### Faza 1 (szybko, bez własnej bazy) ✅ zrobione

- **Wyszukiwanie produktów po nazwie** przez OFF API v1 – wdrożone w `OpenFoodFactsService.searchProducts()`.  
- W „Dodaj posiłek”: opcja **„Wyszukaj produkt”** → `ProductSearchScreen` (debounce 400 ms) → lista wyników OFF → wybór → `BarcodeProductScreen` (waga, dodaj do dziennika).  
- Dodane: **User-Agent** w zapytaniach do OFF. Opcjonalnie w przyszłości: cache wyników (np. 5–10 min).

### Faza 2 (własna baza)

- Migracja Supabase: tabela `products` (+ indeksy na `name`, `barcode`, `brand`).  
- Skrypt importu: pobierz eksport OFF (np. CSV), filtruj `countries=Poland` lub `lang=pl`, wstaw do `products` z `source='off'`.  
- W aplikacji: **„Szukaj produktu”** najpierw zapytanie do Supabase (full-text lub `ilike`), jeśli mało wyników – uzupełnienie z OFF (fallback).  
- Opcjonalnie: przy skanowaniu, gdy OFF zwróci produkt – **zapis do `products`** (cache w swojej bazie), żeby kolejne wyszukiwania były szybsze.

### Faza 3 (restauracje + crowdsourcing)

- Tabela `restaurant_items` lub rozszerzenie `products` o `category=restaurant`, `restaurant_name`.  
- Import McDonald’s (CSV), KFC (ręcznie z PDF), kilka innych sieci.  
- W UI: **„Na mieście”** → wybór sieci → lista dań z kaloriami/makro z bazy.  
- **„Dodaj produkt do bazy”**: po skanowaniu, gdy OFF nie ma produktu – formularz (nazwa, kod, kalorie, makro) → zapis do `products` z `source='user'`, ewentualnie kolejka do moderacji.

### Faza 4 (lepsi od Fitatu)

- **Nutri-Score** (OFF to ma) – pokazywać przy produkcie.  
- **Ostatnio używane / często wybierane** produkty per użytkownik.  
- **Filtry:** kategoria, marka, „tylko z polskiej bazy”, „zweryfikowane”.  
- **Błonnik, sól, cukier** – już macie w posiłkach; w bazie produktów trzymać te same pola.  
- **Lista zakupów** (na później) – generowana z planowanych posiłków/ulubionych.

---

## 4. Funkcje aplikacji pod kątem bazy produktów (cel: jak Fitatu lub lepiej)

| Funkcja | Fitatu | Latwa Forma (docelowo) |
|--------|--------|-------------------------|
| Skanowanie kodu | Tak | Tak (OFF) |
| Wyszukiwanie po nazwie | Tak | Tak (OFF + własna baza) |
| Baza „polska” / duża | Własna, 91% rynku | OFF + import PL + restauracje + crowdsourcing |
| Potrawy z restauracji | Tak (sieci) | Tak – rozszerzone „Na mieście” z bazy dań |
| Kalorie/makro na 100 g | Tak | Tak |
| Dodawanie produktu przez użytkownika | Prawdopodobnie | Tak – „Dodaj do bazy” gdy brak w OFF |
| Nutri-Score | Prawdopodobnie | Tak (z OFF lub obliczony) |
| Ostatnio używane produkty | — | Tak (przewaga) |
| Eksport / otwarte dane | — | Możliwość udostępnienia zbioru (np. CC) (przewaga) |

---

## 5. Podsumowanie

- **Darmowo:** OFF (wyszukiwanie + skan), własna baza w Supabase, import z OFF, restauracje z oficjalnych PDF/CSV, crowdsourcing.  
- **Pierwszy krok:** wyszukiwanie po nazwie przez OFF + nowa opcja „Wyszukaj produkt” w „Dodaj posiłek”.  
- **Dalszy rozwój:** tabela `products` w Supabase, import OFF (Polska), rozbudowa „Na mieście” o bazy restauracji, dodawanie produktów przez użytkowników.  
- Dzięki temu baza może być **co najmniej tak dobra jak Fitatu** (wyszukiwanie + skan + restauracje), a z czasem **lepsza** (ostatnio używane, crowdsourcing, otwarte dane).
