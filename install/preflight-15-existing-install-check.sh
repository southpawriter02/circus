#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Existing Installation
#
# This script checks for the presence of an install marker. Install markers are
# empty files that are created after a successful installation. They can be
# used to determine if the installation has been run before.
#
# This can be useful for preventing the installation from running again
# unnecessarily.
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

#
# CUSTOMIZATION:
# You can change the path of the install marker file by modifying the
# INSTALL_MARKER_PATH variable.
#
INSTALL_MARKER_PATH="$HOME/.dotfiles-installed"

e_msg "Checking for existing installation..."

#
# Check if the install marker file exists.
#
if [ -f "$INSTALL_MARKER_PATH" ]; then
  e_warning "An existing installation was found. If you continue, the installation will run again."
else
  e_success "No previous installation was found."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
