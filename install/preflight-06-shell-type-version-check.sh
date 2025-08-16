#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Shell Type and Version
#
# This script checks the type and version of the user's current shell. The
# dotfiles are often specific to a particular shell (e.g., zsh) and may require
# a minimum version to function correctly.
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

#
# CUSTOMIZATION:
# You can change the required shell and minimum version by modifying the
# REQUIRED_SHELL and MINIMUM_VERSION variables.
#
REQUIRED_SHELL="zsh"
MINIMUM_VERSION="5.0"

e_msg "Checking shell type and version..."

#
# The `SHELL` environment variable contains the path to the user's default shell.
# We use `basename` to extract the shell name from the path.
#
current_shell=$(basename "$SHELL")

if [ "$current_shell" != "$REQUIRED_SHELL" ]; then
  e_error "Current shell is $current_shell, but $REQUIRED_SHELL is required."
  exit 1
fi

e_success "Current shell is $current_shell."

#
# Get the shell version. The command to get the version can vary between shells.
# For zsh, `zsh --version` is a common way to get it.
# We use awk to extract the version number from the output.
#
shell_version=$($current_shell --version | awk '{print $2}')

#
# We use `sort -V` to perform a version number comparison. This handles
# complex version numbers correctly (e.g., 5.0.8 vs 5.1).
#
if [[ "$(printf '%s\n' "$MINIMUM_VERSION" "$shell_version" | sort -V | head -n1)" == "$MINIMUM_VERSION" ]]; then
  e_success "Shell version is $shell_version (meets minimum requirement of $MINIMUM_VERSION)."
  exit 0
else
  e_error "Shell version is $shell_version, but version $MINIMUM_VERSION or higher is required."
  exit 1
fi
