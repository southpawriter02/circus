#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: File Permissions
#
# This script checks if the user has the necessary file permissions to create
# and modify files in their home directory. The installation process needs to
# be able to write to various locations in the home directory, so this check
# is crucial for preventing permission-related errors.
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

e_msg "Checking file permissions..."

#
# We test for write permissions by attempting to create a temporary file in the
# user's home directory. The file is removed immediately after the check.
#
TEST_FILE="$HOME/.dotfiles-permission-test"

#
# The `touch` command attempts to create the file. We redirect any error
# messages to /dev/null to keep the output clean.
#
if touch "$TEST_FILE" 2>/dev/null; then
  # If the file was created successfully, remove it and report success.
  rm "$TEST_FILE"
  e_success "User has write permissions in the home directory."
  exit 0
else
  # If the file could not be created, report an error and exit.
  e_error "User does not have write permissions in the home directory."
  exit 1
fi
