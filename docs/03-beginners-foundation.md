# 🧭 Zero Trust for Absolute Beginners  
### A 30-Day Guided Foundation for Mastering the “Never Trust, Always Verify” Mindset  

> “Zero Trust is not a product — it’s a philosophy of continuous verification.”

---

## 🌍 Course Overview

Welcome to **Module 03 — Beginners Foundation**, the heart of the Zero Trust Comprehensive Course.  
This module transforms a non-specialist into a practitioner through **analogies, labs, diagrams, quizzes, and real-world context**.

You’ll move from *conceptual understanding → hands-on implementation → confident articulation*.

---

## 📆 30-Day Learning Plan (Guided & Progressive)

| Week | Focus Area | Outcome |
|------|-------------|----------|
| 1 | Core Concepts & Mindset | Understand “Never Trust, Always Verify” |
| 2 | Identity & Access | Master MFA / SSO fundamentals |
| 3 | Device Posture & Network Segmentation | Protect devices and workloads |
| 4 | Policy-as-Code & Monitoring | Automate and measure trust decisions |

---

## 🧱 Week 1 — Core Concepts & Mindset  

### 🎯 Goal
Shift from perimeter thinking (“castle and moat”) to continuous verification.

### 🧩 Analogy
**Traditional Security** = a castle & moat. Once you’re inside, free access everywhere.  
**Zero Trust** = an airport. Even with a boarding pass, you re-verify at every gate.

### 📖 Day 1 – Understand “Never Trust, Always Verify”
- Everything — users, devices, workloads — must prove identity and health.
- Verification isn’t one-time; it’s continuous.

```mermaid
flowchart TD
    A[Request Access] --> B{Identity Verified?}
    B -->|No| C[Access Denied]
    B -->|Yes| D{Device Healthy?}
    D -->|No| C
    D -->|Yes| E{Context Allowed?}
    E -->|No| C
    E -->|Yes| F[Limited Access Granted]
Mini-Lab

bash
Copy code
# Check your public IP
curl ifconfig.me
# This illustrates "context awareness" — location is part of Zero Trust.
📖 Day 2 – Identity Is the New Perimeter
Passwords ≠ proof. Combine something you know + something you have + something you are.

Introduce MFA concepts.

📖 Day 3 – Least Privilege by Design
Access = temporary badge. Grant only what’s required.

Check-Yourself

Q : What happens if one admin account is compromised?
A : Least privilege limits the blast radius — only that scope is affected.

🧱 Week 2 — Identity & Access Management
🎯 Goal
Implement secure access: MFA, SSO, conditional policies.

📖 Day 8 – Implement MFA
bash
Copy code
# Azure example (free account)
az ad user update --id you@example.com --force-change-password-next-login true
📖 Day 10 – Single Sign-On (SSO)
Analogy: One passport, many countries.

Tools: Okta, Azure AD, AWS IAM Identity Center.

📖 Day 12 – Conditional Access
Use context (device health, risk score, location).

yaml
Copy code
conditions:
  user_risk: high
  device_compliance: required
  location: not_trusted
grant_controls:
  - require_mfa
  - require_compliant_device
Mini-Quiz

MFA defends against what kind of attack?
a) SQL Injection b) Credential Stuffing ✅ b

What’s a benefit of SSO? → Fewer passwords & centralized policy enforcement.

🧱 Week 3 — Device Posture & Micro-Segmentation
🎯 Goal
Secure endpoints & segment workloads to contain risk.

🧩 Analogy
Think of your network as an office with many rooms — each door has its own badge reader.

📖 Day 15 – Device Posture
Use EDR / MDM to check compliance (patch level, encryption, antivirus).

Unhealthy devices → quarantine network.

📖 Day 18 – Micro-Segmentation
bash
Copy code
# Example: Create a Kubernetes NetworkPolicy that denies all by default
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
YAML
📖 Day 20 – Zero Trust Networking
Replace flat VLANs with identity-based routing.

Introduce AWS Verified Access / Azure ZTNA Gateway.

Mini-Check

🧠 Q: What’s safer — trusting a subnet or verifying the workload identity each time?
✅ Always the workload identity.

🧱 Week 4 — Policy as Code & Monitoring
🎯 Goal
Automate enforcement & visibility.

📖 Day 23 – Policy as Code (PaC)
hcl
Copy code
resource "aws_iam_policy" "least_privilege" {
  name = "zero-trust-example"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::public-data/*"
      Condition = {
        BoolIfExists = {"aws:MultiFactorAuthPresent": "true"}
      }
    }]
  })
}
📖 Day 25 – Continuous Monitoring
bash
Copy code
# AWS GuardDuty example
aws guardduty list-detectors
aws guardduty get-findings --detector-id <id>
Monitor anomalies: impossible travel, after-hours logins, non-compliant devices.

📖 Day 27 – Incident Response Simulation
python
Copy code
def detect_anomaly(events):
    suspicious = [e for e in events if e["risk_score"] > 80]
    for e in suspicious:
        print("🚨 Incident:", e["event_id"])
Quiz – Automation Logic

Why express trust policies as code?
✅ To version, test, and deploy them like software — ensuring consistency.

🏁 Final Project — Your Mini Zero Trust Lab
🔨 Build
1 Identity Provider (Azure AD Free Tier)

1 Cloud (VM or Container) + MFA Policy

1 ZTNA Gateway (simulated Verified Access or App Proxy)

🎯 Deliver
Component	Demonstration
MFA Policy	Login requires MFA
Logging	Access attempts visible in audit logs
Isolation	Deny-by-default proven via blocked ping
Policy as Code	Terraform or YAML snippet committed

🏆 Evaluation
✅ Explains concept clearly

✅ Implements hands-on lab

✅ Uses least privilege

✅ Shows measurable improvement (fewer open ports / access paths)

🧠 Key Takeaways
Principle	Meaning	Example
Never Trust, Always Verify	Default deny	Every API call must authenticate
Least Privilege	Minimize access	IAM roles grant only needed actions
Micro-Segmentation	Divide blast radius	NetworkPolicy per namespace
Continuous Monitoring	Observe every request	GuardDuty, Azure Sentinel
Policy as Code	Automate trust rules	Terraform / OPA / Cedar

📚 Further Reading & Tools
NIST SP 800-207 — Zero Trust Architecture

AWS Verified Access Developer Guide

Microsoft Zero Trust Maturity Model

Google BeyondCorp Papers

Open Policy Agent (OPA)

HashiCorp Boundary & Terraform

🏆 Certification Milestone
After finishing this module, you can pursue:

Zero Trust Fundamentals Badge (course award)

Cloud-Specific Zero Trust Track (AWS / Azure / GCP)

Policy-as-Code Practitioner

Zero Trust Incident Responder

🔄 Next Module
Continue to docs/04-core-concepts-deepdive.md for advanced terminology, architectures, and hands-on multi-cloud identity integration.

🧩 “Security isn’t about walls anymore — it’s about identity, context, and confidence at every interaction.”
