#!/usr/bin/env bash
OPA_URL="http://127.0.0.1:8181"
SIEM_URL="http://127.0.0.1:9200/ingest"

echo "🎯 Correct Zero-Trust SIEM Integration"
echo "Using actual OPA HTTP metrics..."

while true; do
  # Get metrics and extract the HTTP request count
  metrics=$(curl -s "$OPA_URL/metrics")
  
  # Extract the total HTTP request count from the histogram
  # This gets the count for all requests (le="+Inf" bucket)
  request_count=$(echo "$metrics" | grep 'http_request_duration_seconds_bucket{.*le="\+Inf"' | awk '{print $2}' | head -1)
  
  # If not found, try alternative pattern
  if [ -z "$request_count" ]; then
    request_count=$(echo "$metrics" | grep 'http_request_duration_seconds_count{' | awk '{sum+=$2} END{print sum+0}')
  fi
  
  # Fallback: count health endpoint requests specifically
  if [ -z "$request_count" ] || [ "$request_count" = "0" ]; then
    health_requests=$(echo "$metrics" | grep 'handler="health".*le="\+Inf"' | awk '{print $2}' | head -1)
    request_count="${health_requests:-0}"
  fi
  
  echo "$(date -Is) - HTTP Requests: $request_count"
  
  # Create SIEM event
  siem_event=$(cat << EVENT
{
  "timestamp": "$(date -Is)",
  "source": "zero-trust-opa",
  "event_type": "http_metrics",
  "data": {
    "total_requests": "$request_count",
    "metric_type": "http_request_duration_seconds",
    "collection_time": "$(date -Is)"
  }
}
EVENT
)
  
  curl -s -X POST -H "Content-Type: application/json" -d "$siem_event" "$SIEM_URL" > /dev/null
  sleep 10
done
