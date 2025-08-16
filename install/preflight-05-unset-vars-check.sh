#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Unset Variables
#
# This script checks for any unset environment variables that the installation
# scripts may depend on. This is a good practice to catch potential errors
# early in the installation process.
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
# Add any other required environment variables to this array. For example:
#
# REQUIRED_VARS=("HOME" "USER" "SHELL" "MY_CUSTOM_VAR")
#
REQUIRED_VARS=("HOME" "USER" "SHELL")

e_msg "Checking for unset variables..."

#
# A flag to track if any unset variables are found.
#
unset_vars=false

#
# Iterate through the list of required variables.
#
for var in "${REQUIRED_VARS[@]}"; do
  #
  # We use `!var` to get the value of the variable whose name is stored in `var`.
  # The `-z` operator checks if the value is an empty string.
  #
  if [ -z "${!var}" ]; then
    e_error "Required environment variable is not set: $var"
    unset_vars=true
  fi
done

#
# If any unset variables were found, exit with an error status.
#
if [ "$unset_vars" = true ]; then
  exit 1
else
  e_success "All required environment variables are set."
  exit 0
fi
