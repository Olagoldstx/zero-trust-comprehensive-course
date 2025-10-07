#!/usr/bin/env bash
set -euo pipefail

ALERT_FILE="${1:-labs/10-siem-analytics/decision_logs.jsonl}"
WINDOW="${WINDOW:-50}"

if [[ ! -f "$ALERT_FILE" ]]; then
  echo "❌ Error: Alert file not found: $ALERT_FILE" >&2
  exit 1
fi

echo "📊 Analyzing last $WINDOW events from: $ALERT_FILE" >&2

# Count total lines
total_lines=$(wc -l < "$ALERT_FILE")
echo "Total lines in file: $total_lines" >&2

# Get last WINDOW lines
tail -n "$WINDOW" "$ALERT_FILE" > "/tmp/last_${WINDOW}_events.jsonl"

echo "Analyzing last $WINDOW events" >&2

# Count allows and denies using simple grep
allow_count=$(grep -c '"result":true' "/tmp/last_${WINDOW}_events.jsonl" || echo "0")
deny_count=$(grep -c '"result":false' "/tmp/last_${WINDOW}_events.jsonl" || echo "0")

echo "Using alternative counting method..." >&2
echo "Allowed: $allow_count" >&2
echo "Denied: $deny_count" >&2

# Calculate percentages safely
if [[ $WINDOW -gt 0 ]]; then
  allow_pct=$(echo "scale=2; $allow_count / $WINDOW * 100" | bc | awk '{printf "%.1f", $0}')
  deny_pct=$(echo "scale=2; $deny_count / $WINDOW * 100" | bc | awk '{printf "%.1f", $0}')
  deny_ratio=$(echo "scale=2; $deny_count / $WINDOW" | bc | awk '{printf "%.2f", $0}')
else
  allow_pct="0"
  deny_pct="0" 
  deny_ratio="0"
fi

echo "=== FINAL RESULTS ===" >&2
echo "Window size: $WINDOW" >&2
echo "Total events: $WINDOW" >&2
echo "Allowed: $allow_count ($allow_pct%)" >&2
echo "Denied: $deny_count ($deny_pct%)" >&2
echo "Deny ratio: $deny_ratio" >&2

# Output JSON for other scripts to parse
cat << EOF
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
EOF
