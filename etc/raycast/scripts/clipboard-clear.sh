#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clipboard: Clear
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Clear the clipboard
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc clipboard clear
