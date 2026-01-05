#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title App: Hide Others
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 👁️
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Hide all apps except the current one
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript app hide-others
