# Instrukcja konfiguracji Supabase

## ✅ Krok 1: Plik .env - GOTOWE

Plik `.env` został już utworzony z Twoimi kluczami API.

## 📋 Krok 2: Utwórz tabele w bazie danych

### Opcja A: Przez Supabase Dashboard (zalecane)

1. **Otwórz Supabase Dashboard:**
   - Przejdź do: https://supabase.com/dashboard/project/tslsayftpegpliihfmyg
   - Zaloguj się do swojego konta

2. **Otwórz SQL Editor:**
   - W menu po lewej stronie kliknij ikonę bazy danych (SQL Editor)
   - Kliknij przycisk **"New query"**

3. **Wykonaj pierwszy skrypt (schema.sql):**
   - Skopiuj całą zawartość pliku `database/supabase/schema.sql`
   - Wklej do edytora SQL w Supabase
   - Kliknij **"Run"** (lub naciśnij Ctrl+Enter / Cmd+Enter)
   - Poczekaj na komunikat "Success"

4. **Wykonaj drugi skrypt (rls_policies.sql):**
   - Kliknij **"New query"** ponownie
   - Skopiuj całą zawartość pliku `database/supabase/rls_policies.sql`
   - Wklej do edytora SQL
   - Kliknij **"Run"**
   - Poczekaj na komunikat "Success"

5. **Sprawdź, czy tabele zostały utworzone:**
   - W menu po lewej kliknij **"Table Editor"**
   - Powinieneś zobaczyć tabele: `profiles`, `meals`, `activities`, `water_logs`, `weight_logs`, `body_measurements`, `favorite_meals`, `streaks`

### Opcja B: Przez Supabase CLI (dla zaawansowanych)

Jeśli masz zainstalowany Supabase CLI:

```bash
supabase db push
```

## ✅ Krok 3: Sprawdź konfigurację

Uruchom aplikację:

```bash
flutter run
```

Jeśli wszystko działa poprawnie, powinieneś zobaczyć ekran powitalny aplikacji!

## 🔍 Rozwiązywanie problemów

### Błąd: "Supabase URL and Anon Key must be provided"

- Sprawdź, czy plik `.env` istnieje w głównym folderze projektu
- Sprawdź, czy klucze są poprawne (bez dodatkowych spacji)

### Błąd: "relation does not exist"

- Upewnij się, że wykonałeś oba pliki SQL (schema.sql i rls_policies.sql)
- Sprawdź w Table Editor, czy tabele istnieją

### Błąd połączenia z Supabase

- Sprawdź, czy projekt Supabase jest aktywny
- Sprawdź, czy klucze API są poprawne w pliku .env

## 📝 Notatki

- **Row Level Security (RLS)** jest włączone - każdy użytkownik widzi tylko swoje dane
- **Anon key** jest bezpieczny do użycia w aplikacji mobilnej
- Wszystkie tabele mają automatyczne indeksy dla lepszej wydajności
