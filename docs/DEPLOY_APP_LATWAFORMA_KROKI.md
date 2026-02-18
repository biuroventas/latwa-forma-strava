# Wdrożenie app.latwaforma.pl – tylko to, co musisz zrobić

Build jest gotowy (folder **build/web**). Poniżej wdrożenie **bez instalacji CLI** – tylko przeglądarka i OVH.

---

## Krok 1: Wrzucenie aplikacji na Netlify (przeglądarka)

1. Otwórz w przeglądarce: **https://app.netlify.com/drop**
2. Zaloguj się (lub załóż darmowe konto Netlify – przez e‑mail lub GitHub).
3. Na stronie „Drop” zobaczysz obszar **„Drag and drop your site output folder here”**.
4. Na Macu otwórz **Finder** → wejdź w folder projektu Łatwa Forma → **build** → **web**.
5. **Przeciągnij cały folder „web”** (wraz z zawartością) na obszar Drop w przeglądarce.
6. Netlify wgra pliki i pokaże adres typu **nazwa-123abc.netlify.app**. **Skopiuj ten adres** (np. **xyz.netlify.app** – bez https://) – będzie potrzebny w Kroku 3.

---

## Krok 2: Podpięcie domeny app.latwaforma.pl w Netlify

1. W Netlify (po wgraniu) wejdź w **„Domain settings”** / **„Ustawienia domeny”** (albo **„Options”** → **„Domain management”**).
2. Kliknij **„Add custom domain”** / **„Dodaj domenę niestandardową”**.
3. Wpisz: **app.latwaforma.pl** i zatwierdź.
4. Netlify zaproponuje ustawienie DNS. Zazwyczaj pokaże coś w stylu:
   - **Subdomena / Name:** `app` (albo `app.latwaforma.pl`)
   - **Wartość / Target:** `nazwa-twojej-strony.netlify.app` (ten adres z Kroku 1).
5. **Skopiuj dokładnie** tę wartość (np. **random-words-123.netlify.app**).

---

## Krok 3: Rekord CNAME w OVH

1. Wejdź na **https://www.ovh.com/manager/** → zaloguj się.
2. **Domeny** → **latwaforma.pl** → **Strefa DNS** (lub **DNS**).
3. Kliknij **„Dodaj wpis”** / **„Dodaj rekord”**.
4. Wybierz **Typ: CNAME**.
5. **Subdomena:** wpisz **app** (tak żeby wyszło app.latwaforma.pl).
6. **Cel / Target:** wklej adres z Netlify (np. **random-words-123.netlify.app** – bez https://, bez końcowego ukośnika).
7. Zapisz.

Propagacja DNS trwa zwykle 5–30 minut. Po tym czasie **https://app.latwaforma.pl** powinno otwierać Twoją aplikację. Netlify sam wystawi certyfikat SSL dla app.latwaforma.pl.

---

## Gdy coś nie działa

- **„Site not found”** – upewnij się, że w Kroku 1 przeciągnąłeś **zawartość** folderu **build/web** (wszystkie pliki wewnątrz), a nie sam folder „web”.
- **app.latwaforma.pl nie ładuje się** – sprawdź w OVH, czy rekord CNAME ma subdomenę **app** i cel dokładnie taki jak w Netlify (bez literówek).
