#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Lock Screen
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔒
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Lock the screen immediately
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc lock now
