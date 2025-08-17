#!/usr/bin/env bash

# ==============================================================================
#
# Stage 2: Logging Setup
#
# This script configures the logging system for the installation process.
# It initializes the log file for the current run by writing a header with
# key environment details.
#
# Its responsibilities include:
#
#   2.1. Configuring the log file location and format.
#   2.2. Starting the logging of actions and errors.
#
# ==============================================================================

#
# The main logic for the logging setup stage.
#
main() {
  msg_info "Stage 2: Logging Setup"

  # --- Configuration ----------------------------------------------------------
  # The log file path is determined by the `$LOG_FILE_BASE` variable, which is
  # set in `lib/helpers.sh`. The default is `$HOME/.dotfiles-log`.
  local DATE
  DATE=$(date "+%Y-%m-%d")
  local LOG_FILE="$LOG_FILE_BASE-$DATE.log"

  # --- Log Header Initialization ----------------------------------------------
  msg_info "Initializing log file for this session at: $LOG_FILE"

  # Create a header for the current installation log.
  # This makes it easy to distinguish different installation runs in the same file.
  # We append to the log file, as it may already contain logs from previous runs.
  {
    echo ""
    echo "=============================================================================="
    echo " Dotfiles Flying Circus Installation Log"
    echo "=============================================================================="
    echo " Start Time:  $(date)"
    echo " User:        $(whoami)"
    echo " Host:        $(hostname)"
    echo " OS Version:  $(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    # TODO: Log user selections from Stage 1 when that feature is implemented.
    echo "------------------------------------------------------------------------------"
  } >> "$LOG_FILE"

  msg_success "Logging system initialized."
}

#
# Execute the main function.
#
main
