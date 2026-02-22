#!/usr/bin/env bash
# Wgrywa na Netlify (strona latwaforma.pl) build aplikacji Flutter web.
# latwaforma.pl otwiera od razu aplikację; /polityka-prywatnosci.html, /regulamin.html itd. działają z tej samej domeny.
# Wymaga: netlify login + netlify link (strona latwaforma).

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

bash scripts/prepare_app_latwaforma_pl.sh

# Tymczasowo ukryj netlify.toml, żeby CLI nie uruchamiało ponownie buildu – tylko wgrało folder.
TOML="$ROOT/netlify.toml"
BAK="$ROOT/netlify.toml.bak"
if [ -f "$TOML" ]; then
  mv "$TOML" "$BAK"
fi
trap 'if [ -f "$BAK" ]; then mv "$BAK" "$TOML"; fi' EXIT

npx netlify deploy --dir=build/web --prod

echo "Gotowe. Aplikacja: https://latwaforma.pl"
