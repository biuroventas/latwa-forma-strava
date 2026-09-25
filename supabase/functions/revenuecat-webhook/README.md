# revenuecat-webhook

Supabase Edge Function: synchronizuje status Premium z RevenueCat do `profiles`.

## Deploy

```bash
supabase secrets set REVENUECAT_WEBHOOK_AUTH=losowy-sekret
supabase functions deploy revenuecat-webhook --no-verify-jwt
```

W RevenueCat → Project → Integrations → Webhooks:

- URL: `https://<PROJECT_REF>.supabase.co/functions/v1/revenuecat-webhook`
- Authorization: `Bearer <ten sam sekret>`

## Zachowanie

- `app_user_id` musi być Supabase `auth.users.id` (ustawiane przez `Purchases.logIn` w apce).
- Aktywne: INITIAL_PURCHASE, RENEWAL, UNCANCELLATION, …
- Wygaśnięcie: EXPIRATION (oraz CANCELLATION po `expiration_at_ms`).
