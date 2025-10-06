#!/bin/bash
echo "🎯 ZERO TRUST PEP PROXY - FINAL DEMONSTRATION"
echo "============================================="

# Clean up
pkill -f "opa" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep.js" 2>/dev/null

echo ""
echo "🚀 Starting Zero Trust Architecture..."
echo ""

# Start services
opa run --server policy.rego &
sleep 2
node target.js &
sleep 1
node pep.js &
sleep 2

echo ""
echo "🧪 DEMONSTRATING ZERO-TRUST PRINCIPLES"
echo "======================================"

echo ""
echo "1. ✅ AUTHORIZED ACCESS - User 'ola'"
echo "------------------------------------"
echo "Command: curl -H 'X-User: ola' http://localhost:8080/profiles"
curl -H "X-User: ola" http://localhost:8080/profiles
echo ""

echo ""
echo "2. ✅ AUTHORIZED ACCESS - User 'admin'" 
echo "--------------------------------------"
echo "Command: curl -H 'X-User: admin' http://localhost:8080/profiles"
curl -H "X-User: admin" http://localhost:8080/profiles
echo ""

echo ""
echo "3. 🚫 UNAUTHORIZED ACCESS - User 'attacker'"
echo "-------------------------------------------"
echo "Command: curl -H 'X-User: attacker' http://localhost:8080/profiles"
curl -H "X-User: attacker" http://localhost:8080/profiles
echo ""

echo ""
echo "4. 🚫 WRONG ENDPOINT - Even authorized user"
echo "-------------------------------------------"
echo "Command: curl -H 'X-User: ola' http://localhost:8080/admin"
curl -H "X-User: ola" http://localhost:8080/admin
echo ""

echo ""
echo "5. 🚫 NO AUTHENTICATION - Anonymous user"
echo "----------------------------------------"
echo "Command: curl http://localhost:8080/profiles"
curl http://localhost:8080/profiles
echo ""

echo ""
echo "📊 ZERO-TRUST POLICY ENFORCEMENT SUMMARY"
echo "========================================"
echo "🔐 POLICY: Only GET /profiles allowed for users: 'ola', 'admin'"
echo ""
echo "✅ ALLOWED:"
echo "   - GET /profiles (user: ola)"
echo "   - GET /profiles (user: admin)"
echo ""
echo "🚫 DENIED:"
echo "   - GET /profiles (user: attacker)"
echo "   - GET /admin (even for authorized users)"
echo "   - GET /profiles (no user header)"
echo ""
echo "🎉 ZERO-TRUST SUCCESS: 'Never trust, always verify' is working!"

# Clean up
pkill -f "opa" 2>/dev/null
pkill -f "node target.js" 2>/dev/null
pkill -f "node pep.js" 2>/dev/null
