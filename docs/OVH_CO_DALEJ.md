# OVH – hosting gotowy, co dalej (krok po kroku)

Dostałeś maila, że hosting **hosting-perso** jest dostępny, a transfer domeny **latwaforma.pl** trwa. Poniżej co zrobić po kolei.

---

## 1. Hasło FTP

W mailu hasło jest linkiem do panelu OVH („Secret”).  
1. Wejdź na **https://www.ovh.com/manager/** i zaloguj się.  
2. Kliknij w link z maila („Hasło”) albo w panelu: **Hosting** → Twój hosting (**latwafe**) → zakładka **FTP** / **Dane do logowania**.  
3. **Pokaż** / **Skopiuj** hasło FTP i zapisz je w bezpiecznym miejscu (Notatnik, menedżer haseł).

---

## 2. Wgranie landingu (strony) przez FTP

Pliki strony muszą trafić do katalogu **www** na serwerze.

### Opcja A – Program FTP (FileZilla)

1. Pobierz **FileZilla** (darmowy): https://filezilla-project.org/download.php  
2. Uruchom FileZilla. U góry wpisz:
   - **Host:** `ftp.cluster121.hosting.ovh.net`
   - **Nazwa użytkownika:** `latwafe`
   - **Hasło:** (wklej hasło z panelu OVH)
   - **Port:** `21`
3. Kliknij **Szybkie połączenie**. Po lewej masz swój komputer, po prawej – serwer.
4. Po prawej stronie wejdź w folder **www** (dwuklik). Jeśli go nie ma, może być **www** w głównym katalogu – upewnij się, że jesteś w katalogu, który OVH wskazuje jako „katalog strony” (w dokumentacji OVH często jest to właśnie **www**).
5. Z lewej strony (komputer) znajdź na dysku **5 plików**: **index.html** (folder **landing_latwaforma_pl**), **polityka-prywatnosci.html**, **regulamin.html**, **privacy.html**, **terms.html** (folder **web**).
6. Zaznacz wszystkie pięć plików i **przeciągnij je** na prawą stronę (do folderu **www**) albo kliknij prawym → „Prześlij”.

### Opcja B – Menedżer plików w panelu OVH

1. Wejdź na **https://www.ovh.com/manager/** → **Hosting** → wybierz hosting **latwafe**.
2. Szukaj **„Menedżer plików”** / **„FTP”** / **„Pliki”** – OVH czasem oferuje przeglądarkowy menedżer plików.
3. Wejdź w katalog **www**.
4. Użyj opcji **„Prześlij”** / **„Upload”** i wgraj **5 plików**: index.html, polityka-prywatnosci.html, regulamin.html, privacy.html, terms.html. Szczegóły: **docs/INSTRUKCJA_WGRANIA_STRONY_OVH_LAIK.md**.

### Sprawdzenie

- Dopóki trwa transfer domeny, strona działa pod adresem: **http://latwafe.cluster121.hosting.ovh.net** (albo podobnym – dokładny adres jest w mailu od OVH).  
- Wpisz ten adres w przeglądarce – powinna się wyświetlić strona „Łatwa Forma” z przyciskiem „Otwórz aplikację” i linkami do polityki i regulaminu.  
- Po zakończeniu transferu **latwaforma.pl** powinna pokazywać tę samą stronę (OVH często łączy domenę z hostingen automatycznie). Jeśli nie – patrz punkt 4 (DNS).

---

## 3. Poczta e-mail (kontakt@, support@, norbert@)

1. W panelu OVH: **Hosting** → Twój hosting (**latwafe**).  
2. Szukaj sekcji **„Poczta”** / **„E-mail”** / **„Konta e-mail”** (często w tym samym hostingu jest opcja „Utwórz konto e-mail” lub „Zimbra”).  
3. **Dodaj skrzynki** w domenie **latwaforma.pl**:
   - **kontakt@latwaforma.pl**
   - **support@latwaforma.pl**
   - **norbert@latwaforma.pl** (albo imie.nazwisko@latwaforma.pl)
4. Dla każdej ustaw **hasło** i zapisz je.  
5. Po utworzeniu skrzynek sprawdź w panelu, czy OVH pokazuje **rekordy MX** i **SPF/DKIM** – będą potrzebne w kroku 4, jeśli domena jest jeszcze u innego rejestrara.

---

## 4. Domena latwaforma.pl – DNS (gdy transfer się skończy)

Gdy OVH potwierdzi zakończenie **transferu** domeny **latwaforma.pl**:

1. W panelu OVH wejdź w **Domeny** → **latwaforma.pl** → **Strefa DNS** (lub **DNS**).  
2. Sprawdź, czy są ustawione rekordy **A** dla **latwaforma.pl** i **www** na adres IP hostingu (OVH często ustawia je przy transferze).  
3. Dla **poczty** upewnij się, że są rekordy **MX** (i ewentualnie **TXT** SPF/DKIM) – wartości podaje OVH w sekcji Poczta / Konfiguracja. Jeśli OVH zarządza już DNS domeny, często dodaje je sam; w przeciwnym razie dodaj je ręcznie według wskazówek z panelu.

Dopóki transfer trwa, strona działa pod adresem **latwafe.cluster121.hosting.ovh.net** (jak w mailu).

---

## 5. Certyfikat SSL (https)

1. W panelu OVH: **Hosting** → **latwafe** → szukaj **„SSL”** / **„Certyfikat”** / **„Let's Encrypt”**.  
2. Włącz **certyfikat SSL** dla domeny **latwaforma.pl** (i ewentualnie **www.latwaforma.pl**).  
3. Po aktywacji (zwykle kilka–kilkanaście minut) strona powinna działać pod **https://latwaforma.pl**.

---

## 6. Co dalej (z głównej instrukcji)

- **Supabase** – dodanie w Auth adresów **https://app.latwaforma.pl** i **https://latwaforma.pl** (Część 5 w **INSTRUKCJA_WDROZENIA_LAIK.md**).  
- **Aplikacja web** – zbudowanie Flutter Web i wdrożenie pod **app.latwaforma.pl** (Vercel/Netlify) oraz CNAME w DNS (Część 6).  
- **Adresy w aplikacji** – w **app_constants.dart** ustawienie linków do polityki i regulaminu na **https://latwaforma.pl/polityka-prywatnosci.html** i **https://latwaforma.pl/regulamin.html** (Część 7).

Jeśli coś w panelu OVH wygląda inaczej (np. brak „Menedżera plików”), sprawdź **Przewodniki** (guides) z linku w mailu lub pomoc OVH.
