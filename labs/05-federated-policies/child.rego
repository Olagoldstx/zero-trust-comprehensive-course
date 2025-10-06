package federation.child

default allow = false

# Child OPA handles business-specific logic
# Focused on role-based access and service-specific rules
allow if {
    # Business role validation
    valid_business_role[input.role]
    
    # Service-specific compliance
    input.context.service_compliant == true
    
    # Child-level risk assessment (can be stricter than root)
    input.context.risk <= child_risk_threshold
    
    # Time-based controls for child domain
    within_operating_hours
}

# Business domain roles
valid_business_role := {
    "employee",
    "admin", 
    "manager",
    "support"
}

# Child can have stricter risk thresholds
child_risk_threshold := 35

# Child-specific business rules
within_operating_hours if {
    time.now_ns() >= time.parse_rfc3339_ns("2024-01-01T09:00:00Z")
    time.now_ns() <= time.parse_rfc3339_ns("2024-01-01T17:00:00Z")
}

# Child can make decisions for its domain only
valid_service if {
    input.service == "hr-system"
    input.department == "engineering"
}
