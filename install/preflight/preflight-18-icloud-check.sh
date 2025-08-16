#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: iCloud
#
# This script checks if the user is logged into an iCloud account. Some dotfile
# setups rely on iCloud Drive for syncing files and settings across devices.
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

e_msg "Checking for iCloud login..."

#
# This check is specific to macOS.
#
if [[ "$(uname)" == "Darwin" ]]; then

  #
  # The presence of the MobileMeAccounts.plist file is a good indicator that
  # an iCloud account is configured on the system.
  #
  if [ -f "$HOME/Library/Preferences/MobileMeAccounts.plist" ]; then
    e_success "User is logged into iCloud."
  else
    e_warning "User is not logged into iCloud. Some features may not work as expected."
  fi
else
  e_warning "Skipping iCloud check on non-macOS system."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
