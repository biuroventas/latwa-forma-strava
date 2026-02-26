# Garmin Partner Verification – jak przejść Endpoint Coverage Test

Żeby **Apply for Production Key** było aktywne, wszystkie testy muszą być zielone. Endpoint Setup Test masz już zielony; **Endpoint Coverage Test** wymaga, żeby w **ostatnich 24 h** Garmin **wysłał** na `https://latwaforma.pl/api/garmin` przynajmniej jedno żądanie dla **każdej** z włączonych domen.

U Ciebie brakuje ruchu dla 5 domen:
- **ACTIVITY_DETAIL** (push)
- **ACTIVITY_FILE_DATA** (push)
- **AUTO_ACTIVITY_MOVEIQ** (push)
- **GC_ACTIVITY_UPDATE** (push)
- **USER_DEREG** (ping)

---

## Co zrobić po swojej stronie

### 1. Sprawdź, że endpoint działa
```bash
curl -I https://latwaforma.pl/api/garmin
```
Oczekiwane: `200 OK`.  
W Netlify → Functions → garmin → Logi możesz potem zobaczyć, czy przychodzą POSTy od Garmin.

### 2. USER_DEREG (ping) – możesz wywołać sam
- Wejdź na **Garmin Connect** (connect.garmin.com lub aplikacja).
- Ustawienia konta → **Connected Apps** (lub podobna sekcja).
- Znajdź **Łatwa Forma** i **odłącz** / usuń dostęp.
- Garmin *powinien* wysłać **ping** na `https://latwaforma.pl/api/garmin`.
- Potem z powrotem **połącz** Łatwa Forma w aplikacji (latwaforma.pl) – żeby konto było znowu połączone.

**Jeśli po odłączeniu status USER_DEREG nadal się nie zieleni:**

1. **Sprawdź logi Netlify** – zaraz po odłączeniu Łatwa Forma w Garmin Connect:
   - Netlify → **Functions** → **garmin** → **Logs** (lub Deploys → ostatni deploy → Function log).
   - Szukaj wpisu `[Garmin] POST received` z tego momentu.
   - **Jeśli nie ma żadnego POSTa** w chwili odłączenia → Garmin **nie wysyła** requestu na nasz URL. Możliwe przyczyny: w Evaluation USER_DEREG nie jest wysyłany; w portalu wpisany inny callback URL; inna aplikacja (inny Consumer Key).
   - **Jeśli POST jest** → wtedy problemem może być format odpowiedzi (mało prawdopodobne, bo zwracamy 200 + JSON). W logu zobaczysz `body keys:` i `preview:` – możesz to przekazać do Garmin.

2. **Zweryfikuj URL w portalu Garmin**  
   W **Endpoint Configuration** dla **USER_DEREG** musi być *dokładnie*:
   - `https://latwaforma.pl/api/garmin`  
   (bez końcowego slasha, bez literówki, ta sama domena co w pozostałych domenach.)

3. **Zapytaj Garmin w mailu** (ważne):  
   *„We disconnect our app (Łatwa Forma) in Garmin Connect multiple times but see no HTTP request in our endpoint logs for USER_DEREG. Our callback URL is exactly https://latwaforma.pl/api/garmin. Is USER_DEREG ping sent in the Evaluation environment, or only after production verification?“*

### 3. Domeny aktywności (push) – ACTIVITY_DETAIL, ACTIVITY_FILE_DATA, AUTO_ACTIVITY_MOVEIQ, GC_ACTIVITY_UPDATE
Garmin wysyła push, gdy **po jego stronie** pojawią się nowe dane (np. zsynchronizowana aktywność). W praktyce:

1. **Konto połączone** – w Łatwej Formie (latwaforma.pl) musisz mieć **Połącz z Garmin Connect** zrobione (OAuth), żeby Garmin wiedział, gdzie wysyłać dane.
2. **Nowa aktywność** – zarejestruj aktywność (np. bieg, spacer) na **urządzeniu Garmin** lub w **Garmin Connect** (ręczne dodanie).
3. **Synchronizacja** – zsynchronizuj zegarek/urządzenie z Garmin Connect (aplikacja Garmin Connect lub connect.garmin.com), żeby aktywność trafiła do Garmin.
4. **Czekaj** – Garmin może wysłać push z opóźnieniem (minuty do kilku godzin). W **Netlify → Functions → garmin → Logs** zobaczysz, czy przyszły POSTy z `activities` w body.

W środowisku **Evaluation** Garmin nie zawsze wysyła push dla wszystkich typów od razu. Jeśli mimo powyższych kroków przez 24–48 h nie ma ruchu dla domen aktywności, warto **napisać do Garmin** (szablon poniżej) i zapytać, jakie dokładnie akcje użytkownika w Evaluation wywołują push dla ACTIVITY_DETAIL / ACTIVITY_FILE_DATA / AUTO_ACTIVITY_MOVEIQ / GC_ACTIVITY_UPDATE.

### 4. Odśwież test
- Po wykonaniu kroków odczekaj **kilka godzin** (lub do 24 h).
- W **Partner Verification** kliknij **Refresh Tests**.
- Gdy dla każdej domeny był ruch w ostatnich 24 h, **Endpoint Coverage Test** powinien być zielony.

### 5. Apply for Production Key
Gdy **All Tests** są zielone, kliknij **Apply for Production Key** i dokończ proces w portalu.

---

## Szablon maila do Garmin (odpowiedź na wiadomość Eleny)

Możesz odpisać na ostatniego maila (Elena Kononova, Developer Program), np. tak:

---

**Subject:** Re: InvalidPullTokenException / Partner Verification – PUSH setup, Endpoint Coverage Test

Hello Elena,

Thank you for the clarification about Pull token in PING and about our webhooks being set for PUSH – we are not calling the pull API; we only receive data via HTTP POST on our callback URL (https://latwaforma.pl/api/garmin). Our endpoint returns 200 and processes the body when present.

We would like to complete **Partner Verification** and apply for the Production Key. Our **Endpoint Setup Test** is green. The **Endpoint Coverage Test** is still red: we see “5 enabled summary domain(s) without data in the last 24 hours” for:

- ACTIVITY_DETAIL (push)  
- ACTIVITY_FILE_DATA (push)  
- AUTO_ACTIVITY_MOVEIQ (push)  
- GC_ACTIVITY_UPDATE (push)  
- USER_DEREG (ping)

We have:
- Connected our app via OAuth and have our callback URL set to https://latwaforma.pl/api/garmin for all these domains.
- For USER_DEREG we can trigger a ping by disconnecting the app in Garmin Connect.

Could you please advise:
1. **USER_DEREG (ping):** We disconnect our app (Łatwa Forma) in Garmin Connect (Connected Apps) multiple times but see **no HTTP request** in our endpoint logs at that moment. Our callback URL is exactly https://latwaforma.pl/api/garmin. Is the USER_DEREG ping sent in the **Evaluation** environment at all, or only after production verification?
2. What exact user actions (in the Evaluation environment) trigger Garmin to send **PUSH** notifications for the activity-related domains (ACTIVITY_DETAIL, ACTIVITY_FILE_DATA, AUTO_ACTIVITY_MOVEIQ, GC_ACTIVITY_UPDATE)? For example: after we record an activity on a Garmin device and sync with Garmin Connect, should we expect a POST to our callback within 24 hours?
3. Is there any delay or limitation in Evaluation that might prevent these notifications from being sent for a few days after endpoint configuration?

Thank you for your help.

Best regards,  
[Twoje imię]

---

Po ich odpowiedzi dopasujesz kroki (np. „nagraj aktywność i zsynchronizuj w ciągu X godzin”) i ewentualnie ponowisz odłączanie/łączenie dla USER_DEREG i odświeżysz test.
