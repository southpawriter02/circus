#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: macOS
#
# This script checks if the operating system is macOS. Many of the dotfile
# configurations and installation scripts are specific to macOS, so it is
# important to ensure that the script is running on a supported platform.
#
# This is the first and most fundamental check.
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


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

e_msg "Checking for macOS..."

#
# The `uname` command returns the name of the operating system kernel.
# On macOS, this command returns "Darwin".
#
if [[ "$(uname)" == "Darwin" ]]; then
  e_success "Operating system is macOS."
  # Exit with a status of 0 to indicate success.
  exit 0
else
  e_error "This installation is only supported on macOS."
  # Exit with a status of 1 to indicate failure.
  exit 1
fi
