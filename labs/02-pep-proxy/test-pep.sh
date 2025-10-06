#!/bin/bash
echo "🔐 Starting Zero Trust PEP Proxy Test..."

# Kill any existing processes
pkill -f "opa run" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep.js" 2>/dev/null

echo "1. Starting OPA policy engine..."
opa run --server policy.rego &
OPA_PID=$!
sleep 2

echo "2. Starting target service on port 9000..."
node target.js &
TARGET_PID=$!
sleep 1

echo "3. Starting PEP proxy on port 8080..."
node pep.js &
PEP_PID=$!
sleep 2

echo "✅ All services started!"
echo "   OPA: http://localhost:8181"
echo "   PEP: http://localhost:8080" 
echo "   Target: http://localhost:9000"
echo ""
echo "🧪 Testing access control..."

# Test 1: Unauthorized access (should fail)
echo "Test 1: Anonymous user accessing /profiles"
curl -s -H "X-User: anonymous" http://localhost:8080/profiles

echo ""
echo "---"

# Test 2: Authorized user (should succeed)
echo "Test 2: Authorized user 'ola' accessing /profiles"
curl -s -H "X-User: ola" http://localhost:8080/profiles

echo ""
echo "---"

# Test 3: Wrong endpoint (should fail)
echo "Test 3: Authorized user accessing wrong endpoint"
curl -s -H "X-User: ola" http://localhost:8080/admin

echo ""
echo "---"

# Test 4: Another authorized user
echo "Test 4: Authorized user 'admin' accessing /profiles"
curl -s -H "X-User: admin" http://localhost:8080/profiles

echo ""
echo "🧹 Cleaning up..."
kill $OPA_PID $TARGET_PID $PEP_PID 2>/dev/null
