#!/usr/bin/env bash

ALERT_FILE="${1:-labs/10-siem-analytics/decision_logs.jsonl}"
WINDOW="${WINDOW:-50}"

if [[ ! -f "$ALERT_FILE" ]]; then
  echo '{"error": "File not found"}' 
  exit 1
fi

# Use jq to process JSON properly
allow_count=0
deny_count=0

# Process last WINDOW lines with jq
while IFS= read -r line; do
  if [[ -n "$line" ]]; then
    risk=$(echo "$line" | jq -r '.risk' 2>/dev/null)
    if [[ "$risk" =~ ^[0-9]+$ ]]; then
      if [[ "$risk" -gt 70 ]]; then
        ((deny_count++))
      else
        ((allow_count++))
      fi
    fi
  fi
done < <(tail -n "$WINDOW" "$ALERT_FILE")

# Calculate ratios
total=$((allow_count + deny_count))
if [[ $total -gt 0 ]]; then
  deny_ratio=$(echo "scale=2; $deny_count / $total" | bc)
  allow_pct=$(echo "scale=1; $allow_count * 100 / $total" | bc)
  deny_pct=$(echo "scale=1; $deny_count * 100 / $total" | bc)
else
  deny_ratio=0
  allow_pct=0
  deny_pct=0
fi

# Output clean JSON
cat << JSON
{
  "window": $WINDOW,
  "totals": {
    "allow": $allow_count,
    "deny": $deny_count,
    "deny_ratio": $deny_ratio,
    "allow_percentage": $allow_pct,
    "deny_percentage": $deny_pct
  }
}
JSON
