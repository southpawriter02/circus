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

#
# The main logic of the script.
#
main() {
  msg_info "Checking for root user..."

  # The `id -u` command returns the user ID. The root user always has a UID of 0.
  if [ "$(id -u)" -eq "0" ]; then
    msg_error "Running as the root user is not supported. Please run as a regular user."
    return 1
  else
    msg_success "Not running as the root user."
    return 0
  fi
}

#
# Execute the main function.
#
main
