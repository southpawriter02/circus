#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AirDrop: Contacts Only
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📲
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Set AirDrop to contacts only
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc airdrop contacts
