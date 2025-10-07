#!/usr/bin/env bash
THRESHOLD=0.3     # Lower threshold to 30% for testing
WINDOW=10         # Shorter window

deny=0
total=0
start=$(date +%s)

while true; do
  m=$(curl -s http://127.0.0.1:8181/metrics)
  allow_cnt=$(echo "$m" | grep -Ei 'allow.*_count|decision.*allow.*_count' | awk '{s+=$2} END{print s+0}')
  eval_cnt=$(echo "$m" | grep -Ei 'opa_decision_duration_seconds_count|opa_eval_duration_seconds_count' | awk '{s+=$2} END{print s+0}')

  total=${eval_cnt:-0}
  allow=${allow_cnt:-0}
  deny=$(( total - allow ))

  now=$(date +%s)
  if (( now - start >= WINDOW && total > 0 )); then
    ratio=$(awk -v d="$deny" -v t="$total" 'BEGIN{if(t==0)print 0; else print d/t}')
    echo "$(date -Is) window=${WINDOW}s total=$total allow=$allow deny=$deny deny_ratio=$ratio"

    awk -v r="$ratio" -v th="$THRESHOLD" 'BEGIN{exit !(r>th)}' && {
      echo "🚨 TEST CONTAINMENT TRIGGERED: deny_ratio=$ratio > $THRESHOLD"
      echo "This would execute real containment actions:"
      echo "- Isolate compromised devices"
      echo "- Block suspicious IP ranges"
      echo "- Revoke high-risk sessions"
      break
    }
    start=$now
  fi
  sleep 2
done
