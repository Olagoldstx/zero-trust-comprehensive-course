#!/usr/bin/env bash
set -euo pipefail
IN="${1:-labs/12-cross-cloud-correlation/multicloud_events.jsonl}"

if [[ ! -f "$IN" ]]; then
  echo "❌ Input file not found: $IN" >&2
  exit 1
fi

echo "🔍 Correlating events from: $IN" >&2

jq -sr '
  def severity_label(x):
    if x<2 then "low"
    elif x<4 then "medium"  
    else "high"
    end;

  # Group by user and analyze cross-cloud patterns
  group_by(.user)
  | map({
      user: .[0].user,
      clouds: ( [.[].cloud] | unique | sort ),
      total_events: length,
      high_severity_count: (map(select(.severity>=4)) | length),
      medium_severity_count: (map(select(.severity==2 or .severity==3)) | length),
      cloud_count: ( [.[].cloud] | unique | length ),
      is_correlated: ( [.[].cloud] | unique | length > 1 ),
      # Fixed risk score calculation
      risk_score: ( ([.[] | .severity] | add) / length * ([.[].cloud] | unique | length) ),
      last_timestamp: (map(.timestamp) | max),
      event_types: ( [.[].message] | unique )
    })
  | sort_by(-.risk_score)
' "$IN"
