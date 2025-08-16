#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Homebrew
#
# This script checks for the presence of Homebrew, the package manager for
# macOS, and installs it if it is missing.
#
# ==============================================================================

#
# The main logic for installing Homebrew.
#
main() {
  msg_info "Checking for Homebrew..."

  # The `command -v` command checks if a command is available in the system's
  # PATH. We use it to check for the `brew` command.
  if command -v "brew" >/dev/null 2>&1; then
    msg_success "Homebrew is already installed."
    return 0
  fi

  msg_warning "Homebrew is not installed."
  msg_info "The installer will now download and run the official Homebrew installation script."

  # Download and execute the official Homebrew installation script.
  # The script is run with `-c` to execute it from the string.
  # The `NONINTERACTIVE=1` environment variable is used to run the script
  # without user prompts, which is suitable for an automated installer.
  if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    msg_success "Homebrew installed successfully."
    # It is often necessary to add Homebrew to the PATH in the current shell session.
    # This will be handled in a later, dedicated stage for environment setup.
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
