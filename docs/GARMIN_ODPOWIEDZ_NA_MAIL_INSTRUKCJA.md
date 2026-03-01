# Odpowiedź na maila Garmin – instrukcja krok po kroku

**Odniesienie:** Pełny mail od **Marc Lussi (Developer Program)**, 27 Feb 2026 – „Please respond to **this ticket** by providing **screenshots of your evaluation app, per API requested**, to complete verification.” Załącznik: **Garmin_Developer_API_Brand_Guidelines.pdf**.

Cel: **wdrożyć integrację z Garmin w wersji produkcyjnej** – żeby wniosek przeszedł.

Poniżej: **co zrobić**, **gotowy mail do skopiowania**, **numerowana lista screenshotów** (w mailu odnosisz się do nich np. „See screenshot 1”) oraz **branding Garmin – jak wdrożyć, jeśli trzeba**. Wszystkie punkty z maila (Technical Review, Team Members and Account Set up, UX and Brand Compliance) są uwzględnione w szablonie odpowiedzi.

---

## CZĘŚĆ A: Co musisz zrobić (kolejność)

### Krok 1: Partner Verification (testy techniczne)

1. Wejdź na **https://apis.garmin.com/tools/partnerVerification** (zalogowany tym samym kontem co aplikacja Łatwa Forma).
2. Sprawdź, czy **wszystkie testy są zielone**:
   - Endpoint Setup Test  
   - Endpoint Coverage Test  
   - Active User Test (minimum 2 użytkowników z danymi w ostatnich 24 h)
3. Jeśli któryś jest czerwony – zrób to, co w `docs/GARMIN_PORTAL_I_TESTY.md` i `docs/GARMIN_PARTNER_VERIFICATION_KROKI.md` (odłączenie/połączenie Garmin, synchronizacja, odczekanie, Refresh Tests).
4. **Zrób screenshot całego ekranu Partner Verification**, gdzie widać **wszystkie testy zielone**. To będzie **Screenshot 1**.

### Krok 2: API Blog i konto

1. Zapisz się na **API Blog email** Garmin (link w portalu / Start Guide), żeby dostawać informacje o zmianach.
2. W portalu Garmin (Section 4 Start Guide) upewnij się, że **wszyscy upoważnieni użytkownicy** są dodani do konta.
3. Upewnij się, że do kontaktu/udostępniania danych z Garmin używasz **adresu w domenie** (np. **norbert.wroblewski@latwaforma.pl**), a nie gmail/outlook ani support@/info@ jako jedynego konta do danych.

### Krok 3: Screenshoty do maila (numeracja 1–6)

Garmin prosi o **screenshots of your evaluation app, per API requested** – czyli dla każdego API, z którego korzystasz (u Ciebie: **Health API** i **Activity API**), trzeba pokazać, jak dane z tego API wyświetlają się w aplikacji. Poniższe ujęcia to robią (Integracje + lista aktywności = Activity/Health w UI). Zrób dokładnie te ujęcia (pełny ekran albo wyraźny fragment). W mailu będziesz pisał np. „See screenshot 1”, „Screenshot 2 shows…”.

| Nr | Co zrobić | Opis dla Garmin (możesz skopiować do maila) |
|----|-----------|---------------------------------------------|
| **1** | Partner Verification – cały ekran z **wszystkimi testami zielonymi** (Endpoint Setup, Endpoint Coverage, Active User). | „Screenshot 1: Partner Verification – all tests green (Endpoint Setup, Endpoint Coverage, Active User).” |
| **2** | Aplikacja Łatwa Forma – ekran **Integracje** (Profil → Integracje): widać sekcję **Garmin Connect**, przycisk „Połącz z Garmin Connect” lub „Odłącz Garmin”, krótki opis o aktywnościach z Garmin. | „Screenshot 2: Integrations screen – Garmin Connect section, connect/disconnect and description.” |
| **3** | Aplikacja – **lista aktywności** (Aktywności), gdzie widać **co najmniej jedną aktywność z Garmin** (nazwa z „(Garmin)” lub ikona). | „Screenshot 3: Activities list showing Garmin-sourced activity with attribution (Garmin).” |
| **4** | Strona **polityki prywatności**: fragment mówiący o **Garmin Connect** i przetwarzaniu danych (np. sekcja integracje). URL w kadrze lub w opisie: `https://latwaforma.pl/polityka-prywatnosci.html`. | „Screenshot 4: Privacy policy excerpt – Garmin Connect and data usage (same domain).” |
| **5** | **API Configuration** w Garmin Developer Portal: fragment z **Callback URL** `https://latwaforma.pl/api/garmin` i włączonymi endpointami (Activities, Deregistrations, User Permissions). | „Screenshot 5: API Configuration – callback URL and enabled endpoints.” |
| **6** | (Opcjonalnie) Ekran **po powrocie z autoryzacji Garmin** (np. garmin-callback lub ekran Integracje z komunikatem sukcesu). Albo drugi użytkownik z „data uploaded” – jeśli chcesz podkreślić Active User Test. | „Screenshot 6: Post-authorization flow / second user with data (optional).” |

Zapisz pliki jako **Screenshot_1.png**, **Screenshot_2.png** itd. (albo 1.png, 2.png). W mailu załączysz je i opiszesz numerami.

### Krok 4: Atrybucja / branding (zgodnie z PDF Garmin_Developer_API_Brand_Guidelines.pdf)

Z treści **Garmin_Developer_API_Brand_Guidelines.pdf** (załącznik do maila) wynika m.in.:

- **Authenticating applications:** Używać pełnej nazwy aplikacji (np. „Garmin Connect”), nie skracać ani nie stylizować.
- **Title-level / primary displays:** Przy danych z urządzeń Garmin atrybucja „Garmin [device model]” lub „Garmin” (gdy model nieznany), **bezpośrednio pod lub obok** tytułu widoku, **above the fold**, nie w tooltipach ani stopkach rozwijanych.
- **Sample messaging (acceptable):** „This chart was created using data provided by Garmin devices.”, „Activity data provided by Garmin devices.”, „Insights derived in part from Garmin device-sourced data.”
- **Downstream and exported data:** W eksportach (CSV, PDF) atrybucja **przy danych** i na każdej stronie; w API/webhookach odbierający system ma zachować atrybucję.
- **Combined or derived data:** Gdy dane Garmin są łączone z innymi źródłami – Garmin jako odrębne lub współtworzące źródło.

**W aplikacji Łatwa Forma jest już wdrożone:**

- **Integracje (Profil):** pełna nazwa „Garmin Connect”, opis + tekst **„Activity data provided by Garmin devices.”** (zgodnie z sample messaging z PDF).
- **Lista aktywności:** przy każdej aktywności z Garmin nazwa zawiera „(Garmin)”; **nad listą** (gdy jest jakakolwiek aktywność z Garmin) wyświetlany jest tekst **„Activity data provided by Garmin.”** – above the fold, przy danych.
- **Eksport CSV:** nagłówek sekcji aktywności z komentarzem „Activity data may include data provided by Garmin devices.” (gdy są takie aktywności); kolumna **„Źródło danych”** z wartością „Garmin” przy aktywnościach z Garmin.
- **Eksport PDF:** pod tabelą aktywności (gdy są z Garmin) dopisana linia: **„Activity data may include data provided by Garmin devices.”**

**Nie musisz** dodawać logo Garmin w UI, jeśli w PDF nie ma takiego obowiązku – atrybucja tekstowa jest spełniona. Jeśli w wytycznych jest wymóg logo, wykonaj Krok 5.

**Jeśli aktywności z Garmin się nie pojawiają w aplikacji:**  
Wejdź w **Profil → Integracje**. Przy sekcji Garmin Connect, jeśli widać żółty/pomarańczowy komunikat *„Aktywności mogą się nie pojawiać – brak zapisanego ID Garmin”*, kliknij **„Uzupełnij dane do odbierania aktywności”**. To zapisze w bazie Twoje Garmin User ID, dzięki czemu push z Garmin będzie mapowany na Twoje konto. Po tym nowe treningi (zsynchronizowane z Garmin Connect) powinny się pojawiać w aplikacji. Upewnij się też, że w Netlify (Functions → garmin) są ustawione zmienne **SUPABASE_URL** i **SUPABASE_SERVICE_ROLE_KEY**.

### Krok 5: Logo Garmin (tylko jeśli wymagane w wytycznych)

1. Wejdź na **developerportal.garmin.com** → znajdź **GCDP Branding Assets v2** (lub API Brand Guidelines).
2. Pobierz **oficjalne logo** Garmin Connect (format i rozmiar podane w wytycznych – często PNG, max 300×300 px dla „branding image” w formularzu).
3. W projekcie:
   - Umieść plik np. w `web/` (np. `web/garmin-connect-logo.png`) albo w `assets/` i udostępnij pod publicznym URL (np. `https://latwaforma.pl/garmin-connect-logo.png`).
   - Na ekranie **Integracje** obok tekstu „Garmin Connect” możesz dodać ten obrazek (np. w Flutter: `Image.network('https://latwaforma.pl/garmin-connect-logo.png', width: 32, height: 32)` albo plik z assets). Nie powiększaj ani nie zniekształcaj logo – zgodnie z wytycznymi.
4. Po wdrożeniu zrób **dodatkowy screenshot** ekranu Integracje z logo i dołącz do odpowiedzi jako uzupełnienie Screenshot 2.

Jeśli w wytycznych **nie ma** obowiązku logo w samej aplikacji (tylko w formularzu „Branding image” w portalu), ten krok możesz pominąć.

---

## CZĘŚĆ B: Gotowy mail do skopiowania (Reply do Garmin)

Skopiuj poniższy tekst, wklej w odpowiedzi na ticket/maila od Garmin. Uzupełnij **[Twoje imię]** i ewentualnie dopisz jedno zdanie, jeśli coś się zmieniło. Załącz **Screenshot_1** … **Screenshot_5** (i opcjonalnie 6) z opisami jak w tabeli powyżej.

---

**Subject:** Re: Production application access – Łatwa Forma – verification completed

Dear Garmin team,

We are responding to this ticket by providing screenshots of our evaluation app **per API requested** (Health API and Activity API) to complete verification. Below is our confirmation for all points in your email.

**1. Technical Review (Partner Verification Tool)**

- **APIs in use:** Health API and Activity API. We do **not** use Training API or Courses API (no screenshot for Training/Courses).
- **Authorization:** We have at least two Garmin Connect users with authorization; both have had data uploaded in the last 24 hours (see Partner Verification – **Screenshot 1**).
- **User Deregistration and User Permission endpoints:** Enabled and handled on our callback `https://latwaforma.pl/api/garmin` (deregistrations and userPermissionsChange in the same endpoint). **Screenshot 5** shows our API Configuration with this callback URL and enabled endpoints.
- **PING/PUSH (no PULL-only):** We process PING and PUSH notifications on `https://latwaforma.pl/api/garmin`. We do not rely on PULL-only; we receive activity data via PUSH to this callback and process it. We return **HTTP 200** asynchronously within 30 seconds (immediate 200 response, processing in background) for all received data, in line with the payload requirements.
- **Screenshot 1** shows Partner Verification with all tests green (Endpoint Setup, Endpoint Coverage, Active User).

**2. Team Members and Account Setup**

- We have signed up for the API Blog email to be informed of future changes.
- All authorized users have been added to the account as per Section 4 of the Start Guide.
- We use company-domain email (e.g. @latwaforma.pl) for this account and for sharing data with/via the API; we do not use generic (support@, info@, etc.) or freemail accounts for that purpose.
- We do not use third-party integrator accounts; no NDA attachment is applicable.

**3. UX and Brand Compliance Review**

- **Where Garmin data and branding appear:**  
  - Integrations screen (Profil → Integracje): Garmin Connect section, connect/disconnect button, short description (**Screenshot 2**).  
  - Activities list: activities from Garmin are shown with “(Garmin)” attribution (**Screenshot 3**).  
  - Privacy policy: we describe Garmin Connect integration and data use, with link to Garmin privacy policy (**Screenshot 4**).  
  - Callback page title: “Garmin → Łatwa Forma” for the OAuth return flow.
- We have reviewed the **API BRAND GUIDELINES** (GCDP Branding Assets v2, including the attached Garmin_Developer_API_Brand_Guidelines.pdf, pages 2 and 4) and applied the required attribution for Garmin data in the app (e.g. “(Garmin)” for activities, “Garmin Connect” in the integration section). We do not mischaracterize Garmin; the UX flow is: user connects Garmin in Integrations → activities are received via PUSH and displayed in the Activities list with attribution.

Please find attached **Screenshots 1–5** (and 6 if provided) of our evaluation app as referenced above, per API requested. We are ready to proceed to production and would appreciate your confirmation or any further steps required.

Best regards,  
**[Twoje imię]**

---

Po wklejeniu maila **załącz pliki** Screenshot_1.png … Screenshot_5.png (i ewentualnie 6). W treści już są odwołania (Screenshot 1, 2, 3…), więc support wie, który obrazek do czego się odnosi.

---

## CZĘŚĆ C: Szybka checklist przed wysłaniem

- [ ] Wszystkie testy w Partner Verification zielone (Screenshot 1).
- [ ] Zapisany na API Blog; authorized users dodani; konto w domenie @latwaforma.pl.
- [ ] Screenshoty 1–5 (i ewentualnie 6) zrobione i zapisane.
- [ ] W aplikacji: atrybucja dla Garmin („(Garmin)”, „Garmin Connect”) – już jest; ewentualnie jedna formuła z API BRAND GUIDELINES dopisana (ekran Integracje lub aktywności).
- [ ] Mail skopiowany, **[Twoje imię]** uzupełnione, screenshoty załączone.
- [ ] Odpowiedź wysłana na ten sam ticket / adres, z którego przyszedł mail od Garmin.

---

## Zweryfikowane punkty z maila Marca Lussiego (27.02.2026)

| Punkt w mailu | W instrukcji / w szablonie odpowiedzi |
|---------------|--------------------------------------|
| 1. Technical: APIs tested/in use | ✓ Health API, Activity API; Training/Courses – nie używane |
| 1. Technical: ≥2 Garmin Connect users | ✓ Screenshot 1 (Partner Verification) |
| 1. Technical: User Deregistration & User Permission endpoints | ✓ Callback /api/garmin, Screenshot 5 |
| 1. Technical: PING/PUSH (no PULL-only) | ✓ Opis w mailu + zwrot 200 |
| 1. Technical: HTTP 200 async within 30 s | ✓ Opis w mailu |
| 1. Technical: Training/Courses screenshot | ✓ „We do not use” – brak screenshotu |
| 2. Team: API Blog signed up | ✓ W mailu |
| 2. Team: Authorized users added (Section 4) | ✓ W mailu |
| 2. Team: No generic/freemail for data | ✓ @latwaforma.pl |
| 2. Team: Third-party / NDA | ✓ Nie dotyczy, brak NDA |
| 3. UX/Brand: All instances of Garmin data | ✓ Lista + Screenshots 2, 3, 4 |
| 3. UX/Brand: Trademarks, logos, brand elements | ✓ Opis + zgodność z wytycznymi |
| 3. UX/Brand: Required attribution statements | ✓ Zgodnie z API BRAND GUIDELINES (PDF, str. 2 i 4) |
| 3. UX/Brand: Complete UX flow, no mischaracterization | ✓ Opis flow w mailu |
| Respond to this ticket, screenshots per API requested | ✓ Pierwsze zdanie maila + załączone Screenshots 1–5(6) |

*Dokument przygotowany na podstawie pełnego maila od Marc Lussi (Garmin Connect Partner Services), załącznik Garmin_Developer_API_Brand_Guidelines.pdf, oraz dokumentacji w repo.*
