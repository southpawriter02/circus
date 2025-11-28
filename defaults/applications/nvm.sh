#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: NVM (Node Version Manager) Setup
#
# DESCRIPTION:
#   This script handles the post-installation setup for NVM (Node Version
#   Manager), including creating its directory and installing the latest
#   LTS version of Node.js. NVM allows you to install and switch between
#   multiple Node.js versions.
#
# REQUIRES:
#   - NVM installed via Homebrew (brew install nvm)
#   - Shell configuration that sources nvm.sh (handled by topics/node/path.zsh)
#
# REFERENCES:
#   - NVM GitHub Repository
#     https://github.com/nvm-sh/nvm
#   - NVM Documentation
#     https://github.com/nvm-sh/nvm#usage
#   - Node.js Release Schedule
#     https://nodejs.org/en/about/previous-releases
#   - NVM via Homebrew Notes
#     https://formulae.brew.sh/formula/nvm
#
# PATHS:
#   NVM directory:    ~/.nvm
#   Node versions:    ~/.nvm/versions/node/
#   nvm.sh (Silicon): /opt/homebrew/opt/nvm/nvm.sh
#   nvm.sh (Intel):   /usr/local/opt/nvm/nvm.sh
#
# COMMON COMMANDS:
#   nvm install --lts          # Install latest LTS version
#   nvm install 18             # Install specific version
#   nvm use 18                 # Switch to version 18
#   nvm alias default 18       # Set default version
#   nvm ls                     # List installed versions
#   nvm ls-remote              # List available versions
#
# NOTES:
#   - LTS (Long Term Support) versions are recommended for production
#   - Each Node version has its own global npm packages
#   - .nvmrc files can specify project-specific Node versions
#   - nvm adds some shell startup time; consider lazy loading
#
# ==============================================================================

main() {
  msg_info "Configuring nvm (Node Version Manager)..."

  # --- Prerequisite: Find nvm.sh ---
  # Homebrew installs to different locations based on architecture:
  # - Apple Silicon (arm64): /opt/homebrew/
  # - Intel (x86_64): /usr/local/
  local nvm_sh
  if [ -f "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    nvm_sh="/opt/homebrew/opt/nvm/nvm.sh"
  elif [ -f "/usr/local/opt/nvm/nvm.sh" ]; then
    nvm_sh="/usr/local/opt/nvm/nvm.sh"
  else
    msg_error "Could not find nvm.sh. Is nvm installed correctly via Homebrew?"
    return 1
  fi

  # ==============================================================================
  # NVM Directory Setup
  # ==============================================================================
  #
  # NVM stores Node.js versions and configuration in ~/.nvm.
  # This directory must exist before nvm can install versions.

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would ensure directory exists: $HOME/.nvm"
  else
    mkdir -p "$HOME/.nvm"
  fi

  # --- Source nvm for this script's context ---
  # This makes the `nvm` command available within this script.
  # Note: This doesn't affect the user's shell; that's handled by shell config.
  if [ "$DRY_RUN_MODE" = false ]; then
    # shellcheck source=/dev/null
    source "$nvm_sh"
  fi

  # ==============================================================================
  # Install Node.js LTS
  # ==============================================================================
  #
  # LTS (Long Term Support) versions are recommended for most use cases:
  # - Longer maintenance window (30 months)
  # - More stable and well-tested
  # - Widely supported by frameworks and libraries
  #
  # The --lts flag installs the latest LTS version (e.g., v20.x Hydrogen).
  # Setting it as the default means new shells will use this version.

  msg_info "Installing the latest LTS version of Node.js..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: nvm install --lts"
    msg_info "[Dry Run] Would run: nvm alias default lts/*"
  else
    if nvm install --lts; then
      # Set the newly installed LTS version as the default
      # This version will be used in new shell sessions
      nvm alias default lts/*
      msg_success "Latest LTS version of Node.js installed and set as default."
      
      # Display the installed version for user reference
      msg_info "Installed Node.js version: $(node --version)"
      msg_info "Installed npm version: $(npm --version)"
    else
      msg_error "Failed to install LTS version of Node.js."
    fi
  fi

  msg_success "nvm configuration complete."
}

main
