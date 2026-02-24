#!/usr/bin/env bash
# Buduje aplikację Flutter web i przygotowuje build/web pod wdrożenie na latwaforma.pl.
# Produkcja tylko na https://latwaforma.pl (Netlify) – bez subdomeny app.latwaforma.pl.
# Uruchom z katalogu głównego projektu.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Konfiguracja Supabase w buildzie web: env.production musi istnieć (ładuje go supabase_config.dart).
# Na Netlify CI tworzy go netlify_env.sh z zmiennych; przy lokalnym deployu bierzemy z .env.
if [ -f "$ROOT/.env" ]; then
  grep -E '^SUPABASE_URL=' "$ROOT/.env" > "$ROOT/env.production" 2>/dev/null || true
  grep -E '^SUPABASE_ANON_KEY=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^STRAVA_CLIENT_ID=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^STRAVA_CLIENT_SECRET=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^STRAVA_REDIRECT_URI=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^GARMIN_CLIENT_ID=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^GARMIN_CLIENT_SECRET=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  grep -E '^GARMIN_REDIRECT_URI=' "$ROOT/.env" >> "$ROOT/env.production" 2>/dev/null || true
  if [ -s "$ROOT/env.production" ]; then
    echo "env.production utworzony z .env (Supabase, Strava w buildzie)."
    mkdir -p "$ROOT/assets"
    cp "$ROOT/env.production" "$ROOT/assets/env.production"
  fi
fi
if [ ! -s "$ROOT/env.production" ] && [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_URL=$SUPABASE_URL" > "$ROOT/env.production"
  echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> "$ROOT/env.production"
  echo "env.production utworzony z zmiennych środowiskowych."
fi
if [ ! -s "$ROOT/env.production" ]; then
  echo "Uwaga: brak env.production i .env – aplikacja na webie uruchomi się bez Supabase („Zacznij bez konta” nie zadziała)."
  touch "$ROOT/env.production"
fi

echo "Budowanie Flutter web (optymalizacja: bez source maps)..."
# --no-source-maps: mniejszy build (mapy źródłowe nie są potrzebne w produkcji).
flutter build web --release --no-source-maps

BUILD_WEB="$ROOT/build/web"
echo "Dodawanie polityki, regulaminu, env.production i auth_redirect do build/web..."
cp "$ROOT/web/polityka-prywatnosci.html" "$BUILD_WEB/"
cp "$ROOT/web/regulamin.html" "$BUILD_WEB/"
cp "$ROOT/web/privacy.html" "$BUILD_WEB/"
cp "$ROOT/web/terms.html" "$BUILD_WEB/"
[ -f "$ROOT/web/garmin-callback.html" ] && cp "$ROOT/web/garmin-callback.html" "$BUILD_WEB/" || true
[ -f "$ROOT/web/strava-callback.html" ] && cp "$ROOT/web/strava-callback.html" "$BUILD_WEB/" || true
[ -f "$ROOT/web/logo300x300.png" ] && cp "$ROOT/web/logo300x300.png" "$BUILD_WEB/" || true
[ -f "$ROOT/env.production" ] && cp "$ROOT/env.production" "$BUILD_WEB/" || true
mkdir -p "$BUILD_WEB/auth_redirect"
cp "$ROOT/web/auth_redirect/index.html" "$BUILD_WEB/auth_redirect/" 2>/dev/null || true

# SPA: najpierw /api/garmin (Netlify Function), potem env, na końcu fallback na index.html.
printf '%s\n%s\n%s\n' '/api/garmin  /.netlify/functions/garmin  200' '/env.production  /env.production  200' '/*    /index.html   200' > "$BUILD_WEB/_redirects"

# Długi cache dla JS i assets – szybsze ponowne wejścia
cat > "$BUILD_WEB/_headers" << 'EOF'
/*.js
  Cache-Control: public, max-age=31536000, immutable
/*.wasm
  Cache-Control: public, max-age=31536000, immutable
/assets/*
  Cache-Control: public, max-age=31536000, immutable
/icons/*
  Cache-Control: public, max-age=31536000, immutable
EOF

echo "Gotowe: $BUILD_WEB (deploy na latwaforma.pl)"
