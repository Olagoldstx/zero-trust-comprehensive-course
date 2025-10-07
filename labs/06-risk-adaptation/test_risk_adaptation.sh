#!/bin/bash
echo "🎯 Testing Continuous Risk Adaptation & JIT Access"
echo "=================================================="

echo ""
echo "1. Normal JIT Access (should ALLOW):"
opa eval -i jit_normal.json -d policy.rego "data.risk.adaptation.allow"

echo ""
echo "2. High Risk Scenario (should DENY):"
opa eval -i jit_high_risk.json -d policy.rego "data.risk.adaptation.allow"

echo ""
echo "3. Emergency Override (should ALLOW):"
opa eval -i jit_emergency.json -d policy.rego "data.risk.adaptation.allow"

echo ""
echo "4. Expired Grant (should DENY):"
opa eval -i jit_expired.json -d policy.rego "data.risk.adaptation.allow"

echo ""
echo "5. Behavioral Anomaly (should DENY):"
opa eval -i jit_anomaly.json -d policy.rego "data.risk.adaptation.allow"

echo ""
echo "6. Decision Logging (view audit trail):"
opa eval -i jit_normal.json -d policy.rego "data.risk.adaptation.decision_log"
