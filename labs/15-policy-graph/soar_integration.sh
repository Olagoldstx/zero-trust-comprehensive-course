#!/usr/bin/env bash
set -euo pipefail

echo "🔒 Policy Graph SOAR Integration"
echo "================================"

RISK_THRESHOLD="${1:-20}"

# Analyze attack paths
python3 labs/15-policy-graph/pathfinder.py > /tmp/graph_analysis.txt

# Extract highest risk score
HIGHEST_RISK=$(grep "Risk Score:" /tmp/graph_analysis.txt | head -1 | awk '{print $3}')

if [[ -n "$HIGHEST_RISK" && "$HIGHEST_RISK" -ge "$RISK_THRESHOLD" ]]; then
    echo "🚨 CRITICAL: Attack path detected with risk score $HIGHEST_RISK (threshold: $RISK_THRESHOLD)"
    echo "📋 Top attack path:"
    grep -A 2 "1\. Risk Score:" /tmp/graph_analysis.txt | head -3
    
    # Trigger SOAR response
    echo '{"mode":"restricted"}' > labs/11-soar-integration/policy_state.json
    echo "✅ SOAR Response: Policy set to RESTRICTED mode"
    
    # Log the event
    echo "$(date -Is) - Graph analysis triggered restricted mode (risk: $HIGHEST_RISK)" >> labs/15-policy-graph/soar_actions.log
else
    echo "✅ No critical attack paths detected (highest risk: ${HIGHEST_RISK:-0})"
    echo '{"mode":"normal"}' > labs/11-soar-integration/policy_state.json
fi

echo ""
echo "📊 Analysis saved to: /tmp/graph_analysis.txt"
