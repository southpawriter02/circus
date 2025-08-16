#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Terminal Type
#
# This script checks the user's terminal emulator. Some dotfile setups are
# optimized for specific terminal emulators, such as iTerm2. This check can
# be used to provide recommendations to the user.
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
# You can change the recommended terminal by modifying the
# RECOMMENDED_TERMINAL variable.
#
RECOMMENDED_TERMINAL="iTerm.app"

e_msg "Checking terminal type..."

#
# The `TERM_PROGRAM` environment variable usually contains the name of the
# terminal emulator.
#
if [ "$TERM_PROGRAM" == "$RECOMMENDED_TERMINAL" ]; then
  e_success "Terminal is $TERM_PROGRAM."
else
  e_warning "Terminal is $TERM_PROGRAM. For the best experience, it is recommended to use $RECOMMENDED_TERMINAL."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
