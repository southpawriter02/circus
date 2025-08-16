#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Xcode Command Line Tools
#
# This script checks if the Xcode Command Line Tools are installed. These tools
# are a prerequisite for many development-related tasks on macOS, such as
# compiling software from source and using Git.
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

e_msg "Checking for Xcode Command Line Tools..."

#
# The `xcode-select -p` command prints the path to the active developer
# directory. If this command returns a non-zero exit code, it means the
# tools are not installed.
# We redirect the output to /dev/null to keep the output clean.
#
if xcode-select -p >/dev/null 2>&1; then
  e_success "Xcode Command Line Tools are installed."
  exit 0
else
  e_error "Xcode Command Line Tools are not installed."
  e_msg "You can install them by running the following command in your terminal:"
  e_msg "xcode-select --install"
  exit 1
fi
