#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Locale and Encoding
#
# This script checks the system's locale and encoding settings. It is important
# to ensure that the system is using a UTF-8 encoding to avoid issues with
# special characters and internationalization.
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

e_msg "Checking locale and encoding..."

#
# The `locale` command prints information about the current locale settings.
# We check if the output contains "UTF-8" to determine the encoding.
#
if locale | grep -q "UTF-8"; then
  e_success "Locale and encoding are set to UTF-8."
  exit 0
else
  e_error "Locale and encoding are not set to UTF-8. Please reconfigure your system."
  exit 1
fi
