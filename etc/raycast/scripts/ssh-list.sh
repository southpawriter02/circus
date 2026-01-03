#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title SSH: List Keys
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description List SSH keys
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc ssh list
