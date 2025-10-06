#!/bin/bash
echo "🧪 Testing Policy Federation"
echo "============================"

echo ""
echo "1. Testing Child OPA Directly:"
echo "   Employee role:"
curl -s -H "Content-Type: application/json" \
  -d '{"input":{"role":"employee", "context":{"risk":20, "service_compliant":true}}}' \
  http://127.0.0.1:8282/v1/data/federation/child/allow

echo ""
echo "   Contractor role (should fail):"
curl -s -H "Content-Type: application/json" \
  -d '{"input":{"role":"contractor", "context":{"risk":20, "service_compliant":true}}}' \
  http://127.0.0.1:8282/v1/data/federation/child/allow

echo ""
echo "2. Testing Root OPA with Federation:"
echo "   Successful federation:"
opa eval -i successful-federation.json -d root.rego "data.federation.root.allow"

echo ""
echo "   Failed delegation:"
opa eval -i failed-delegation.json -d root.rego "data.federation.root.allow"

echo ""
echo "   High risk rejection:"
opa eval -i high-risk.json -d root.rego "data.federation.root.allow"

echo ""
echo "   Emergency override:"
opa eval -i emergency-override.json -d root.rego "data.federation.root.allow"
