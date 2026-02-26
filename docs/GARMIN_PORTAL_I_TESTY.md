# Garmin Developer Portal – co ustawić, żeby przejść testy i dostać produkcję

## Gdzie wchodzić (zakładki w portalu)

1. **developerportal.garmin.com** → zaloguj się.
2. **Apps** (menu) → wybierz aplikację Łatwa Forma.
3. **API Configuration** (lub **API Access** / **Endpoint Configuration**) – tu ustawiasz callback i typy powiadomień.
4. **Partner Verification** – tu są testy i przycisk **Apply for Production Key**.

---

## Co poustawiać (API Configuration / Endpoint Configuration)

- **Callback URL** (dla każdej domeny): dokładnie  
  `https://latwaforma.pl/api/garmin`  
  (bez slash na końcu, bez literówek.)

- **Upload Type** dla domen aktywności: **PUSH** (nie ping).  
  Łatwa Forma odbiera tylko PUSH (POST z danymi w body).

- **USER_DEREG**: zwykle **PING** – Garmin wyśle ping, gdy użytkownik odłączy app w Garmin Connect.

---

## Co wyłączyć (żeby łatwiej przejść testy)

**Endpoint Coverage Test** wymaga ruchu w **ostatnich 24 h** dla **każdej włączonej** domeny. Im mniej domen włączonych, tym mniej musisz „obsłużyć”.

- Wejdź w **API Configuration** → sekcja z **Summary Domains** / **Endpoint Configuration**.
- **Wyłącz** domeny, których nie potrzebujesz:
  - Łatwa Forma korzysta z **aktywności** (jeden typ PUSH wystarczy).
  - Możesz **zostawić włączone** np. **ACTIVITY_DETAIL** (lub inny jeden typ push aktywności, który masz w dokumentacji) + **USER_DEREG** (ping przy odłączeniu).
  - **Wyłącz** np. ACTIVITY_FILE_DATA, AUTO_ACTIVITY_MOVEIQ, GC_ACTIVITY_UPDATE, jeśli nie są Ci potrzebne – wtedy test wymaga ruchu tylko dla tych, co zostawisz.

Po wyłączeniu niepotrzebnych domen zapisz zmiany. **Refresh Tests** w Partner Verification będzie wymagał ruchu tylko dla domen nadal włączonych.

---

## Kolejność: od konfiguracji do produkcji

1. **Endpoint Setup Test (zielony)**  
   Callback URL = `https://latwaforma.pl/api/garmin`, deploy Netlify z Gita (funkcja `garmin` wdrożona).  
   Sprawdzenie: `curl -I https://latwaforma.pl/api/garmin` → `200 OK`.

2. **Endpoint Coverage Test (zielony)**  
   W ostatnich 24 h Garmin musi wysłać na ten URL przynajmniej jedno żądanie **dla każdej** włączonej domeny:
   - **USER_DEREG:** odłącz Łatwa Forma w Garmin Connect (Connected Apps), potem ewentualnie połącz ponownie.
   - **Domeny aktywności (PUSH):** połącz Łatwa Forma z Garmin w aplikacji, zarejestruj aktywność na zegarku, zsynchronizuj z Garmin Connect; poczekaj (minuty–godziny), sprawdź logi Netlify (Functions → garmin).

3. **Refresh Tests** w **Partner Verification** – po odczekaniu (kilka godzin / do 24 h) kliknij odśwież. Gdy oba testy zielone → **Apply for Production Key** i dokończ proces w portalu.

---

## Jeśli Coverage dalej czerwony

- **Netlify → Functions → garmin → Logs:** czy w ostatnich 24 h są POSTy od Garmin.
- **Security review:** po dodaniu/zmianie domeny Garmin przez 24–48 h może nie wysyłać requestów; po tym czasie spróbuj ponownie odłączyć/połączyć i odświeżyć test.
- **Mail do Garmin (Support w portalu):** szablon w `docs/GARMIN_PARTNER_VERIFICATION_KROKI.md` – pytanie, czy USER_DEREG i push aktywności w Evaluation są wysyłane i po jakich akcjach.
