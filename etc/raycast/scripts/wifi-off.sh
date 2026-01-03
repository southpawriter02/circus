#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Wi-Fi Off
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📶
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Turn off the Wi-Fi adapter
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc wifi off
