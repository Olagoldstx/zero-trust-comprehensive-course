# Lesson 11 — Automated Response & Adaptive Access (SOAR Integration)

We connect SIEM alerts to automated response logic and dynamically tune policy states.

## Objectives
- Watch deny_ratio signals and trigger actions automatically.
- Modify OPA policy state based on live telemetry.
- Build a feedback loop between analytics and enforcement.

## How to Run
```bash
opa run --server --addr :8181 --set prometheus=true
labs/11-soar-integration/response_engine.sh
labs/11-soar-integration/adaptive_policy.sh
labs/10-siem-analytics/generate_events.sh
Reflection
What's the risk of false positives triggering restricted mode?

How could you escalate to human review before lockdown?

Would you integrate external playbooks (e.g., AWS Lambda, Slack alerts, PagerDuty)?

Visual Overview
See: diagrams/model-05-soar.mmd
