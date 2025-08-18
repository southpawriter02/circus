#!/usr/bin/env bash

# ==============================================================================
#
# Stage 2: Logging Setup
#
# This script configures the logging system for the installation process.
# It creates a unique, timestamped log file for the current run and sets
# the global LOG_FILE_PATH variable that helper functions will use.
#
# ==============================================================================

#
# The main logic for the logging setup stage.
#
main() {
  msg_info "Stage 2: Logging Setup"

  # If in dry-run mode, skip log file creation.
  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Skipping log file creation."
    return 0
  fi

  # --- Configuration ----------------------------------------------------------
  local LOG_DIR="$HOME/.circus/logs"
  local TIMESTAMP
  TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
  
  # Set the global variable for the log file path. This will be used by the
  # helper functions in `lib/helpers.sh` from this point forward.
  LOG_FILE_PATH="$LOG_DIR/install-$TIMESTAMP.log"

  # --- Log File Initialization ----------------------------------------------
  
  # Ensure the log directory exists.
  if ! mkdir -p "$LOG_DIR"; then
    # If we can't create the log directory, we must abort.
    msg_critical "Failed to create log directory at: $LOG_DIR"
    msg_critical "Please check permissions and try again. Aborting."
    exit 1
  fi

  # Inform the user where the log file will be stored.
  msg_info "Initializing log file for this session at: $LOG_FILE_PATH"

  # Create a header for the new log file.
  {
    echo "=============================================================================="
    echo " Dotfiles Flying Circus Installation Log"
    echo "=============================================================================="
    echo " Start Time:  $(date)"
    echo " User:        $(whoami)"
    echo " Host:        $(hostname)"
    echo " OS Version:  $(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    echo "------------------------------------------------------------------------------"
  } >> "$LOG_FILE_PATH"

  msg_success "Logging system initialized."
}

#
# Execute the main function.
#
main
