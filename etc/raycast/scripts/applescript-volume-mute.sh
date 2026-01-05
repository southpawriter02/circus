#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Volume: Toggle Mute
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔇
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Toggle audio mute on/off
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript volume mute
