#!/usr/bin/env bash
URL="http://127.0.0.1:8181/v1/data/telemetry/enforce/allow"
while true; do
  # alternate good/bad to vary metrics
  curl -s -H "Content-Type: application/json" -d '{"input":{"user":"ola","device":{"compliant":true},"context":{"risk":25}}}' "$URL" >/dev/null
  curl -s -H "Content-Type: application/json" -d '{"input":{"user":"guest","device":{"compliant":true},"context":{"risk":75}}}' "$URL" >/dev/null
done
