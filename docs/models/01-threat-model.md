mkdir -p docs/models
nano docs/models/01-threat-model.md
Paste and edit:

markdown
Copy code
# Threat Model v0

## Protect Surface
- App: ZT Demo API
- Data: user_profiles, payment_tokens
- Services: auth-api, analytics

## Adversaries
- External attacker, stolen creds
- Rogue insider with excessive privileges
- Compromised device (outdated, rooted)

## Entry Points
- Public API gateway (HTTPS)
- Admin console (Web)
- CI/CD tokens (machine identities)

## Security Controls
- PEP: API gateway policy + mTLS (future)
- Signals: IAM group, device_compliant, risk_score
- Decision: allow if `identity ∧ device ∧ risk ≤ threshold`

## Residual Risks / Assumptions
- Device posture rely on MDM truth
- Time-bound exceptions reviewed weekly
Save. Commit later with lab outputs.

Part C — Hands-On: Micro Policy Engine with OPA (15–20 min)
We’ll evaluate access based on identity, device posture, and risk score.

1) Setup lab folder
bash
Copy code
mkdir -p labs/01-policy-eval
cd labs/01-policy-eval
2) Policy (Rego)
bash
Copy code
cat > policy.rego << 'EOF'
package zt

default allow = false
required_groups := {"zt-students", "engineering"}

# Input shape:
# {
#   "user": {"id": "...", "groups": ["..."]},
#   "device": {"compliant": true},
#   "context": {"risk": 25, "resource": "profiles"}
# }

allow {
  some g
  input.user.groups[g]
  required_groups[g]
  input.device.compliant == true
  input.context.risk <= 50
}
EOF
3) Sample inputs
bash
Copy code
cat > good.json << 'EOF'
{
  "user":   {"id":"ola","groups":["engineering","zt-students"]},
  "device": {"compliant": true},
  "context":{"risk": 10, "resource":"profiles"}
}
EOF

cat > bad.json << 'EOF'
{
  "user":   {"id":"ola","groups":["contractors"]},
  "device": {"compliant": false},
  "context":{"risk": 80, "resource":"profiles"}
}
EOF
4) Run with OPA (single binary)
bash
Copy code
# Linux x86_64 example; adjust if needed:
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa

# Evaluate
./opa eval -i good.json -d policy.rego 'data.zt.allow'
./opa eval -i bad.json  -d policy.rego 'data.zt.allow'
Expected:

good.json → true

bad.json → false

You just implemented a Policy Engine decision. In a real stack, your PEP (API gateway, proxy, sidecar) would call this before allowing requests.

5) Commit your work
bash
Copy code
cd ../../
git add docs/models/01-threat-model.md labs/01-policy-eval
git commit -m "lesson1: add threat model and OPA policy eval lab"
git push origin main
Checkpoint Questions (self-grade, 5 min)
What’s the difference between a PDP/PE (decision) and a PEP (enforcement)?

Which signals did we use in policy? Which ones would you add next (geo, time, behavior)?

Where would you place a PEP for web apps vs databases?

---

## 🧠 Zero Trust Runtime Flow (OPA ↔ Proxy ↔ Target App)

Below is the real-time architecture view of your Zero Trust decision path:

```mermaid
flowchart LR
    A[👤 User / Client] -->|HTTP Request<br/>x-user header| B[🔐 PEP Proxy :8080]
    B -->|Policy Query<br/>JSON input| C[🧠 OPA Policy Engine :8181]
    C -->|Decision: ALLOW / DENY| B
    B -->|If ALLOW → Forward| D[🎯 Target App :9000]
    D -->|Response<br/>Data / 403| A

    subgraph ControlPlane [Control Plane Trust Decisions]
        C
    end

    subgraph DataPlane [Data Plane App Access]
        B
        D
    end

    style A fill:#e6f3ff,stroke:#6cb0f5,stroke-width:2px
    style B fill:#fff0f5,stroke:#ff69b4,stroke-width:2px
    style C fill:#f0fff0,stroke:#66cc66,stroke-width:2px
    style D fill:#fff5e6,stroke:#ff9900,stroke-width:2px

eof
---

## 🧠 Zero Trust Runtime Flow (OPA ↔ Proxy ↔ Target App)

Below is the real-time architecture view of your Zero Trust decision path:

```mermaid
flowchart LR
    A[👤 User / Client] -->|HTTP Request| B[🔐 PEP Proxy :8080]
    B -->|Policy Query| C[🧠 OPA Policy Engine :8181]
    C -->|ALLOW / DENY| B
    B -->|Forward Request| D[🎯 Target App :9000]
    D -->|Response| A

    subgraph ControlPlane [Control Plane]
        C
    end

    subgraph DataPlane [Data Plane]
        B
        D
    end

    style A fill:#e6f3ff,stroke:#6cb0f5,stroke-width:2px
    style B fill:#fff0f5,stroke:#ff69b4,stroke-width:2px
    style C fill:#f0fff0,stroke:#66cc66,stroke-width:2px
    style D fill:#fff5e6,stroke:#ff9900,stroke-width:2px

---

## 🧠 Zero Trust Runtime Flow (OPA ↔ Proxy ↔ Target App)

Below is the real-time architecture view of your Zero Trust decision path:

```mermaid
flowchart LR
    A[👤 User / Client] -->|HTTP Request<br/>x-user header| B[🔐 PEP Proxy :8080]
    B -->|Policy Query<br/>JSON input| C[🧠 OPA Policy Engine :8181]
    C -->|Decision: ALLOW / DENY| B
    B -->|If ALLOW → Forward| D[🎯 Target App :9000]
    D -->|Response<br/>Data / 403| A

    subgraph ControlPlane [Control Plane Trust Decisions]
        C
    end

    subgraph DataPlane [Data Plane App Access]
        B
        D
    end

    style A fill:#e6f3ff,stroke:#6cb0f5,stroke-width:2px
    style B fill:#fff0f5,stroke:#ff69b4,stroke-width:2px
    style C fill:#f0fff0,stroke:#66cc66,stroke-width:2px
    style D fill:#fff5e6,stroke:#ff9900,stroke-width:2px
