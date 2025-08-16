#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Homebrew
#
# This script checks if Homebrew, the package manager for macOS, is installed.
# Homebrew is a core dependency for this dotfile setup, as it is used to
# install many of the required tools and applications.
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

e_msg "Checking for Homebrew..."

#
# The `command -v` command checks if a command is available in the system's
# PATH. We use it to check for the `brew` command.
# The output is redirected to /dev/null to keep the output clean.
#
if command -v "brew" >/dev/null 2>&1; then
  e_success "Homebrew is installed."
  exit 0
else
  e_error "Homebrew is not installed."
  e_msg "You can install it by running the following command in your terminal:"
  e_msg "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi
