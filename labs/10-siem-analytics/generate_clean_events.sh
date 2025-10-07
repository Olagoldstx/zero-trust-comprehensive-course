#!/usr/bin/env bash

LOG_FILE="labs/10-siem-analytics/decision_logs.jsonl"
EVENTS=200

echo "🎲 Generating $EVENTS clean test events..."

# Ensure directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Clear existing file
> "$LOG_FILE"

for i in $(seq 1 $EVENTS); do
  # Random risk between 1-100
  risk=$(( RANDOM % 100 + 1 ))
  user="user$(( RANDOM % 5 ))"
  compliant=$(( RANDOM % 2 ))
  
  # Create proper JSON event
  if [[ $risk -gt 70 ]]; then
    result="false"
  else
    result="true"
  fi
  
  cat << JSON >> "$LOG_FILE"
{"ts":"$(date -Is)","user":"$user","risk":$risk,"device_compliant":true,"result":$result}
JSON
  sleep 0.01
done

echo "✅ Generated $EVENTS clean test events to $LOG_FILE"
echo "Sample event:"
tail -1 "$LOG_FILE" | jq .
