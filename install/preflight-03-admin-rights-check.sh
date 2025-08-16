#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Admin Rights
#
# This script checks if the current user has administrator privileges. Some
# dotfile installations may require admin rights to install certain software
# or to modify system-level settings.
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

e_msg "Checking for admin rights..."

#
# On macOS, users with administrator privileges are members of the "admin" group.
# The `groups` command lists the groups the current user is a member of.
# We use `grep -q` to quietly search for the "admin" group in the output.
#
if groups | grep -q "\badmin\b"; then
  e_success "User has admin rights."
  exit 0
else
  e_warning "User does not have admin rights. Some parts of the installation may fail."
  # We don't exit with an error here, as the installation might still be able
  # to proceed without admin rights for some tasks.
  exit 0
fi
