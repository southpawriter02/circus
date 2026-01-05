#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clipboard: lowercase
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Convert clipboard text to lowercase
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript clip lower
