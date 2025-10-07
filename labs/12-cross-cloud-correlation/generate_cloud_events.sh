#!/usr/bin/env bash
set -euo pipefail

OUT="labs/12-cross-cloud-correlation/multicloud_events.jsonl"
COUNT="${COUNT:-60}"
mkdir -p "$(dirname "$OUT")"
> "$OUT"  # Clear file

clouds=("aws" "azure" "gcp")
users=("ola" "admin" "guest" "devops" "attacker" "monitor")

echo "🌐 Generating $COUNT synthetic multi-cloud events..."

for i in $(seq 1 "$COUNT"); do
  cloud=${clouds[$RANDOM % ${#clouds[@]}]}
  user=${users[$RANDOM % ${#users[@]}]}
  sev=$((RANDOM % 5))
  
  # More realistic event types
  case $((RANDOM % 6)) in
    0) msg="Login failure" ;;
    1) msg="Privilege escalation attempt" ;;
    2) msg="Unusual API call pattern" ;;
    3) msg="Resource access from unusual location" ;;
    4) msg="Security group modification" ;;
    5) msg="IAM policy change detected" ;;
  esac
  
  # Make some events high severity and correlated
  if [[ "$user" == "attacker" ]]; then
    sev=4
    # Attacker appears across multiple clouds
    cloud=${clouds[$((i % 3))]}
  fi
  
  jq -nc --arg c "$cloud" --arg u "$user" --arg m "$msg" \
    --argjson s "$sev" --arg ts "$(date -Is)" \
    '{timestamp:$ts,cloud:$c,user:$u,severity:$s,message:$m}' \
    >> "$OUT"
    
  sleep 0.01
done

echo "✅ Generated $COUNT synthetic multi-cloud events → $OUT"
echo "📊 Sample event:"
tail -1 "$OUT" | jq .
