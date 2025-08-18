#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 2: Set Environment Variables
#
# This script ensures that Homebrew's environment variables are correctly set
# for the current installation session. This is crucial because after a fresh
# install, the `brew` command may not be in the shell's PATH.
#
# ==============================================================================

#
# The main logic for setting Homebrew environment variables.
#
main() {
  msg_info "Configuring Homebrew environment variables..."

  # Determine the Homebrew prefix, which can vary based on the system architecture.
  local brew_prefix
  if [ -x "/opt/homebrew/bin/brew" ]; then
    # Apple Silicon (M1/M2) Macs
    brew_prefix="/opt/homebrew"
  elif [ -x "/usr/local/bin/brew" ]; then
    # Intel Macs
    brew_prefix="/usr/local"
  elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    # Linux
    brew_prefix="/home/linuxbrew/.linuxbrew"
  else
    msg_error "Homebrew is not installed in a standard location."
    return 1
  fi

  # Add Homebrew's bin directory to the PATH for the current session.
  export PATH="$brew_prefix/bin:$PATH"

  # Add Homebrew's sbin directory to the PATH for the current session.
  export PATH="$brew_prefix/sbin:$PATH"

  msg_success "Homebrew environment variables configured for this session."
}

#
# Execute the main function.
#
main
