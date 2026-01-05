#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Safari: Copy Tab URLs
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧭
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Copy all open Safari tab URLs to clipboard
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript safari tabs
