#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AirDrop: Everyone
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📲
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Set AirDrop to discoverable by everyone
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc airdrop everyone
