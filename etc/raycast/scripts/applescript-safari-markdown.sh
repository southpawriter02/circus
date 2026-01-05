#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Safari: Export as Markdown
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧭
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Export Safari tabs as Markdown list to clipboard
# @raycast.author Flying Circus

source "$(dirname "$0")/fc-env.sh"
fc applescript safari markdown
