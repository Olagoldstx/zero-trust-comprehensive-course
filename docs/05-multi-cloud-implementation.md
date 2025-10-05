🧭 Module 5 — Multi-Cloud Zero Trust Implementation
“Identity everywhere, trust nowhere.”

“In the cloud, perimeter is no longer a wall — it’s every workload, every device, and every identity.”

🎯 Learning Objectives

By the end of this module, you’ll be able to:

Design and deploy Zero Trust controls across AWS, Azure, and GCP.

Build unified identity and cross-cloud SSO.

Enforce policy-as-code for consistent least-privilege.

Automate posture checks and logging across clouds.

1️⃣ Understanding Multi-Cloud Zero Trust
🧩 Analogy: “Airports with different terminals”

AWS, Azure, and GCP are three different airports.

Each has its own gates (IAM systems), customs (policies), and flight crews (services).

Zero Trust = a unified travel authority that verifies your passport and ticket before you enter each gate.

🧠 Core Principles Recap
Concept	AWS	Azure	GCP
Identity Provider	IAM Identity Center / AWS SSO	Entra ID (Azure AD)	Cloud Identity
ZTNA Gateway	Verified Access	App Proxy / Private Link	BeyondCorp Enterprise
Policy Engine	Cedar / ABAC policies	Conditional Access	Access Context Manager
Telemetry & Logs	CloudTrail	Sentinel / Log Analytics	Cloud Logging
2️⃣ Unified Identity & Access Flow
flowchart TD
    subgraph IdP["Central Identity Provider (Azure AD / Okta)"]
        A[User Sign-In → MFA / Risk Analysis]
        A --> B[Issue OIDC Token (JWT)]
    end

    subgraph AWS["AWS Trust Boundary"]
        B --> C[Verified Access Gateway]
        C --> D[Private App (EC2/EKS)]
    end

    subgraph Azure["Azure Trust Boundary"]
        B --> E[App Proxy / Conditional Access]
        E --> F[VMSS / AKS Apps]
    end

    subgraph GCP["GCP Trust Boundary"]
        B --> G[BeyondCorp Enterprise]
        G --> H[Cloud Run / GKE Apps]
    end


Workflow

Central IdP authenticates user + device.

Each cloud validates that token using its own ZTNA gateway.

Access is context-aware: location, device health, risk score.

3️⃣ Hands-On Lab — Multi-Cloud SSO
🔧 Step 1 — Set Up Azure AD as Primary Identity Provider
az ad app create --display-name "MultiCloud-ZeroTrust"
az ad app federated-credential create \
  --id <AppID> --parameters '{"name":"AWSFederation","issuer":"https://sts.windows.net/...","subject":"user@domain.com"}'

🔧 Step 2 — Integrate with AWS IAM Identity Center
aws sso-admin create-instance --region us-east-1
aws sso-admin create-application --instance-arn <InstanceArn> \
  --display-name "AzureAD-Linked-App"

🔧 Step 3 — Enable GCP Workforce Identity Federation
gcloud iam workload-identity-pools create "zero-trust-pool" \
  --location="global" --description="Cross-cloud federation pool"

🔧 Step 4 — Test Access Flow
TOKEN=$(az account get-access-token --query accessToken -o tsv)
curl -H "Authorization: Bearer $TOKEN" https://aws-app.example.com
curl -H "Authorization: Bearer $TOKEN" https://gcp-app.example.com


✅ Expected Result:
All three clouds honor the same MFA-verified token for controlled app access.

4️⃣ Policy-as-Code Blueprint
# Terraform Module: Zero-Trust-Policy
variable "require_mfa" { default = true }

locals {
  common_policy = {
    "Version" = "2023-01-01"
    "Statement" = [{
      "Effect" = "Allow"
      "Action" = ["read", "write"]
      "Condition" = {
        "Bool" = { "aws:MultiFactorAuthPresent" = var.require_mfa }
      }
    }]
  }
}

output "policy_json" {
  value = jsonencode(local.common_policy)
}


This same logic can be reused for Azure Blueprints or GCP IAM Conditions, giving you policy consistency across providers.

5️⃣ Monitoring & Response Integration
flowchart LR
    A[CloudTrail] --> X[Central SIEM (Sentinel)]
    B[Azure Diagnostics] --> X
    C[Cloud Logging] --> X
    X --> Y[Anomaly Detection Engine]
    Y --> Z[Incident Response Playbooks]


Example Python Alert:

if event.user_risk > 0.8 and event.cloud in ["AWS","GCP","Azure"]:
    quarantine_account(event.user)
    notify_secops(event)

6️⃣ Real-World Case Study — “FinSecure Inc.”
Challenge	Before ZT	After ZT Multi-Cloud
Fragmented access policies	Each cloud managed separately	Unified SSO through Azure AD
Lateral movement risk	VPN shared credentials	Per-app ZTNA tokens
Slow incident detection	Logs in different formats	Central SIEM + automation
7️⃣ Quiz Checkpoint

Q1: Why is policy-as-code critical in multi-cloud Zero Trust?
A: It keeps security logic consistent and auditable across providers.

Q2: What service replaces VPN in Zero Trust?
A: ZTNA Gateway (AWS Verified Access, App Proxy, BeyondCorp).

Q3: What’s the main role of identity federation?
A: To let one trusted identity travel securely across multiple clouds.

🧩 Key Takeaways

Zero Trust = Identity + Policy + Telemetry —not firewalls.

Multi-cloud requires federated identity and shared context.

Policies should be coded, tested, and versioned just like software.

Security and usability can co-exist when trust is adaptive.

🚀 Next Module

Move to docs/06-case-study-failure-analysis.md
and learn how to diagnose and fix Zero Trust rollout failures with incident forensics.

“Zero Trust is not a toolset — it’s a discipline of constant verification and measured confidence.”

✅ That’s the entire content for Module 5.
