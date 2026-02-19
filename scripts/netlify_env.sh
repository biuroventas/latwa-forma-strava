#!/bin/bash
# Tworzy plik env z zmiennych Netlify przed `flutter build web`.
# Na webie pliki z kropką (.env) często nie działają w buildzie – używamy env.production.
if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_URL=$SUPABASE_URL" > env.production
  echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> env.production
  echo "Created env.production from Netlify env vars"
else
  echo "Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set – app will run without backend"
  touch env.production
fi
