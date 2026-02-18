# Stripe – instrukcja krok po kroku (dla laika)

Poniżej masz **konkretne kroki**, co po kolei zrobić, żeby płatności Stripe działały w Łatwej Formie. Wystarczy iść od punktu 1 do końca.

**Kolejność od zera:**  
1) Stripe: konto → produkt + 2 ceny → API key → webhook → signing secret  
2) Supabase: 6 sekretów (klucze i URLe)  
3) Terminal: `supabase functions deploy` (3 funkcje)  
4) Baza: `supabase db push` (jeśli jeszcze nie robione) – albo SQL Editor jak w Kroku 15.

---

## CZĘŚĆ 1: Konto i produkt w Stripe

### Krok 1. Załóż konto Stripe
- Wejdź na **https://stripe.com**
- Kliknij **„Zarejestruj się”** (lub „Sign up”).
- Wypełnij e-mail, hasło i załóż konto. Na start możesz używać **trybu testowego** (testowe płatności, bez prawdziwych pieniędzy).

### Krok 2. Wejdź w panel Stripe
- Zaloguj się na **https://dashboard.stripe.com**
- U góry strony upewnij się, że masz włączony **„Tryb testowy”** (przełącznik „Test mode” / „Tryb testowy”). Na początek zostaw go włączony.

### Krok 3. Utwórz produkt (Premium) z dwoma cennikami
W aplikacji są dwie opcje: **69,98 zł / miesiąc** oraz **194,95 zł / rok**. W Stripe musisz mieć jeden produkt z **dwoma cennikami**.

- W lewym menu kliknij **„Produkty”** („Products”).
- Kliknij **„+ Dodaj produkt”** („+ Add product”).
- **Nazwa produktu:** wpisz **„Łatwa Forma Premium”**.
- **Opis:** np. „Subskrypcja Premium – nieograniczona porada AI, eksport PDF i inne”.
- **Pierwszy cennik (miesięczny):**
  - W sekcji **„Cennik”** wybierz **„Recurring”** (cykliczne), **69,98** PLN, **Miesięcznie** (Monthly).
  - Zapisz produkt („Add product” / „Save product”).
- **Drugi cennik (roczny subskrypcja):**  
  Po zapisaniu produktu wejdź w ten produkt, w sekcji **„Cennik”** kliknij **„Dodaj kolejną cenę”** („Add another price”). Ustaw **194,95** PLN, **Recurring**, **Rocznie** (Yearly). Zapisz.
- **Trzeci cennik (rok jednorazowo – BLIK):**  
  W tym samym produkcie kliknij **„Dodaj kolejną cenę”**. Ustaw **194,95** PLN, **One time** (jednorazowa), waluta PLN. Zapisz – ta cena jest używana przy opcji „Rocznie (jednorazowo)” z BLIKiem.

### Krok 4. Skopiuj trzy Price ID
- W karcie produktu „Łatwa Forma Premium” zobaczysz **trzy cenniki**.
- **Miesięczny (recurring):** kliknij w cenę 69,98 zł / miesiąc. Na górze skopiuj **Price ID** (np. `price_1ABC...`). Zapisz jako **„Price ID miesięczny”**.
- **Roczny (recurring):** kliknij w cenę 194,95 zł / rok (subskrypcja). Skopiuj **Price ID**. Zapisz jako **„Price ID roczny”**.
- **Roczny jednorazowo:** kliknij w cenę 194,95 zł **One time**. Skopiuj **Price ID**. Zapisz jako **„Price ID roczny jednorazowo”** (do BLIK).

### Krok 4a. Metody płatności (karta, BLIK, Apple Pay, Google Pay)
- W Stripe w lewym menu: **Settings** (Ustawienia) → **Payment methods** (Metody płatności).
- Włącz: **Cards** (Visa, Mastercard itd.), **BLIK**, **Apple Pay**, **Google Pay**. BLIK będzie dostępny przy płatności „Rocznie (jednorazowo)” w aplikacji.

### Krok 5. Skopiuj Secret key (klucz API)
- W lewym menu Stripe kliknij **„Developers”** („Programiści”), potem **„API keys”** („Klucze API”).
- Zobaczysz dwa klucze: **Publishable key** (zaczyna się od `pk_`) i **Secret key** (zaczyna się od `sk_test_` w trybie testowym).
- Przy **Secret key** kliknij **„Reveal”** („Pokaż”), żeby zobaczyć cały klucz.
- **Skopiuj cały Secret key** (sk_test_...) i **zapisz w Notatniku** – będzie potrzebny w Supabase. **Nie udostępniaj go nikomu.**

---

## CZĘŚĆ 2: Webhook w Stripe (żeby Stripe „powiedział” Supabase, że ktoś zapłacił)

### Krok 6. Znajdź adres URL swojego projektu Supabase
- Wejdź na **https://supabase.com** i zaloguj się.
- Otwórz **swój projekt** (Łatwa Forma).
- W lewym menu kliknij **ikonę zębatki** (Settings) → **„API”**.
- W sekcji **„Project URL”** zobaczysz adres, np. **`https://abcdefghijk.supabase.co`**.
- **Skopiuj tylko tę część:** `abcdefghijk` (ciąg liter/cyfr przed `.supabase.co`). To jest **Project REF** (identyfikator projektu). Zapisz w Notatniku.

### Krok 7. Dodaj endpoint webhooka w Stripe
- Wróć do Stripe: **Developers** → **„Webhooks”** (w lewym menu).
- Kliknij **„Add endpoint”** („Dodaj endpoint”).
- W polu **„Endpoint URL”** wklej (zamień `TWOJ_PROJECT_REF` na to, co skopiowałeś w kroku 6):
  ```
  https://TWOJ_PROJECT_REF.supabase.co/functions/v1/stripe-webhook
  ```
  Przykład: jeśli Project REF to `tslsayftpegpliihfmyg`, adres będzie:
  ```
  https://tslsayftpegpliihfmyg.supabase.co/functions/v1/stripe-webhook
  ```
- W sekcji **„Events to send”** („Zdarzenia do wysłania”) kliknij **„Select events”**.
- Wyszukaj i **zaznacz jedno zdarzenie:** **`checkout.session.completed`**.
- Kliknij **„Add endpoint”**.

### Krok 8. Skopiuj Signing secret webhooka
- Na liście webhooków zobaczysz nowy endpoint. **Kliknij w niego** (w adres URL albo w nazwę).
- W sekcji **„Signing secret”** kliknij **„Reveal”** („Pokaż”).
- **Skopiuj cały Signing secret** (zaczyna się od `whsec_...`) i **zapisz w Notatniku** – będzie potrzebny w Supabase.

---

## CZĘŚĆ 3: Ustawienie „sekretów” w Supabase (żeby funkcje mogły rozmawiać ze Stripe)

### Krok 9. Wejdź w ustawienia Edge Functions w Supabase
- W Supabase (twój projekt) w lewym menu kliknij **„Edge Functions”**.
- U góry przejdź do zakładki **„Secrets”** („Sekrety”) albo **„Manage secrets”**.

(Jeśli nie widzisz „Secrets”, możesz ustawić je przez **Project Settings** → **Edge Functions** → sekcja z zmiennymi środowiskowymi / secrets.)

### Krok 10. Dodaj każdy sekret po kolei
Dodaj **7 sekretów**. Dla każdego: wybierz **„New secret”** / **„Add new secret”**, wpisz **nazwę** i **wartość**, zapisz.

| Nr | Nazwa (Name)                             | Wartość (Value) – skąd wziąć                          |
|----|------------------------------------------|--------------------------------------------------------|
| 1  | `STRIPE_SECRET_KEY`                      | Wklej **Secret key** z kroku 5 (sk_test_...)          |
| 2  | `STRIPE_PREMIUM_PRICE_MONTHLY`           | Wklej **Price ID miesięczny** z kroku 4 (price_...)    |
| 3  | `STRIPE_PREMIUM_PRICE_YEARLY`            | Wklej **Price ID roczny** (subskrypcja) z kroku 4     |
| 4  | `STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME`   | Wklej **Price ID roczny jednorazowo** z kroku 4 (BLIK)|
| 5  | `STRIPE_WEBHOOK_SECRET`                  | Wklej **Signing secret** z kroku 8 (whsec_...)        |
| 6  | `STRIPE_SUCCESS_URL`                     | Adres strony po udanej płatności, np. `https://twojastrona.pl/dziekujemy` albo na test: `https://example.com/success` |
| 7  | `STRIPE_CANCEL_URL`                      | Adres po anulowaniu, np. `https://twojastrona.pl/anulowano` albo na test: `https://example.com/cancel` |

**Uwaga:** Nazwy wpisuj **dokładnie** tak jak w tabeli (wielkie litery, podkreślniki). Wartości wklejaj bez spacji na początku i końcu.

---

## CZĘŚĆ 4: Wgranie funkcji na Supabase (deploy)

### Krok 11. Zainstaluj Supabase CLI (jeśli jeszcze go nie masz)
- Na komputerze otwórz **terminal** (lub „Wiersz poleceń” / PowerShell).
- Wpisz (lub wklej) i naciśnij Enter:
  - **Windows (PowerShell):**  
    `irm https://windows.supabase.com/install.ps1 | iex`
  - **Mac:**  
    `brew install supabase/tap/supabase`
- Jeśli coś się nie instaluje, wejdź na **https://supabase.com/docs/guides/cli** i wybierz swoją platformę – tam są aktualne komendy.

### Krok 12. Zaloguj się w Supabase z terminala
- W terminalu wpisz:  
  `supabase login`  
- Naciśnij Enter. Otworzy się przeglądarka – zaloguj się do Supabase i potwierdź dostęp. Potem wróć do terminala.

### Krok 13. Połącz terminal z Twoim projektem
- W terminalu przejdź do **folderu z projektem Łatwa Forma** (tam, gdzie masz pliki aplikacji). Np.:
  `cd "ścieżka\do\Latwa_Forma"`
- Wpisz:  
  `supabase link --project-ref TWOJ_PROJECT_REF`  
  (zamiast `TWOJ_PROJECT_REF` wklej ten sam ciąg znaków co w kroku 6, np. `tslsayftpegpliihfmyg`).
- Gdy zapyta o hasło, wpisz hasło do projektu z Supabase (jeśli je ustawiałeś).

### Krok 14. Wgraj trzy funkcje
- W terminalu, w folderze projektu, wpisz po kolei (po każdej naciśnij Enter i poczekaj na „Deployed”):

  ```
  supabase functions deploy create-checkout-session --no-verify-jwt
  supabase functions deploy stripe-webhook
  supabase functions deploy create-portal-session
  ```

- **create-checkout-session** – płatność (wykup Premium).
- **stripe-webhook** – odbieranie informacji od Stripe po płatności.
- **create-portal-session** – zarządzanie subskrypcją i rezygnacja (portal Stripe).

- Jeśli zobaczysz błąd, sprawdź czy jesteś w dobrym folderze (tam gdzie jest folder `supabase/functions`) i czy `supabase link` się udał.

---

## CZĘŚĆ 5: Baza danych (kolumny subskrypcji)

### Krok 15. Kolumny w tabeli „profiles”
- Jeśli używasz **Supabase CLI** i projekt jest podłączony (`supabase link`), w terminalu w folderze projektu wpisz:  
  **`supabase db push`**  
  – wgra to wszystkie migracje (subscription_tier, subscription_expires_at, stripe_customer_id itd.).
- Jeśli **nie** używasz CLI: w Supabase → **SQL Editor** uruchom po kolei skrypty z folderu **`database/supabase/`**:  
  **`migration_subscription_tier.sql`**, potem **`migration_stripe_customer_id.sql`** (skopiuj zawartość, wklej, Run).

---

## Gotowe – co dalej?

- W **aplikacji** użytkownik wchodzi w **Profil** → **Łatwa Forma Premium** i klika **„Wykup Premium (Stripe)”**.
- Otworzy się **strona Stripe** z płatnością. Po opłaceniu Stripe wyśle informację do Supabase (webhook), a konto użytkownika dostanie Premium.
- **Testowanie:** dopóki w Stripe masz włączony **tryb testowy**, użyj karty testowej: **4242 4242 4242 4242**, dowolna data w przyszłości i dowolny CVC. Pieniądze nie będą pobierane.
- **Produkcja:** gdy będziesz gotowy na prawdziwe płatności, w Stripe wyłącz tryb testowy, ustaw **klucze live** (Secret key z `sk_live_...`) i **live Price ID** w sekretach Supabase oraz upewnij się, że webhook w Stripe wskazuje na ten sam adres (bez zmian).

---

## Szybka ściąga – co gdzie wkleić

| Gdzie (Supabase Secrets)        | Skąd (Stripe / własne)                    |
|---------------------------------|-------------------------------------------|
| STRIPE_SECRET_KEY               | Developers → API keys → Secret key        |
| STRIPE_PREMIUM_PRICE_MONTHLY    | Produkty → Premium → cena 69,98 zł / m-c → Price ID |
| STRIPE_PREMIUM_PRICE_YEARLY     | Produkty → Premium → cena 194,95 zł / rok → Price ID |
| STRIPE_WEBHOOK_SECRET           | Developers → Webhooks → endpoint → Signing secret |
| STRIPE_SUCCESS_URL              | Własny adres (np. strona „Dziękujemy”)    |
| STRIPE_CANCEL_URL               | Własny adres (np. strona „Anulowano”)     |

**Metody płatności:** Settings → Payment methods – włącz Cards, BLIK, Apple Pay, Google Pay.

Jeśli któryś krok jest niejasny, napisz który numer – doprecyzuję tylko ten fragment.
