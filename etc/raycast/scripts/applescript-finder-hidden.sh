#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Finder: Toggle Hidden Files
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📁
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Toggle visibility of hidden files in Finder
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript finder hidden
