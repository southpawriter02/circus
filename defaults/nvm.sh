#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: NVM (Node Version Manager) Setup
#
# This script handles the post-installation setup for nvm, including creating
# its directory and installing the latest LTS version of Node.js.
#
# ==============================================================================

main() {
  msg_info "Configuring nvm (Node Version Manager)..."

  # --- Prerequisite: Find nvm.sh ---
  # Homebrew on Apple Silicon installs to /opt/homebrew, on Intel to /usr/local
  local nvm_sh
  if [ -f "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    nvm_sh="/opt/homebrew/opt/nvm/nvm.sh"
  elif [ -f "/usr/local/opt/nvm/nvm.sh" ]; then
    nvm_sh="/usr/local/opt/nvm/nvm.sh"
  else
    msg_error "Could not find nvm.sh. Is nvm installed correctly via Homebrew?"
    return 1
  fi

  # --- Directory Creation ---
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would ensure directory exists: $HOME/.nvm"
  else
    mkdir -p "$HOME/.nvm"
  fi

  # --- Source nvm for this script's context ---
  # This makes the `nvm` command available to us right now.
  if [ "$DRY_RUN_MODE" = false ]; then
    source "$nvm_sh"
  fi

  # --- Install Latest LTS Node.js ---
  msg_info "Installing the latest LTS version of Node.js..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: nvm install --lts"
    msg_info "[Dry Run] Would run: nvm alias default lts/*"
  else
    if nvm install --lts; then
      # Set the newly installed LTS version as the default.
      nvm alias default lts/*
      msg_success "Latest LTS version of Node.js installed and set as default."
    else
      msg_error "Failed to install LTS version of Node.js."
    fi
  fi

  msg_success "nvm configuration complete."
}

main
