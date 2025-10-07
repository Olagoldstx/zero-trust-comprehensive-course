#!/bin/bash
echo "📈 Real-time OPA Metrics Monitor"
echo "================================"

while true; do
  clear
  echo "$(date) - OPA Decision Metrics"
  echo "=================================="
  
  metrics=$(curl -s http://localhost:8181/metrics)
  
  # Extract key metrics
  echo "Decision Counters:"
  echo "$metrics" | grep 'opa_decision_count' | head -10
  
  echo ""
  echo "Decision Duration:"
  echo "$metrics" | grep 'opa_decision_duration_seconds' | head -5
  
  echo ""
  echo "Active Bundles:"
  echo "$metrics" | grep 'opa_bundle' | head -5
  
  sleep 5
done
