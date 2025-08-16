#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Oh My Zsh
#
# This script checks for the presence of Oh My Zsh and installs it if it is
# missing. Oh My Zsh is a popular framework for managing Zsh configuration.
#
# ==============================================================================

#
# The main logic for installing Oh My Zsh.
#
main() {
  msg_info "Checking for Oh My Zsh..."

  # Check if the Oh My Zsh directory already exists.
  if [ -d "$HOME/.oh-my-zsh" ]; then
    msg_success "Oh My Zsh is already installed."
    return 0
  fi

  msg_warning "Oh My Zsh is not installed."
  msg_info "The installer will now download and run the official Oh My Zsh installation script."

  # Download and execute the official Oh My Zsh installation script.
  # We use `sh -c` to run the script from the string.
  # The `RUNZSH=no` and `CHSH=no` arguments prevent the script from
  # automatically changing the user's shell or starting a new zsh session,
  # which is desirable in an automated installer.
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    msg_success "Oh My Zsh installed successfully."
  else
    msg_error "Oh My Zsh installation failed."
    msg_error "Please check the output above for details."
    return 1
  fi
}

#
# Execute the main function.
#
main
