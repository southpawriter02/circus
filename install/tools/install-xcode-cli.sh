#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Xcode Command Line Tools
#
# This script triggers the installation of the Xcode Command Line Tools.
# It is only run if the preflight check in Stage 3 determines that the tools
# are missing. It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing Xcode Command Line Tools.
#
main() {
  msg_info "Installing Xcode Command Line Tools..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would trigger the macOS GUI prompt to install Xcode Command Line Tools."
    return 0
  fi

  msg_info "The installer will now attempt to begin the installation process."
  msg_info "Please follow the on-screen prompts from macOS to complete the installation."

  # This command opens a macOS GUI prompt to install the tools.
  # The script will pause until the user has completed this process.
  xcode-select --install

  # After the user completes the installation, verify that it was successful.
  if xcode-select -p >/dev/null 2>&1; then
    msg_success "Xcode Command Line Tools installed successfully."
  else
    msg_error "Xcode Command Line Tools installation failed or was canceled."
    msg_error "Please install them manually and re-run the script."
    return 1
  fi
}

#
# Execute the main function.
#
main
