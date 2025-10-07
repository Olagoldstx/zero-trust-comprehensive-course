package telemetry.enforce

default allow = false

allow {
    input.user == "ola"
    input.device.compliant
    input.context.risk <= 50
}

allow {
    input.user == "guest" 
    input.device.compliant
    input.context.risk <= 30
}
