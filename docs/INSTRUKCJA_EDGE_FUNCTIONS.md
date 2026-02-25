# Edge Functions – instrukcja wdrożenia

Funkcje `delete_user` (usuwanie konta) i `invite_user` (zapraszanie znajomych) działają jako Supabase Edge Functions. Aby działały w aplikacji, muszą być **wdrożone** do Twojego projektu Supabase.

## Zaproś znajomego (invite_user) – co trzeba zrobić

1. **Wdróż funkcję** (bez `--no-verify-jwt` – wymagana jest zalogowana sesja):
   ```bash
   supabase functions deploy invite_user
   ```
2. **Opcjonalnie** – w Supabase → Edge Functions → Secrets ustaw:
   - `INVITE_REDIRECT_URL` = adres, na który ma trafić zaproszony po kliknięciu w link (domyślnie: `https://latwaforma.pl/`).
3. W aplikacji: Profil → **Zaproś znajomego** → wpisz e-mail → Wyślij. Zaproszenie leci z Supabase Auth (mail z linkiem do rejestracji).

Jeśli widzisz **„Sesja wygasła”**: odśwież stronę (F5), zaloguj się ponownie i spróbuj jeszcze raz. Aplikacja przed wysłaniem odświeża sesję i wywołuje funkcję przez HTTP z aktualnym tokenem.

## Czy trzeba coś konfigurować w panelu Supabase?

**Nie.** W panelu Supabase nie trzeba nic włączać ani ustawiać. Supabase automatycznie wstrzykuje do każdej Edge Function zmienne:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

Nie musisz ich ręcznie konfigurować – są dostępne od razu po wdrożeniu.

---

## Opcja 1: Wdrożenie przez CLI (zalecane)

### Wymagania
- Zainstalowany Supabase CLI
- Zalogowanie i powiązanie projektu

### Kroki

1. Zaloguj się do Supabase:
   ```bash
   supabase login
   ```

2. Powiąż projekt (jeśli jeszcze nie jest powiązany):
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   `YOUR_PROJECT_REF` znajdziesz w panelu Supabase: **Settings** → **General** → **Reference ID**.

3. Wdróż funkcje:
   ```bash
   supabase functions deploy delete_user
   supabase functions deploy invite_user
   ```

Po wdrożeniu funkcje będą dostępne pod adresami:
- `https://[project-ref].supabase.co/functions/v1/delete_user`
- `https://[project-ref].supabase.co/functions/v1/invite_user`

---

## Opcja 2: Wdrożenie przez Dashboard

Jeśli nie chcesz używać CLI, możesz wdrożyć funkcje z poziomu panelu Supabase:

1. Wejdź na **supabase.com** → wybierz swój projekt.
2. W menu po lewej kliknij **Edge Functions**.
3. Kliknij **Deploy a new function** → **Via Editor**.
4. Nazwij funkcję: `delete_user`.
5. W edytorze wklej cały kod z pliku `supabase/functions/delete_user/index.ts` z tego repozytorium.
6. Kliknij **Deploy function**.
7. Powtórz kroki 3–6 dla funkcji `invite_user` (użyj pliku `supabase/functions/invite_user/index.ts`).

### Uwaga
Edytor w Dashboard nie ma wersjonowania. Dla większych zmian lepiej używać CLI i repozytorium.

---

## Sprawdzenie, czy działa

- **delete_user**: Kliknij „Usuń konto” w profilu – jeśli widzisz błąd 404, funkcja nie jest wdrożona.
- **invite_user**: Użyj „Zaproś znajomego” – jeśli zaproszenie się wysyła, funkcja działa.

---

## Błędy 404 po wdrożeniu

Jeśli nadal widzisz 404:
1. Sprawdź, czy nazwa funkcji to dokładnie `delete_user` (bez `-`, małe litery).
2. Poczekaj kilka minut – czasami propagacja trwa chwilę.
3. Upewnij się, że URL projektu w `.env` (SUPABASE_URL) wskazuje na ten sam projekt, do którego wdrożyłeś funkcje.
