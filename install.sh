#!/usr/bin/env bash
# ==============================================================================
#
# FILE:         install.sh
#
# DESCRIPTION:  The main entry point for the Dotfiles Flying Circus installer.
#               This script orchestrates the entire installation process, from
#               argument parsing to the execution of individual installation
#               stages.
#
# ==============================================================================

# --- Globals ------------------------------------------------------------------
# The root directory of the dotfiles repository.
export DOTFILES_ROOT
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=true
INSTALL_ROLE=""
FORCE_MODE=false
PARANOID_MODE=false

# ==============================================================================
# SCRIPT SETUP
# ==============================================================================

# --- Library Sourcing ---------------------------------------------------------
# Source all the necessary helper libraries. This must be done before the
# main script logic begins.
source "$DOTFILES_ROOT/lib/helpers.sh"
source "$DOTFILES_ROOT/lib/config.sh"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

#
# @description
#   Prints the installer's usage information and exits.
#
usage() {
  echo "Usage: ./install.sh [options]"
  echo ""
  echo "Options:"
  echo "  --role <name>      Specify the role to install (e.g., developer)."
  echo "  --dry-run          Run the installer without making any changes."
  echo "  --force            Force re-running of already completed stages."
  echo "  --non-interactive  Run the installer without prompting for confirmation."
  echo "  --silent           Run the installer with minimal output to protect privacy."
  echo "  --help             Display this help message."
  exit 1
}

#
# @description
#   The main function of the installer. It orchestrates the entire process,
#   from parsing arguments to executing the installation stages.
#
main() {
  # --- Argument Parsing -------------------------------------------------------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role) INSTALL_ROLE="$2"; shift 2 ;; 
      --dry-run) DRY_RUN_MODE=true; shift ;;
      --force) FORCE_MODE=true; shift ;; 
      --non-interactive) INTERACTIVE_MODE=false; shift ;; 
      --silent) PARANOID_MODE=true; shift ;; 
      --help) usage ;; 
      *) usage ;; 
    esac
  done

  export PARANOID_MODE

  # --- Installation Stages ----------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."
  prompt_for_confirmation "Ready to begin the installation."

  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    "04-macos-system-settings.sh"
    "05-oh-my-zsh-installation.sh"
    "09-dotfiles-deployment.sh"
    "10-git-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "16-jetbrains-configuration.sh"
    "17-secrets-management.sh"
    "14-cleanup.sh"
    "15-finalization-and-reporting.sh"
  )

  # --- Execute Installation Stages --------------------------------------------
  for stage in "${INSTALL_STAGES[@]}"; do
    local stage_path="$DOTFILES_ROOT/install/$stage"
    if [ -f "$stage_path" ]; then
      msg_info "Executing stage: $stage"
      source "$stage_path"
    else
      # If a critical stage script is missing, we should not continue.
      die "Critical installation stage not found: $stage_path"
    fi
  done

  msg_success "Dotfiles Flying Circus setup complete!"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

main "$@"
