#!/usr/bin/env bash
set -euo pipefail
POLICY_STATE="labs/11-soar-integration/policy_state.json"
ACTIONS="labs/11-soar-integration/actions.log"

mkdir -p "$(dirname "$POLICY_STATE")"

# initialize policy state if not present
if [[ ! -f "$POLICY_STATE" ]]; then
  echo '{"mode":"normal"}' > "$POLICY_STATE"
fi

echo "🧩 Watching actions and updating policy mode..."
tail -Fn0 "$ACTIONS" | \
while read -r line; do
  if echo "$line" | grep -q "SOAR Trigger"; then
    echo '{"mode":"restricted"}' > "$POLICY_STATE"
    echo "⚠️  Policy set to RESTRICTED mode"
  else
    echo '{"mode":"normal"}' > "$POLICY_STATE"
    echo "✅ Policy back to NORMAL"
  fi
done
