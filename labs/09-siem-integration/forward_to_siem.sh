#!/usr/bin/env bash
OPA_URL="http://127.0.0.1:8181"
SIEM_URL="http://127.0.0.1:9200/ingest"
LOG_FILE="opa_siem_forwarder.log"

echo "📡 Zero-Trust SIEM Integration Started"
echo "OPA: $OPA_URL"
echo "SIEM: $SIEM_URL"
echo "Log: $LOG_FILE"
echo ""

# Check if SIEM is reachable
if ! curl -s "$SIEM_URL" > /dev/null; then
  echo "❌ SIEM server not reachable at $SIEM_URL"
  echo "💡 Start it with: node siem_server.js"
  exit 1
fi

echo "✅ SIEM server is ready"
echo "🔄 Monitoring OPA decisions and forwarding to SIEM..."
echo "$(date -Is) - Forwarder started" >> "$LOG_FILE"

# Continuous monitoring loop
while true; do
  # Get OPA health and metrics
  health=$(curl -s "$OPA_URL/health")
  metrics=$(curl -s "$OPA_URL/metrics")
  
  # Extract decision count
  decision_count=$(echo "$metrics" | grep "opa_decision_duration_seconds_count" | awk '{print $2}' | tail -1)
  
  # Create SIEM event
  siem_event=$(cat << EVENT
{
  "timestamp": "$(date -Is)",
  "source": "zero-trust-opa",
  "event_type": "policy_decision_metrics",
  "data": {
    "decision_count": "$decision_count",
    "opa_health": $health,
    "collection_time": "$(date -Is)"
  }
}
EVENT
)
  
  # Send to SIEM
  curl -s -X POST -H "Content-Type: application/json" \
    -d "$siem_event" \
    "$SIEM_URL" >> "$LOG_FILE" 2>&1
  
  echo "$(date -Is) - Forwarded metrics: decisions=$decision_count" | tee -a "$LOG_FILE"
  sleep 10
done
