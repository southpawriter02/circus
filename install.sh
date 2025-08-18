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
# All global variables are prefixed with 'DFC_' to avoid conflicts.

# The root directory of the dotfiles repository.
# The `readlink -f` command resolves the full, absolute path to the script,
# which allows the installer to be run from any directory.
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
# Source all the necessary helper libraries.
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
  # This loop parses the command-line arguments and sets the global state
  # variables accordingly.
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role)
        INSTALL_ROLE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN_MODE=true
        shift
        ;;
      --force)
        FORCE_MODE=true
        shift
        ;;
      --non-interactive)
        INTERACTIVE_MODE=false
        shift
        ;;
      --silent)
        PARANOID_MODE=true
        shift
        ;;
      --help)
        usage
        ;;
      *)
        usage
        ;;
    esac
  done

  # Export the PARANOID_MODE so it's available to all sourced scripts
  export PARANOID_MODE

  # --- Installation Stages ----------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."
  prompt_for_confirmation "Ready to begin the installation."

  # The canonical list of installation stages. The installer will execute
  # these scripts in the specified order.
  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    "04-macos-system-settings.sh"
    "05-oh-my-zsh-installation.sh"
    "09-dotfiles-deployment.sh"
    "10-git-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "12-aliases-configuration.sh"
    "13-env-configuration.sh"
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
      # We source the script so that it runs in the current shell context,
      # giving it access to all the helper functions and global variables.
      source "$stage_path"
    else
      msg_warning "Stage script not found, skipping: $stage_path"
    fi
  done

  msg_success "Dotfiles Flying Circus setup complete!"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

#
# This is the main entry point of the script. We call the `main` function,
# passing all the command-line arguments to it.
#
main "$@"
