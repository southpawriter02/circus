#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clipboard: UPPERCASE
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Convert clipboard text to UPPERCASE
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript clip upper
