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
export PRIVACY_PROFILE=""

# --- Valid Roles -------------------------------------------------------------
# These are the supported installation roles. Each role has a corresponding
# directory under roles/ with role-specific configurations.
VALID_ROLES=("developer" "personal" "work")

# ==============================================================================
# FUNCTIONS
# ==============================================================================

#
# Validate that a role name is one of the supported roles.
# @param $1 The role name to validate
# @return 0 if valid, 1 if invalid
#
validate_role() {
  local role="$1"
  for valid_role in "${VALID_ROLES[@]}"; do
    if [[ "$role" == "$valid_role" ]]; then
      return 0
    fi
  done
  return 1
}

usage() {
  msg_info "Usage: ./install.sh [options]"
  echo ""
  msg_info "Options:"
  echo "  --role <name>            Specify the role to install (e.g., developer)."
  echo "  --privacy-profile <lvl>  Set privacy/security level (standard, privacy, lockdown)."
  echo "  --dry-run                Run the installer without making any changes."
  echo "  --force                  Force re-running of already completed stages."
  echo "  --non-interactive        Run the installer without prompting for confirmation."
  echo "  --log-file <path>        Redirect all log output to the specified file."
  echo "  --log-level <lvl>        Set the console log level (DEBUG, INFO, WARN, ERROR, CRITICAL)."
  echo "  --silent                 Alias for --log-level CRITICAL. Overrides --log-level."
  echo "  --help                   Display this help message."
  echo ""
  msg_info "Privacy Profiles:"
  echo "  standard   - Balanced security and convenience (default)"
  echo "  privacy    - Enhanced privacy, disables telemetry and tracking"
  echo "  lockdown   - Maximum security for high-risk environments"
  exit 0
}

main() {
  # --- Argument Parsing -------------------------------------------------------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --privacy-profile)
        local profile_name
        profile_name=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        case "$profile_name" in
          standard|privacy|lockdown)
            PRIVACY_PROFILE="$profile_name"
            ;;
          *)
            die "Invalid privacy profile: $2. Use standard, privacy, or lockdown."
            ;;
        esac
        shift 2
        ;;
      --role)
        if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
          die "Error: --role requires a role name. Valid roles: ${VALID_ROLES[*]}"
        fi
        if ! validate_role "$2"; then
          die "Error: Invalid role '$2'. Valid roles: ${VALID_ROLES[*]}"
        fi
        INSTALL_ROLE="$2"
        shift 2
        ;;
      --dry-run) DRY_RUN_MODE=true; shift ;;
      --force) FORCE_MODE=true; shift ;;
      --non-interactive) INTERACTIVE_MODE=false; shift ;;
      --log-file)
        if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
          die "Error: --log-file requires a file path."
        fi
        export LOG_FILE_PATH="$2"
        shift 2
        ;;
      --log-level)
        if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
          die "Error: --log-level requires a level name (DEBUG, INFO, WARN, ERROR, CRITICAL)."
        fi
        level_name=$(echo "$2" | tr '[:lower:]' '[:upper:]')
        case "$level_name" in
          DEBUG) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
          INFO) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_INFO ;;
          WARN) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_WARN ;;
          ERROR) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
          CRITICAL) export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL ;;
          *) die "Error: Invalid log level '$2'. Use DEBUG, INFO, WARN, ERROR, or CRITICAL." ;;
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

  # --- Stage Definitions -------------------------------------------------------
  # Each stage is defined as: "filename|title|description"
  local INSTALL_STAGES=(
    "00-preflight-checks.sh|Preflight Checks|Verifying system readiness"
    "01-introduction-and-user-interaction.sh|Welcome & Configuration|Displaying introduction and gathering preferences"
    "02-logging-setup.sh|Logging Setup|Configuring installation logging"
    "03-homebrew-installation.sh|Homebrew & Packages|Installing Homebrew and bundled packages"
    "04-macos-system-settings.sh|macOS Settings|Applying system preferences and defaults"
    "05-oh-my-zsh-installation.sh|Oh My Zsh|Installing shell framework and plugins"
    "09-dotfiles-deployment.sh|Dotfiles Deployment|Deploying configuration files"
    "10-git-configuration.sh|Git Configuration|Setting up Git preferences"
    "11-defaults-and-additional-configuration.sh|Additional Config|Applying additional settings"
    "16-jetbrains-configuration.sh|JetBrains IDEs|Configuring development environments"
    "17-secrets-management.sh|Secrets Management|Setting up secure credentials"
    "14-cleanup.sh|Cleanup|Removing temporary files"
    "15-finalization-and-reporting.sh|Finalization|Generating installation report"
  )

  local TOTAL_STAGES=${#INSTALL_STAGES[@]}

  # Initialize stage tracking for the UI
  local stage_names=()
  for stage_def in "${INSTALL_STAGES[@]}"; do
    IFS='|' read -r _ title _ <<< "$stage_def"
    stage_names+=("$title")
  done
  ui_stages_init "${stage_names[@]}"

  # Export stage information for use by stage scripts
  export INSTALLER_TOTAL_STAGES="$TOTAL_STAGES"

  # --- Execute Installation Stages --------------------------------------------
  local stage_num=0
  for stage_def in "${INSTALL_STAGES[@]}"; do
    stage_num=$((stage_num + 1))

    # Parse stage definition
    IFS='|' read -r stage_file stage_title stage_desc <<< "$stage_def"
    local stage_path="$DOTFILES_ROOT/install/$stage_file"

    # Export current stage info for the stage script to use
    export INSTALLER_CURRENT_STAGE="$stage_num"
    export INSTALLER_STAGE_TITLE="$stage_title"

    if [ -f "$stage_path" ]; then
      # Display stage header with progress
      ui_stage_header "$stage_num" "$TOTAL_STAGES" "$stage_title" "$stage_desc"

      # Mark stage as active and record start time
      ui_stage_start
      local stage_start_time=$(date +%s)

      # Execute the stage
      source "$stage_path"

      # Calculate duration and mark complete
      local stage_end_time=$(date +%s)
      local stage_duration=$((stage_end_time - stage_start_time))
      ui_stage_complete
      ui_stage_complete_msg "$stage_title" "success" "$stage_duration"
    else
      ui_stage_fail
      die "Critical installation stage not found: $stage_path"
    fi
  done

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

  if [ -n "$PRIVACY_PROFILE" ]; then
    msg_info "  -> Recording privacy profile: $PRIVACY_PROFILE"
    echo "$PRIVACY_PROFILE" > "$state_dir/privacy_profile"
  fi

  msg_success "Dotfiles Flying Circus setup complete!"
}

# ==============================================================================
# EXECUTION
# ==============================================================================

main "$@"
