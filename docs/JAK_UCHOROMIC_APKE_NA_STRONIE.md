# Jak uruchomić aplikację na stronie (app.latwaforma.pl)

Prosta instrukcja krok po kroku.

---

## Co musisz mieć

- W głównym folderze projektu plik **`.env`** z wpisami:
  ```
  SUPABASE_URL=https://twoj-projekt.supabase.co
  SUPABASE_ANON_KEY=twoj_klucz_anon
  ```
- Zainstalowany Flutter na komputerze.

---

## Krok 1: Zbuduj aplikację web

1. Otwórz **terminal**.
2. Wejdź w folder projektu Łatwa Forma (tam gdzie jest `pubspec.yaml`).
3. Wpisz i zatwierdź:
   ```bash
   flutter build web
   ```
4. Poczekaj, aż build się skończy (bez błędów).

---

## Krok 2: Wgraj na Netlify

1. Otwórz w przeglądarce: **https://app.netlify.com/drop**
2. Zaloguj się (lub załóż darmowe konto).
3. Na komputerze otwórz folder projektu → **build** → **web**.
4. **Przeciągnij całą ZAWARTOŚĆ folderu „web”** (wszystkie pliki i foldery wewnątrz) na obszar „Drag and drop” w przeglądarce.
   - Ważne: przeciągaj **zawartość** (index.html, main.dart.js, folder assets itd.), a nie sam folder „web”.
5. Netlify wgra pliki i poda adres typu **nazwa-xyz.netlify.app**. Skopiuj ten adres (bez https://).

---

## Krok 3: Podłącz domenę app.latwaforma.pl (opcjonalnie)

Jeśli chcesz, żeby aplikacja działała pod **app.latwaforma.pl**:

1. W Netlify: **Domain settings** → **Add custom domain** → wpisz **app.latwaforma.pl**.
2. W panelu OVH: **Domeny** → **latwaforma.pl** → **Strefa DNS** → **Dodaj wpis**:
   - Typ: **CNAME**
   - Subdomena: **app**
   - Cel: wklej adres z Netlify (np. **nazwa-xyz.netlify.app**).
3. Zapisz. Po kilku–kilkunastu minutach **https://app.latwaforma.pl** powinno otwierać aplikację.

---

## Sprawdzenie

- Otwórz w przeglądarce adres z Netlify (np. https://nazwa-xyz.netlify.app) albo **https://app.latwaforma.pl** po podpięciu domeny.
- Powinien się pojawić ekran startowy Łatwa Forma (Welcome) z przyciskami „Zaloguj” i „Zacznij bez konta”.
- Jeśli widzisz biały/ pusty ekran: odśwież stronę (Ctrl+F5 / Cmd+Shift+R), wyczyść cache przeglądarki albo sprawdź, czy w Kroku 2 wgrałeś **zawartość** folderu build/web (index.html musi być w głównym katalogu strony).

---

## Gdy coś nie działa

- **„Brak połączenia z serwerem”** na starcie – sprawdź, czy w projekcie (przed `flutter build web`) jest plik **.env** z poprawnymi SUPABASE_URL i SUPABASE_ANON_KEY. Zbuduj ponownie i wgraj jeszcze raz.
- **Strona nie ładuje się** – w OVH sprawdź, czy rekord CNAME dla **app** wskazuje dokładnie na adres z Netlify (bez https://, bez ukośnika na końcu).
