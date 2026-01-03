#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title SSH: Copy Public Key
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Copy default SSH public key to clipboard
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc ssh copy
