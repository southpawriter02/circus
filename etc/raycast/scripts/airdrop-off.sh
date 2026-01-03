#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AirDrop: Off
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📲
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Turn off AirDrop
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc airdrop off
