#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: WiFi Connection
#
# This script checks if the device is connected to a WiFi network. An active
# internet connection is often required for downloading dependencies and other
# files during the installation process.
#
# This check is specific to macOS.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for WiFi connection..."

  # Allow command injection for testing
  local uname_cmd="${UNAME_CMD:-uname}"
  local networksetup_cmd="${NETWORKSETUP_CMD:-networksetup}"

  # This check is specific to macOS and uses the `networksetup` command.
  if [[ "$($uname_cmd)" == "Darwin" ]]; then

    # The `networksetup -getairportnetwork` command returns the current WiFi
    # network name. If the command fails or doesn't return a network name,
    # it means the device is not connected to a WiFi network.
    # We check for the output `Current Wi-Fi Network: ` followed by a non-empty string.
    if $networksetup_cmd -getairportnetwork en0 | grep -q "Current Wi-Fi Network: .*"; then
      msg_success "Device is connected to WiFi."
      return 0
    else
      msg_error "Device is not connected to WiFi. Please connect to a network and try again."
      return 1
    fi
  else
    msg_warning "Skipping WiFi check on non-macOS system."
    return 0
  fi
}

#
# Execute the main function.
#
main
