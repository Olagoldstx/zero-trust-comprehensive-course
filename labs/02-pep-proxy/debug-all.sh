#!/bin/bash
echo "🐛 Zero Trust Debug - All Components"
echo "===================================="

# Clean up
pkill -f "opa" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep" 2>/dev/null

echo ""
echo "1. 🧪 TESTING TARGET SERVICE DIRECTLY..."
node target.js &
TARGET_PID=$!
sleep 2
echo "   Testing /profiles:"
curl -s -w "HTTP Status: %{http_code}\n" http://localhost:9000/profiles
echo "   Testing /admin:"
curl -s -w "HTTP Status: %{http_code}\n" http://localhost:9000/admin
kill $TARGET_PID 2>/dev/null

echo ""
echo "2. 🧪 TESTING OPA POLICY DIRECTLY..."
opa run --server policy.rego &
OPA_PID=$!
sleep 2
echo "   Testing OPA health:"
curl -s -w "HTTP Status: %{http_code}\n" http://localhost:8181/health
echo ""
echo "   Testing policy evaluation for 'ola':"
curl -s -X POST http://localhost:8181/v1/data/httpapi/authz/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"method": "GET", "path": "/profiles", "user": "ola"}}'
echo ""
echo "   Testing policy evaluation for 'attacker':"
curl -s -X POST http://localhost:8181/v1/data/httpapi/authz/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"method": "GET", "path": "/profiles", "user": "attacker"}}'
kill $OPA_PID 2>/dev/null

echo ""
echo "3. 🧪 TESTING COMPLETE FLOW..."
echo "   Starting all services..."
opa run --server policy.rego &
OPA_PID=$!
sleep 2

node target.js &
TARGET_PID=$!
sleep 1

node pep.js &
PEP_PID=$!
sleep 2

echo ""
echo "   Testing authorized access (ola):"
curl -v -H "X-User: ola" http://localhost:8080/profiles 2>&1 | grep -E "(HTTP|< X-Powered-By|> GET|> User-Agent:|> X-User:)"

echo ""
echo "   Testing unauthorized access (attacker):"
curl -v -H "X-User: attacker" http://localhost:8080/profiles 2>&1 | grep -E "(HTTP|< X-Powered-By|> GET|> User-Agent:|> X-User:)"

echo ""
echo "🧹 Cleaning up..."
kill $OPA_PID $TARGET_PID $PEP_PID 2>/dev/null
echo "Debug complete!"
