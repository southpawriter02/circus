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


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo an error message to the console and exit.
#
# @param string $1 The message to echo.
#
function e_error() {
  printf " [31;1m✖[0m %s\n" "$1"
}

#
# Echo a warning message to the console.
#
# @param string $1 The message to echo.
#
function e_warning() {
  printf " [33;1mWarning[0m: %s\n" "$1"
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

e_msg "Checking for WiFi connection..."

#
# This check is specific to macOS and uses the `networksetup` command.
#
if [[ "$(uname)" == "Darwin" ]]; then

  #
  # The `networksetup -getairportnetwork` command returns the current WiFi
  # network name. If the command fails or doesn't return a network name,
  # it means the device is not connected to a WiFi network.
  # We check for the output `Current Wi-Fi Network: ` followed by a non-empty string.
  #
  if networksetup -getairportnetwork en0 | grep -q "Current Wi-Fi Network: .*"; then
    e_success "Device is connected to WiFi."
    exit 0
  else
    e_error "Device is not connected to WiFi. Please connect to a network and try again."
    exit 1
  fi
else
  e_warning "Skipping WiFi check on non-macOS system."
  exit 0
fi
