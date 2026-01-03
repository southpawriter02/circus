#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DNS: Cloudflare
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Set DNS to Cloudflare (1.1.1.1)
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc dns set cloudflare
