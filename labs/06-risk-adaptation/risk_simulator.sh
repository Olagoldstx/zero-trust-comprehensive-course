#!/bin/bash
echo "🔄 Real-time Risk Adaptation Simulator"
echo "======================================"

# Simulate changing risk scores
echo "Simulating risk adaptation over time..."

for i in 20 35 55 75 15; do
  echo ""
  echo "--- Risk Score: $i ---"
  
  # Create dynamic input
  cat > dynamic_test.json << DYNAMIC_EOF
{
  "user": "ola",
  "role": "admin",
  "device": {"compliant": true},
  "context": {
    "risk": $i,
    "sensitivity": "high",
    "grant_time": 1738830000000000000,
    "grant_duration": 900000000000,
    "geo_restricted": false,
    "behavior_anomaly": false
  }
}
DYNAMIC_EOF

  result=$(opa eval -i dynamic_test.json -d policy.rego "data.risk.adaptation.allow" 2>/dev/null | grep -o '"result":[^,]*' | cut -d: -f2)
  
  if [ "$result" = "true" ]; then
    echo "✅ ACCESS GRANTED - Risk $i is acceptable"
  else
    echo "🚫 ACCESS DENIED - Risk $i exceeds threshold"
  fi
  
  sleep 1
done

rm dynamic_test.json
