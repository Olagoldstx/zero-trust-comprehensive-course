#!/bin/bash
echo "🔍 Starting OPA with Telemetry & SIEM Forwarding"
echo "================================================"

LOGFILE="opa_decision.log"
SIEM_ENDPOINT="https://siem.example.com/api/logs"  # Mock SIEM endpoint

# Clean up previous log
rm -f "$LOGFILE"

# Start OPA with decision logging and metrics
echo "Starting OPA server on :8181 with Prometheus metrics..."
opa run -s -a :8181 policy.rego \
  --set decision_logs.console=true \
  --set prometheus=true \
  --log-level=debug \
  2>&1 | tee -a "$LOGFILE" &

OPA_PID=$!
sleep 3

echo ""
echo "✅ OPA Server PID: $OPA_PID"
echo "📊 Metrics: http://localhost:8181/metrics"
echo "📝 Decision Log: $LOGFILE"
echo ""

# Start SIEM forwarder in background
echo "🔄 Starting SIEM Forwarder..."
tail -f "$LOGFILE" | while read line; do
  if echo "$line" | grep -q "decision_outcome"; then
    # Extract JSON decision log
    json_line=$(echo "$line" | sed 's/.*{/{/' | sed 's/}$//' | jq -r '.result[]?.msg? // empty')
    
    if [ -n "$json_line" ]; then
      # Simulate sending to SIEM
      echo "[SIEM] $(date): $json_line"
      
      # In production, this would be:
      # curl -X POST "$SIEM_ENDPOINT" \
      #   -H "Content-Type: application/json" \
      #   -H "Authorization: Bearer $SIEM_TOKEN" \
      #   -d "$json_line"
    fi
  fi
done &

FORWARDER_PID=$!

echo ""
echo "🧪 Running test scenarios..."
echo "============================"

# Test scenarios
for test_file in test_*.json; do
  echo ""
  echo "Testing: $test_file"
  curl -s -H "Content-Type: application/json" \
    -d @"$test_file" \
    http://127.0.0.1:8181/v1/data/telemetry/enforce/allow
  echo ""
done

echo ""
echo "📊 Checking Prometheus metrics..."
curl -s http://localhost:8181/metrics | grep opa_decision

echo ""
echo "🎯 Telemetry stack is running!"
echo "Press Ctrl+C to stop all services"

# Cleanup on exit
trap "kill $OPA_PID $FORWARDER_PID; exit" INT
wait
