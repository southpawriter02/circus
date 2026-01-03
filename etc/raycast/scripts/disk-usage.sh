#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Disk Usage
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 💾
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Show detailed disk usage
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc disk usage
