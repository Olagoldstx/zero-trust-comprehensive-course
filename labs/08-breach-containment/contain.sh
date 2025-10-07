#!/usr/bin/env bash
# safer flags (avoid exiting on minor subshell issues)
set -e

OPA_URL="http://127.0.0.1:8181/v1/data/telemetry/enforce/allow"
WINDOW_SEC=20          # measure over 20 seconds
SAMPLES=80             # number of decisions per window
THRESHOLD=0.6          # trigger if >60% denies

# Pre-compute the pacing interval; fall back to 0.25s if awk fails
INTERVAL=$(awk -v w="$WINDOW_SEC" -v n="$SAMPLES" 'BEGIN{ if(n>0){print w/n}else{print 0.25} }') || INTERVAL=0.25

good='{"input":{"user":"ola","device":{"compliant":true},"context":{"risk":25}}}'
bad='{"input":{"user":"guest","device":{"compliant":true},"context":{"risk":75}}}'

echo "🎯 Watching deny ratio every ${WINDOW_SEC}s (samples=${SAMPLES}) threshold=${THRESHOLD} interval=${INTERVAL}s"

while true; do
  allow=0
  deny=0

  for ((i=1;i<=SAMPLES;i++)); do
    payload="$good"
    (( i % 2 == 0 )) && payload="$bad"

    # If OPA is briefly unavailable, treat as deny but keep going
    res=$(curl -sS -H "Content-Type: application/json" -d "$payload" "$OPA_URL" || echo "")
    if echo "$res" | grep -q '"result":true'; then
      ((allow++))
    else
      ((deny++))
    fi

    sleep "$INTERVAL"
  done

  total=$((allow+deny))
  if [ "$total" -gt 0 ]; then
    ratio=$(awk -v d="$deny" -v t="$total" 'BEGIN{printf "%.3f", d/t}')
  else
    ratio="0.000"
  fi

  ts=$(date -Is 2>/dev/null || date)

  echo "$ts window=${WINDOW_SEC}s total=$total allow=$allow deny=$deny deny_ratio=$ratio"

  awk -v r="$ratio" -v th="$THRESHOLD" 'BEGIN{exit !(r>th)}' && {
    echo "🚨 Containment triggered: deny_ratio=$ratio > $THRESHOLD"
    # TODO: place your containment action here (block IP, revoke session, call EDR/MDM, etc.)
    break
  }
done
