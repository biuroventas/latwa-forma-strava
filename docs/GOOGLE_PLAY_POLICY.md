# Google Play – zgodność z Developer Policy (Łatwa Forma)

Źródło polityk: [Google Play Developer Content Policy](https://play.google/developer-content-policy/).

Ten dokument mówi, **co jest już w kodzie / na stronie**, a **co musisz zaznaczyć w Play Console** przed recenzją.

---

## Co aplikacja już spełnia (kod + strona)

| Polityka | Status |
| --- | --- |
| [Payments](https://support.google.com/googleplay/android-developer/answer/9858738) – cyfrowe Premium w Androidzie tylko przez Play Billing (RevenueCat), bez Stripe w aplikacji ze sklepu | ✓ |
| [Subscriptions](https://support.google.com/googleplay/android-developer/answer/9900533) – cena, okres, auto-odnawianie, anulowanie, trial 24 h bez auto-zapisu na płatność, link Regulamin/Polityka przy zakupie | ✓ |
| [User Data](https://support.google.com/googleplay/android-developer/answer/10144311) – polityka w aplikacji i pod stałym URL | ✓ |
| Usunięcie konta **w aplikacji** (Profil → Usuń konto) oraz **na stronie** | ✓ `https://latwaforma.pl/usun-konto.html` |
| [Health Content](https://support.google.com/googleplay/android-developer/answer/16679511) – disclaimer w aplikacji, regulaminie i opisie sklepu | ✓ |
| Uprawnienie kamery tylko do kodu kreskowego / zdjęcia posiłku; `camera` nie jest wymagane (`required=false`) | ✓ |
| Brak `USE_EXACT_ALARM` / `SCHEDULE_EXACT_ALARM` (przypomnienia: alarmy nieprecyzyjne) | ✓ |
| AI: zdjęcie/pytanie ujawnione w UI i polityce; model odrzuca treści medyczne / szkodliwe | ✓ |
| Min. wiek w onboardingu: 13 lat | ✓ |

---

## Co musisz wypełnić w Play Console (nie da się z kodu)

### 1. Polityka prywatności

Store listing → **Privacy policy URL:** `https://latwaforma.pl/polityka-prywatnosci.html`

### 2. Usuwanie konta (Data safety)

- Czy użytkownik może utworzyć konto? **Tak**
- Czy jest ścieżka usunięcia w aplikacji? **Tak** (Profil → Usuń konto)
- URL strony usuwania konta: **`https://latwaforma.pl/usun-konto.html`**
- Czy usuwacie dane powiązane z kontem (nie „zamrażacie”)? **Tak** (do 30 dni; dokumenty księgowe zgodnie z prawem)

### 3. Health apps declaration (App content)

Zaznacz m.in.:

- **Activity and fitness**
- **Nutrition and weight management**

Nie zaznaczaj: Medical device, clinical decision support, diseases/conditions management.

Aplikacja **nie jest wyrobem medycznym**.

### 4. Data safety – jakie dane zadeklarować

Zbierane (nie sprzedawane, nie używane do reklam):

| Typ | Przykład | Cel |
| --- | --- | --- |
| Dane osobowe | e-mail, ID konta | zarządzanie kontem |
| Zdrowie i fitness | waga, wzrost, wiek, aktywność, posiłki, woda | funkcja aplikacji |
| Zdjęcia | zdjęcie posiłku (opcjonalnie, AI) | funkcja aplikacji; udostępniane OpenAI |
| Aktywność fizyczna | treningi, Strava/Garmin (opcjonalnie) | funkcja aplikacji |
| Identyfikatory urządzenia | powiadomienia lokalne | funkcja aplikacji |
| Dane zakupów | status subskrypcji (Play / RevenueCat) | zarządzanie kontem |

Udostępnianie podmiotom trzecim (procesorzy, nie sprzedaż): Supabase, OpenAI (gdy user użyje AI), RevenueCat, Stripe **tylko na stronie www**, Strava/Garmin **tylko po połączeniu konta**.

Nie zbieracie: lokalizacji, kontaktów, SMS, reklamowego ID.

### 5. Grupa odbiorców / Families

- Aplikacja **nie jest skierowana do dzieci**.
- Grupa docelowa: **13+** (lub 18+ – spójnie z tym, że zbieracie dane zdrowotne).
- Nie zapisujcie aplikacji do programu Families.

### 6. Subskrypcje w Play Console

Utwórz produkty zgodne z `lib/core/constants/store_product_ids.dart`:

- `premium_monthly` – subskrypcja auto-odnawiana
- `premium_yearly` – subskrypcja auto-odnawiana
- `premium_yearly_once` – produkt jednorazowy (nie subskrypcja)

W opisie oferty: auto-odnawianie, cena, jak anulować. Nie nazywaj SKU „Free trial”.

### 7. Opis w sklepie

Tekst z disclaimerem medycznym i informacją o kamerze / Premium: `docs/STORE_LISTING.md`.

### 8. Uprawnienia

W deklaracji uprawnień:

- **CAMERA** – skan kodu kreskowego i (opcjonalnie) zdjęcie posiłku
- **POST_NOTIFICATIONS** – przypomnienia o wodzie i posiłkach (włączane przez użytkownika)
- **BILLING** – zakupy Premium

Nie deklarujcie exact alarm / Health Connect.

---

## Świadomie poza zakresem kodu

- Formularz **Bezpieczeństwo danych**, **content rating (IARC)**, **Health apps declaration** – tylko w konsoli.
- Po zmianie polityki / strony usuwania konta **wdrożyć** `web/usun-konto.html` na latwaforma.pl (skrypt `scripts/prepare_latwaforma_pl.sh` kopiuje plik do buildu).
- Edge Function `ai-advice` po zmianie promptu: `supabase functions deploy ai-advice`.
