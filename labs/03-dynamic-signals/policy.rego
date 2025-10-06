💡 This policy enforces:

user = ola

GET /profiles

device compliant

risk score ≤ 50

time between 8 AM and 6 PM

⚙️ Step 4 — Test Inputs
cat > good.json <<'EOF'
{
  "user": "ola",
  "method": "GET",
  "path": "/profiles",
  "device": {"compliant": true},
  "context": {"risk": 20}
}
EOF

cat > bad.json <<'EOF'
{
  "user": "guest",
  "method": "GET",
  "path": "/profiles",
  "device": {"compliant": false},
  "context": {"risk": 80}
}
EOF

🔍 Step 5 — Evaluate
opa eval -i good.json -d policy.rego "data.httpapi.authz.allow"
opa eval -i bad.json -d policy.rego "data.httpapi.authz.allow"

✅ good.json → true
🚫 bad.json → false

