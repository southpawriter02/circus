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

# --- Initialization ---------------------------------------------------------
# Source the centralized initialization script to set up the environment.
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

# --- Global State Variables -------------------------------------------------
DRY_RUN_MODE=false
INTERACTIVE_MODE=true
INSTALL_ROLE=""
FORCE_MODE=false

# ==============================================================================
# FUNCTIONS
# ==============================================================================

usage() {
  msg_info "Usage: ./install.sh [options]"
  echo ""
  msg_info "Options:"
  echo "  --role <name>      Specify the role to install (e.g., developer)."
  echo "  --dry-run          Run the installer without making any changes."
  echo "  --force            Force re-running of already completed stages."
  echo "  --non-interactive  Run the installer without prompting for confirmation."
  echo "  --log-file <path>  Redirect all log output to the specified file."
  echo "  --log-level <lvl>  Set the console log level (DEBUG, INFO, WARN, ERROR)."
  echo "  --silent           Alias for --log-level CRITICAL. Overrides --log-level."
  echo "  --help             Display this help message."
  exit 0
}

main() {
  # --- Argument Parsing -------------------------------------------------------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role) INSTALL_ROLE="$2"; shift 2 ;;
      --dry-run) DRY_RUN_MODE=true; shift ;;
      --force) FORCE_MODE=true; shift ;; 
      --non-interactive) INTERACTIVE_MODE=false; shift ;; 
      --log-file) export LOG_FILE_PATH="$2"; shift 2 ;;
      --log-level)
        level_name=$(echo "$2" | tr '[:lower:]' '[:upper:]')
        case "$level_name" in
          DEBUG) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_DEBUG ;; 
          INFO) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_INFO ;; 
          WARN) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_WARN ;; 
          ERROR) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_ERROR ;; 
          CRITICAL) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL ;; 
          *) die "Invalid log level: $2. Use DEBUG, INFO, WARN, or ERROR." ;;
        esac
        shift 2
        ;;
      --silent)
        export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL
        shift
        ;;
      --help) usage ;; 
      *) usage ;; 
    esac
  done

  # --- Installation Stages ----------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."
  if [ -n "$LOG_FILE_PATH" ]; then
    mkdir -p "$(dirname "$LOG_FILE_PATH")"
    touch "$LOG_FILE_PATH"
    msg_info "Logging to file: $LOG_FILE_PATH"
  fi
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
      die "Critical installation stage not found: $stage_path"
    fi
  done

  msg_success "Dotfiles Flying Circus setup complete!"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

main "$@"
