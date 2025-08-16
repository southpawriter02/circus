#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Root User
#
# This script checks if the installation is being run by the root user. It is
# strongly recommended to not run installation scripts as root, as this can
# lead to unintended consequences and security vulnerabilities.
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

e_msg "Checking for root user..."

#
# The `id -u` command returns the user ID. The root user always has a UID of 0.
#
if [ "$(id -u)" -eq "0" ]; then
  e_error "Running as the root user is not supported. Please run as a regular user."
  exit 1
else
  e_success "Not running as the root user."
  exit 0
fi
