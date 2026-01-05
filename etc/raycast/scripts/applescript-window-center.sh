#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window: Center
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Center current window on screen
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript window center
