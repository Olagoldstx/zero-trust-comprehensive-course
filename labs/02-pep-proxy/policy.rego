package httpapi.authz

default allow = false

# Allowlist of authorized users
allowlist := {"ola", "admin"}

# Allow rule: user must be in allowlist and making GET to /profiles
allow {
    input.method == "GET"
    input.path == "/profiles"
    allowlist[input.user]
}
