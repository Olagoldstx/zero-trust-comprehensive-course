# Lesson 1: Zero Trust Threat Modeling & Architecture Foundation

## 🎯 Learning Objectives
- Understand Zero Trust core principles
- Learn threat modeling methodologies  
- Design Zero Trust architecture
- Implement basic policy enforcement

## 🏗️ Core Zero Trust Principles
1. **Never Trust, Always Verify**: Authenticate and authorize every request
2. **Assume Breach**: Operate as if the environment is already compromised
3. **Least Privilege**: Grant minimum required access for minimum time
4. **Explicit Verification**: Verify all resources and access requests

## 🔧 Key Components
- **Policy Engine** (OPA - Open Policy Agent)
- **Policy Enforcement Points** (PEPs)
- **Telemetry Collection**
- **Threat Intelligence Integration**

## 📊 Architecture Overview

```mermaid
flowchart TB
    A[User/Device] --> B[PEP<br/>Policy Enforcement]
    B --> C[Policy Engine<br/>OPA]
    C --> D{Access Decision}
    D -->|Allow| E[Resource]
    D -->|Deny| F[Blocked]
    B --> G[Telemetry<br/>Collection]
    G --> H[Analytics<br/>& Monitoring]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style H fill:#fff3e0
🚀 Hands-On Lab
bash
# Initialize Zero Trust environment
./labs/01-threat-modeling/setup.sh

# Test basic policy enforcement
./labs/01-threat-modeling/test_policy.sh
📚 Next Steps
Lesson 2: Policy Enforcement Points

Lesson 3: Dynamic Signals & Telemetry

Lesson 4-15: Advanced Zero Trust Implementation

text

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

### Step 2: Create Lesson 01 Setup Script
```bash
nano labs/01-threat-modeling/setup.sh
Paste this content:

bash
#!/bin/bash
echo "🔐 Lesson 1: Zero Trust Foundation Setup"
echo "========================================"

# Create basic directory structure
mkdir -p policies logs telemetry

# Initialize basic policy file
cat > policies/basic_auth.rego << 'POLICY'
package zero_trust.auth

default allow = false

allow {
    input.user == "admin"
    input.device.compliant == true
    input.context.risk < 50
}
POLICY

echo "✅ Zero Trust foundation established"
echo "📁 Created: policies/basic_auth.rego"
echo "📁 Created: telemetry/ directory"
echo "📁 Created: logs/ directory"
