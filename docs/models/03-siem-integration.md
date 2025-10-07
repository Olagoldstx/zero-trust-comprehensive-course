
# 🛰️ Lesson 9 — Automated SOC & SIEM Integration

> Connecting OPA decisions, telemetry, and containment events to centralized security monitoring.

---

## 🎯 Objectives

- Forward **OPA policy decisions** and **containment alerts** to a SIEM.  
- Enrich data with context (user, device, geo, risk).  
- Enable **automated SOC response** workflows.

---

## 🧱 Lab Setup

```bash
mkdir -p ~/zero-trust-comprehensive-course/labs/09-siem-integration
cd ~/zero-trust-comprehensive-course/labs/09-siem-integration

⚙️ 1️⃣ Create a Mock SIEM Receiver
cat > siem_server.js <<'EOF'
#!/usr/bin/env node
import express from "express";
const app = express();
app.use(express.json());

// Receive logs from OPA or watcher
app.post("/ingest", (req, res) => {
  const event = req.body;
  console.log("📥 SIEM received event:", JSON.stringify(event));
  res.status(200).send({ status: "ok" });
});

app.listen(9200, () => console.log("🛰️ SIEM endpoint running on :9200/ingest"));
EOF


Install and start:

npm init -y
npm install express
node siem_server.js

⚙️ 2️⃣ Create a Forwarder to SIEM
cat > forward_to_siem.sh <<'EOF'
#!/usr/bin/env bash
OPA_LOG="opa_decision.log"
SIEM_URL="http://127.0.0.1:9200/ingest"

echo "📡 Forwarding OPA decisions from $OPA_LOG → $SIEM_URL"

tail -Fn0 "$OPA_LOG" | \
while read -r line; do
  if [[ "$line" == *"decision_id"* ]]; then
    curl -s -X POST -H "Content-Type: application/json" \
         -d "$(echo "$line" | jq '{timestamp:(now|toiso8601), source:"OPA", event:.}')" \
         "$SIEM_URL" >/dev/null
  fi
done
EOF

chmod +x forward_to_siem.sh

🔁 3️⃣ Run All Components
Terminal	Command	Role
🧠 A	opa run -s -a :8181 policy.rego --set decision_logs.console=true --set decision_logs.service=http://127.0.0.1:9200/ingest	OPA Decision Engine
🛰️ B	node siem_server.js	Mock SIEM Receiver
📡 C	./forward_to_siem.sh	Log Forwarder
⚔️ D	./attack.sh or ./contain.sh	Generate Events

When traffic flows, you’ll see:

📥 SIEM received event: {"timestamp":"...","source":"OPA","event":{"decision_id":"...","result":false}}

📊 4️⃣ Visualization (Optional)

You can save events to JSON or integrate with Grafana, Splunk, or Elasticsearch for dashboards and threat correlation.

🧠 Reflection

What is the value of centralized event aggregation for a SOC?

How can risk context (geo, device posture, MFA) enrich events?

How would you trigger alerts (Slack, PagerDuty, SIEM rules) from these events?

🕸️ 5️⃣ Visual Overview
![SIEM Integration Diagram](../../diagrams/model-03-siem.mmd)

