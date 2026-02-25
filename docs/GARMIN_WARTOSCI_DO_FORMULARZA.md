# Garmin – wartości do formularza „Create app”

**Gdy w Overview klikniesz „creating apps”, wklej poniższe wartości.**  
Po zapisaniu aplikacji skopiuj **Consumer Key** i **Consumer Secret** do `.env` (GARMIN_CLIENT_ID i GARMIN_CLIENT_SECRET).

---

## Application Name (nazwa aplikacji)

```
Łatwa Forma
```

---

## Application Description (opis)

```
Aplikacja do śledzenia kalorii, makroskładników i aktywności. Użytkownicy mogą połączyć konto Garmin Connect i importować aktywności (spalone kalorie) do dziennika. Strona: latwaforma.pl
```

---

## Privacy Policy URL

```
https://latwaforma.pl/polityka-prywatnosci.html
```

---

## Redirect URL(s)

**Wklej oba (każdy w osobnej linii lub pole, jeśli portal pozwala na wiele):**

Dla **aplikacji mobilnej** (deep link):

```
latwaforma://garmin-callback
```

Dla **aplikacji web** (przeglądarka):

```
https://latwaforma.pl/garmin-callback.html
```

*(Jeśli w portalu jest tylko jedno pole „Redirect URL”, wpisz najpierw ten drugi – web – albo sprawdź w Documentation, czy można dodać kilka URLi.)*

---

## Po zapisaniu aplikacji

1. W portalu zobaczysz **Consumer Key** i **Consumer Secret** (czasem „Client ID” / „Client Secret”).
2. Otwórz w projekcie plik **`.env`**.
3. Wklej:
   - **Consumer Key** → w linii `GARMIN_CLIENT_ID=` (po znaku `=`).
   - **Consumer Secret** → w linii `GARMIN_CLIENT_SECRET=` (po znaku `=`).
4. Zapisz plik. Gotowe – możesz testować „Połącz z Garmin Connect” w aplikacji.
