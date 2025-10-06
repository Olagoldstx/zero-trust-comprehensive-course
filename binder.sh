#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_PDF="$ROOT/ZeroTrust_Binder.pdf"

FILES=(
  "$ROOT/cover.md"
  "$ROOT/docs/models/01-threat-model.md"
  "$ROOT/labs/02-pep-proxy/policy.rego"
  "$ROOT/labs/02-pep-proxy/pep.js"
  "$ROOT/labs/02-pep-proxy/target.js"
  "$ROOT/labs/03-dynamic-signals/policy.rego"
)

echo "📚 Building Zero Trust Binder..."

# Verify inputs exist
for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ Missing: $f"
    exit 1
  fi
done

# Build PDF with XeLaTeX
pandoc "${FILES[@]}" -s --pdf-engine=xelatex -o "$OUT_PDF"

echo "✅ Binder created: $OUT_PDF"
