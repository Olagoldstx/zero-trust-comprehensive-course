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

## 📈 Enterprise Extensions

- **Dynamic Tier Assignment**: Classify resources based on content scanning
- **Temporal Controls**: Time-based access restrictions
- **Geofencing**: Location-based tier enforcement
- **Behavioral Analytics**: Anomaly detection for high-tier resources

[Back to Main Course](../../README.md)
