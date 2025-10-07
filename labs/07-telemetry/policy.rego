package telemetry.enforce

default allow = false

# Simple working policy with telemetry
allow {
    input.user == "ola"
    input.device.compliant
    input.context.risk <= 50
    trace(sprintf("ALLOW user=%v risk=%v", [input.user, input.context.risk]))
}

# Deny with telemetry
deny {
    not allow
    trace(sprintf("DENY user=%v risk=%v", [input.user, input.context.risk]))
}
