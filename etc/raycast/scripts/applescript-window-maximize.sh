#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Window: Maximize
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Maximize current window to fill screen
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript window maximize
