# Lesson 4: Multi-Resource Policies & Sensitivity Tiers

## 🎯 Learning Objectives
- Implement tier-based access control for different data sensitivity levels
- Apply contextual enforcement using risk, device, and role signals
- Design enterprise-grade authorization policies
- Extend dynamic signals from Lesson 3

## 🔐 Sensitivity Tiers Implementation

### Tier Definitions:
- **Public**: Read-only for authenticated users
- **Internal**: Employees with basic verification  
- **Confidential**: Admins with MFA requirement
- **Restricted**: Enhanced security with lower risk thresholds
- **Regulated**: Maximum security with multiple controls

### Policy Enforcement Points:
1. **User Identity** - Allowlist verification
2. **Device Compliance** - Encryption and compliance checks
3. **Risk Assessment** - Contextual risk scoring
4. **Tier-Based Rules** - Progressive security requirements

## 📊 Authorization Flow Visualization

### Decision Flow Diagram
\`\`\`mermaid
flowchart TD
    A[📨 Access Request] --> B{User in Allowlist?}
    B -->|No| C[🚫 Access Denied]
    B -->|Yes| D{Device Compliant?}
    
    D -->|No| C
    D -->|Yes| E{Risk ≤ 40?}
    
    E -->|No| C
    E -->|Yes| F[🔍 Determine Resource Tier]
    
    F --> G{Tier Classification}
    G -->|Public| H[🌐 Public Tier]
    G -->|Internal| I[🏢 Internal Tier]
    G -->|Confidential| J[🔒 Confidential Tier]
    G -->|Restricted| K[⚡ Restricted Tier]
    G -->|Regulated| L[📜 Regulated Tier]
    
    H --> M{Authenticated?}
    M -->|Yes| N[✅ Access Granted]
    M -->|No| C
    
    I --> O{Role = Employee?}
    O -->|Yes| N
    O -->|No| C
    
    J --> P{Role = Admin?}
    P -->|No| C
    P -->|Yes| Q{MFA Passed?}
    Q -->|No| C
    Q -->|Yes| N
    
    K --> R{Role = Admin?}
    R -->|No| C
    R -->|Yes| S{MFA Passed?}
    S -->|No| C
    S -->|Yes| T{Risk ≤ 20?}
    T -->|No| C
    T -->|Yes| U{Device Encrypted?}
    U -->|No| C
    U -->|Yes| N
    
    L --> V{Role = Auditor?}
    V -->|No| C
    V -->|Yes| W{MFA Passed?}
    W -->|No| C
    W -->|Yes| X{Risk ≤ 10?}
    X -->|No| C
    X -->|Yes| Y{Device Encrypted?}
    Y -->|No| C
    Y -->|Yes| Z{Working Hours?}
    Z -->|No| C
    Z -->|Yes| N
    
    classDef tierPublic fill:#E8F5E8,stroke:#4CAF50
    classDef tierInternal fill:#E3F2FD,stroke:#2196F3
    classDef tierConfidential fill:#FFF3E0,stroke:#FF9800
    classDef tierRestricted fill:#FFEBEE,stroke:#F44336
    classDef tierRegulated fill:#F3E5F5,stroke:#9C27B0
    classDef success fill:#C8E6C9,stroke:#2E7D32
    classDef denied fill:#FFCDD2,stroke:#C62828
    
    class H tierPublic
    class I tierInternal
    class J tierConfidential
    class K tierRestricted
    class L tierRegulated
    class N success
    class C denied
\`\`\`

### Role-Tier Access Matrix
\`\`\`mermaid  
graph TB
    subgraph ROLES [User Roles]
        R1[👨‍💼 Employee]
        R2[👨‍💻 Admin]
        R3[👨‍⚖️ Auditor]
        R4[👤 Guest]
    end
    
    subgraph TIERS [Sensitivity Tiers]
        T1[🌐 Public]
        T2[🏢 Internal]
        T3[🔒 Confidential]
        T4[⚡ Restricted]
        T5[📜 Regulated]
    end
    
    subgraph CONDITIONS [Security Conditions]
        C1[✅ Authenticated]
        C2[📱 Device Compliant]
        C3[🎯 Risk ≤ 40]
        C4[🔐 MFA Required]
        C5[📊 Risk ≤ 20]
        C6[💾 Device Encrypted]
        C7[📊 Risk ≤ 10]
        C8[🕒 Working Hours]
    end
    
    R1 -->|Can Access| T1
    R1 -->|Can Access| T2
    T1 --> C1
    T2 --> C1
    T2 --> C2
    T2 --> C3
    
    R2 -->|Can Access| T1
    R2 -->|Can Access| T2
    R2 -->|Can Access| T3
    R2 -->|Can Access| T4
    T3 --> C1
    T3 --> C2
    T3 --> C3
    T3 --> C4
    T4 --> C1
    T4 --> C2
    T4 --> C4
    T4 --> C5
    T4 --> C6
    
    R3 -->|Can Access| T5
    T5 --> C1
    T5 --> C2
    T5 --> C4
    T5 --> C7
    T5 --> C6
    T5 --> C8
    
    R4 -->|Can Access| T1
    T1 --> C1
    
    classDef role fill:#E3F2FD,stroke:#1976D2
    classDef tier fill:#F3E5F5,stroke:#7B1FA2
    classDef condition fill:#E8F5E8,stroke:#388E3C
    
    class R1,R2,R3,R4 role
    class T1,T2,T3,T4,T5 tier
    class C1,C2,C3,C4,C5,C6,C7,C8 condition
\`\`\`

## 🧪 Test Scenarios

| User | Tier | Role | MFA | Risk | Expected |
|------|------|------|-----|------|----------|
| Admin | Confidential | admin | ✅ | 20 | ✅ ALLOW |
| Employee | Internal | employee | ❌ | 20 | ✅ ALLOW |
| Guest | Confidential | guest | ❌ | 20 | ❌ DENY |
| Auditor | Regulated | auditor | ✅ | 5 | ✅ ALLOW |
| Admin | Restricted | admin | ✅ | 45 | ❌ DENY |

## 🚀 Integration with PEP Proxy

This policy can be integrated into your Lesson 2 PEP proxy by:
1. Adding resource classification to target services
2. Enriching request context with device and risk signals
3. Implementing the tier-based policy in OPA

## 🎯 Visual Key Takeaways

1. **Progressive Security** - Each tier adds additional controls
2. **Role-Based Foundation** - Different roles access different tiers  
3. **Contextual Enforcement** - Risk, device, and time factors influence access
4. **Defense in Depth** - Multiple security layers protect sensitive data

## 🔧 Implementation Notes

- The diagrams match exactly with the `policy.rego` logic
- Each decision point corresponds to a policy rule
- Real enterprises use similar tiered approaches for data classification

[Back to Main Course](../../README.md)
