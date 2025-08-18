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

set -eo pipefail

# ------------------------------------------------------------------------------
# SECTION: LOGGING CONFIGURATION & SETUP
# ------------------------------------------------------------------------------

# Define log levels as numerical values. This allows us to easily compare them.
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_SUCCESS=2
readonly LOG_LEVEL_WARN=3
readonly LOG_LEVEL_ERROR=4
readonly LOG_LEVEL_CRITICAL=5

# Set the default log level for console output. Can be overridden by flags.
# For example, if set to WARN, only WARN, ERROR, and CRITICAL messages will be shown.
CONSOLE_LOG_LEVEL=${CONSOLE_LOG_LEVEL:-$LOG_LEVEL_INFO}

# The global path to the log file. If this is set, all messages will be written to it.
LOG_FILE_PATH="${LOG_FILE_PATH:-}"

# ------------------------------------------------------------------------------
# SECTION: ERROR HANDLING
# ------------------------------------------------------------------------------

error_handler() {
  local line_number="$1"
  local script_name="$2"
  local error_message="An unexpected error occurred in '$script_name' on line $line_number."
  log $LOG_LEVEL_CRITICAL "$error_message"
  log $LOG_LEVEL_CRITICAL "Aborting execution."
  exit 1
}

trap 'error_handler ${LINENO} ${BASH_SOURCE[0]}' ERR

die() {
  log $LOG_LEVEL_ERROR "$1"
  exit 1
}

# ------------------------------------------------------------------------------
# SECTION: CORE LOGGING ENGINE
# ------------------------------------------------------------------------------

#
# @description
#   The new, centralized logging function. This is the single point of control
#   for all logging output. It decides whether to print to the console and/or
#   write to a file based on the global configuration.
#
# @param $1 The numerical log level of the message.
# @param $2 The message to log.
#
log() {
  local level_num="$1"
  local message="$2"
  local level_name
  local color_code

  # --- Determine Level Name and Color ---
  case "$level_num" in
    $LOG_LEVEL_DEBUG)   level_name="DEBUG";   color_code="\033[0;35m" ;; # Purple
    $LOG_LEVEL_INFO)    level_name="INFO";    color_code="\033[1;34m" ;; # Blue
    $LOG_LEVEL_SUCCESS) level_name="SUCCESS"; color_code="\033[1;32m" ;; # Green
    $LOG_LEVEL_WARN)    level_name="WARN";    color_code="\033[1;33m" ;; # Yellow
    $LOG_LEVEL_ERROR)   level_name="ERROR";   color_code="\033[1;31m" ;; # Red
    $LOG_LEVEL_CRITICAL)level_name="CRITICAL";color_code="\033[1;41m" ;; # White on Red
    *) level_name="UNKNOWN"; color_code="" ;;
  esac

  # --- Log to File (if configured) ---
  if [ -n "$LOG_FILE_PATH" ]; then
    # Format with a timestamp for the log file.
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level_name] $message" >> "$LOG_FILE_PATH"
  fi

  # --- Log to Console (if level is high enough) ---
  if [ "$level_num" -ge "$CONSOLE_LOG_LEVEL" ]; then
    if [ "${PARANOID_MODE:-false}" = true ]; then
      return 0
    fi
    local color_reset="\033[0m"
    local formatted_message="${color_code}[%-8s]${color_reset} %s\n"
    if [ "$level_num" -ge "$LOG_LEVEL_ERROR" ]; then
      printf "$formatted_message" "$level_name" "$message" >&2
    else
      printf "$formatted_message" "$level_name" "$message"
    fi
  fi
}

# ------------------------------------------------------------------------------
# SECTION: CONVENIENCE WRAPPER FUNCTIONS
# ------------------------------------------------------------------------------
# These functions provide a simple, readable interface for the logging engine.
# They maintain backwards compatibility with the old `msg_*` functions.

msg_debug()   { log $LOG_LEVEL_DEBUG   "$1"; }
msg_info()    { log $LOG_LEVEL_INFO    "$1"; }
msg_success() { log $LOG_LEVEL_SUCCESS "$1"; }
msg_warning() { log $LOG_LEVEL_WARN    "$1"; }
msg_error()   { log $LOG_LEVEL_ERROR   "$1"; }
msg_critical(){ log $LOG_LEVEL_CRITICAL "$1"; }

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

prompt_for_confirmation() {
  if [ "$INTERACTIVE_MODE" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
    msg_info "$1"
    read -p "Press Enter to continue..."
  fi
}
