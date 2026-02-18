# Łatwa Forma

Aplikacja do śledzenia kalorii, makroskładników i aktywności fizycznej.

## Funkcjonalności

### Podstawowe
- ✅ Ekran powitalny z logo i informacjami
- ✅ Onboarding (płeć, wiek, wzrost, waga, cel, aktywność)
- ✅ Automatyczne obliczenia: BMR, TDEE, makroskładniki, szacowany termin
- ✅ Dashboard z podsumowaniem dziennym i kalendarzem tygodniowym
- ✅ Makroskładniki na dashboardzie (włączane/wyłączane, preferencja zapisywana)

### Posiłki
- ✅ Dodawanie: ręczne, składniki, kod kreskowy (Open Food Facts), AI ze zdjęcia (OpenAI Vision)
- ✅ „Jem na mieście” – szybkie szacowanie kalorii (pizza, burger, chińczyk itd.)
- ✅ Ulubione posiłki – zapis i szybkie dodawanie do wybranego dnia
- ✅ Lista posiłków z nawigacją dni, date picker, edycja i usuwanie

### Aktywności
- ✅ Dodawanie spalonych kalorii (ręcznie)
- ✅ Integracja ze Strava – import treningów
- ✅ Integracja z Garmin Connect – import aktywności
- ✅ Lista aktywności z nawigacją dni, date picker, edycja i usuwanie

### Woda
- ✅ Śledzenie z szybkimi przyciskami (100, 200, 250, 500 ml) i własną ilością
- ✅ Cel wody z profilu (water_goal_ml)
- ✅ Przegląd dowolnego dnia – edycja i usuwanie wpisów z przeszłości
- ✅ Nawigacja dni i date picker

### Waga i pomiary
- ✅ Śledzenie wagi z wykresem i historią
- ✅ Pomiary ciała z wykresami i historią

### Profil i ustawienia
- ✅ Profil użytkownika z edycją danych
- ✅ Powiadomienia – przypomnienia o wodzie i posiłkach (konfigurowalne godziny)
- ✅ Integracje Strava i Garmin w profilu
- ✅ Eksport danych – CSV (pełne dane) lub PDF (raport z ostatnich 30 dni)

### Statystyki i cele
- ✅ Statystyki – wykresy, weryfikacja celu, podsumowanie tygodnia
- ✅ Serie (streaks) – dostęp z poziomu Statystyk
- ✅ Cele i wyzwania – śledzenie postępów (waga, deficyt, woda, treningi, seria)
- ✅ Porada AI – zapytania o dietę (limit dzienny)

## Wymagania

- Flutter SDK (3.10.4 lub nowszy)
- Konto Supabase
- Klucze API (opcjonalnie: OpenAI dla analizy zdjęć)

## Instalacja

1. Sklonuj repozytorium lub pobierz pliki projektu

2. Zainstaluj zależności:
```bash
flutter pub get
```

3. Skonfiguruj zmienne środowiskowe:
   - Skopiuj `.env.example` do `.env`
   - Wypełnij klucze API:
     ```
     SUPABASE_URL=...
     SUPABASE_ANON_KEY=...
     OPENAI_API_KEY=...          # opcjonalnie (analiza zdjęć AI)
     STRAVA_CLIENT_ID=...        # opcjonalnie
     STRAVA_CLIENT_SECRET=...
     STRAVA_REDIRECT_URI=...     # np. GitHub Pages callback
     GARMIN_CLIENT_ID=...        # opcjonalnie
     GARMIN_CLIENT_SECRET=...
     GARMIN_REDIRECT_URI=...
     ```

4. Skonfiguruj bazę danych Supabase:
   - Zaloguj się do Supabase Dashboard
   - Uruchom migracje z folderu `supabase/migrations/` (w kolejności dat)

## Uruchomienie

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

### Web
```bash
flutter run -d chrome
```

## Struktura projektu

```
lib/
├── main.dart
├── core/
│   ├── config/          # Konfiguracja API, Supabase
│   ├── router/          # Nawigacja (go_router)
│   ├── theme/           # Kolory, style, dark mode
│   ├── utils/           # Funkcje pomocnicze, obliczenia, streak_updater
│   └── constants/       # Stałe aplikacji
├── features/
│   ├── onboarding/      # Ekran powitalny + onboarding
│   ├── dashboard/       # Strona główna z kalendarzem
│   ├── meals/           # Posiłki (dodawanie, lista, AI, kod, ulubione)
│   ├── activities/      # Aktywności (dodawanie, lista)
│   ├── water/           # Śledzenie wody
│   ├── weight/          # Śledzenie wagi
│   ├── body_measurements/ # Pomiary ciała
│   ├── profile/         # Profil użytkownika, eksport
│   ├── statistics/      # Statystyki, serie
│   ├── challenges/      # Cele i wyzwania
│   ├── integrations/    # Strava, Garmin Connect
│   └── notifications/   # Ustawienia przypomnień
├── shared/
│   ├── models/          # Modele danych
│   ├── services/        # Supabase, Strava, Garmin, OpenAI, Open Food Facts
│   └── widgets/         # Komponenty współdzielone
├── strava_redirect/     # Strony OAuth (GitHub Pages)
└── supabase/migrations/ # Migracje bazy danych
```

## Obliczenia

Aplikacja automatycznie oblicza:
- **BMR** (Basal Metabolic Rate) - wzór Harris-Benedict
- **TDEE** (Total Daily Energy Expenditure) - na podstawie poziomu aktywności
- **Makroskładniki** - białko, tłuszcze, węglowodany
- **Szacowany termin** - czas do osiągnięcia celu

## Planowane funkcje / Do zrobienia

- **Subskrypcja (Free/Premium)** – model płatności, rozgraniczenie funkcji
- **Logowanie social (Google, Apple)** – opcjonalnie, szybsze zakładanie konta
- **Apple Health / Google Fit** – synchronizacja danych (opcjonalnie)

## Licencja

Prywatny projekt - wszystkie prawa zastrzeżone.
