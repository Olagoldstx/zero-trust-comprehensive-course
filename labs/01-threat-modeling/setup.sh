#!/bin/bash
echo "🔐 Lesson 1: Zero Trust Foundation Setup"
echo "========================================"

# Create basic directory structure
mkdir -p policies logs telemetry

# Initialize basic policy file
cat > policies/basic_auth.rego << 'POLICY'
package zero_trust.auth

default allow = false

allow {
    input.user == "admin"
    input.device.compliant == true
    input.context.risk < 50
}
POLICY

echo "✅ Zero Trust foundation established"
echo "📁 Created: policies/basic_auth.rego"
echo "📁 Created: telemetry/ directory"
echo "📁 Created: logs/ directory"
