#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 1: Install Homebrew
#
# This script runs the official Homebrew installation script.
# It is only run if the preflight check in Stage 3 determines that Homebrew
# is missing. It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing Homebrew.
#
main() {
  msg_info "Installing Homebrew..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would download and run the official Homebrew installation script."
    return 0
  fi

  msg_info "The installer will now download and run the official Homebrew installation script."

  # Download the official Homebrew installer to a file, then run it from disk.
  # Piping curl straight into bash means the code is executed as it arrives,
  # with no opportunity to verify it. Set CIRCUS_HOMEBREW_INSTALLER_SHA256 to
  # pin the expected digest; fetch_verified_script fails closed on a mismatch.
  local installer
  installer=$(mktemp) || return 1

  if ! fetch_verified_script \
      "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" \
      "$installer" "${CIRCUS_HOMEBREW_INSTALLER_SHA256:-}"; then
    rm -f "$installer"
    msg_error "Homebrew installation aborted."
    return 1
  fi

  NONINTERACTIVE=1 /bin/bash "$installer"
  local rc=$?
  rm -f "$installer"

  if [ $rc -eq 0 ]; then
    msg_success "Homebrew installed successfully."
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
