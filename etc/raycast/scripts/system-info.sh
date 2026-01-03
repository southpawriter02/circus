#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System Info
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 💻
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Show system information
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc info
