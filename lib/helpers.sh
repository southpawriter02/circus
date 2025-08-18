#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/helpers.sh
#
# DESCRIPTION:  This script contains shared helper functions for logging,
#               error handling, and user interaction. It is sourced by all
#               major scripts in the project.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION: SCRIPT SETUP & ROBUSTNESS
# ------------------------------------------------------------------------------

# -e: Exit immediately if a command exits with a non-zero status.
# -o pipefail: The return value of a pipeline is the status of the last
#              command to exit with a non-zero status, or zero if no
#              command exited with a non-zero status.
set -eo pipefail

# ------------------------------------------------------------------------------
# SECTION: ERROR HANDLING
# ------------------------------------------------------------------------------

#
# @description
#   The global error handler. This function is called by the `trap` command
#   whenever a command fails. It prints a detailed error report and then exits.
#
# @param $1 The line number where the error occurred.
# @param $2 The name of the script where the error occurred.
#
error_handler() {
  local line_number="$1"
  local script_name="$2"
  local error_message="An unexpected error occurred in '$script_name' on line $line_number."

  # Use the existing logging function to print the error in red.
  logm "CRITICAL" "$error_message"
  logm "CRITICAL" "Aborting execution."
  exit 1
}

# Set the global error trap.
# The `ERR` signal is triggered when a command fails.
# We pass the line number and script name to our handler function.
trap 'error_handler ${LINENO} ${BASH_SOURCE[0]}' ERR

#
# @description
#   Prints a fatal error message and exits the script. This is for handling
#   expected errors gracefully (e.g., a missing dependency).
#
# @param $1 The error message to display.
#
die() {
  logm "ERROR" "$1"
  exit 1
}

# ------------------------------------------------------------------------------
# SECTION: LOGGING FUNCTIONS
# ------------------------------------------------------------------------------

logm() {
  if [ "${PARANOID_MODE:-false}" = true ]; then
    return 0
  fi

  local log_level="$1"
  local message="$2"
  local color_code

  case "$log_level" in
    INFO)     color_code="\033[1;34m" ;; # Blue
    SUCCESS)  color_code="\033[1;32m" ;; # Green
    WARN)     color_code="\033[1;33m" ;; # Yellow
    ERROR)    color_code="\033[1;31m" ;; # Red
    CRITICAL) color_code="\033[1;41m" ;; # White on Red
    DEBUG)    color_code="\033[0;35m" ;; # Purple
    *)        echo "Unknown message type: $log_level" >&2; return 1 ;;
  esac

  local color_reset="\033[0m"
  printf "${color_code}[%-8s]${color_reset} %s\n" "$log_level" "$message"
}

msg_info()    { logm "INFO"    "$1"; }
msg_success() { logm "SUCCESS" "$1"; }
msg_warning() { logm "WARN"    "$1"; }
msg_error()   { logm "ERROR"   "$1" >&2; }
msg_critical(){ logm "CRITICAL" "$1" >&2; }
msg_debug()   { logm "DEBUG"   "$1"; }

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

prompt_for_confirmation() {
  if [ "$INTERACTIVE_MODE" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
    msg_info "$1"
    read -p "Press Enter to continue..."
  fi
}
