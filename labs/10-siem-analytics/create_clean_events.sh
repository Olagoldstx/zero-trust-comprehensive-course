#!/bin/bash
echo "🔄 Creating clean test events manually"

OUT="clean_events.jsonl"
rm -f "$OUT"

# Create 10 perfectly formatted test events manually
cat > "$OUT" << 'EOF'
{"ts":"2025-10-07T12:00:00-07:00","user":"ola","risk":25,"device_compliant":true,"decision_id":"test-1","result":true}
{"ts":"2025-10-07T12:00:01-07:00","user":"guest","risk":75,"device_compliant":true,"decision_id":"test-2","result":false}
{"ts":"2025-10-07T12:00:02-07:00","user":"admin","risk":15,"device_compliant":false,"decision_id":"test-3","result":false}
{"ts":"2025-10-07T12:00:03-07:00","user":"ola","risk":80,"device_compliant":true,"decision_id":"test-4","result":false}
{"ts":"2025-10-07T12:00:04-07:00","user":"analyst","risk":35,"device_compliant":true,"decision_id":"test-5","result":true}
{"ts":"2025-10-07T12:00:05-07:00","user":"api","risk":45,"device_compliant":true,"decision_id":"test-6","result":true}
{"ts":"2025-10-07T12:00:06-07:00","user":"guest","risk":85,"device_compliant":false,"decision_id":"test-7","result":false}
{"ts":"2025-10-07T12:00:07-07:00","user":"ola","risk":30,"device_compliant":true,"decision_id":"test-8","result":true}
{"ts":"2025-10-07T12:00:08-07:00","user":"admin","risk":65,"device_compliant":true,"decision_id":"test-9","result":true}
{"ts":"2025-10-07T12:00:09-07:00","user":"analyst","risk":50,"device_compliant":false,"decision_id":"test-10","result":false}
EOF

echo "✅ Created clean test events in $OUT"

# Validate
echo "📋 Validating:"
jq -e . < "$OUT" >/dev/null && echo "✅ JSON is valid" || echo "❌ JSON invalid"

# Count results
echo "📊 Results:"
echo "Allows: $(grep -c '"result":true' "$OUT")"
echo "Denies: $(grep -c '"result":false' "$OUT")"

# Test metrics
echo "📈 Metrics:"
./compute_metrics.sh "$OUT"
