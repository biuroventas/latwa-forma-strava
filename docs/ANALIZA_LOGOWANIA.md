# Analiza funkcji logowania – Łatwa Forma

## Obecne przepływy (flow)

### 1. Nowy użytkownik – „Zaczynamy”

- **Welcome** → `signInAnonymously` → **Onboarding** → zapis profilu → **Plan Loading** → **Dashboard**
- ✅ Działa poprawnie

### 2. Powracający użytkownik – „Mam już konto” – Google

- **Welcome** → `signInWithGoogle` → Safari → logowanie → powrót deep link
- Router: `auth/callback` → redirect na **Splash**
- **Splash** (2 s opóźnienia) → profil istnieje → **Dashboard** + SnackBar „Zalogowano pomyślnie!”
- ✅ Działa poprawnie

### 3. Powracający użytkownik – „Mam już konto” – Email (magic link)

- **Welcome** → `signInWithEmail` → wysłanie linku → SnackBar „Sprawdź skrzynkę…”
- Użytkownik klika link w mailu → strona HTTPS → `latwaforma://` → aplikacja
- Router → **Splash** → **Dashboard**
- ⚠️ Brak SnackBara „Zalogowano pomyślnie!” po magic link (bo splash nie rozróżnia OAuth vs magic link – oba mają sesję)

### 4. Zapisz postępy – łączenie konta (Google / Email)

- **Dashboard** (anonimowy, ≥5 posiłków) → modal „Zapisz postępy” → Google/Email
- **Email już zarejestrowany** → dialog „Wyloguj i zaloguj się” → **Welcome**
- ✅ Działa poprawnie po ostatnich poprawkach

### 5. Wylogowanie

- **Profil** → Wyloguj → **Welcome**
- ✅ Działa

---

## Zidentyfikowane problemy i propozycje

### 🔴 1. Splash – stałe 2 sekundy opóźnienia

**Problem:** Każde uruchomienie aplikacji pokazuje splash przez 2 sekundy, nawet gdy użytkownik ma szybkie połączenie i profil ładuje się w 0,2 s.

**Propozycja:** Skrócić do 1 s lub użyć warunku: jeśli profil załadowany w &lt; 1 s, przejdź od razu; w przeciwnym razie pokaż splash min. 0,8 s (żeby nie migało).

---

### 🟡 2. Welcome – brak loading przy „Mam już konto” → Email

**Problem:** Po wpisaniu emaila i kliknięciu „Wyślij link” nie ma żadnego wskaźnika ładowania – użytkownik nie wie, czy coś się dzieje.

**Propozycja:** Pokazać krótki loading (np. CircularProgressIndicator w dialogu lub przycisku) podczas wysyłania maila.

---

### 🟡 3. Welcome – obsługa błędów w „Mam już konto”

**Problem:** `_runSignIn` nie obsługuje `suggestSignOutAndLogin` ani `suggestTryBrowser`. Te flagi są używane tylko w Save Progress, ale `signInWithEmail`/`signInWithGoogle` rzadko je zwracają. Dla spójności warto jednak sprawdzać te flagi.

**Status:** Na welcome użytkownik zwykle nie ma sesji, więc `suggestSignOutAndLogin` nie powinien się pojawić. Niski priorytet.

---

### 🟡 4. Welcome – komunikat po magic link

**Problem:** Po kliknięciu „Wyślij link” użytkownik widzi SnackBar i zostaje na Welcome. Może być niejasne, że ma teraz przejść do aplikacji mailowej.

**Propozycja:** Rozszerzyć komunikat: „Wysłaliśmy link na {email}. Przejdź do skrzynki (również spam), kliknij link i wróć do aplikacji.”

---

### 🔴 5. Splash – brak SnackBara po magic link

**Problem:** Po logowaniu przez magic link użytkownik trafia na Splash → Dashboard. Splash pokazuje „Zalogowano pomyślnie!” tylko gdy `!(user?.isAnonymous ?? true)`. Dla magic link `user` nie jest anonimowy – więc SnackBar **powinien** się pokazać. Warto zweryfikować w praktyce.

---

### 🟡 6. Duplikacja logiki (Email dialog, run flow)

**Problem:** Podobna logika w `save_progress_checker` i `welcome_screen`: dialog z email, uruchomienie flow, obsługa rezultatu.

**Propozycja:** Wyciągnąć wspólny komponent/serwis – zmniejszy to duplikację i ułatwi utrzymanie.

---

### 🟡 7. Router – anonimowy użytkownik na `/welcome`

**Problem:** Gdy użytkownik anonimowy ma profil i jest na dashboardzie, może wejść na `/welcome` np. przez deep link lub błąd. Redirect `isLoggedIn && isWelcome` nie przekieruje go, bo `isLoggedIn = !anonymous`.

**Propozycja:** Dodać redirect: jeśli użytkownik ma sesję (łącznie z anonimową) i profil, a jest na `/welcome` → przekieruj na splash/dashboard. Zapobiega to mylącemu widokowi welcome zamiast dashboardu.

---

### 🟢 8. Spójna obsługa błędów

**Status:** `AuthLinkService._formatError` dobrze mapuje typowe błędy na czytelne komunikaty. Rozszerzona o „email już zarejestrowany” i `suggestSignOutAndLogin`.

---

## Wdrożone ulepszenia (2025-02)

1. ✅ **Splash – elastyczny czas** – minimalne 0,8 s, koniec po załadowaniu profilu (zamiast stałych 2 s)
2. ✅ **Welcome – loading przy magic link** – „Wysyłanie linku…” podczas wysyłania maila
3. ✅ **Welcome – doprecyzowany komunikat** – „Przejdź do skrzynki (sprawdź też spam), kliknij link i wróć do aplikacji”
4. ✅ **Router – redirect anonimowego** – anonim na `/welcome` → splash (spójność nawigacji)

## Do rozważenia w przyszłości

- **Refaktor** – wspólna logika dla dialogów email / flow (save_progress vs welcome)
