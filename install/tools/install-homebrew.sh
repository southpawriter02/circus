#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Homebrew (Orchestrator)
#
# This script orchestrates the entire Homebrew setup process by sourcing a
# series of modular scripts from the `homebrew/` subdirectory. This keeps
# the installation process clean, organized, and easy to maintain.
#
# ==============================================================================

#
# The main logic for the Homebrew installation orchestrator.
#
main() {
  msg_info "Starting Homebrew setup process..."

  # --- Configuration ----------------------------------------------------------
  local HOMEBREW_SCRIPTS_DIR="$INSTALL_DIR/tools/homebrew"

  # @description: An array defining the order of the Homebrew setup steps.
  # The process is now much simpler thanks to `brew bundle`.
  local HOMEBREW_STAGES=(
    "01-install-homebrew.sh"      # Install Homebrew itself if missing.
    "02-set-variables.sh"         # Set environment variables for Homebrew.
    "04-install-formulae.sh"      # Install all dependencies from the Brewfile.
  )

  # --- Installation Logic ---------------------------------------------------
  for stage_script in "${HOMEBREW_STAGES[@]}"; do
    local script_path="$HOMEBREW_SCRIPTS_DIR/$stage_script"
    if [ -f "$script_path" ]; then
      # shellcheck source=/dev/null
      source "$script_path"
    else
      msg_warning "Homebrew setup script not found: $script_path. Skipping."
    fi
  done

  msg_success "Homebrew setup process complete."
}

#
# Execute the main function.
#
main
