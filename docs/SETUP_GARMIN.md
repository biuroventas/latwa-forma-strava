# Integracja Garmin Connect – konfiguracja krok po kroku

Aplikacja Łatwa Forma ma już gotowy kod integracji z Garmin (OAuth 2.0 PKCE, import aktywności). Żeby działała, musisz założyć aplikację w Garmin Developer Portal i dodać klucze do projektu.

---

## 1. Dostęp do portalu (masz już z maila)

- **Portal:** https://developerportal.garmin.com/
- **Login:** `norbert.wroblewski@latwaforma.pl` (wpisywać ręcznie, case sensitive).
- Ustaw pierwsze hasło przez link z maila od Garmin („click HERE”).

Na razie masz **Evaluation Environment** (środowisko testowe). Produkcja będzie po osobnej weryfikacji – do rozwoju i testów Evaluation wystarczy.

---

## 2. Utworzenie aplikacji w portalu

1. Zaloguj się na https://developerportal.garmin.com/
2. W **Overview** kliknij niebieski link **„creating apps”** (albo w menu po lewej: **Apps** → Create / Add app).
3. Wypełnij formularz – **gotowe wartości do skopiowania** masz w pliku **`docs/GARMIN_WARTOSCI_DO_FORMULARZA.md`** (nazwa, opis, Privacy Policy URL, Redirect URL).
4. Zapisz aplikację. W portalu dostaniesz:
   - **Consumer Key** → w projekcie = `GARMIN_CLIENT_ID`
   - **Consumer Secret** → w projekcie = `GARMIN_CLIENT_SECRET`

W dokumentacji Garmin „Consumer Key” = `client_id`, „Consumer Secret” = `client_secret` w żądaniach OAuth.

---

## 3. Konfiguracja w projekcie Łatwa Forma

### 3.1 Plik `.env` (lokalnie i ewentualnie na CI)

W katalogu głównym projektu w pliku `.env` dodaj (bez commitu – `.env` jest w `.gitignore`):

```env
# Garmin Connect
GARMIN_CLIENT_ID=twój_consumer_key_z_portalu
GARMIN_CLIENT_SECRET=twój_consumer_secret_z_portalu
```

**Redirect URI:**

- Dla **aplikacji mobilnej** nie musisz nic ustawiać – domyślnie używane jest `latwaforma://garmin-callback`.
- Dla **aplikacji web** ustaw w `.env`:

```env
GARMIN_REDIRECT_URI=https://latwaforma.pl/garmin-callback.html
```

(Aplikacja wdrażana jest tylko na latwaforma.pl – **dokładnie ten sam URL** wpisz w Garmin Developer Portal jako Redirect URL.)

### 3.2 Build web (produkcja)

Przy budowaniu wersji web (`scripts/prepare_latwaforma_pl.sh`) zmienne `GARMIN_CLIENT_ID`, `GARMIN_CLIENT_SECRET` i opcjonalnie `GARMIN_REDIRECT_URI` są kopiowane z `.env` do `env.production` i do `build/web`, tak aby aplikacja web miała do nich dostęp. Upewnij się, że w `.env` (lub w zmiennych na Netlify/CI) są ustawione przed buildem.

### 3.2 Edge Function (wymiana tokenów na stronie)

Na **stronie** (przeglądarka) bezpośredni POST do Garmin jest blokowany przez CORS. Wymiana kodu na tokeny odbywa się więc przez **Supabase Edge Function** `garmin_exchange_code`.

1. **Wdróż funkcję:**  
   `supabase functions deploy garmin_exchange_code`

2. **Ustaw sekrety** w Supabase (Dashboard → Edge Functions → garmin_exchange_code → Secrets albo przez CLI):  
   - `GARMIN_CLIENT_ID` = Consumer Key z portalu  
   - `GARMIN_CLIENT_SECRET` = Consumer Secret  
   - `GARMIN_REDIRECT_URI` = `https://latwaforma.pl/garmin-callback.html` (opcjonalnie, domyślnie ten URL)

Bez wdrożonej funkcji i sekretów „Połącz z Garmin” na stronie zakończy się błędem typu „Failed to fetch” przy wymianie kodu.

---

## 4. Callback na stronie (web)

Plik `web/garmin-callback.html` jest w repozytorium i przy buildzie trafia do `build/web`. Deploy idzie na latwaforma.pl (Netlify), więc callback jest pod `https://latwaforma.pl/garmin-callback.html`. Skrypt na tej stronie przekazuje `code` do SPA (`/#/integrations?garmin_code=...`) lub do aplikacji mobilnej przez deep link `latwaforma://garmin-callback?...`.

---

## 5. Sprawdzenie działania

1. **Lokalnie (mobile):**  
   Uruchom aplikację, wejdź w **Profil** → **Integracje** → **Połącz z Garmin Connect**. Powinno otworzyć się Garmin, po autoryzacji przekierowanie z powrotem do aplikacji i zapis tokenów.

2. **Web:**  
   Otwórz aplikację pod adresem, dla którego ustawiłeś `GARMIN_REDIRECT_URI` i Redirect URL w portalu. Po kliknięciu „Połącz z Garmin Connect” po autoryzacji użytkownik wróci na `garmin-callback.html`, a stamtąd na `/#/integrations?garmin_code=...` – aplikacja wymieni kod na tokeny.

3. **Synchronizacja:**  
   Po połączeniu użyj przycisku „Synchronizuj aktywności”. **Garmin Health API udostępnia dane tylko z ostatnich 7 dni** (polityka retencji) – synchronizacja pobiera aktywności z tego okresu.

---

## 6. Gdy coś nie działa

- **„Garmin nie jest skonfigurowane”** – brak `GARMIN_CLIENT_ID` lub `GARMIN_CLIENT_SECRET` w załadowanym env (sprawdź `.env` lokalnie, `env.production` / zmienne builda na web).
- **Błąd redirect_uri / invalid redirect** – w Garmin Developer Portal w ustawieniach aplikacji Redirect URL musi być **identyczny** z tym, którego używa aplikacja (w tym protokół, domena, ścieżka). Dla web – ten sam co `GARMIN_REDIRECT_URI`.
- **Evaluation vs produkcja** – na razie używaj tylko Evaluation; użycie aplikacji eval w produkcji komercyjnej może skutkować wyłączeniem. Po uzyskaniu dostępu do produkcji załóż osobną aplikację w portalu i wpisz nowe Consumer Key/Secret do konfiguracji produkcyjnej.
- **InvalidPullTokenException / Invalid Pull Token** – Zgodnie z odpowiedzią Garmin (Developer Program): przy **PING** token do pull jest **w body powiadomienia PING** i musi być przekazany **w URL** przy wywołaniu API; statyczny Consumer Pull Token z portalu nie wystarcza. Przy **PUSH** nie wywołuj pull – dane przychodzą w POST na Twój URL (patrz sekcja 9). U nas: Endpoint Configuration ustawiona na **PUSH** → dane w body POST → zapis w `netlify/functions/garmin.js`.
- **Data Viewer / sync zwraca puste** – jeśli w Data Viewerze (healthapi.garmin.com/tools/dataViewer) dla Twojego User ID w zakresie 7 dni pojawia się „Could not find data”, to samo API używa Łatwa Forma przy synchronizacji; sync nie będzie miał czego pobrać. W środowisku **Evaluation** dane mogą być udostępniane z opóźnieniem lub tylko przez **Push** (webhook). Warto odczekać 24–48 h po skonfigurowaniu Endpoint Configuration albo skontaktować się z Garmin (Support w portalu).

---

## 7. Endpoint Coverage Test (CONSUMER_PERMISSIONS, USER_DEREG)

W Garmin Developer Portal test **Endpoint Coverage Test** wymaga, żeby w ciągu **24 h** na adres **https://latwaforma.pl/api/garmin** trafiły dane dla **każdego** włączonego summary domain (**CONSUMER_PERMISSIONS** – push, **USER_DEREG** – ping). Netlify Function `netlify/functions/garmin.js` zwraca `200 OK` na GET i POST.

- **Deploy endpointu:** Wdraża się **wyłącznie przy deployu z Gita** (Netlify buduje z `netlify.toml` i wgrywa też `netlify/functions`). Ręczne wgrywanie tylko folderu `build/web` (np. skrypt `deploy_site_netlify.sh`) **nie** wgrywa funkcji – wtedy POST od Garmin (CONSUMER_PERMISSIONS) dostaje **404**. Żeby endpoint był na żywo: **push do repozytorium** i poczekaj na build w Netlify.
- Po wdrożeniu: `curl -I https://latwaforma.pl/api/garmin` → powinno być `200`.
- W portalu Garmin w **API Configuration** / **Endpoint Configuration** ustaw **Callback URL** na `https://latwaforma.pl/api/garmin`.

---

## 8. Test produkcyjny (Partner Verification) – jak przejść

Strona: **Partner Verification** w Garmin (np. `apis.garmin.com/tools/partnerVerification` lub z menu w Developer Portal).

### Co musi być zielone

- **Endpoint Setup Test** – zwykle zielony, jeśli Callback URL jest ustawiony i endpoint zwraca 200.
- **Endpoint Coverage Test** – wymaga, żeby **w ostatnich 24 godzinach** Garmin **wysłał** do Twojego URL przynajmniej jedno żądanie dla **każdego** włączonego summary domain. Komunikat *„1 enabled summary domain(s) without data in the last 24 hours”* oznacza, że dla jednej z domen (np. USER_DEREG lub CONSUMER_PERMISSIONS) w tym oknie nie było żadnego ruchu.

### Kroki, żeby Endpoint Coverage Test przeszedł

1. **Upewnij się, że endpoint żyje**  
   - Deploy Netlify **z Gita** (nie tylko `deploy_site_netlify.sh`), żeby wgrać `netlify/functions/garmin.js`.  
   - Sprawdź: `curl -I https://latwaforma.pl/api/garmin` → `200 OK`.  
   - W portalu Garmin: **API Configuration** → Callback URL = `https://latwaforma.pl/api/garmin`.

2. **Wyślij ruch z Garmina na swój URL (trigger webhooków)**  
   Garmin liczy „data” tylko wtedy, gdy **on** wyśle request do Twojego URLa.  
   - **USER_DEREG (ping):** Wejdź w **Garmin Connect** (connect.garmin.com lub aplikacja) → Ustawienia konta / Connected Apps. Znajdź **Łatwa Forma** i **odłącz** / usuń dostęp. Garmin powinien wysłać ping na `https://latwaforma.pl/api/garmin`. Potem możesz z powrotem połączyć Łatwa Forma.  
   - **CONSUMER_PERMISSIONS (push):** Zazwyczaj wysyłany przy **pierwszej autoryzacji**. Wykonaj **„Połącz z Garmin Connect”** w aplikacji (latwaforma.pl) i dokończ OAuth – to może wygenerować push na Twój callback.

3. **Poczekaj i odśwież test**  
   Test sprawdza ruch w ostatnich 24 h. Po wykonaniu kroków odczekaj (nawet kilka godzin) i w **Partner Verification** kliknij **Refresh Tests**. Gdy obie domeny miały ruch, **Endpoint Coverage Test** powinien być zielony.

4. **Apply for Production Key**  
   Gdy **All Tests** są zielone, użyj **Apply for Production Key** i dokończ weryfikację zgodnie z instrukcjami Garmin.

### „Could not find corresponding ping request” (pull notifications) – wszystkie rekordy na czerwono

W **Pull Test** każdy wiersz to **pull** = żądanie pobrania danych (np. wywołanie Garmin API po aktywności). **„Corresponding ping”** = wcześniejsze powiadomienie (ping), które Garmin **wysłał** na Twój backchannel (`https://latwaforma.pl/api/garmin`), zanim ten pull się pojawił.

**Dlaczego u nas wszystkie pull-e są „bez pingu”:** W Łatwej Formie użytkownik klika **„Synchronizuj aktywności”** → aplikacja (lub Edge Function) **od razu** wywołuje Garmin Health API (GET activities). To jest **pull** inicjowany przez nas. Garmin **nie wysyła** wcześniej pinga na nasz URL, bo to my sami odpytujemy API. Dlatego przy każdym takim pullu Garmin nie ma „corresponding ping request” i pokazuje błąd. To **zachowanie oczekiwane** przy tym modelu (sync na żądanie użytkownika).

**Kiedy byłby „corresponding ping”:** Gdyby najpierw użytkownik zsynchronizował zegarek z Garmin Connect i pojawiły się nowe dane → Garmin mógłby wysłać **ping** (POST) na `https://latwaforma.pl/api/garmin` → wtedy kolejny pull mógłby mieć ten ping przypisany. Przy samym kliku „Synchronizuj” w aplikacji pingu nie ma.

**Co zrobić:** Endpoint musi zwracać **200** i minimalne JSON (np. `{}`) na POST – tak jest w `netlify/functions/garmin.js`. Żeby zobaczyć, czy Garmin w ogóle wysyła pingi: **Netlify → Functions → garmin → Logs**. Jeśli po zsynchronizowaniu zegarka z Garmin Connect pojawią się wpisy „Garmin backchannel POST: ping”, backchannel działa; Pull Test nadal może pokazywać błąd dla pulli wywołanych przyciskiem „Synchronizuj”.

### Jeśli nadal „without data in the last 24 hours“

- W Netlify (Functions → garmin) sprawdź logi – czy są wywołania z ostatnich 24 h.
- W portalu Garmin upewnij się, że wymagane summary domains mają ten sam Callback URL.

---

## 9. Tryb Push zamiast Pull (unikanie InvalidPullTokenException)

Jeśli synchronizacja przez **Pull** (przycisk „Synchronizuj”) zwraca **InvalidPullTokenException**, możesz przejść na **Push**: Garmin sam wysyła dane aktywności na `https://latwaforma.pl/api/garmin`, a Netlify Function zapisuje je do Supabase.

**Kroki:**

1. **Migracja i zapis Garmin User ID**  
   - Wdróż migrację `20250225000001_garmin_user_id_for_push.sql` (kolumna `garmin_integrations.garmin_user_id`).  
   - Po połączeniu konta Garmin aplikacja zapisuje `garmin_user_id` (albo uzupełnia go przy pierwszej synchronizacji).  
   - Istniejący użytkownik: niech raz kliknie „Synchronizuj” – w tle uzupełnimy `garmin_user_id`.

2. **W portalu Garmin (Endpoint Configuration)**  
   - Dla domen związanych z aktywnościami (np. **ACTIVITY_DETAIL**, **ACTIVITY_FILE_DATA**) ustaw **Upload Type** na **push** (zamiast ping).  
   - Callback URL bez zmian: `https://latwaforma.pl/api/garmin`.

3. **Netlify – zmienne środowiskowe**  
   W ustawieniach funkcji (lub Site → Environment variables) ustaw:  
   - `SUPABASE_URL` = URL projektu Supabase (np. `https://xxx.supabase.co`)  
   - `SUPABASE_SERVICE_ROLE_KEY` = klucz service role (Supabase → Settings → API)  
   Bez tych zmiennych endpoint nadal zwróci 200 dla Garmin, ale aktywności z push nie będą zapisywane do bazy.

4. **Deploy**  
   Wgraj zmiany (w tym `netlify/functions/garmin.js`) przez **push do Gita**, żeby Netlify zbudował i wgrał funkcję.

Po przełączeniu na push **przycisk „Synchronizuj”** nadal wywołuje Pull (może dalej zwracać błąd). Aktywności będą jednak dopisywane automatycznie, gdy Garmin wyśle push (np. po synchronizacji zegarka z Garmin Connect).

**Z GCDP Start Guide (Garmin):** Dostęp do API jest **server-to-server**; „ad-hoc requests for data are not permitted” – dane przychodzą wyłącznie przez webhook (PING lub PUSH). **Support GCDP (2026):** *„We are webhooks based API only. All data pushed to you via PUSH or PING notification.”* **Security review:** *„During security review, we would not be able to reach your endpoints.”* – dopóki nowa domena/URL jest w security review (zwykle 24–48 h, Start Guide 2.6.1), Garmin **nie wysyła** PING/PUSH na ten adres; po przejściu review powiadomienia wznawiają się. Endpoint **deregistration** wysyła `{"deregistrations":[{"userId":"..."}]}` gdy użytkownik odłączy app w Garmin Connect; **userPermissionsChange** – gdy użytkownik zmieni uprawnienia (np. wyłączy eksport). Nasza funkcja obsługuje oba i zapisuje aktywności z push `activities`.

**Z Activity API spec:** Push `activities` ma pole **activeKilocalories** (kcal z urządzenia) – używamy go w zapisie. Activity Files tylko przez PING. Backfill (apis.garmin.com/tools) – ponowne wysłanie powiadomień za zakres dat. Production: min. 2 użytkowników, HTTP 200 w 30 s, PING/PUSH.

**Z FAQ Garmin:**  
*„Data will be removed from the Health API, Activity API, and Women's Health API in seven days after it is initially uploaded by a user device sync to Garmin Connect or when the user removes their consent to share their data with the partner, whichever comes first. The removed data is then considered historical and may be reloaded through the Backfill process.”*  
Czyli: dane w API dostępne **7 dni** od syncu (albo do momentu wycofania zgody); potem tylko przez **Backfill**.

**Kiedy przychodzą nowe dane (FAQ Garmin):**  
*„The Health API, Activity API, and Women's Health API deliver data via PING or PUSH notifications as soon as a user syncs their device or uploads new data. This is described in Ping Service and Push Service chapters of the REST API specification.”*  
Czyli: PING/PUSH jest wysyłany **zaraz po** syncu urządzenia z Garmin Connect lub po ręcznym uploadzie – szczegóły w specyfikacji (Ping Service, Push Service).

**Przejście na produkcję (FAQ Garmin):**  
*„The first consumer key generated through the Developer Portal is an evaluation key. This key is rate-limited and should only be used for testing, evaluation, and development. To obtain a production-level key that is not rate-limited, your integration must be verified using the Partner Verification Tool or be reviewed by Garmin for approval, depending on the API(s) included in your integration. Please refer to documentation for specific steps on obtaining a production-level key.”*  
Czyli: pierwszy klucz = **Evaluation**, z limitami; klucz produkcyjny (bez limitów) po weryfikacji przez **Partner Verification Tool** albo po recenzji Garmin – w zależności od API. Kroki: dokumentacja + sekcja 8 (Partner Verification) w tym pliku.

**Kalorie (FAQ Garmin):**  
*„Garmin's activity tracker products track calories throughout the day. This includes calories burned while at rest (BMR) as well as calories burned from being active. Garmin's fitness products only capture and display calories for being active. Calories can be viewed by users on Garmin Connect and these will correspond to what is captured and displayed by the devices.”*  
Czyli: **activity trackery** (np. Vivoactive) = BMR + active; **fitness products** (np. zegarki do treningu) = tylko **active**. W API (np. activeKilocalories) zwykle dostajemy kcal z aktywności; jeśli użytkownik porównuje z Garmin Connect, liczby mogą się różnić w zależności od typu urządzenia.

**Czas lokalny (FAQ Garmin):**  
*„Each summary contains a local time offset in seconds. This offset can be used with the summary start time to calculate the local start and end times as they appear to the user in Garmin Connect. These offsets are calculated by a combination of device time, user's Garmin Connect time-zone preference, and a reconciliation algorithm used to smooth data into a continuous stream when the user crosses time-zone boundaries within the summary's time range.”*  
W praktyce: **local time = startTimeInSeconds + startTimeOffsetInSeconds** (w sekundach); offset pochodzi z czasu urządzenia, ustawienia strefy w Garmin Connect i algorytmu przy przekraczaniu granic stref.

### Odpowiedź Garmin (Developer Program, 2026-02-26)

> Pull token is provided in the **PING** notification. Pull token must be included in the **URL** you are calling to get data.  
> I see that your webhooks are set for **PUSH** notifications – data will be provided via HTTP POST and be included in the body. Why are you trying to pull data?

**Wnioski:** Przy **PUSH** nie używamy pull – dane są w body POST. Przy **PING** token do pull nie jest stałym CPT z portalu, tylko pochodzi z **każdego powiadomienia PING** (w body) i musi być przekazany w URL przy wywołaniu API.

- W razie wątpliwości: **Garmin Developer Support** (Support w portalu lub connect-support@developer.garmin.com).

**Z OAuth2 PKCE spec:** Przy „Odłącz Garmin” aplikacja wywołuje DELETE `https://apis.garmin.com/wellness-api/rest/user/registration` (z tokenem użytkownika), potem usuwa wpis z naszej bazy. Refresh token ważny do **3 miesięcy**; dokładny timestamp wygaśnięcia jest w odpowiedzi OAuth2 (drugi krok flow, gdy token został utworzony). Przy problemach z OAuth2: connect-support@developer.garmin.com. Zalecane odjęcie 600 s od expires_in przy odświeżaniu access tokena.

**Testowanie push (forum GCDP):** Żeby wywołać push z **pełnymi danymi** (np. konkretne pola) do testów: użyj narzędzia **Summary Resender** (apis.garmin.com/tools) – *„You can use Summary resender to resend existing summary for the user.”* – zamiast polegać tylko na Data Generator lub jednorazowym syncu z aplikacji.

---

## 9. Przydatne linki

- [Garmin Developer Portal](https://developerportal.garmin.com/)
- [Connect Developer API – overview](https://developerportal.garmin.com/developer-programs/connect-developer-api)
- [Programs Docs (OAuth, API)](https://developerportal.garmin.com/developer-programs/programs-docs) – m.in. OAuth 2.0 PKCE
- W projekcie: `lib/shared/services/garmin_service.dart` – logika OAuth i Wellness API
