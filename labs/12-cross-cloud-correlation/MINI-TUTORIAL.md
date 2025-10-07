# 🎯 Lesson 12 Mini-Tutorial: Cross-Cloud Event Correlation
## Building Enterprise Multi-Cloud Security Monitoring

![Tutorial Level](https://img.shields.io/badge/Level-Intermediate-blue)
![Time Required](https://img.shields.io/badge/Time-30--45%20mins-orange)
![Hands-On](https://img.shields.io/badge/Type-Hands--On%20Lab-green)

## 🎯 Tutorial Objectives

By completing this tutorial, you will:

- ✅ **Understand** cross-cloud security correlation concepts
- ✅ **Generate** synthetic multi-cloud security events
- ✅ **Analyze** cross-cloud attack patterns
- ✅ **Detect** multi-cloud anomalies automatically
- ✅ **Build** a working correlation engine
- ✅ **Visualize** the complete security workflow

## 🏗️ Architecture Overview

```mermaid
flowchart TD
    A[🌐 AWS CloudWatch] --> F[Event Collector]
    B[🔷 Azure Monitor] --> F
    C[🔧 GCP Ops Suite] --> F
    F --> G[🔄 Normalization]
    G --> H[🎯 Correlation Engine]
    H --> I{Multi-Cloud Anomaly?}
    I -->|Yes| J[🚨 Alert Generation]
    I -->|No| K[✅ Normal Operation]
    J --> L[📊 Security Dashboard]
    K --> L
    
    style A fill:#ff9900
    style B fill:#0078d4
    style C fill:#4285f4
    style J fill:#ff4444
🛠️ Prerequisites
Basic understanding of cloud security concepts

Familiarity with JSON and command line

Completed Lessons 1-11 (recommended)

📚 Part 1: Understanding Cross-Cloud Correlation
What is Cross-Cloud Correlation?
Cross-cloud correlation means connecting security events across multiple cloud providers to detect coordinated attacks that might be invisible when looking at individual clouds.

Real-World Example:
text
🚨 ATTACK SCENARIO:
- 09:00: User "attacker" fails login on AWS (Medium risk)
- 09:02: Same user "attacker" accesses sensitive Azure resource (High risk)  
- 09:05: Same user "attacker" modifies GCP IAM policies (Critical risk)

INDIVIDUAL CLOUDS: Each event might be dismissed as noise
CROSS-CLOUD VIEW: Clear coordinated attack pattern!
Key Benefits:
Reduced False Positives - Validate alerts across clouds

Early Attack Detection - Spot patterns before major damage

Comprehensive Visibility - See the full attack chain

Automated Response - Trigger actions across all clouds

🎮 Part 2: Hands-On Lab Setup
Step 1: Verify Your Environment
bash
# Navigate to the lesson directory
cd ~/zero-trust-comprehensive-course/labs/12-cross-cloud-correlation

# Check available scripts
ls -la

# Expected output:
# generate_cloud_events.sh   - Creates synthetic cloud events
# correlate_events.sh        - Analyzes cross-cloud patterns  
# alert_correlations.sh      - Generates security alerts
Step 2: Understand the Data Model
Our system uses a unified security schema:

json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "cloud": "aws|azure|gcp",
  "user": "identity@domain", 
  "severity": 0-4,
  "message": "Security event description"
}
Severity Levels:

0-1: Low risk (Normal operations)

2-3: Medium risk (Suspicious activity)

4: High risk (Potential attack)

🔥 Part 3: Generating Multi-Cloud Events
Step 3: Create Synthetic Security Events
bash
# Generate 60 multi-cloud events
./generate_cloud_events.sh

# Expected output:
# 🌐 Generating 60 synthetic multi-cloud events...
# ✅ Generated 60 synthetic multi-cloud events → multicloud_events.jsonl
Step 4: Examine the Generated Data
bash
# View sample events
head -5 multicloud_events.jsonl | jq .

# Count events by cloud provider
jq -sr 'group_by(.cloud) | map({cloud: .[0].cloud, count: length})' multicloud_events.jsonl

# Count events by severity  
jq -sr 'group_by(.severity) | map({severity: .[0].severity, count: length})' multicloud_events.jsonl
📊 Sample Analysis Output:

json
[
  {"cloud": "aws", "count": 20},
  {"cloud": "azure", "count": 20}, 
  {"cloud": "gcp", "count": 20}
]
🕵️ Part 4: Correlation Analysis
Step 5: Run Cross-Cloud Correlation
bash
# Analyze user behavior across clouds
./correlate_events.sh | jq .

# For pretty formatted output:
./correlate_events.sh | jq -r '
  .[] | "User: \(.user) | Clouds: \(.clouds) | Events: \(.total_events) | High Severity: \(.high_severity_count)"
'
Step 6: Understand Correlation Results
The correlation engine analyzes:

User Activity Patterns - Which users operate across multiple clouds?

Severity Distribution - How many high-risk events per user?

Temporal Patterns - When did events occur?

Risk Scoring - Calculated risk based on severity and cloud spread

🎯 Key Metrics to Watch:

is_correlated: true - User active across multiple clouds

high_severity_count - Number of critical events

risk_score - Calculated threat level (higher = more dangerous)

🚨 Part 5: Anomaly Detection & Alerting
Step 7: Generate Security Alerts
bash
# Run the alerting system
./alert_correlations.sh

# Expected output includes:
# 🔥 CRITICAL alerts for multi-cloud attack patterns
# ⚠️ SUSPICIOUS alerts for cross-cloud activity
# ✅ NORMAL status for low-risk users
Step 8: Analyze Alert Scenarios
Scenario A: The Obvious Attacker

text
🔥 CRITICAL: Multi-cloud attack pattern detected!
   User: attacker | Clouds: [aws, azure, gcp]
   High-severity events: 13 | Total events: 13
   Risk Score: 12/100
   ➡️ Action: Immediate investigation required
Scenario B: Suspicious Cross-Cloud Activity

text
⚠️ SUSPICIOUS: Cross-cloud activity detected
   User: admin | Clouds: [aws, gcp] 
   Events: 7 across 2 clouds
   Risk Score: 45/100
   ➡️ Action: Enhanced monitoring
Scenario C: Normal User Behavior

text
✅ NORMAL: User: guest | Clouds: [aws] | Events: 3
🧪 Part 6: Advanced Exercises
Exercise 1: Custom Event Generation
Create your own attack scenario:

bash
# Create a targeted attack pattern
for i in {1..10}; do
  jq -nc --arg ts "$(date -Is)" \
    '{timestamp:$ts,cloud:"aws",user:"malicious_user",severity:4,message:"Privilege escalation"}' \
    >> multicloud_events.jsonl
  jq -nc --arg ts "$(date -Is)" \
    '{timestamp:$ts,cloud:"azure",user:"malicious_user",severity:4,message:"Sensitive data access"}' \
    >> multicloud_events.jsonl
done

# Re-run correlation
./alert_correlations.sh
Exercise 2: Modify Alert Thresholds
Edit the alert logic in alert_correlations.sh:

bash
# Change from:
if [[ "$correlated" == "true" && "$high" -gt 0 ]]; then

# To (more sensitive):
if [[ "$correlated" == "true" && "$total" -gt 3 ]]; then
Exercise 3: Add New Cloud Provider
Extend the system for additional clouds:

bash
# In generate_cloud_events.sh, add:
clouds=("aws" "azure" "gcp" "oracle" "ibm")

# Re-generate events and test correlation
📊 Part 7: Real-World Application
Production Deployment Considerations
Data Ingestion Pipeline:

yaml
aws:
  source: cloudwatch_logs_subscription
  filter: "SecurityHubEvents"
azure:  
  source: event_grid_service_bus
  filter: "SecurityCenterAlerts"
gcp:
  source: pubsub_topics  
  filter: "SecurityCommandCenter"
Correlation Rules for SOC:

Same user, multiple clouds within 5 minutes → Investigate

High severity + cross-cloud → Immediate alert

IAM changes across clouds → High priority review

Integration with Existing Tools
bash
# Send alerts to Slack
./alert_correlations.sh | grep "CRITICAL" | \
  curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚨 Multi-cloud attack detected!"}' \
  $SLACK_WEBHOOK_URL

# Create Jira tickets for critical alerts  
./alert_correlations.sh | grep "CRITICAL" | \
  while read alert; do
    # Jira API integration code here
    echo "Creating ticket for: $alert"
  done
🎯 Part 8: Knowledge Check
Quiz Questions:
What does is_correlated: true indicate?

A) User has events in a single cloud

B) User has events across multiple clouds ✅

C) User has only low-severity events

Which scenario would trigger a CRITICAL alert?

A) User with 1 event in AWS

B) User with high-severity events across 3 clouds ✅

C) User with 10 low-severity events in GCP

What's the purpose of risk scoring?

A) To count total events

B) To prioritize investigation efforts ✅

C) To generate pretty reports

Hands-On Challenge:
Mission: Detect a sophisticated attacker who:

Uses different usernames across clouds

Spreads medium-severity events

Operates across all 3 cloud providers

Hint: Modify the event generator to create this pattern, then update correlation logic to detect it.

🔧 Part 9: Troubleshooting Guide
Common Issues & Solutions
Issue: "jq: command not found"

bash
# Solution: Install jq
sudo apt-get install jq  # Ubuntu/Debian
# or
brew install jq         # macOS
Issue: "Permission denied" when running scripts

bash
# Solution: Make scripts executable  
chmod +x *.sh
Issue: No events generated

bash
# Solution: Check file permissions and disk space
ls -la multicloud_events.jsonl
df -h
Issue: Correlation shows no results

bash
# Solution: Verify JSON format
jq . multicloud_events.jsonl | head -1
🚀 Part 10: Next Steps
Continue Your Learning Path:
Lesson 13: Real-time Dashboard & Visualization

Advanced Correlation: Machine Learning integration

Production Deployment: Kubernetes & scaling

Cloud-Specific Deep Dives: AWS GuardDuty, Azure Sentinel, GCP SCC

Enterprise Extensions:
SIEM Integration: Splunk, Elasticsearch, Datadog

SOAR Automation: Automated response playbooks

Compliance Mapping: SOC2, ISO27001, HIPAA reporting

Threat Intelligence: Integration with external feeds

🏆 Completion Checklist
Generated multi-cloud events successfully

Ran correlation analysis and understood output

Generated security alerts for attack patterns

Modified alert thresholds and tested changes

Completed at least one advanced exercise

Understand how to deploy in production

🎉 Congratulations!
You've successfully built and operated a cross-cloud security correlation system that can detect sophisticated multi-cloud attacks. This is enterprise-grade security monitoring that many organizations are still trying to implement!

Key Skills Demonstrated:

Multi-cloud security monitoring

Event correlation and pattern detection

Risk-based alert prioritization

Security automation fundamentals

Ready to visualize this data in Lesson 13 with a real-time dashboard! 🚀

Need help? Check the main README.md or create an issue in the GitHub repository.

text

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

## 🎯 Let's Add the Tutorial to GitHub

```bash
# Add the mini-tutorial
git add labs/12-cross-cloud-correlation/MINI-TUTORIAL.md

# Commit with descriptive message
git commit -m "docs: add comprehensive mini-tutorial for Lesson 12

- Step-by-step hands-on guide for cross-cloud correlation
- Includes theory, practical exercises, and troubleshooting
- Covers all skill levels from beginner to advanced
- Real-world scenarios and production deployment guidance
- Knowledge checks and completion checklist"

# Push to GitHub
git push origin main
✅ Mini-Tutorial Complete!
This comprehensive tutorial provides:

For Beginners:

Step-by-step instructions with expected outputs

Clear explanations of concepts

Hands-on exercises with solutions

For Intermediate Users:

Real-world attack scenarios

Customization exercises

Integration patterns

For Advanced Professionals:

Production deployment considerations

Enterprise integration guides

Troubleshooting and optimization

The tutorial includes:

🎯 Clear learning objectives

🏗️ Architecture diagrams

🛠️ Hands-on labs

🧪 Advanced exercises

📊 Real-world applications

🔧 Troubleshooting guide

🏆 Completion checklist
