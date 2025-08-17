#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Oh My Zsh
#
# This script installs Oh My Zsh, a popular framework for managing Zsh
# configuration. It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing Oh My Zsh.
#
main() {
  # Check if Oh My Zsh is already installed. If so, do nothing.
  if [ -d "$HOME/.oh-my-zsh" ]; then
    msg_success "Oh My Zsh is already installed. Skipping."
    return 0
  fi

  msg_info "Installing Oh My Zsh..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would download and run the official Oh My Zsh installation script."
    return 0
  fi

  # Download and execute the official Oh My Zsh installation script.
  # The `RUNZSH=no` and `CHSH=no` arguments prevent the script from
  # automatically changing the user's shell or starting a new zsh session.
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
