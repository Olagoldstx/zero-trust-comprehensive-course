#!/usr/bin/env bash
set -euo pipefail

OPA_URL="http://127.0.0.1:8181/v1/data/telemetry/enforce/allow"
OUT="decision_logs.jsonl"
COUNT=50
SLEEP=0.1

echo "🎯 Generating $COUNT clean test events to $OUT"

# Remove any existing file and create fresh
rm -f "$OUT"
touch "$OUT"

users=("ola" "admin" "guest" "analyst" "api")

for i in $(seq 1 $COUNT); do
    user=${users[$RANDOM % ${#users[@]}]}
    risk=$((RANDOM % 100))
    comp=$((RANDOM % 2))
    
    if [ $comp -eq 1 ]; then
        device_compliant="true"
    else
        device_compliant="false"
    fi

    # Create the request body
    body="{\"input\": {\"user\": \"$user\", \"context\": {\"risk\": $risk}, \"device\": {\"compliant\": $device_compliant}}}"
    
    # Make the request to OPA and capture response
    response=$(curl -s -H "Content-Type: application/json" -d "$body" "$OPA_URL" 2>/dev/null || echo "{}")
    
    # Extract result safely
    if echo "$response" | jq -e '.result' >/dev/null 2>&1; then
        result=$(echo "$response" | jq -r '.result')
        decision_id=$(echo "$response" | jq -r '.decision_id // "unknown"')
    else
        # Fallback logic
        if [ "$user" == "ola" ] && [ $risk -le 50 ] && [ "$device_compliant" == "true" ]; then
            result="true"
        elif [ "$user" == "admin" ] && [ $risk -le 70 ] && [ "$device_compliant" == "true" ]; then
            result="true" 
        elif [ "$user" == "guest" ] && [ $risk -le 30 ] && [ "$device_compliant" == "true" ]; then
            result="true"
        elif [ "$user" == "analyst" ] && [ $risk -le 40 ] && [ "$device_compliant" == "true" ]; then
            result="true"
        elif [ "$user" == "api" ] && [ $risk -le 60 ] && [ "$device_compliant" == "true" ]; then
            result="true"
        else
            result="false"
        fi
        decision_id="fallback-$i"
    fi
    
    # Create clean JSON event using jq to ensure proper formatting
    event=$(jq -n \
        --arg ts "$(date -Is)" \
        --arg user "$user" \
        --argjson risk "$risk" \
        --argjson compliant "$device_compliant" \
        --arg decision_id "$decision_id" \
        --argjson result "$result" \
        '{
            ts: $ts,
            user: $user, 
            risk: $risk,
            device_compliant: $compliant,
            decision_id: $decision_id,
            result: $result
        }')
    
    # Append to file
    echo "$event" >> "$OUT"
    echo -n "."
    
    sleep $SLEEP
done

echo ""
echo "✅ Generated $COUNT clean events in $OUT"

# Validate the file
echo "📋 Validating JSON format..."
if jq -e . < "$OUT" >/dev/null 2>&1; then
    echo "✅ JSON is valid"
else
    echo "❌ JSON validation failed"
    exit 1
fi
