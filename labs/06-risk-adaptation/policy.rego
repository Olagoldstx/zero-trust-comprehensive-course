package risk.adaptation

default allow = false

# Just-in-time access with continuous risk assessment
allow if {
    # Identity verification
    valid_user[input.user]
    
    # Role-based access
    valid_role[input.role]
    
    # Device compliance
    input.device.compliant == true
    
    # Risk threshold based on sensitivity
    input.context.risk <= risk_threshold[input.context.sensitivity]
    
    # Time-bound access (JIT principle)
    within_access_window
    
    # Geographic restrictions (if enabled)
    valid_location
    
    # Behavioral baseline (if available)
    normal_behavior
}

# User validation
valid_user := {"ola", "admin", "jit-user", "emergency-responder"}

# Role validation with permissions
valid_role := {
    "admin",
    "operator", 
    "auditor",
    "emergency-admin"
}

# Dynamic risk thresholds based on resource sensitivity
risk_threshold := {
    "low": 60,     # Public data
    "medium": 40,   # Internal data  
    "high": 25,     # Confidential data
    "critical": 15  # Regulated data
}

# Time-bound access window (JIT principle)
within_access_window if {
    now := time.now_ns()
    grant_start := input.context.grant_time
    grant_duration := input.context.grant_duration // Default to 15 minutes
    
    # Check within time window
    now >= grant_start
    now <= grant_start + grant_duration
}

# Emergency override for critical situations
emergency_override if {
    input.context.emergency_mode == true
    input.user == "emergency-responder"
    input.context.risk <= 80  # Higher risk tolerance in emergencies
}

# Geographic controls
valid_location if {
    not input.context.geo_restricted  # No restrictions
}

valid_location if {
    input.context.geo_restricted
    input.context.country == "US"  # Only allow US access
}

# Behavioral analysis (simplified)
normal_behavior if {
    not input.context.behavior_anomaly  # No anomalies detected
}

# Revocation conditions
access_revoked if {
    input.context.revoked == true
}

access_revoked if {
    input.context.risk > max_risk_threshold
}

# Maximum absolute risk threshold
max_risk_threshold := 85

# Audit logging rule
decision_log = {
    "timestamp": time.now_ns(),
    "user": input.user,
    "risk_score": input.context.risk,
    "sensitivity": input.context.sensitivity,
    "grant_duration": input.context.grant_duration,
    "decision": allow,
    "reason": decision_reason
}

decision_reason := "granted" if {
    allow
    not emergency_override
}

decision_reason := "emergency_override" if {
    allow
    emergency_override
}

decision_reason := "denied" if {
    not allow
}
