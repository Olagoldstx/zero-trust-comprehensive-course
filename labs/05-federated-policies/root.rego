package federation.root

default allow = false

# Root OPA acts as central policy coordinator
# Only allows requests that pass both local AND delegated checks
allow if {
    # Local identity verification
    user_allowlist[input.user]
    
    # Risk assessment
    input.context.risk <= risk_threshold
    
    # Delegated policy decision from child OPA
    input.context.delegated_allow == true
    
    # Additional root-level controls
    input.context.origin_verified == true
}

# Root-level user authorization
user_allowlist := {"ola", "admin", "federation-admin"}

# Central risk management
risk_threshold := 40

# Root can override child decisions in emergencies
emergency_override if {
    input.context.emergency_mode == true
    input.user == "federation-admin"
}
