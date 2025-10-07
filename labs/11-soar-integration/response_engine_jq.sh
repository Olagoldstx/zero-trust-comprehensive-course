#!/usr/bin/env bash

ALERT_FILE="${ALERT_FILE:-labs/10-siem-analytics/decision_logs.jsonl}"
ACTION_LOG="labs/11-soar-integration/actions.log"
THRESHOLD="${THRESHOLD:-0.6}"
WINDOW="${WINDOW:-100}"
SLEEP="${SLEEP:-5}"

mkdir -p "$(dirname "$ACTION_LOG")"

echo "🤖 Monitoring alerts from $ALERT_FILE (threshold=$THRESHOLD)..."

while true; do
  if [[ -f "$ALERT_FILE" ]]; then
    # Use the jq metrics script
    json_output=$(WINDOW=$WINDOW ./labs/10-siem-analytics/compute_metrics_jq.sh "$ALERT_FILE")
    ratio=$(echo "$json_output" | jq -r '.totals.deny_ratio')
    
    # Handle if ratio is null or empty
    if [[ "$ratio" == "null" || -z "$ratio" ]]; then
      ratio="0"
    fi
    
    above=$(echo "$ratio > $THRESHOLD" | bc -l 2>/dev/null || echo "0")
    ts=$(date -Is)
    
    if [[ "$above" -eq 1 ]]; then
      echo "$ts 🚨 SOAR Trigger: deny_ratio=$ratio  → Action: quarantine API access" | tee -a "$ACTION_LOG"
    else
      echo "$ts ✅ Normal operation, deny_ratio=$ratio" >> "$ACTION_LOG"
    fi
  else
    echo "$(date -Is) ⚠️  No alert file found: $ALERT_FILE" >> "$ACTION_LOG"
  fi
  sleep "$SLEEP"
done
