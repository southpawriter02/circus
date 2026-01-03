#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Caffeine 1 Hour
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Prevent sleep for 1 hour
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc caffeine for 60
