#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window: Left Half
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Move current window to left half of screen
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript window left
