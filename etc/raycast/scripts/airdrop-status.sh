#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AirDrop Status
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📲
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Show AirDrop status
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc airdrop status
