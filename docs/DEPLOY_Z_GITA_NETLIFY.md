# Deploy z Gita na Netlify (bez ręcznego przeciągania)

Po konfiguracji każdy **push** do repozytorium zbuduje aplikację i wgra ją na Netlify.

---

## Krok 1: Inicjalizacja Gita i repozytorium

1. Otwórz **terminal** w folderze projektu (Łatwa Forma).

2. Inicjalizacja i pierwszy commit:
   ```bash
   git init
   git add .
   git commit -m "Pierwszy commit – Łatwa Forma"
   ```

3. Załóż repozytorium na **GitHub** (github.com → New repository). Nazwa np. `latwa-forma`. **Nie** dodawaj README ani .gitignore (masz je w projekcie).

4. Podłącz projekt i wypchnij:
   ```bash
   git remote add origin https://github.com/TWOJ_LOGIN/latwa-forma.git
   git branch -M main
   git push -u origin main
   ```
   (Zamień `TWOJ_LOGIN` na swoją nazwę użytkownika GitHub.)

---

## Krok 2: Zmienne środowiskowe na Netlify

Plik **.env** nie jest w Gicie (jest w .gitignore). Netlify musi mieć te same dane do budowania.

1. Wejdź na **app.netlify.com** → wybierz projekt (app.latwaforma.pl).
2. **Site configuration** (lub **Project configuration**) → **Environment variables** → **Add a variable** / **Add environment variables**.
3. Dodaj:
   - **SUPABASE_URL** = `https://twoj-projekt.supabase.co`
   - **SUPABASE_ANON_KEY** = twój klucz anon (z .env)
4. Zapisz. (Opcjonalnie: **Build** → **Deploy settings** upewnij się, że te zmienne są dostępne przy buildzie.)

---

## Krok 3: Podłączenie repozytorium w Netlify

1. W Netlify: **Site configuration** → **Build & deploy** → **Build settings** (lub **Link repository**).
2. Kliknij **Link repository** / **Connect to Git provider**.
3. Wybierz **GitHub**, zaloguj się jeśli trzeba, wybierz repozytorium **latwa-forma**.
4. Ustawienia builda (powinny się wypełnić z **netlify.toml**):
   - **Build command:** `flutter build web --release`
   - **Publish directory:** `build/web`
   - **Base directory:** zostaw puste
5. Zapisz. Netlify od razu uruchomi **pierwszy build** (może potrwać kilka minut – instalacja Fluttera przez plugin).

---

## Krok 4: Sprawdzenie

- W zakładce **Deploys** zobaczysz status buildu (Building → Published).
- Po sukcesie **https://app.latwaforma.pl** będzie działać z kodu z Gita.

Od teraz: **zmiany w kodzie → commit → push do main** i Netlify sam zbuduje i wgra nową wersję.

---

## Uwagi

- **Gałąź:** Domyślnie Netlify buduje z gałęzi **main**. Możesz to zmienić w Build & deploy → Branch to deploy.
- **Błędy buildu:** W **Deploys** kliknij nieudany deploy → **Deploy log** – zobaczysz błąd (np. brak zmiennych, błąd w Flutterze).
- **.env w Gicie:** Nie commituj pliku **.env** (zawiera klucze). Trzymaj go tylko lokalnie; na Netlify używaj **Environment variables** z Kroku 2.
