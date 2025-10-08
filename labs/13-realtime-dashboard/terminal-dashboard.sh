#!/usr/bin/env bash

echo "🔭 Zero-Trust Multicloud - Terminal Dashboard"
echo "============================================="
echo ""

while true; do
    # Clear screen
    clear
    
    # Header
    echo "🔭 Zero-Trust Multicloud - Live Terminal Dashboard"
    echo "=================================================="
    echo ""
    
    # Get correlations
    echo "📊 CORRELATED USERS (Multi-Cloud + High Severity):"
    echo "--------------------------------------------------"
    CORRELATIONS=$(curl -s http://127.0.0.1:5050/api/correlations 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$CORRELATIONS" ]; then
        echo "$CORRELATIONS" | jq -r '
            .[] | 
            if .correlated == true and .high_sev > 0 then
                "🚨 \(.user) | Clouds: \(.clouds | join(",")) | High: \(.high_sev) | Total: \(.total_events)"
            elif .correlated == true then
                "⚠️  \(.user) | Clouds: \(.clouds | join(",")) | Events: \(.total_events)"
            else
                "✅ \(.user) | Cloud: \(.clouds[0]) | Events: \(.total_events)"
            end
        ' | head -10
    else
        echo "    (Unable to fetch correlations)"
    fi
    
    echo ""
    echo "📈 RECENT SECURITY EVENTS:"
    echo "-------------------------"
    EVENTS=$(curl -s "http://127.0.0.1:5050/api/events?n=8" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$EVENTS" ]; then
        echo "$EVENTS" | jq -r '
            .[] | 
            "\(.timestamp[11:19]) | \(.cloud) | \(.user) | \(.severity) | \(.message[0:40])..."
        ' | head -8
    else
        echo "    (Unable to fetch events)"
    fi
    
    echo ""
    echo "🔄 Refreshing in 5 seconds... (Ctrl+C to exit)"
    sleep 5
done
