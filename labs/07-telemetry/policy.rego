package telemetry.enforce

default allow = false

# Annotated rule to emit decision metadata
allow if {
    input.user == "ola"
    input.device.compliant
    input.context.risk <= 50
    trace(sprintf("ALLOW user=%v risk=%v", [input.user, input.context.risk]))
}

deny if {
    trace(sprintf("DENY user=%v risk=%v", [input.user, input.context.risk]))
    not allow
}
💡 trace() writes structured messages OPA can expose to logs → Prometheus/SIEM.

⚙️ Step 3 – Run OPA with Decision Logs and Metrics
OPA can emit Prometheus metrics + decision logs locally:

bash
Copy code
opa run -s -a :8181 policy.rego \
  --set decision_logs.console=true \
  --set prometheus=true
OPA now:

Serves policy decisions → :8181

Exposes Prometheus metrics → /metrics

Prints audit events → console (JSON form)

🧮 Step 4 – Query and Test
bash
Copy code
# Simulate requests
curl -s -H "Content-Type: application/json" \
  -d '{"input":{"user":"ola","device":{"compliant":true},"context":{"risk":25}}}' \
  http://127.0.0.1:8181/v1/data/telemetry/enforce/allow

curl -s -H "Content-Type: application/json" \
  -d '{"input":{"user":"guest","device":{"compliant":true},"context":{"risk":70}}}' \
  http://127.0.0.1:8181/v1/data/telemetry/enforce/allow

# View metrics
curl http://127.0.0.1:8181/metrics | grep opa_decision
You’ll see counters like:

arduino
Copy code
opa_decision_duration_seconds_count{decision_id="data.telemetry.enforce.allow"} 2
opa_decision_duration_seconds_sum{decision_id="data.telemetry.enforce.allow"} 0.004
📊 Step 5 – Simulated SIEM Integration
Create a simple forwarder that tails OPA’s decision logs and ships them to a SIEM API.

bash
Copy code
nano forwarder.sh
Paste:

bash
Copy code
#!/bin/bash
LOGFILE=opa_decision.log

opa run -s -a :8181 policy.rego --set decision_logs.console=true 2>&1 | tee -a $LOGFILE &

# Simulate ship to SIEM (mock endpoint)
tail -f $LOGFILE | while read line; do
  echo "Forwarding to SIEM: $line"
done
Then run:

bash
Copy code
chmod +x forwarder.sh
./forwarder.sh
You’ll see “Forwarding to SIEM: {…decision log JSON…}”.

🧠 Reflection
Why is decision telemetry vital in Zero Trust?

How would you correlate OPA metrics with network flows in SIEM?

Could you auto-quarantine a device if deny rate > threshold?
