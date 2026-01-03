#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DNS: Clear (Use DHCP)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Flying Circus

# Documentation:
# @raycast.description Clear custom DNS, use DHCP defaults
# @raycast.author Flying Circus

# Load environment
source "$(dirname "$0")/fc-env.sh"

# Execute command
fc dns clear
