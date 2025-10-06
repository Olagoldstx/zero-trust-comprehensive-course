package httpapi.authz

default allow = false

# Role- and tier-based policy with comprehensive checks
allow if {
    # Identity verification
    user_allowlist[input.user]
    
    # Method restrictions
    input.method == "GET"
    
    # Device compliance
    input.device.compliant
    
    # Risk threshold
    input.context.risk <= risk_threshold
    
    # Resource sensitivity tier enforcement
    tier := resource_tiers[input.path]
    check_tier_access(tier, input.role, input.context)
}

# User authorization
user_allowlist := {"ola", "admin", "employee", "auditor"}

# Risk management
risk_threshold := 40

# Map resource paths → sensitivity tiers
resource_tiers := {
    "/public": "public",
    "/internal": "internal", 
    "/confidential": "confidential",
    "/restricted": "restricted",
    "/regulated": "regulated"
}

# Authorization matrix - Tier-based access control
check_tier_access(tier, role, context) if {
    tier == "public"
    # Minimal checks for public data
}

check_tier_access(tier, role, context) if {
    tier == "internal"
    role == "employee"
    # Basic employment verification
}

check_tier_access(tier, role, context) if {
    tier == "confidential"
    role == "admin"
    context.mfa_passed
    # MFA required for confidential data
}

check_tier_access(tier, role, context) if {
    tier == "restricted"
    role == "admin"
    context.mfa_passed
    context.risk <= 20  # Lower risk threshold
    input.device.encrypted
    # Enhanced security for restricted data
}

check_tier_access(tier, role, context) if {
    tier == "regulated"
    role == "auditor"
    context.mfa_passed
    context.risk <= 10  # Very low risk threshold
    input.device.encrypted
    context.working_hours
    # Maximum security for regulated data
}
