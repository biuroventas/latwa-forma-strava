#!/usr/bin/env bash
# Ustawia adresy powrotu Stripe na latwaforma.pl (nie app.latwaforma.pl).
# Po płatności użytkownik wraca na latwaforma.pl/#/premium-success.
set -e
echo "Ustawianie STRIPE_SUCCESS_URL i STRIPE_CANCEL_URL na latwaforma.pl..."
supabase secrets set \
  STRIPE_SUCCESS_URL='https://latwaforma.pl/#/premium-success' \
  STRIPE_CANCEL_URL='https://latwaforma.pl/#/premium-cancel'
echo "Gotowe. Przekierowania po płatności będą na latwaforma.pl."
