#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Finder: Open in Terminal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📁
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Open current Finder folder in Terminal
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript finder terminal
