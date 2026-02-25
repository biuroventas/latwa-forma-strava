#!/usr/bin/env bash
# Wdraża Edge Functions dla Stripe (Premium). Bez --no-verify-jwt bramka zwraca 401:
# - create-checkout/create-portal – użytkownik nie może wykupić; stripe-webhook – Stripe dostaje 401 przy dostarczaniu eventów.
set -e
echo "Deploy Edge Functions (Stripe)..."
supabase functions deploy create-checkout-session --no-verify-jwt
supabase functions deploy create-portal-session --no-verify-jwt
supabase functions deploy stripe-webhook --no-verify-jwt
echo "Gotowe. Wszystkie trzy funkcje z --no-verify-jwt (Stripe nie wysyła JWT, webhook weryfikuje podpis)."
