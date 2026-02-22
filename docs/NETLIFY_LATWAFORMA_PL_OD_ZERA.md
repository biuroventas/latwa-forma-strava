# latwaforma.pl na Netlify – nowy projekt od zera (z certyfikatem)

Szybka ścieżka: jeden nowy projekt Netlify, tylko strona firmowa (landing + polityka + regulamin), domena latwaforma.pl i SSL.

---

## Krok 1. Przygotuj folder do wgrania (lokalnie)

W katalogu głównym projektu (w terminalu lub Cursorze) uruchom:

```bash
bash scripts/prepare_latwaforma_pl_site.sh
```

Powstanie folder **`dist_latwaforma_pl`** z plikami: `index.html`, `polityka-prywatnosci.html`, `regulamin.html`, `privacy.html`, `terms.html` (i opcjonalnie `auth_redirect/`).

---

## Krok 2. Nowy projekt na Netlify (Deploy z folderu – Drop)

1. Wejdź na **https://app.netlify.com** i zaloguj się.
2. **Add new site** → **Deploy manually** (albo wejdź od razu na **https://app.netlify.com/drop**).
3. Otwórz na komputerze folder **`dist_latwaforma_pl`**.
4. **Ważne:** Przeciągnij **zawartość** folderu (wszystkie pliki i podfoldery **w środku**), a nie sam folder. W głównym katalogu musi być **index.html** (landing) – wtedy https://latwaforma.pl pokaże stronę główną, a nie auth_redirect.
5. Zaznacz wszystkie pliki w środku (np. Cmd+A), **przeciągnij je** w okno Netlify Drop.
6. Poczekaj na zakończenie wgrywania. Netlify poda adres typu **`nazwa-xyz.netlify.app`** – skopiuj go (bez `https://`).

---

## Krok 3. Domena latwaforma.pl w Netlify

1. W tym samym projekcie: **Domain configuration** / **Domain management** → **Add custom domain** (lub **Add domain alias**).
2. Wpisz: **`latwaforma.pl`** (bez www, bez https://).
3. Zapisz. Netlify pokaże, co ustawić w DNS (np. **A** na `75.2.60.5` albo **CNAME** na `nazwa-xyz.netlify.app` – zależnie od wersji panelu).

---

## Krok 4. DNS w OVH

1. Wejdź do panelu **OVH** → domena **latwaforma.pl** → **Strefa DNS** (DNS zone).
2. **Usuń** lub **edytuj** stare wpisy dla **latwaforma.pl** (rekord A lub CNAME), żeby nie kolidowały z Netlify.
3. **Dodaj** dokładnie to, co Netlify pokazuje:
   - często **rekord A**: nazwa `@` (lub pusta), cel **75.2.60.5** (adres Netlify – sprawdź w Netlify w Domain setup, „Configure external DNS”);
   - albo **CNAME**: nazwa `@` (jeśli OVH obsługuje CNAME na apex) lub `www`, cel **`nazwa-xyz.netlify.app`** (ten z Kroku 2).
4. Zapisz zmiany. Propagacja DNS: zwykle 5–30 minut, czasem do kilku godzin.

---

## Krok 5. Certyfikat SSL w Netlify

1. W Netlify: **Domain configuration** → przy domenie **latwaforma.pl** zobaczysz opcję **HTTPS** / **Verify DNS** / **Provision certificate**.
2. Gdy DNS jest już poprawne (Netlify pokaże „DNS configured” / zielony ptak), kliknij **Verify** lub **Renew certificate** / **Provision certificate**.
3. Poczekaj 1–2 minuty. Gdy certyfikat będzie gotowy, przy domenie pojawi się informacja o HTTPS.

---

## Krok 6. Sprawdzenie

- Otwórz w przeglądarce **https://latwaforma.pl** – powinna załadować się strona (landing Łatwa Forma) z zieloną kłódką (ważny certyfikat).
- Sprawdź linki: **https://latwaforma.pl/polityka-prywatnosci.html**, **https://latwaforma.pl/regulamin.html**.

---

## Uwagi

- **Stare projekty Netlify:** możesz je zostawić lub usunąć. Domena **latwaforma.pl** powinna być dodana **tylko w jednym** projekcie (tym nowym), żeby SSL i DNS były jednoznaczne.
- **Aktualizacje strony:** po zmianach w `landing_latwaforma_pl/` lub `web/*.html` uruchom ponownie `bash scripts/prepare_latwaforma_pl_site.sh`, a potem w Netlify: **Deploys** → **Drag and drop** (przeciągnij zawartość `dist_latwaforma_pl` jeszcze raz) albo połącz ten projekt z Git i ustaw build (publish = katalog wygenerowany przez skrypt).
