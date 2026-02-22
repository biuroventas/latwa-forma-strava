#!/usr/bin/env bash
# Przygotowuje jeden folder do wgrania na Netlify: landing + polityka + regulamin.
# Uruchom z katalogu głównego projektu: bash scripts/prepare_latwaforma_pl_site.sh
# Wynik: folder dist_latwaforma_pl/ – jego ZAWARTOŚĆ przeciągnij na app.netlify.com/drop

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist_latwaforma_pl"
rm -rf "$OUT"
mkdir -p "$OUT"

cp "$ROOT/landing_latwaforma_pl/index.html" "$OUT/"
cp "$ROOT/web/polityka-prywatnosci.html" "$OUT/"
cp "$ROOT/web/regulamin.html" "$OUT/"
cp "$ROOT/web/privacy.html" "$OUT/"
cp "$ROOT/web/terms.html" "$OUT/"
# auth_redirect – opcjonalnie, jeśli chcesz magic link na tej samej domenie
mkdir -p "$OUT/auth_redirect"
cp "$ROOT/web/auth_redirect/index.html" "$OUT/auth_redirect/" 2>/dev/null || true

echo "Gotowe: $OUT"
echo "Zawartość folderu dist_latwaforma_pl wgraj na Netlify (Drop lub jako publish directory)."
