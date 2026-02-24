#!/usr/bin/env bash
# Wgrywa na Netlify (strona latwaforma.pl) build aplikacji Flutter web.
# Endpoint /api/garmin (Garmin Coverage Test) jest w netlify.toml – wdraża się przy deployu z Gita (Netlify CI).
# Lokalnie: build + upload folderu (bez netlify build, żeby uniknąć konfliktu pluginu Flutter).

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

bash scripts/prepare_latwaforma_pl.sh

# Tymczasowo ukryj netlify.toml, żeby CLI nie uruchamiało buildu – tylko wgrało folder (bez Netlify Functions).
TOML="$ROOT/netlify.toml"
BAK="$ROOT/netlify.toml.bak"
if [ -f "$TOML" ]; then
  mv "$TOML" "$BAK"
fi
trap 'if [ -f "$BAK" ]; then mv "$BAK" "$TOML"; fi' EXIT

npx netlify deploy --dir=build/web --prod

echo "Gotowe. Aplikacja: https://latwaforma.pl"
echo "Endpoint /api/garmin: wdrożysz go przez push do Gita (Netlify zbuduje i wgra funkcję)."
