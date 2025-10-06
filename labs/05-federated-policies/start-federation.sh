#!/bin/bash
echo "🚀 Starting Policy Federation Demo"
echo "=================================="

# Kill any existing OPA processes
pkill -f "opa run" 2>/dev/null

echo ""
echo "1. Starting Child OPA on port 8282 (Business Logic)"
opa run -s -a :8282 child.rego &
CHILD_PID=$!
sleep 2

echo "2. Starting Root OPA on port 8181 (Central Authority)" 
opa run -s -a :8181 root.rego &
ROOT_PID=$!
sleep 2

echo ""
echo "✅ Federation OPAs Running:"
echo "   - Child OPA: http://localhost:8282"
echo "   - Root OPA: http://localhost:8181"
echo ""
echo "🧪 Ready for testing! Run: ./test-federation.sh"
echo ""
echo "🧹 To stop: pkill -f 'opa run'"
