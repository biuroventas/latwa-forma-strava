# Edge Function: ai-advice

Proxy do OpenAI dla „Porady AI” w aplikacji. Dzięki temu klucz API nie jest wysyłany z przeglądarki (brak CORS i ryzyka wycieku).

## Wymagania

- W projekcie Supabase ustaw sekret: **OPENAI_API_KEY** (klucz z platform.openai.com).

## Wdrożenie

```bash
# Z katalogu głównego projektu
supabase functions deploy ai-advice --no-verify-jwt

# Ustawienie sekretu (jeśli jeszcze nie ustawiony)
supabase secrets set OPENAI_API_KEY=sk-...
```

Flaga `--no-verify-jwt` sprawia, że żądania z aplikacji (anon key lub użytkownik) docierają do funkcji; autoryzację sprawdza sama funkcja (nagłówek Bearer).

Po wdrożeniu aplikacja web (latwaforma.pl) wywołuje tę funkcję zamiast OpenAI bezpośrednio – Porada AI działa w przeglądarce bez błędu CORS.
