#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System Healthcheck
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🩺
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Run system diagnostics
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc healthcheck
