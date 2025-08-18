#!/usr/bin/env bash

# ==============================================================================
#
# Stage 05: Oh My Zsh Framework Installation
#
# This script installs the Oh My Zsh framework, which will manage the shell
# environment, plugins, and themes.
#
# ==============================================================================

main() {
  msg_info "Stage 05: Oh My Zsh Framework Installation"

  local oh_my_zsh_dir="$HOME/.oh-my-zsh"
  local oh_my_zsh_repo="https://github.com/ohmyzsh/ohmyzsh.git"

  if [ -d "$oh_my_zsh_dir" ]; then
    msg_info "Oh My Zsh is already installed. Skipping."
    return 0
  fi

  msg_info "Installing Oh My Zsh from official repository..."
  
  # Clone the repository using Git.
  # The --depth=1 flag creates a shallow clone, which is faster as it
  # doesn't download the entire commit history.
  if git clone --depth=1 "$oh_my_zsh_repo" "$oh_my_zsh_dir"; then
    msg_success "Oh My Zsh has been successfully installed to: $oh_my_zsh_dir"
  else
    msg_error "Failed to clone the Oh My Zsh repository."
    return 1
  fi
}

main
