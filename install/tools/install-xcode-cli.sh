#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Xcode Command Line Tools
#
# This script checks for the presence of the Xcode Command Line Tools and
# prompts the user to install them if they are missing. These tools are a
# prerequisite for many other development tools, including Homebrew.
#
# ==============================================================================

#
# The main logic for installing Xcode Command Line Tools.
#
main() {
  msg_info "Checking for Xcode Command Line Tools..."

  # The `xcode-select -p` command prints the path to the active developer
  # directory. If this command returns a non-zero exit code, it means the
  # tools are not installed.
  if xcode-select -p >/dev/null 2>&1; then
    msg_success "Xcode Command Line Tools are already installed."
    return 0
  fi

  msg_warning "Xcode Command Line Tools are not installed."
  msg_info "The installer will now attempt to begin the installation process."
  msg_info "Please follow the on-screen prompts to complete the installation."

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
