# Zgodność z prawem i wymagania sklepów (App Store, Google Play)

Lista tego, co powinna mieć aplikacja, żeby była **legalna** (RODO, prawo konsumenckie) i **zaakceptowana w sklepach**.

---

## 1. Polityka prywatności (masz ✓)

- **Obowiązek:** RODO, Apple i Google wymagają linku do polityki prywatności.
- **Status:** Masz pliki `strava_redirect/privacy-pl.html` i `privacy.html` z administratorem, danymi, celami, prawami użytkownika.
- **Do zrobienia:**
  - Opublikuj politykę pod **stałym adresem** (np. `https://twojadomena.pl/polityka-prywatnosci` lub GitHub Pages) i podaj ten adres w sklepach oraz **w aplikacji** (link w profilu / ustawieniach).
  - Dopisz w polityce: **Stripe** (płatności – przetwarzanie przez Stripe, nie przechowujesz kart), **logowanie Google** (przekazywanie e-maila/identyfikatora do świadczenia usługi), ewentualnie **powiadomienia** (identyfikatory urządzenia do wysyłki powiadomień).
  - W produkcji używaj stałego URL (np. `https://latwaforma.pl/polityka-prywatnosci.html`).

---

## 2. Regulamin / Warunki korzystania (trzeba dodać)

- **Obowiązek:** Apple i Google często wymagają regulaminu lub warunków korzystania z usługi. Prawo konsumenckie (UE) wymaga jasnych warunków przed zawarciem umowy (w tym subskrypcji).
- **Co powinien zawierać:**
  - Kto świadczy usługę (VENTAS NORBERT WRÓBLEWSKI lub firma), kontakt.
  - Zasady korzystania z aplikacji (zakaz nadużyć, odpowiedzialność użytkownika).
  - **Subskrypcja Premium:** cena, okres rozliczeniowy, sposób rezygnacji (np. przez Stripe Customer Portal lub e-mail), brak zwrotu za niewykorzystany okres (jeśli tak jest), co obejmuje Premium.
  - Okres próbny (24 h) – że to jednorazowa oferta, po niej płatna subskrypcja lub jednorazowy zakup.
  - Prawo odstąpienia (konsument w UE ma 14 dni – doprecyzuj, czy dotyczy subskrypcji i jak rezygnacja).
  - Prawo właściwe (np. prawo polskie) i ewentualnie rozstrzyganie sporów.
- **Gdzie opublikować:** Ta sama domena co polityka (np. `https://twojadomena.pl/regulamin` lub `terms-pl.html` na GitHub Pages).
- **W aplikacji:** Link do regulaminu w profilu / ustawieniach (już dodany w kodzie – ustaw URL po opublikowaniu).

---

## 3. Dostęp do polityki i regulaminu w aplikacji (dodane ✓)

- **Wymóg sklepów:** Użytkownik musi móc zobaczyć politykę prywatności (i często regulamin) **z poziomu aplikacji**, nie tylko ze sklepu.
- **Status:** W ekranie **Profil** dodane są linki: „Polityka prywatności” i „Regulamin” – otwierają się w przeglądarce. **Musisz ustawić stały URL regulaminu** (stała w kodzie / konfiguracji).

---

## 4. Informacje o subskrypcji (masz w praktyce ✓)

- **Wymóg:** Przed zakupem użytkownik powinien widzieć cenę, okres, sposób anulowania.
- **Status:** Ekran Premium pokazuje ceny (69,98 zł / 194,95 zł), okres (miesięcznie/rocznie). Rezygnacja przez Stripe Customer Portal („Anuluj subskrypcję” w Premium). Warto w regulaminie jasno opisać: „Subskrypcję możesz anulować w dowolnym momencie w aplikacji (Premium → Anuluj subskrypcję).”

---

## 5. Zgoda na przetwarzanie danych (opcjonalnie, zalecane)

- **RODO:** Dla przetwarzania **niekoniecznego** do wykonania umowy (np. marketing, analityka) potrzebna jest zgoda. Dla konta, profilu, posiłków – często „wykonanie umowy” lub „prawnie uzasadniony interes”.
- **Praktyka:** W wielu aplikacjach przy **pierwszej rejestracji** lub przed pierwszym logowaniem pokazuje się krótki tekst: „Tworząc konto, akceptujesz [Regulamin] i [Politykę prywatności]” z linkami i przyciskiem „Akceptuję”. To wzmacnia zgodność i wymagania sklepów.
- **Opcja:** Dodać na ekranie rejestracji / welcome jednorazowy checkbox lub przycisk „Akceptuję Regulamin i Politykę prywatności” z linkami.

---

## 6. Sklepy – dodatkowe pola

### App Store (Apple)

- **App Privacy (etykieta prywatności):** W App Store Connect wypełnij sekcję **App Privacy**: jakie dane zbierasz (np. e-mail, dane zdrowotne / waga, identyfikator urządzenia do powiadomień), czy są używane do śledzenia, czy zbierane są dane z aplikacji. Apple pokazuje to użytkownikowi przed pobraniem.
- **Polityka prywatności:** URL w metadanych aplikacji (masz treść – podaj stały link).
- **Obsługa konta / usunięcie konta:** Apple wymaga, żeby użytkownik mógł **usunąć konto** z poziomu aplikacji. Masz przycisk „Usuń konto” w profilu – upewnij się, że faktycznie usuwa konto i dane użytkownika (Supabase Auth + dane w `profiles` i powiązanych tabelach).

### Google Play

- **Polityka prywatności:** URL w karcie aplikacji (wymagane).
- **Formularz „Bezpieczeństwo danych”:** W Play Console wypełnij, jakie dane zbierasz i w jakim celu (zgodne z polityką).
- **Usunięcie konta:** Podobnie jak Apple – opcja usunięcia konta w aplikacji (masz „Usuń konto” – sprawdź, że usuwa dane).

---

## 7. Podsumowanie – co masz i co dokończyć

| Element | Status | Działanie |
|--------|--------|-----------|
| Polityka prywatności | ✓ | Opublikuj pod stałym URL; dopisz Stripe, Google, powiadomienia; link w aplikacji ✓ |
| Regulamin | Do dodania | Napisz regulamin (subskrypcja, rezygnacja, odstąpienie); opublikuj; ustaw URL w aplikacji |
| Linki w aplikacji | ✓ | Profil → Polityka prywatności i Regulamin (URL regulaminu ustaw w kodzie) |
| Informacje o subskrypcji | ✓ | Ceny i anulowanie w aplikacji + doprecyzuj w regulaminie |
| Zgoda przy rejestracji | Opcjonalnie | Tekst „Akceptuję Regulamin i Politykę” z linkami przy zakładaniu konta |
| App Privacy (Apple) | Do wypełnienia | App Store Connect → App Privacy – zgodnie z polityką |
| Usunięcie konta | ✓ | Przycisk w profilu – upewnij się, że usuwa dane w Supabase |

---

## 8. Gdzie w kodzie ustawić URL regulaminu

- Stała z URL polityki i regulaminu: np. w `lib/core/constants/app_constants.dart` lub osobnym pliku (np. `legal_urls.dart`). W `profile_screen.dart` używane są te stałe do otwierania linków. Po opublikowaniu regulaminu wstaw tam docelowy adres.
