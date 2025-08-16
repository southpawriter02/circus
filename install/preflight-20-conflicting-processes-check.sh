#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Conflicting Processes
#
# This script checks for any running processes that could potentially conflict
# with the installation process. For example, if the installation needs to
# modify shell configuration files, it's a good idea to check if a shell
# process is currently running.
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
# Add any other process names to this array that you want to check for.
# For example:
#
# CONFLICTING_PROCESSES=("bash" "zsh" "fish")
#
CONFLICTING_PROCESSES=("zsh")

e_msg "Checking for conflicting processes..."

#
# A flag to track if any conflicting processes were found.
#
found_process=false

#
# Iterate through the list of conflicting processes.
#
for process in "${CONFLICTING_PROCESSES[@]}"; do
  #
  # The `pgrep -x` command searches for processes by exact name.
  # We redirect output to /dev/null to keep the output clean.
  #
  if pgrep -x "$process" >/dev/null; then
    e_warning "A potentially conflicting process is running: $process"
    found_process=true
  fi
done

#
# If any conflicting processes were found, display a general warning.
#
if [ "$found_process" = true ]; then
  e_warning "It is recommended to close any conflicting processes before proceeding."
else
  e_success "No conflicting processes were found."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
