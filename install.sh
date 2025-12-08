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
export DRY_RUN_MODE=false
export INTERACTIVE_MODE=true
export INSTALL_ROLE=""
export FORCE_MODE=false

# ==============================================================================
# FUNCTIONS
# ==============================================================================

usage() {
  ui_print_banner_mini
  echo ""
  echo "Usage: ./install.sh [options]"
  echo ""

  ui_header "Options"
  ui_list_item "--role <name>" 2 "Specify the role to install (e.g., developer)."
  ui_list_item "--dry-run" 2 "Run the installer without making any changes."
  ui_list_item "--force" 2 "Force re-running of already completed stages."
  ui_list_item "--non-interactive" 2 "Run the installer without prompting for confirmation."
  ui_list_item "--log-file <path>" 2 "Redirect all log output to the specified file."
  ui_list_item "--log-level <lvl>" 2 "Set the console log level (DEBUG, INFO, WARN, ERROR)."
  ui_list_item "--silent" 2 "Alias for --log-level CRITICAL. Overrides --log-level."
  ui_list_item "--help" 2 "Display this help message."
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
  ui_print_banner

  msg_info "Starting Dotfiles Flying Circus setup..."
  if [ -n "$LOG_FILE_PATH" ]; then
    mkdir -p "$(dirname "$LOG_FILE_PATH")"
    touch "$LOG_FILE_PATH"
    msg_info "Logging to file: $LOG_FILE_PATH"
  fi

  if [ "$INTERACTIVE_MODE" = true ]; then
    if ! ui_confirm "Ready to begin the installation?" "Y"; then
      die "Installation aborted by user."
    fi
  fi

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

  # --- Initialize Progress Tracker --------------------------------------------
  local stage_names=()
  for stage in "${INSTALL_STAGES[@]}"; do
    # Cleanup stage name for display: remove number and .sh, replace - with space
    local name="${stage#[0-9][0-9]-}"
    name="${name%.sh}"
    name="${name//-/ }"
    # Capitalize first letter of each word
    name="$(echo "$name" | sed -e "s/\b\(.\)/\u\1/g")"
    stage_names+=("$name")
  done

  ui_stages_init "${stage_names[@]}"
  ui_stages_print

  # --- Execute Installation Stages --------------------------------------------
  local i=0
  for stage in "${INSTALL_STAGES[@]}"; do
    local stage_path="$DOTFILES_ROOT/install/$stage"

    ui_stage_start
    ui_stages_print

    if [ -f "$stage_path" ]; then
      ui_header "Executing Stage: ${stage_names[$i]}"

      # Run stage in subshell to isolate environment if needed, or source directly
      # Sourcing is preferred to share variables like INSTALL_ROLE
      source "$stage_path"

      ui_stage_complete
    else
      ui_stage_fail
      die "Critical installation stage not found: $stage_path"
    fi

    ((i++))
  done

  # Print final progress
  ui_stages_print

  # --- Finalization & State Management ----------------------------------------
  # After a successful installation, record the repository root and the
  # installed role. This allows other commands to be context-aware.
  local state_dir="$HOME/.circus"
  msg_info "Recording installation state in $state_dir..."
  mkdir -p "$state_dir"
  echo "$DOTFILES_ROOT" > "$state_dir/root"

  if [ -n "$INSTALL_ROLE" ]; then
    msg_info "  -> Recording installed role: $INSTALL_ROLE"
    echo "$INSTALL_ROLE" > "$state_dir/role"
  fi

  echo ""
  ui_notice "success" "Dotfiles Flying Circus setup complete!"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

main "$@"
