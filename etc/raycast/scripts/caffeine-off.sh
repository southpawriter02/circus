#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Caffeine Off
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Allow sleep (disable caffeine)
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc caffeine off
