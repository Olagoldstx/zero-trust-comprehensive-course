package telemetry.enforce

default allow = false

# User "ola" - trusted employee, medium risk tolerance
allow {
    input.user == "ola"
    input.device.compliant
    input.context.risk <= 50
}

# User "admin" - administrative access, higher risk tolerance  
allow {
    input.user == "admin"
    input.device.compliant
    input.context.risk <= 70
}

# User "guest" - external user, strict controls
allow {
    input.user == "guest"
    input.device.compliant
    input.context.risk <= 30
}

# User "analyst" - data analyst, medium-low risk tolerance
allow {
    input.user == "analyst" 
    input.device.compliant
    input.context.risk <= 40
}

# User "api" - service account, medium risk tolerance
allow {
    input.user == "api"
    input.device.compliant
    input.context.risk <= 60
}
