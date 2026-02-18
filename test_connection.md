# Test połączenia z Supabase

## Sprawdź logi aplikacji

Po uruchomieniu aplikacji (`flutter run`), sprawdź logi w konsoli. Powinieneś zobaczyć:

- ✅ `.env załadowany z głównego folderu`
- ✅ `Inicjalizacja Supabase z URL: https://tslsayftpegpliihfmyg.supabase.co`
- ✅ `Supabase zainicjalizowane pomyślnie`

LUB

- ❌ Błędy z opisem problemu

## Możliwe problemy:

### 1. Plik .env nie jest ładowany
**Rozwiązanie:** Sprawdź czy plik `.env` jest w głównym folderze projektu (tam gdzie `pubspec.yaml`)

### 2. Supabase projekt jest wstrzymany
**Rozwiązanie:** 
- Otwórz https://supabase.com/dashboard/project/tslsayftpegpliihfmyg
- Sprawdź czy projekt jest aktywny
- Jeśli jest wstrzymany, wznow go

### 3. Błąd połączenia sieciowego
**Rozwiązanie:**
- Sprawdź połączenie internetowe
- Sprawdź czy firewall nie blokuje połączenia

### 4. Problem z platformą Web
**Rozwiązanie:** Na web, plik .env musi być w assets. Skopiuj `.env` do `assets/.env`

## Szybki test:

Uruchom aplikację i sprawdź logi:
```bash
flutter run
```

Szukaj w logach:
- `Błąd inicjalizacji Supabase`
- `Supabase zainicjalizowane pomyślnie`
