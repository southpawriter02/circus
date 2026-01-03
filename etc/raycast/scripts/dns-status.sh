#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DNS Status
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Show current DNS servers
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc dns status
