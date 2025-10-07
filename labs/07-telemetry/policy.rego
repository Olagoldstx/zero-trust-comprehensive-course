package telemetry.enforce

import future.keywords.in

default allow = false

# Telemetry-enhanced authorization with comprehensive metrics
allow if {
    # Identity verification
    input.user in user_allowlist
    
    # Device compliance
    input.device.compliant
    
    # Risk assessment
    input.context.risk <= risk_threshold
    
    # Geographic controls (if enabled)
    valid_geolocation
    
    # Time-based restrictions
    within_access_hours
    
    # Emit telemetry for ALLOW decisions
    trace_decision("ALLOW", input.user, input.context.risk, "low_risk_compliant_device")
}

# Automatic deny with detailed telemetry
deny if {
    # Emit telemetry for DENY decisions with reason
    decision_reason := get_deny_reason
    trace_decision("DENY", input.user, input.context.risk, decision_reason)
}

# User authorization list
user_allowlist := {"ola", "admin", "operator", "auditor"}

# Dynamic risk threshold
risk_threshold := 50

# Geolocation validation
valid_geolocation if {
    not input.context.geo_restricted
}

valid_geolocation if {
    input.context.geo_restricted
    input.context.country in allowed_countries
}

allowed_countries := {"US", "CA", "UK", "DE"}

# Time-based access controls
within_access_hours if {
    not input.context.time_restricted
}

within_access_hours if {
    input.context.time_restricted
    current_hour >= 9
    current_hour <= 17
}

current_hour := time.clock(time.now_ns())[0]

# Determine deny reason for telemetry
get_deny_reason := reason if {
    not input.user in user_allowlist
    reason := "unauthorized_user"
}

get_deny_reason := reason if {
    input.user in user_allowlist
    not input.device.compliant
    reason := "non_compliant_device"
}

get_deny_reason := reason if {
    input.user in user_allowlist
    input.device.compliant
    input.context.risk > risk_threshold
    reason := "high_risk_score"
}

get_deny_reason := reason if {
    input.user in user_allowlist
    input.device.compliant
    input.context.risk <= risk_threshold
    input.context.geo_restricted
    not input.context.country in allowed_countries
    reason := "geographic_restriction"
}

get_deny_reason := reason if {
    input.user in user_allowlist
    input.device.compliant
    input.context.risk <= risk_threshold
    not within_access_hours
    reason := "outside_access_hours"
}

get_deny_reason := "unknown_reason"

# Telemetry helper function
trace_decision(outcome, user, risk, reason) = true if {
    trace(sprintf("decision_outcome=%s user=%s risk=%d reason=%s timestamp=%s", 
        [outcome, user, risk, reason, time.format_rfc3339_ns(time.now_ns())]))
}

# Metrics counters for Prometheus
decision_counter[outcome] := count if {
    some i
    decision := trace_decision(outcome, _, _, _)
    count := i + 1
}
