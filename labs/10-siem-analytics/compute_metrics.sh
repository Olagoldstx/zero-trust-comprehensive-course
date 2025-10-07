#!/usr/bin/env bash

FILE="${1:-decision_logs.jsonl}"
WINDOW=50

echo "📊 Analyzing last $WINDOW events from: $FILE"

if [ ! -f "$FILE" ]; then
    echo "❌ Error: File $FILE not found"
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "❌ Error: File $FILE is empty"
    exit 1
fi

# Get actual line count
total_lines=$(wc -l < "$FILE")
echo "Total lines in file: $total_lines"

# Use the smaller of WINDOW or total_lines
if [ "$total_lines" -lt "$WINDOW" ]; then
    actual_window=$total_lines
else
    actual_window=$WINDOW
fi

echo "Analyzing last $actual_window events"

# Extract the last N lines to a temp file
tail -n "$actual_window" "$FILE" > "/tmp/analysis_window.jsonl"

# Count using reliable methods
total=$(wc -l < "/tmp/analysis_window.jsonl")

# Method 1: Use jq to count true/false results
allow=$(jq -r 'select(.result == true) | .result' "/tmp/analysis_window.jsonl" 2>/dev/null | wc -l || echo "0")
deny=$(jq -r 'select(.result == false) | .result' "/tmp/analysis_window.jsonl" 2>/dev/null | wc -l || echo "0")

# Method 2: Alternative counting if above fails
if [ "$allow" -eq 0 ] && [ "$deny" -eq 0 ]; then
    echo "Using alternative counting method..."
    allow=$(grep -c '"result":true' "/tmp/analysis_window.jsonl" || echo "0")
    deny=$(grep -c '"result":false' "/tmp/analysis_window.jsonl" || echo "0")
fi

# Verify counts make sense
if [ $((allow + deny)) -ne $total ] && [ $total -gt 0 ]; then
    echo "⚠️  Count mismatch: allow($allow) + deny($deny) != total($total)"
    # Force reasonable values
    if [ $((allow + deny)) -gt $total ]; then
        ratio=$((total / (allow + deny)))
        allow=$((allow / ratio))
        deny=$((deny / ratio))
    fi
fi

# Calculate percentages safely
if [ "$total" -gt 0 ]; then
    deny_ratio=$(echo "scale=3; $deny / $total" | bc)
    allow_pct=$(echo "scale=1; ($allow / $total) * 100" | bc)
    deny_pct=$(echo "scale=1; ($deny / $total) * 100" | bc)
else
    deny_ratio=0
    allow_pct=0
    deny_pct=0
fi

echo "=== FINAL RESULTS ==="
echo "Window size: $actual_window"
echo "Total events: $total"
echo "Allowed: $allow ($allow_pct%)"
echo "Denied: $deny ($deny_pct%)"
echo "Deny ratio: $deny_ratio"

# Create JSON output
cat << EOF
{
  "window": $total,
  "allow": $allow,
  "deny": $deny,
  "deny_ratio": $deny_ratio,
  "allow_percentage": $allow_pct,
  "deny_percentage": $deny_pct
}
EOF

# Cleanup
rm -f "/tmp/analysis_window.jsonl"
