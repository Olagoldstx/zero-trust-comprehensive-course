#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-decision_logs.jsonl}"
WINDOW="${WINDOW:-200}"

echo "📊 Simple Metrics - Last $WINDOW events from: $FILE"

if [[ ! -f "$FILE" ]]; then
    echo "❌ Error: File $FILE not found"
    exit 1
fi

# Get the last WINDOW lines
tail -n "$WINDOW" "$FILE" > /tmp/current_window.jsonl

# Basic counts
total=$(wc -l < /tmp/current_window.jsonl)
allow=$(grep '"result":true' /tmp/current_window.jsonl | wc -l)
deny=$(grep '"result":false' /tmp/current_window.jsonl | wc -l)

# Calculate ratios
if [[ $total -gt 0 ]]; then
    deny_ratio=$(echo "scale=3; $deny / $total" | bc)
    allow_ratio=$(echo "scale=3; $allow / $total" | bc)
else
    deny_ratio=0
    allow_ratio=0
fi

echo "{
  \"window\": $total,
  \"allow\": $allow,
  \"deny\": $deny,
  \"deny_ratio\": $deny_ratio,
  \"allow_ratio\": $allow_ratio
}"

# Cleanup
rm -f /tmp/current_window.jsonl
