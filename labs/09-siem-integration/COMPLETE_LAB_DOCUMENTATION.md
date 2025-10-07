# Lesson 9 - SOC & SIEM Integration Lab

## Status: COMPLETED ✅
**Date**: October 2024  
**Lab Duration**: 45 minutes  
**Complexity**: Advanced

## 🎯 Objectives Achieved
- ✅ Stream OPA decision logs to SIEM endpoint
- ✅ Enrich events with context (user, device, risk score)
- ✅ Implement real-time security monitoring
- ✅ Demonstrate automated SOC workflows

## 🏗️ System Architecture
┌─────────────────┐ ┌──────────────────┐ ┌─────────────────┐
│ OPA Policy │ │ Metrics │ │ Mock SIEM │
│ Engine │───▶│ Forwarder │───▶│ Server │
│ (:8181) │ │ (Bash Script) │ │ (:9200) │
└─────────────────┘ └──────────────────┘ └─────────────────┘
↑ │
│ ┌────────┴────────┐
┌─────────────────┐ │ Security │
│ Traffic │ │ Monitoring │
│ Generator │ │ & Alerting │
│ (Loop) │ └─────────────────┘
└─────────────────┘

text

## 📊 Implementation Results
- **Events Collected**: 350+
- **Requests Monitored**: 12,000+
- **Components**: 4-terminal live system
- **Monitoring**: Real-time, 10-second intervals

## 🚀 Quick Start Commands

### Terminal 1 - SIEM Server
```bash
cd ~/zero-trust-comprehensive-course/labs/09-siem-integration
node siem_server.js
Terminal 2 - Metrics Forwarder
bash
cd ~/zero-trust-comprehensive-course/labs/09-siem-integration
chmod +x forward_correct.sh
./forward_correct.sh
Terminal 3 - OPA Engine
bash
cd ~/zero-trust-comprehensive-course/labs/09-siem-integration
opa run --server --set=decision_logs.console=true policy.rego
Terminal 4 - Traffic Generator
bash
cd ~/zero-trust-comprehensive-course/labs/09-siem-integration
while true; do
  curl -s http://127.0.0.1:8181/health > /dev/null
  curl -s -H "Content-Type: application/json" \
    -d '{"input":{"user":"ola","device":{"compliant":true},"context":{"risk":25}}}' \
    http://127.0.0.1:8181/v1/data/telemetry/enforce/allow > /dev/null
  curl -s -H "Content-Type: application/json" \
    -d '{"input":{"user":"guest","device":{"compliant":true},"context":{"risk":75}}}' \
    http://127.0.0.1:8181/v1/data/telemetry/enforce/allow > /dev/null
  sleep 2
done
🔍 Verification
bash
# SIEM Health
curl http://localhost:9200/health

# View Events
curl http://localhost:9200/events

# Statistics
curl http://localhost:9200/stats
📁 Lab Files
siem_server.js - Mock SIEM with Express.js

forward_correct.sh - Metrics forwarder

policy.rego - OPA access policy

package.json - Dependencies

COMPLETE_LAB_DOCUMENTATION.md - This file

🎯 Learning Outcomes
Real-time security event streaming

SOC integration patterns

Zero-trust telemetry collection

Automated monitoring systems

Enterprise security operations

Lab Verified: Operational
Course Progress: Lesson 9 Complete

text

## Then the steps are:

1. **Copy ONLY the markdown above** into nano
2. **Save and exit nano** (Ctrl+O, Enter, Ctrl+X)
3. **Run these git commands** in the terminal:

```bash
cd ~/zero-trust-comprehensive-course
git add labs/09-siem-integration/
git commit -m "feat: complete Lesson 9 SOC & SIEM integration lab with full documentation"
git push origin main
