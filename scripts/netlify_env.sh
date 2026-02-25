#!/bin/bash
# Tworzy plik env z zmiennych Netlify przed `flutter build web`.
# Na webie pliki z kropką (.env) często nie działają w buildzie – używamy env.production.
if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_URL=$SUPABASE_URL" > env.production
  echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> env.production
  # Publiczne/konfiguracyjne zmienne integracji używane na webie.
  [ -n "$STRAVA_CLIENT_ID" ] && echo "STRAVA_CLIENT_ID=$STRAVA_CLIENT_ID" >> env.production
  [ -n "$STRAVA_CLIENT_SECRET" ] && echo "STRAVA_CLIENT_SECRET=$STRAVA_CLIENT_SECRET" >> env.production
  [ -n "$STRAVA_REDIRECT_URI" ] && echo "STRAVA_REDIRECT_URI=$STRAVA_REDIRECT_URI" >> env.production
  [ -n "$GARMIN_CLIENT_ID" ] && echo "GARMIN_CLIENT_ID=$GARMIN_CLIENT_ID" >> env.production
  [ -n "$GARMIN_REDIRECT_URI" ] && echo "GARMIN_REDIRECT_URI=$GARMIN_REDIRECT_URI" >> env.production
  echo "Created env.production from Netlify env vars"
else
  echo "Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set – app will run without backend"
  touch env.production
fi
