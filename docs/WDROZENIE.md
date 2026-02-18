# Wdrożenie Łatwa Forma – sklepy, strona, Windows, Mac

Krótki przewodnik: co zrobić, żeby opublikować aplikację w sklepach, w internecie i na komputerach.

---

## Ogólnie przed wdrożeniem

- **Supabase:** Upewnij się, że używasz projektu produkcyjnego (ten sam dla wszystkich platform).
- **Stripe:** Na produkcję przełącz na **Live**, ustaw live klucze i Price ID w sekretach Edge Functions, dodaj live webhook i nowy Signing secret.
- **Wersja:** W `pubspec.yaml` pole `version` (np. `1.0.0+1`) – druga liczba to build number (zwiększ przy każdym uploadzie do sklepów).

---

## 1. Sklepy (App Store + Google Play)

### Apple App Store (iOS)

1. **Konto:** Apple Developer Program (99 USD/rok) – [developer.apple.com](https://developer.apple.com).
2. **App Store Connect:** Stwórz aplikację, wypełnij metadane (opis, screenshots, kategoria, prywatność).
3. **Xcode:** Otwórz `ios/Runner.xcworkspace`, ustaw **Team** i **Bundle ID** (np. `pl.latwaforma.app`). W **Signing & Capabilities** wybierz swój certyfikat i provisioning profile (Distribution).
4. **Build:**
   ```bash
   flutter build ipa
   ```
   Plik `.ipa` będzie w `build/ios/ipa/`.
5. **Upload:** Przez Xcode (Window → Organizer → Distribute App) albo **Transporter** (z Mac App Store) – wybierz plik `.ipa` i wyślij do App Store Connect.
6. **W App Store Connect:** Wybierz build, wyślij do recenzji.

Dokładna instrukcja: [docs.flutter.dev/deployment/ios](https://docs.flutter.dev/deployment/ios).

### Google Play (Android)

1. **Konto:** Google Play Console (25 USD jednorazowo) – [play.google.com/console](https://play.google.com/console).
2. **Aplikacja:** Utwórz aplikację, wypełnij dane sklepu (opis, grafiki, polityka prywatności, kategoria).
3. **Klucz do podpisywania:** Wygeneruj keystore (jeśli jeszcze nie masz):
   ```bash
   keytool -genkey -v -keystore latwa-forma-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Zapisz hasło i `latwa-forma-upload-key.jks` w bezpiecznym miejscu.
4. **Konfiguracja:** W projekcie utwórz (lub uzupełnij) `android/key.properties`:
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=../latwa-forma-upload-key.jks
   ```
   W `android/app/build.gradle.kts` dodaj odczyt `key.properties` i konfigurację `signingConfigs` (instrukcja w [docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)).
5. **Build:**
   ```bash
   flutter build appbundle
   ```
   Plik `.aab` będzie w `build/app/outputs/bundle/release/`.
6. **Upload:** W Play Console → Twoja aplikacja → Release → Production (lub testing) → Create new release → Upload `app-release.aab`.

---

## 2. Strona (Web)

1. **Build:**
   ```bash
   flutter build web
   ```
   Wynik w `build/web/` (pliki do wrzucenia na serwer).

2. **Hosting** – opcje:
   - **Firebase Hosting:** `firebase init hosting`, potem `firebase deploy` (katalog `build/web`).
   - **Vercel / Netlify:** Połącz repozytorium, ustaw katalog build na `build/web` i komendę `flutter build web` (albo buduj lokalnie i wrzucaj `build/web`).
   - **Supabase Storage:** Można wgrać zawartość `build/web` do bucketu i włączyć hosting statyczny (jeśli w Twoim planie jest taka opcja).
   - **Własny serwer:** Skopiuj `build/web` na serwer i skonfiguruj serwer WWW (np. nginx) tak, żeby serwował SPA (fallback na `index.html`).

3. **URL:** Ustaw w Supabase (Auth URL redirect) i Stripe (success/cancel URL) adres strony, np. `https://twojadomena.pl`.

Dokładna instrukcja: [docs.flutter.dev/deployment/web](https://docs.flutter.dev/deployment/web).

---

## 3. Windows

1. **Build:**
   ```bash
   flutter build windows
   ```
   Aplikacja w `build/windows/runner/Release/` (folder z `.exe` i DLL).

2. **Dystrybucja:**
   - **Ręcznie:** Spakuj folder Release (np. ZIP) i udostępnij użytkownikom.
   - **Microsoft Store (opcjonalnie):** Potrzebne konto developer, pakiet w formacie MSIX – [docs.flutter.dev/deployment/windows](https://docs.flutter.dev/deployment/windows).

3. **Uwaga:** Niektóre pluginy (np. skaner kodów, powiadomienia) mogą mieć ograniczoną obsługę na Windows – przetestuj wszystkie funkcje.

---

## 4. Mac (desktop)

1. **Build:**
   ```bash
   flutter build macos
   ```
   Aplikacja w `build/macos/Build/Products/Release/` (plik `.app`).

2. **Notaryzacja (żeby macOS nie blokował):** Potrzebne konto Apple Developer. Podpisz i prześlij do Apple do notaryzacji (Xcode lub `xcrun notarytool`). Bez tego użytkownicy zobaczą ostrzeżenie „aplikacja od nieznanego dewelopera”.

3. **Dystrybucja:**
   - **Ręcznie:** Daj użytkownikom `.app` (np. w DMG).
   - **Mac App Store (opcjonalnie):** Wymaga pełnej konfiguracji w App Store Connect i sandboxu – [docs.flutter.dev/deployment/macos](https://docs.flutter.dev/deployment/macos).

---

## Szybka lista kontrolna

| Platforma   | Konto / narzędzie              | Komenda build           | Gdzie wgrać / co udostępnić      |
|------------|---------------------------------|-------------------------|-----------------------------------|
| iOS        | Apple Developer, Xcode          | `flutter build ipa`     | App Store Connect (Transporter)   |
| Android    | Play Console, keystore          | `flutter build appbundle` | Play Console (upload .aab)     |
| Web        | Konto u hostingu                | `flutter build web`     | Hosting (Firebase/Vercel/Netlify/…) |
| Windows    | –                               | `flutter build windows` | ZIP / Microsoft Store (MSIX)    |
| macOS      | Apple Developer (do notaryzacji)| `flutter build macos`   | DMG / Mac App Store              |

---

## Po wdrożeniu

- Stripe: tryb **Live**, live webhook, live klucze w Supabase.
- W aplikacji (wszystkie platformy): ten sam projekt Supabase i ten sam backend.
- Zwiększaj `version` / build number przy każdej nowej wersji w sklepach.
