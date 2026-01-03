#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Caffeine On
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Prevent sleep indefinitely
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc caffeine on
