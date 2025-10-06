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

## 🔄 Federation Flow

1. **Request** → PEP Proxy intercepts
2. **Delegation** → PEP calls Child OPA for business logic
3. **Coordination** → PEP calls Root OPA with child decision
4. **Enforcement** → Root makes final decision based on both inputs
5. **Action** → PEP allows or denies request

## 🧪 Test Scenarios

| Scenario | User | Role | Delegated | Risk | Expected |
|----------|------|------|-----------|------|----------|
| Normal Access | ola | admin | ✅ | 20 | ✅ ALLOW |
| Business Deny | ola | contractor | ❌ | 20 | ❌ DENY |
| High Risk | admin | admin | ✅ | 45 | ❌ DENY |
| Emergency | federation-admin | admin | ❌ | 60 | ✅ ALLOW |

## 🚀 Enterprise Applications

### Microservices Federation:
- Each service team manages their child OPA
- Root OPA enforces cross-cutting concerns
- Consistent security posture across services

### Hybrid Cloud Federation:
- Child OPAs in different cloud regions
- Root OPA in central governance plane
- Unified policy across cloud boundaries

### Multi-Tenant Systems:
- Tenant-specific child OPAs
- Root OPA ensures tenant isolation
- Scalable policy management

## 🔒 Security Considerations

- **Decision Signing**: Child decisions should be cryptographically signed
- **Transport Security**: mTLS between OPAs
- **Audit Trail**: Log all federation decisions
- **Rate Limiting**: Prevent policy decision exhaustion

[Back to Main Course](../../README.md)
