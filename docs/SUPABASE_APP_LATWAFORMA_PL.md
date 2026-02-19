# Supabase – ustawienia dla latwaforma.pl

Żeby **Zacznij bez konta**, **Google** i **email** działały na https://latwaforma.pl, w projekcie Supabase ustaw poniższe.

---

## 1. Authentication → URL Configuration

- **Site URL:** `https://latwaforma.pl`
- **Redirect URLs** – dopisz (każdy w osobnej linii):
  - `https://latwaforma.pl`
  - `https://latwaforma.pl/**`

Zapisz (Save).

---

## 2. Authentication → Providers → Anonymous

- **Enable Anonymous Sign-Ins:** włącz (ON).

Bez tego przycisk „Zacznij bez konta” zwróci błąd (np. „Anonymous sign-ins are disabled”).

---

## 3. Authentication → Providers → Google (dla logowania Google)

- Włącz provider **Google**.
- Uzupełnij **Client ID** i **Client Secret** z Google Cloud Console (OAuth 2.0, typ „Aplikacja internetowa”, redirect URI z Supabase).

---

## 4. Netlify – zmienne środowiskowe

W **Netlify** → projekt → **Environment variables** muszą być ustawione:

- `SUPABASE_URL` = URL projektu (np. `https://xxxx.supabase.co`)
- `SUPABASE_ANON_KEY` = klucz anon (z Supabase → Project Settings → API)

Bez nich build nie ma połączenia z Supabase i „Zacznij bez konta” nie zadziała.

---

Po zapisaniu zmian w Supabase odśwież https://latwaforma.pl i spróbuj ponownie.
