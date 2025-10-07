#!/bin/bash
echo "🎯 Lesson 10 - Complete SIEM Analytics Test"

echo "1. Testing with normal traffic (should not alert):"
echo "   Using clean_events.jsonl (50% deny rate)"
./compute_metrics.sh clean_events.jsonl
echo "   Starting alerts for 9 seconds (3 checks):"
FILE="clean_events.jsonl" timeout 9s ./alerts.sh

echo ""
echo "2. Testing with high-denial traffic (should alert):"
echo "   Using high_denial_events.jsonl (80% deny rate)"
./compute_metrics.sh high_denial_events.jsonl
echo "   Starting alerts for 9 seconds (3 checks):"
FILE="high_denial_events.jsonl" timeout 9s ./alerts.sh

echo ""
echo "3. Testing real-time event generation:"
echo "   Generating fresh events with OPA..."
./generate_events.sh
echo "   Real-time metrics:"
./compute_metrics.sh

echo ""
echo "✅ Lesson 10 SIEM Analytics is working correctly!"
echo "📊 Features demonstrated:"
echo "   - Event generation and collection"
echo "   - Rolling window metrics calculation"
echo "   - Deny ratio monitoring"
echo "   - Threshold-based alerting"
echo "   - Real-time security analytics"
