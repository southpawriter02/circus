#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DNS: Quad9
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Set DNS to Quad9 (9.9.9.9)
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc dns set quad9
