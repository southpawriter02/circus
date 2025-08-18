#!/usr/bin/env bash

# ==============================================================================
#
# Stage 05: Oh My Zsh Framework & Community Plugins Installation
#
# This script installs the Oh My Zsh framework and popular community plugins
# that provide an enhanced shell experience.
#
# ==============================================================================

#
# @description
#   A helper function to clone a Git repository if the destination directory
#   does not already exist.
#
# @param $1 The URL of the Git repository to clone.
# @param $2 The destination directory for the clone.
#
clone_plugin() {
  local repo_url="$1"
  local dest_dir="$2"
  local plugin_name
  plugin_name=$(basename "$dest_dir")

  if [ -d "$dest_dir" ]; then
    msg_info "Plugin '$plugin_name' is already installed. Skipping."
    return 0
  fi

  msg_info "Installing plugin: $plugin_name..."
  if git clone --depth=1 "$repo_url" "$dest_dir"; then
    msg_success "  -> Successfully installed $plugin_name."
  else
    msg_error "  -> Failed to install plugin: $plugin_name."
  fi
}

main() {
  msg_info "Stage 05: Oh My Zsh Framework & Community Plugins Installation"

  # --- Install Oh My Zsh Core ---
  local oh_my_zsh_dir="$HOME/.oh-my-zsh"
  if [ ! -d "$oh_my_zsh_dir" ]; then
    msg_info "Installing Oh My Zsh from official repository..."
    if ! git clone --depth=1 "https://github.com/ohmyzsh/ohmyzsh.git" "$oh_my_zsh_dir"; then
      msg_error "Failed to clone the Oh My Zsh repository. Aborting stage."
      return 1
    fi
  else
      msg_info "Oh My Zsh is already installed. Skipping core installation."
  fi

  # --- Install Community Plugins ---
  local custom_plugins_dir="$oh_my_zsh_dir/custom/plugins"
  mkdir -p "$custom_plugins_dir"

  # 1. zsh-syntax-highlighting
  clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$custom_plugins_dir/zsh-syntax-highlighting"

  # 2. zsh-autosuggestions
  clone_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$custom_plugins_dir/zsh-autosuggestions"

  msg_success "Oh My Zsh installation and plugin setup complete."
}

main
