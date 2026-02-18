# Jak uruchomić logowanie e-mailem (instrukcja krok po kroku)

Jeśli użytkownicy dostają maila z linkiem, ale po kliknięciu widzą „witryna nieosiągalna” — trzeba to skonfigurować. Poniżej instrukcja dla osób bez technicznego doświadczenia.

**Bonus:** Jeśli włączysz kod 6-cyfrowy (Krok 0), użytkownicy mogą zalogować się także gdy otworzą maila na innym urządzeniu – wpisują kod w aplikacji na telefonie.

---

## Krok 0 (opcjonalnie): Kod 6-cyfrowy dla logowania na innym urządzeniu

Jeśli chcesz, aby użytkownik mógł zalogować się bez klikania linku (np. gdy otworzy maila na laptopie):

1. Wejdź na **supabase.com** → swój projekt.
2. **Authentication** → **Email Templates**.
3. Otwórz szablon **Magic Link**.
4. W treści maila dopisz (np. na początku lub obok linku):

   ```
   Twój kod logowania: {{ .Token }}
   ```

5. Zapisz. W mailu będzie zarówno link, jak i 6-cyfrowy kod. Użytkownik może wpisać kod w aplikacji, jeśli nie może kliknąć linku.

### Cały mail po polsku

W **Authentication** → **Email Templates** → **Magic Link** możesz podmienić całą treść na polską:

**Temat (Subject):**
```
Zaloguj się do Łatwa Forma
```

**Treść (Message body):**
```
Cześć!

Oto Twój link do logowania w aplikacji Łatwa Forma:

{{ .ConfirmationURL }}

Jeśli czytasz maila na innym urządzeniu (np. komputerze), możesz wpisać ten kod w aplikacji na telefonie:

Twój kod logowania: {{ .Token }}

(Uwaga: niektóre szablony Supabase mogą wysyłać kod o innej długości niż 6 cyfr – aplikacja akceptuje pełny kod z maila.)

Link i kod ważne są przez ograniczony czas.

—
Łatwa Forma
```

Zapisz zmiany. Mail będzie po polsku i zawierał zarówno link, jak i kod.

**Uwaga:** Informacja o sprawdzeniu folderu Spam jest wyświetlana w aplikacji po kliknięciu „Wyślij link oraz kod” – tak aby użytkownik wiedział, gdzie szukać, gdy nie widzi maila. W treści samego maila nie ma sensu dopisywać „jeśli nie widzisz tej wiadomości sprawdź spam” – czytający mail oczywiście go widzi.

### Jak zrobić entery (nowe linie) w treści maila

Edytor Supabase może wyświetlać treść jako jeden ciąg znaków. Możesz wstawić nowe linie na dwa sposoby:

1. **Znak nowej linii** – wpisz `\n` (backslash + n) tam, gdzie ma być enter, np.:
   ```
   Cześć!\n\nOto Twój link...
   ```

2. **Tagi HTML** – użyj `<br>` lub `<br/>`:
   ```
   Cześć!<br><br>Oto Twój link...
   ```

3. **Enter w edytorze** – część pól w Dashboardzie akceptuje zwykły Enter podczas pisania (choć po zapisaniu może wyglądać jak jeden ciąg – wysłany mail i tak zachowa podziały linii).

### Inne maile (używane przy „Zapisz postępy” z emailem)

Gdy użytkownik wybiera „Kontynuuj z emailem” w „Zapisz postępy”, Supabase wysyła mail z potwierdzeniem. Możesz go zmienić na polski:

**Confirm signup** (potwierdzenie rejestracji / łączenia konta):

- **Subject:** `Potwierdź swój adres e-mail – Łatwa Forma`
- **Message body:**
```
Cześć!

Aby zapisać swoje postępy w aplikacji Łatwa Forma, potwierdź adres e-mail:

{{ .ConfirmationURL }}

Kod (gdy czytasz maila na innym urządzeniu): {{ .Token }}

—
Łatwa Forma
```

**Change email address** (zmiana adresu e-mail):

- **Subject:** `Potwierdź nowy adres e-mail – Łatwa Forma`
- **Message body:**
```
Cześć!

Potwierdź zmianę adresu e-mail na {{ .NewEmail }}:

{{ .ConfirmationURL }}

Kod (gdy czytasz maila na innym urządzeniu): {{ .Token }}

—
Łatwa Forma
```

**Invite user** (zaproszenie – używane przy „Zaproś znajomego”):

- **Subject:** `Zostałeś zaproszony do Łatwa Forma`
- **Message body:**
```
Cześć!

Zostałeś zaproszony do aplikacji Łatwa Forma. Kliknij link, aby założyć konto:

{{ .ConfirmationURL }}

Kod (gdy czytasz maila na innym urządzeniu): {{ .Token }}

—
Łatwa Forma
```

---

## Krok 0c: Jak uruchomić „Zaproś znajomego”

**W skrócie:** Zrób 3 rzeczy: wgraj funkcję w terminalu, dodaj adres w Supabase, ustaw treść maila po polsku.

---

**1. Wgraj funkcję na Supabase**

Otwórz terminal w folderze projektu (tam gdzie jest plik `pubspec.yaml`) i wpisz:
```
supabase functions deploy invite_user
```
Jeśli nie masz Supabase CLI – zainstaluj go albo użyj Supabase Dashboard: Project Settings → Edge Functions → Deploy.

**2. Adres przekierowania**

Ten sam adres co dla magic link musi być w Supabase:
- Supabase → Authentication → URL Configuration → Redirect URLs
- Powinna być linia: `https://biuroventas.github.io/latwa-forma-strava/auth_redirect/`
- Jeśli jej nie ma – dodaj ją i zapisz.

**3. Mail z zaproszeniem po polsku**

- Supabase → Authentication → Email Templates → **Invite user**
- Wklej temat i treść po polsku z sekcji „Inne maile” powyżej.

---

## Krok 1: Skopiuj plik na GitHub

1. Otwórz folder z projektem **Łatwa Forma** na komputerze.
2. Znajdź plik:
   ```
   web/auth_redirect/index.html
   ```
3. Otwórz w przeglądarce stronę **GitHub** (github.com) i zaloguj się.
4. Wejdź w repozytorium **latwa-forma-strava** (to samo, które używasz dla Strava).
5. **Dodaj plik na GitHub**:
   - Kliknij „Add file” → „Create new file”
   - W polu „Name your file” wpisz: `auth_redirect/index.html` (GitHub utworzy folder automatycznie)
   - Otwórz na komputerze plik `web/auth_redirect/index.html` (np. w Notatniku)
   - Zaznacz całą zawartość (Ctrl+A), skopiuj (Ctrl+C)
   - Wklej zawartość do edytora na stronie GitHub (Ctrl+V)
   - Na dole strony kliknij zielony przycisk „Commit changes”

   **Jeśli masz Git na komputerze**: możesz po prostu skopiować cały folder `web/auth_redirect/` do repozytorium latwa-forma-strava i zrobić commit + push.

6. Po zapisaniu Twoja strona będzie pod adresem:
   ```
   https://biuroventas.github.io/latwa-forma-strava/auth_redirect/
   ```
   (Jeśli używasz innej nazwy użytkownika/repozytorium, zamień `biuroventas` i `latwa-forma-strava` na swoje).

---

## Krok 2: Ustaw adres w pliku .env

1. W folderze projektu otwórz plik **.env** (np. w Notatniku albo Cursor).
2. Sprawdź, czy jest tam linia:
   ```
   EMAIL_AUTH_REDIRECT_URL=https://biuroventas.github.io/latwa-forma-strava/auth_redirect/
   ```
3. Jeśli jej nie ma — dodaj ją na końcu pliku.
4. Jeśli używasz innego adresu GitHub Pages — wpisz tam swój adres.
5. Zapisz plik.

---

## Krok 3: Dopisz adres w Supabase

1. Wejdź na stronę **supabase.com** i zaloguj się.
2. Otwórz swój projekt (Łatwa Forma).
3. W menu po lewej wybierz **Authentication**.
4. Kliknij **URL Configuration**.
5. W sekcji **Redirect URLs** dodaj nową linię:
   ```
   https://biuroventas.github.io/latwa-forma-strava/auth_redirect/
   ```
   (Użyj tego samego adresu co w kroku 2.)
6. Kliknij **Save** / **Zapisz**.

---

## Krok 4: Zweryfikuj, czy działa

1. Uruchom aplikację Łatwa Forma.
2. Wybierz „Mam już konto” i wpisz swój adres e-mail.
3. Sprawdź skrzynkę (także folder „Spam”) i kliknij link w mailu.
4. Powinieneś zobaczyć stronę „Otwieram Łatwa Forma...” — po chwili otworzy się aplikacja i zalogujesz się automatycznie.

---

## Jeśli coś nie działa

- **Link nadal prowadzi do „witryna nieosiągalna”** — sprawdź, czy adres z kroków 1–3 jest wszędzie identyczny (bez literówek, z `https://`).
- **Mail nie przychodzi** — sprawdź folder Spam i poczekaj kilka minut (Supabase ma limit wysyłki).
- **Strona się nie otwiera** — sprawdź, czy plik `index.html` jest w repo w folderze `auth_redirect/` i czy GitHub Pages jest włączone w ustawieniach repozytorium.

---

## Skrót (dla przypomnienia)

1. Wrzuć `auth_redirect/index.html` na GitHub (repo latwa-forma-strava).
2. W pliku `.env` dodaj `EMAIL_AUTH_REDIRECT_URL` z adresem tej strony.
3. W Supabase → Authentication → URL Configuration dopisz ten sam adres do Redirect URLs.
4. Wyślij nowy mail z linkiem i przetestuj logowanie.
