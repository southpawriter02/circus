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

  # Download the official Oh My Zsh installer to a file, then run it from disk.
  # The `--unattended` argument prevents the script from changing the user's
  # shell or starting a new zsh session.
  #
  # This matters more than usual here: Oh My Zsh is sourced by every interactive
  # shell, so whatever this installs runs on every terminal you open. Pin
  # CIRCUS_OHMYZSH_INSTALLER_SHA256 to verify the payload before it executes.
  local installer
  installer=$(mktemp) || return 1

  if ! fetch_verified_script \
      "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
      "$installer" "${CIRCUS_OHMYZSH_INSTALLER_SHA256:-}"; then
    rm -f "$installer"
    msg_error "Oh My Zsh installation aborted."
    return 1
  fi

  sh "$installer" "" --unattended
  local rc=$?
  rm -f "$installer"

  if [ $rc -eq 0 ]; then
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
