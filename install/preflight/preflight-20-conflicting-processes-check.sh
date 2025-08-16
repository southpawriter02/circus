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

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # Add any other process names to this array that you want to check for.
  # For example:
  #
  # CONFLICTING_PROCESSES=("bash" "zsh" "fish")
  #
  local CONFLICTING_PROCESSES=("zsh")

  msg_info "Checking for conflicting processes..."

  # A flag to track if any conflicting processes were found.
  local found_process=false

  # Iterate through the list of conflicting processes.
  for process in "${CONFLICTING_PROCESSES[@]}"; do
    # The `pgrep -x` command searches for processes by exact name.
    # We redirect output to /dev/null to keep the output clean.
    if pgrep -x "$process" >/dev/null; then
      msg_warning "A potentially conflicting process is running: $process"
      found_process=true
    fi
  done

  # If any conflicting processes were found, display a general warning.
  if [ "$found_process" = true ]; then
    msg_warning "It is recommended to close any conflicting processes before proceeding."
  else
    msg_success "No conflicting processes were found."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
