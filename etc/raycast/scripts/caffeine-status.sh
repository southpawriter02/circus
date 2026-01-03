#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Caffeine Status
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Show caffeine status
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc caffeine status
