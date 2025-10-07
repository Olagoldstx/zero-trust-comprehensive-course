#!/usr/bin/env bash
set -euo pipefail

echo "🚨 Cross-Cloud Security Correlation Analysis"
echo "==========================================="

IN="labs/12-cross-cloud-correlation/multicloud_events.jsonl"

if [[ ! -f "$IN" ]]; then
  echo "❌ No events found. Generate events first with:"
  echo "   ./labs/12-cross-cloud-correlation/generate_cloud_events.sh"
  exit 1
fi

# Run correlation analysis
./labs/12-cross-cloud-correlation/correlate_events.sh "$IN" | jq -c '.[]' | while read -r row; do
  user=$(echo "$row" | jq -r '.user')
  clouds=$(echo "$row" | jq -r '.clouds | join(", ")')
  total=$(echo "$row" | jq -r '.total_events')
  high=$(echo "$row" | jq -r '.high_severity_count')
  cloud_count=$(echo "$row" | jq -r '.cloud_count')
  correlated=$(echo "$row" | jq -r '.is_correlated')
  risk_score=$(echo "$row" | jq -r '.risk_score | round')

  # Alert logic
  if [[ "$correlated" == "true" && "$high" -gt 0 ]]; then
    echo "🔥 CRITICAL: Multi-cloud attack pattern detected!"
    echo "   User: $user | Clouds: [$clouds]"
    echo "   High-severity events: $high | Total events: $total"
    echo "   Risk Score: $risk_score/100"
    echo "   ➡️  Action: Immediate investigation required"
    echo ""
  elif [[ "$cloud_count" -gt 1 && "$total" -gt 5 ]]; then
    echo "⚠️  SUSPICIOUS: Cross-cloud activity detected"
    echo "   User: $user | Clouds: [$clouds]"
    echo "   Events: $total across $cloud_count clouds"
    echo "   Risk Score: $risk_score/100"
    echo "   ➡️  Action: Enhanced monitoring"
    echo ""
  else
    echo "✅ NORMAL: User: $user | Clouds: [$clouds] | Events: $total"
  fi
done

echo ""
echo "📊 Summary: Run './labs/12-cross-cloud-correlation/correlate_events.sh' for detailed analysis"
