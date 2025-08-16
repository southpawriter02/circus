#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Dependencies
#
# This script checks if all the required dependencies are installed. It iterates
# through a list of commands and checks if they are available in the system's
# PATH.
#
# If a dependency is missing, an error message is displayed, and the
# installation process is halted.
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
# Add any additional dependencies to this array. For example, to check for
# the `wget` command, you would add it to the list like this:
#
# DEPENDENCIES=("git" "curl" "zsh" "wget")
#
DEPENDENCIES=("git" "curl")

e_msg "Checking for dependencies..."

#
# A flag to track if any dependencies are missing.
#
missing_dependencies=false

#
# Iterate through the list of dependencies.
#
for dep in "${DEPENDENCIES[@]}"; do
  #
  # The `command -v` command checks if a command is available.
  # If it is, it will exit with a status of 0.
  #
  if command -v "$dep" >/dev/null 2>&1; then
    e_success "$dep is installed."
  else
    e_error "$dep is not installed. Please install it and try again."
    missing_dependencies=true
  fi
done

#
# If any dependencies were missing, exit with an error status.
#
if [ "$missing_dependencies" = true ]; then
  exit 1
else
  e_success "All required dependencies are installed."
  exit 0
fi
