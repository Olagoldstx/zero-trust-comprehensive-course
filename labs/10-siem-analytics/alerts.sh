#!/usr/bin/env bash

FILE="decision_logs.jsonl"
WINDOW=50
THRESHOLD=0.60
INTERVAL=3

echo "🔎 Watching deny ratio every ${INTERVAL}s (window=${WINDOW}) threshold=${THRESHOLD}"
echo "📁 Monitoring: $FILE"

counter=0
while true; do
    ((counter++))
    
    if [ ! -f "$FILE" ]; then
        echo "[$counter] ❌ File not found"
        sleep $INTERVAL
        continue
    fi
    
    # Get metrics
    metrics=$(./compute_metrics.sh "$FILE" 2>/dev/null || echo "{}")
    
    # Extract values safely
    deny_ratio=$(echo "$metrics" | grep -o '"deny_ratio":[^,]*' | cut -d: -f2 | tr -d ' ' || echo "0")
    window_size=$(echo "$metrics" | grep -o '"window":[^,]*' | cut -d: -f2 | tr -d ' ' || echo "0")
    
    printf "[%d] deny_ratio=%.3f window=%s" "$counter" "$deny_ratio" "$window_size"
    
    # Check threshold (using awk for floating point comparison)
    if command -v awk >/dev/null 2>&1; then
        above=$(awk -v a="$deny_ratio" -v b="$THRESHOLD" 'BEGIN {if (a > b) print 1; else print 0}')
    else
        # Basic comparison without awk
        above=$(echo "$deny_ratio > $THRESHOLD" | bc -l 2>/dev/null || echo "0")
    fi
    
    if [ "$above" = "1" ]; then
        echo " 🚨 ALERT: ${deny_ratio} > ${THRESHOLD}"
    else
        echo ""
    fi
    
    sleep $INTERVAL
done
