#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Bluetooth On
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📳
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Turn on Bluetooth
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc bluetooth on
