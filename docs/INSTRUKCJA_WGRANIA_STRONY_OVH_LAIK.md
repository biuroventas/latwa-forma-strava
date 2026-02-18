# Instrukcja wgrania strony na OVH – krok po kroku (dla laika)

Wszystko w jednym miejscu. Robisz po kolei, nic nie szukasz.

---

## KROK 1: Wejście do panelu OVH

1. Otwórz przeglądarkę (Chrome, Safari, Firefox – bez różnicy).
2. W pasku adresu wklej i naciśnij Enter:
   - **https://www.ovh.com/manager/**
3. Zaloguj się (e-mail i hasło do konta OVH). Jeśli nie masz konta – najpierw je załóż na ovh.com.

---

## KROK 2: Przejście do hostingu i FTP

1. W panelu OVH **po lewej stronie** zobaczysz menu.
2. Kliknij w **„Web Cloud”** (jeśli jest zwinięte – rozwiń je).
3. Kliknij w **„Hosting”** (czasem nazwa: „Strony WWW” / „Hostingi”).
4. Na liście hostingu kliknij w **„latwaforma.pl”** (pod spodem może być napis: latwafe.cluster121.hosting.ovh.net – to ten sam).
5. U góry strony zobaczysz zakładki. Kliknij w **„FTP - SSH”**.

**Szybki link** (działa po zalogowaniu):  
**https://www.ovh.com/manager/#/web/hosting/latwafe.cluster121.hosting.ovh.net/ftp**

---

## KROK 3: Pobranie i instalacja FileZilla (program do FTP)

OVH nie udostępnia już wgrania plików w przeglądarce (FTP Explorer / Net2FTP). Trzeba użyć programu FTP – np. **FileZilla** (darmowy).

1. Otwórz w przeglądarce stronę pobierania FileZilla:
   - **https://filezilla-project.org/download.php?type=client**
2. Wybierz wersję **dla macOS** (przycisk „Download FileZilla Client” dla Mac).
3. Pobierz plik (np. **FileZilla_*.tar.bz2** lub **FileZilla.app** w zależności od wersji).
4. Otwórz pobrany plik i **przeciągnij FileZilla** do folderu **Aplikacje** (Applications), jeśli instalator tego nie zrobi.
5. Uruchom **FileZilla** (z Aplikacji lub z Launchpada).

---

## KROK 4: Połączenie z hostingen w FileZilli

1. W **FileZilli** u góry jest pasek **„Szybkie połączenie”** (Host, Nazwa użytkownika, Hasło, Port).
2. Wpisz (skopiuj dokładnie):
   - **Host:** `ftp.cluster121.hosting.ovh.net`
   - **Nazwa użytkownika:** `latwafe`
   - **Hasło:** (wklej swoje hasło FTP z panelu OVH)
   - **Port:** `21`
3. Kliknij **„Szybkie połączenie”** (niebieski przycisk).
4. Może pojawić się okno **„Nieznany certyfikat”** – zaznacz **„Zawsze ufaj temu certyfikatowi”** i kliknij **OK**.
5. Gdy połączenie się uda, **po prawej stronie** zobaczysz foldery na serwerze (np. **www**, **logs**, **cgi-bin**).

Jeśli wyskoczy błąd „Nie udało się połączyć” – sprawdź hasło (bez spacji na początku/końcu) i czy Host i Port są wpisane dokładnie jak wyżej.

---

## KROK 5: Wejście do folderu „www” na serwerze (w FileZilli)

1. **Po prawej stronie** FileZilli („Strona zdalna” / „Remote site”) zobaczysz listę folderów na serwerze.
2. Znajdź folder **www** i **kliknij go dwukrotnie** (dwuklik = wejście do środka folderu).
3. U góry po prawej zobaczysz ścieżkę typu `/www` lub `/home/latwafe/www` – znaczy to, że jesteś **w folderze www**. Tu muszą trafić pliki strony.

---

## KROK 6: Gdzie na Twoim komputerze są pliki do wgrania

Na Macu pliki projektu Łatwa Forma są w folderze:

**iCloud Drive → Documents → Latwa_Forma**

Pełna ścieżka (do wklejenia w „Idź do folderu” w Finderze, jeśli nie widzisz projektu):

```
/Users/norbisparrow/iCloud Drive/Documents/Latwa_Forma
```

Potrzebujesz **pięciu plików** z tego projektu:

| Co wgrać na serwer | Skąd wziąć na komputerze |
|--------------------|---------------------------|
| **index.html** | Folder **Latwa_Forma** → w środku folder **landing_latwaforma_pl** → plik **index.html** |
| **polityka-prywatnosci.html** | Folder **Latwa_Forma** → w środku folder **web** → plik **polityka-prywatnosci.html** |
| **regulamin.html** | Folder **Latwa_Forma** → w środku folder **web** → plik **regulamin.html** |
| **privacy.html** | Folder **Latwa_Forma** → w środku folder **web** → plik **privacy.html** (polityka po angielsku) |
| **terms.html** | Folder **Latwa_Forma** → w środku folder **web** → plik **terms.html** (regulamin po angielsku) |

---

## KROK 7: Wgranie plików w FileZilli (upload)

**Lewa strona** = Twój komputer. **Prawa strona** = serwer (folder **www**).

1. **Po lewej stronie** FileZilli przejdź do folderu z plikami:
   - W górnej części lewej strony wpisz ścieżkę (lub przejdź przez foldery):  
     **Documents** → **Latwa_Forma** (albo **iCloud Drive** → **Documents** → **Latwa_Forma**).
2. Najpierw wgraj **index.html**:
   - Po lewej wejdź do folderu **landing_latwaforma_pl**, zaznacz plik **index.html**.
   - Kliknij **prawym przyciskiem** na **index.html** → wybierz **„Prześlij”** (Upload).  
   **Albo** przeciągnij **index.html** z lewej strony na **prawą** (na listę plików w folderze www).
3. Potem wgraj pozostałe cztery pliki z folderu **web**:
   - Po lewej wejdź do folderu **web** (w **Latwa_Forma**).
   - Zaznacz **polityka-prywatnosci.html**, **regulamin.html**, **privacy.html**, **terms.html** (trzymaj **Cmd** i klikaj po kolei, żeby zaznaczyć wszystkie cztery).
   - Kliknij prawym → **„Prześlij”** albo przeciągnij wszystkie cztery pliki na prawą stronę.
4. Na dole FileZilli zobaczysz listę transferów – poczekaj, aż wszystkie pięć plików ma status **„Zakończono pomyślnie”**.

---

## KROK 8: Sprawdzenie, czy strona działa

1. Otwórz **nową kartę** w przeglądarce.
2. W pasku adresu wklej i naciśnij Enter:
   - **http://latwafe.cluster121.hosting.ovh.net**
3. Powinna się wyświetlić strona **„Łatwa Forma”** z przyciskiem „Otwórz aplikację” i linkami do polityki prywatności oraz regulaminu.
4. Kliknij **„Polityka prywatności”** – powinna otworzyć się strona z polityką.
5. Kliknij **„Regulamin”** – powinna otworzyć się strona z regulaminem.

Jeśli widzisz błąd „Strona nie działa” lub pustą stronę – wróć do Kroku 5 i upewnij się, że pliki są **w folderze www**, a nie w głównym katalogu (np. /home/latwafe).

---

## Przydatne linki (do zapisania)

| Do czego | Link |
|----------|------|
| Panel OVH (logowanie) | https://www.ovh.com/manager/ |
| Strona FTP tego hostingu (po zalogowaniu) | https://www.ovh.com/manager/#/web/hosting/latwafe.cluster121.hosting.ovh.net/ftp |
| Twoja strona (dopóki trwa transfer domeny) | http://latwafe.cluster121.hosting.ovh.net |
| Twoja strona (gdy domena latwaforma.pl już działa) | https://latwaforma.pl |

---

## Gdy coś nie działa

- **„Nieprawidłowy login lub hasło”** w FileZilli – sprawdź, czy wpisujesz **latwafe** (małymi literami) i poprawne hasło FTP (bez spacji na początku/końcu). Host: `ftp.cluster121.hosting.ovh.net`, port **21**.
- **FTP Explorer (Net2FTP) nie jest dostępny** – OVH wyłączył wgrywanie w przeglądarce. Użyj **FileZilla** (Krok 3) – link: https://filezilla-project.org/download.php?type=client
- **Strona się nie ładuje** – upewnij się, że wgrałeś pliki do folderu **www** (po prawej w FileZilli musisz być w **www**). Po wgraniu po prawej stronie powinny być widoczne: index.html, polityka-prywatnosci.html, regulamin.html, privacy.html, terms.html.

Jeśli napiszesz, na którym kroku jesteś i co dokładnie widzisz na ekranie, można to doprecyzować.

---

## Co dalej (po wgraniu landingu)

Kolejność ma znaczenie. Szczegóły znajdziesz w **docs/INSTRUKCJA_WDROZENIA_LAIK.md** (Części 5–7) oraz **docs/OVH_CO_DALEJ.md**.

| Krok | Co zrobić | Gdzie |
|------|-----------|--------|
| **1** | **Domena** – gdy transfer latwaforma.pl się skończy, sprawdź w OVH (Domeny → latwaforma.pl → Strefa DNS), czy domena wskazuje na hosting. | Panel OVH |
| **2** | **SSL (https)** – w panelu OVH: Hosting → latwaforma.pl → zakładka **Certyfikaty SSL** → włącz **Let's Encrypt** dla latwaforma.pl. Po kilku minutach strona będzie pod **https://latwaforma.pl**. | Panel OVH |
| **3** | **Poczta e-mail** – w OVH (Hosting lub sekcja E-mail) załóż skrzynki: **kontakt@latwaforma.pl**, **support@latwaforma.pl**, **norbert@latwaforma.pl**. Ustaw hasła i zapisz je. | Panel OVH |
| **4** | **Supabase** – w projekcie: Authentication → URL Configuration. Ustaw **Site URL** na **https://app.latwaforma.pl**. W **Redirect URLs** dodaj: https://app.latwaforma.pl, https://app.latwaforma.pl/**, https://latwaforma.pl, https://latwaforma.pl/**. Zapisz. | supabase.com |
| **5** | **Aplikacja web** – zbuduj (Flutter: `flutter build web`) i wdróż na Vercel lub Netlify. W DNS OVH dodaj rekord **CNAME**: subdomena **app** → cel: adres z Vercel/Netlify (np. cname.vercel-dns.com). Wtedy **app.latwaforma.pl** będzie otwierać aplikację. | Cursor/terminal + Vercel/Netlify + OVH DNS |
| **6** | **Linki w aplikacji** – w pliku **lib/core/constants/app_constants.dart** ustaw adresy polityki i regulaminu na **https://latwaforma.pl/polityka-prywatnosci.html** i **https://latwaforma.pl/regulamin.html** (oraz success/cancel URL Stripe na app.latwaforma.pl, jeśli jeszcze nie). | Projekt w Cursorze |

Gdy **app.latwaforma.pl** będzie działać, użytkownicy z landingu (przycisk „Otwórz aplikację”) trafią do aplikacji, a logowanie i płatności będą działać z nową domeną.
