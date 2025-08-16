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

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # Add any other required environment variables to this array. For example:
  #
  # REQUIRED_VARS=("HOME" "USER" "SHELL" "MY_CUSTOM_VAR")
  #
  local REQUIRED_VARS=("HOME" "USER" "SHELL")

  msg_info "Checking for unset variables..."

  # A flag to track if any unset variables are found.
  local unset_vars=false

  # Iterate through the list of required variables.
  for var in "${REQUIRED_VARS[@]}"; do
    # We use `!var` to get the value of the variable whose name is stored in `var`.
    # The `-z` operator checks if the value is an empty string.
    if [ -z "${!var}" ]; then
      msg_error "Required environment variable is not set: $var"
      unset_vars=true
    fi
  done

  # If any unset variables were found, return an error status.
  if [ "$unset_vars" = true ]; then
    return 1
  else
    msg_success "All required environment variables are set."
    return 0
  fi
}

#
# Execute the main function.
#
main
