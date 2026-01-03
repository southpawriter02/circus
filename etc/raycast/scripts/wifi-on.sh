#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Wi-Fi On
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📶
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Turn on the Wi-Fi adapter
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc wifi on
