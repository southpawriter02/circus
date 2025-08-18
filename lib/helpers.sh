#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/helpers.sh
#
# DESCRIPTION:  This script contains shared helper functions for logging and
#               user interaction that are used across the installer scripts.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION: LOGGING FUNCTIONS
# ------------------------------------------------------------------------------

###
# @description
#   The core logging function. It formats and prints messages to the console.
#   It is the single point of control for all logging output.
# @param $1
#   The log level (e.g., "INFO", "ERROR").
# @param $2
#   The message to log.
###
logm() {
  # --- Paranoid Mode Check ---
  # If the PARANOID_MODE is active, suppress all logging output immediately.
  if [ "${PARANOID_MODE:-false}" = true ]; then
    return 0
  fi

  local log_level="$1"
  local message="$2"
  local color_code

  # Assign a color based on the log level.
  case "$log_level" in
    INFO)     color_code="\033[1;34m" ;; # Blue
    SUCCESS)  color_code="\033[1;32m" ;; # Green
    WARN)     color_code="\033[1;33m" ;; # Yellow
    ERROR)    color_code="\033[1;31m" ;; # Red
    CRITICAL) color_code="\033[1;41m" ;; # White on Red
    DEBUG)    color_code="\033[0;35m" ;; # Purple
    *)        echo "Unknown message type: $log_level" >&2; return 1 ;;
  esac

  # Reset color code
  local color_reset="\033[0m"

  # Print the formatted message.
  printf "${color_code}[%-8s]${color_reset} %s\n" "$log_level" "$message"
}


###
# @description Wrapper functions for each log level for convenience.
###
msg_info()    { logm "INFO"    "$1"; }
msg_success() { logm "SUCCESS" "$1"; }
msg_warning() { logm "WARN"    "$1"; }
msg_error()   { logm "ERROR"   "$1" >&2; }
msg_critical(){ logm "CRITICAL" "$1" >&2; }
msg_debug()   { logm "DEBUG"   "$1"; }

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

###
# @description
#   Prompts the user to press Enter to continue. This function is also
#   suppressed when PARANOID_MODE is active.
# @param $1
#   The message to display to the user.
###
prompt_for_confirmation() {
  # Suppress prompts in non-interactive and paranoid modes.
  if [ "$INTERACTIVE_MODE" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
    msg_info "$1"
    read -p "Press Enter to continue..."
  fi
}

###
# @description
#   A wrapper for the `defaults` command that respects `DRY_RUN_MODE`.
#   In dry-run mode, it prints the command instead of executing it.
# @param $@
#   The arguments to pass to the `defaults` command.
###
run_defaults() {
  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would run: defaults $*"
  else
    defaults "$@"
  fi
}

###
# @description
#   A wrapper for the `sudo` command that respects `DRY_RUN_MODE`.
#   In dry-run mode, it prints the command instead of executing it.
# @param $@
#   The arguments to pass to the `sudo` command.
###
run_sudo() {
  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would run: sudo $*"
    # In a dry run, we assume the command would have succeeded.
    return 0
  else
    sudo "$@"
  fi
}
