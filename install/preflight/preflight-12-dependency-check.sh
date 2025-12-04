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

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # Add any additional dependencies to this array. For example, to check for
  # the `wget` command, you would add it to the list like this:
  #
  # DEPENDENCIES=("git" "curl" "zsh" "wget")
  #
  local DEPENDENCIES=("git" "curl")

  msg_info "Checking for dependencies..."

  # A flag to track if any dependencies are missing.
  local missing_dependencies=false

  # Allow overriding the command check function for testing
  local command_check="${COMMAND_CHECK_CMD:-command -v}"

  # Iterate through the list of dependencies.
  for dep in "${DEPENDENCIES[@]}"; do
    # The `command -v` command checks if a command is available.
    # If it is, it will exit with a status of 0.
    if $command_check "$dep" >/dev/null 2>&1; then
      msg_success "$dep is installed."
    else
      msg_error "$dep is not installed. Please install it and try again."
      missing_dependencies=true
    fi
  done

  # If any dependencies were missing, return an error status.
  if [ "$missing_dependencies" = true ]; then
    return 1
  else
    msg_success "All required dependencies are installed."
    return 0
  fi
}

#
# Execute the main function.
#
main
