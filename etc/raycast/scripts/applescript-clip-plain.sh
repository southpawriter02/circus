#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clipboard: Plain Text
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Convert clipboard contents to plain text (strip formatting)
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript clip plain
