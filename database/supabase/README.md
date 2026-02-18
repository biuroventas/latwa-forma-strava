# Supabase Database Setup

Ten katalog zawiera schemat bazy danych i migracje dla aplikacji Łatwa Forma.

## Instalacja

1. Zaloguj się do Supabase Dashboard
2. Przejdź do SQL Editor
3. Wykonaj pliki w następującej kolejności:
   - `schema.sql` - tworzy tabele i indeksy
   - `rls_policies.sql` - włącza Row Level Security i tworzy polityki
   - `migration_add_weekly_weight_change.sql` - dodaje kolumnę weekly_weight_change (jeśli nie została dodana w schema.sql)

## Struktura bazy danych

### Tabele:
- `profiles` - profil użytkownika z danymi i obliczeniami
- `meals` - posiłki użytkownika
- `activities` - aktywności fizyczne
- `water_logs` - logi wypitej wody
- `weight_logs` - logi wagi
- `body_measurements` - pomiary ciała
- `favorite_meals` - ulubione posiłki/przepisy
- `streaks` - serie codziennych aktywności

## Bezpieczeństwo

Wszystkie tabele mają włączone Row Level Security (RLS), co oznacza, że każdy użytkownik widzi tylko swoje dane.
