#!/bin/bash
echo "🔐 Fixed Zero Trust Test..."

# Clean up any existing processes
pkill -f "opa run" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep.js" 2>/dev/null

echo "1. Validating policy..."
opa check policy.rego

echo "2. Starting OPA server..."
opa run --server policy.rego &
OPA_PID=$!
sleep 3

echo "3. Testing OPA health..."
curl -s http://localhost:8181/health
echo ""

echo "4. Testing policy via HTTP API..."
curl -s -X POST http://localhost:8181/v1/data/httpapi/authz/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"method": "GET", "path": "/profiles", "user": "ola"}}'
echo ""

echo "5. Starting target service..."
node target.js &
TARGET_PID=$!
sleep 1

echo "6. Starting PEP proxy..."
node pep.js &
PEP_PID=$!
sleep 2

echo "7. Testing through PEP proxy..."
echo "Authorized request:"
curl -s -H "X-User: ola" http://localhost:8080/profiles
echo ""

echo "Unauthorized request:"
curl -s -H "X-User: attacker" http://localhost:8080/profiles
echo ""

echo "🧹 Cleaning up..."
kill $OPA_PID $TARGET_PID $PEP_PID 2>/dev/null
