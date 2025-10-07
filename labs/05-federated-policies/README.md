# Lesson 5: Policy Federation & Delegated Trust

## 🎯 Learning Objectives
- Implement distributed policy decision points across services
- Establish trust chains between root and child policy engines
- Design federation patterns for microservices and hybrid clouds
- Understand delegated authority with verification

## 🏗️ Federation Architecture

### Components:
- **Root OPA**: Central policy coordinator and trust anchor
- **Child OPA**: Domain-specific policy decision point  
- **PEP Proxy**: Policy enforcement point (from Lesson 2)
- **Trust Chain**: Verified communication between components

### Key Concepts:
1. **Delegated Authority**: Child OPAs make business-specific decisions
2. **Trust Verification**: Root validates child decisions and context
3. **Emergency Override**: Central authority can bypass normal flow
4. **Risk Aggregation**: Combined risk assessment across domains

## 🔧 Files in This Lab

### Policy Files:
- `root.rego` - Central policy coordinator with emergency override
- `child.rego` - Business-specific policy logic

### Test Scenarios:
- `successful-federation.json` - Normal federation flow
- `failed-delegation.json` - Child denies access
- `high-risk.json` - Risk threshold violation
- `emergency-override.json` - Emergency bypass scenario

### Automation Scripts:
- `start-federation.sh` - Start both OPA servers
- `test-federation.sh` - Run all test scenarios

## 🚀 Quick Start

1. **Start the federation servers:**
   ```bash
   ./start-federation.sh
Run the tests:

bash
./test-federation.sh
🧪 Test Scenarios
Scenario	User	Role	Delegated	Risk	Expected
Normal Access	ola	admin	✅	20	✅ ALLOW
Business Deny	ola	contractor	❌	20	❌ DENY
High Risk	admin	admin	✅	45	❌ DENY
Emergency	federation-admin	admin	❌	60	✅ ALLOW
🔒 Security Features
Delegated Trust: Child OPA handles business logic

Central Governance: Root OPA maintains overall control

Emergency Override: Break-glass access for critical situations

Risk-Based Decisions: Combined risk assessment

🌐 Enterprise Applications
Microservices: Each service team manages child OPA

Hybrid Cloud: Regional OPAs with central governance

Multi-Tenant: Tenant-specific policies with isolation

Compliance: Centralized audit and control

🔄 Integration Flow
Request → PEP Proxy intercepts

Business Logic → PEP calls Child OPA

Central Decision → PEP calls Root OPA with child result

Enforcement → Root makes final decision

Action → PEP allows or denies request

Back to Main Course

text

## 🎯 **Why Include All Sections:**

- **🧪 Test Scenarios** - Shows learners exactly what to expect
- **🔒 Security Features** - Highlights the security benefits  
- **🌐 Enterprise Applications** - Demonstrates real-world use cases
- **🔄 Integration Flow** - Explains how everything works together
