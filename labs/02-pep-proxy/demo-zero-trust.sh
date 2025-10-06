#!/bin/bash
echo "🎯 Zero Trust PEP Proxy - Complete Demonstration"
echo "================================================"

# Clean up
pkill -f "opa run" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep.js" 2>/dev/null

echo ""
echo "🚀 Starting Zero Trust Components..."
echo ""

# Start OPA
echo "1. 🔐 OPA Policy Engine (Port 8181)"
opa run --server policy.rego &
OPA_PID=$!
sleep 2

# Start Target Service
echo "2. 🎯 Target Service (Port 9000)"
node target.js &
TARGET_PID=$!
sleep 1

# Start PEP Proxy with detailed logging
echo "3. 🛡️ PEP Proxy (Port 8080)"
node pep-debug.js &
PEP_PID=$!
sleep 2

echo ""
echo "✅ All Services Running"
echo ""

echo "🧪 TEST SCENARIOS:"
echo "=================="

echo ""
echo "Test 1: ✅ Authorized User 'ola' accessing /profiles"
echo "----------------------------------------------------"
curl -s -H "X-User: ola" http://localhost:8080/profiles
echo ""

echo ""
echo "Test 2: ✅ Authorized User 'admin' accessing /profiles" 
echo "------------------------------------------------------"
curl -s -H "X-User: admin" http://localhost:8080/profiles
echo ""

echo ""
echo "Test 3: 🚫 Unauthorized User 'attacker' accessing /profiles"
echo "-----------------------------------------------------------"
curl -s -H "X-User: attacker" http://localhost:8080/profiles
echo ""

echo ""
echo "Test 4: 🚫 Authorized User accessing wrong endpoint /admin"
echo "----------------------------------------------------------"
curl -s -H "X-User: ola" http://localhost:8080/admin
echo ""

echo ""
echo "Test 5: 🚫 No user header (anonymous)"
echo "-------------------------------------"
curl -s http://localhost:8080/profiles
echo ""

echo ""
echo "📊 ZERO-TRUST POLICY SUMMARY:"
echo "============================="
echo "✅ ALLOWED: GET /profiles for users: 'ola', 'admin'"
echo "🚫 DENIED:  All other users and endpoints"
echo "🔒 ENFORCED: Never trust, always verify"

echo ""
echo "🧹 Cleaning up..."
kill $OPA_PID $TARGET_PID $PEP_PID 2>/dev/null
echo "Demo complete! 🎉"
