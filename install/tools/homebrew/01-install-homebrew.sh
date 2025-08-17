#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 1: Install Homebrew
#
# This script runs the official Homebrew installation script.
# It is only run if the preflight check in Stage 3 determines that Homebrew
# is missing.
#
# ==============================================================================

#
# The main logic for installing Homebrew.
#
main() {
  msg_info "Installing Homebrew..."
  msg_info "The installer will now download and run the official Homebrew installation script."

  # Download and execute the official Homebrew installation script.
  # The script is run with `-c` to execute it from the string.
  # The `NONINTERACTIVE=1` environment variable is used to run the script
  # without user prompts, which is suitable for an automated installer.
  if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    msg_success "Homebrew installed successfully."
  else
    msg_error "Homebrew installation failed."
    msg_error "Please check the output above for details."
    return 1
  fi
}

#
# Execute the main function.
#
main
