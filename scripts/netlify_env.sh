#!/bin/bash
# Tworzy .env ze zmiennych Netlify przed `flutter build web`, żeby aplikacja miała SUPABASE_* w buildzie.
if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_URL=$SUPABASE_URL" > .env
  echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
  echo "Created .env from Netlify env vars"
else
  echo "Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set – app will run without backend"
fi
