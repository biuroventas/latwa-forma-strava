# Jak włączyć anonimową autoryzację w Supabase

Błąd autoryzacji może wynikać z tego, że anonimowa autoryzacja nie jest włączona w Twoim projekcie Supabase.

## Krok po kroku:

1. **Otwórz Supabase Dashboard:**
   - Przejdź do: https://supabase.com/dashboard/project/tslsayftpegpliihfmyg
   - Zaloguj się do swojego konta

2. **Przejdź do ustawień autoryzacji:**
   - W menu po lewej stronie kliknij **"Authentication"** (ikona klucza)
   - Następnie kliknij **"Providers"** w menu po lewej

3. **Włącz anonimową autoryzację:**
   - Przewiń w dół do sekcji **"Anonymous"**
   - Przełącz przełącznik **"Enable Anonymous Sign-ins"** na **ON**
   - Kliknij **"Save"**

4. **Sprawdź ustawienia:**
   - Upewnij się, że przełącznik jest zielony (włączony)
   - Możesz również sprawdzić inne ustawienia autoryzacji

5. **Uruchom aplikację ponownie:**
   ```bash
   flutter run
   ```

## Alternatywnie - przez SQL:

Możesz też włączyć anonimową autoryzację przez SQL Editor:

```sql
-- Włącz anonimową autoryzację
UPDATE auth.config 
SET enable_anonymous_sign_ins = true;
```

## Sprawdź czy działa:

Po włączeniu anonimowej autoryzacji, uruchom aplikację i spróbuj zapisać profil. Powinno działać bez błędów autoryzacji.
