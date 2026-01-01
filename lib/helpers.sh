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
# We check if the variable is already defined to prevent "readonly" errors
# when this script is sourced multiple times in the test environment.
if [ -z "$LOG_LEVEL_DEBUG" ]; then
  readonly LOG_LEVEL_DEBUG=0
  readonly LOG_LEVEL_INFO=1
  readonly LOG_LEVEL_SUCCESS=2
  readonly LOG_LEVEL_WARN=3
  readonly LOG_LEVEL_ERROR=4
  readonly LOG_LEVEL_CRITICAL=5
fi

# Set the default log level for console output. Can be overridden by flags.
# For example, if set to WARN, only WARN, ERROR, and CRITICAL messages will be shown.
CONSOLE_LOG_LEVEL=${CONSOLE_LOG_LEVEL:-$LOG_LEVEL_INFO}

# The global path to the log file. If this is set, all messages will be written to it.
LOG_FILE_PATH="${LOG_FILE_PATH:-}"

# Maximum log file size in bytes (default 10MB)
LOG_MAX_SIZE=${LOG_MAX_SIZE:-10485760}

# Number of rotated logs to keep (default 3)
LOG_ROTATE_COUNT=${LOG_ROTATE_COUNT:-3}

# ------------------------------------------------------------------------------
# SECTION: LOG ROTATION
# ------------------------------------------------------------------------------

#
# @description
#   Rotates the log file if it exceeds LOG_MAX_SIZE. Called automatically
#   by log() when LOG_FILE_PATH is set.
#
# @param $1 The path to the log file.
#
rotate_log_if_needed() {
  local log_file="$1"

  # Skip if file doesn't exist or rotation is disabled
  [ -f "$log_file" ] || return 0
  [ "$LOG_MAX_SIZE" -gt 0 ] || return 0

  # Get file size (macOS uses -f%z, Linux uses -c%s)
  local file_size
  if [[ "$(uname)" == "Darwin" ]]; then
    file_size=$(stat -f%z "$log_file" 2>/dev/null || echo 0)
  else
    file_size=$(stat -c%s "$log_file" 2>/dev/null || echo 0)
  fi

  # Rotate if file exceeds max size
  if [ "$file_size" -ge "$LOG_MAX_SIZE" ]; then
    # Shift existing rotated logs
    local i=$LOG_ROTATE_COUNT
    while [ $i -gt 1 ]; do
      local prev=$((i - 1))
      [ -f "${log_file}.${prev}" ] && mv "${log_file}.${prev}" "${log_file}.${i}"
      i=$prev
    done

    # Rotate current log to .1
    mv "$log_file" "${log_file}.1"
  fi
}

# ------------------------------------------------------------------------------
# SECTION: ERROR HANDLING
# ------------------------------------------------------------------------------

error_handler() {
  local line_number="$1"
  local script_name="$2"
  local error_message="An unexpected error occurred in '$script_name' on line $line_number."
  log "$LOG_LEVEL_CRITICAL" "$error_message"
  log "$LOG_LEVEL_CRITICAL" "Aborting execution."
  exit 1
}

trap 'error_handler ${LINENO} ${BASH_SOURCE[0]}' ERR

die() {
  log "$LOG_LEVEL_ERROR" "$1"
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
    "$LOG_LEVEL_DEBUG")   level_name="DEBUG";   color_code="${UI_MUTED}" ;;
    "$LOG_LEVEL_INFO")    level_name="INFO";    color_code="${UI_INFO}" ;;
    "$LOG_LEVEL_SUCCESS") level_name="SUCCESS"; color_code="${UI_SUCCESS}" ;;
    "$LOG_LEVEL_WARN")    level_name="WARN";    color_code="${UI_WARNING}" ;;
    "$LOG_LEVEL_ERROR")   level_name="ERROR";   color_code="${UI_ERROR}" ;;
    "$LOG_LEVEL_CRITICAL")level_name="CRITICAL";color_code="${UI_BG_RED}${UI_WHITE}" ;;
    *) level_name="UNKNOWN"; color_code="" ;;
  esac

  # --- Log to File (if configured) ---
  if [ -n "$LOG_FILE_PATH" ]; then
    # Check if rotation is needed before writing
    rotate_log_if_needed "$LOG_FILE_PATH"

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
    local color_reset="${UI_RESET}"

    # Use UI variables if available, otherwise fallback is handled by ui.sh loaded before or after.
    # But note: helpers.sh is often loaded BEFORE ui.sh in init.sh.
    # However, init.sh sources helpers, then ui.sh.
    # So when log() is CALLED, ui.sh should be loaded.

    # Using direct format string in printf to avoid SC2059 shellcheck warning about dynamic format strings
    if [ "$level_num" -ge "$LOG_LEVEL_ERROR" ]; then
      printf "${color_code}[%-8s]${color_reset} %s\n" "$level_name" "$message" >&2
    else
      printf "${color_code}[%-8s]${color_reset} %s\n" "$level_name" "$message"
    fi
  fi
}

# ------------------------------------------------------------------------------
# SECTION: CONVENIENCE WRAPPER FUNCTIONS
# ------------------------------------------------------------------------------
# These functions provide a simple, readable interface for the logging engine.
# They maintain backwards compatibility with the old `msg_*` functions.

msg_debug()   { log "$LOG_LEVEL_DEBUG"   "$1"; }
msg_info()    { log "$LOG_LEVEL_INFO"    "$1"; }
msg_success() { log "$LOG_LEVEL_SUCCESS" "$1"; }
msg_warning() { log "$LOG_LEVEL_WARN"    "$1"; }
msg_error()   { log "$LOG_LEVEL_ERROR"   "$1"; }
msg_critical(){ log "$LOG_LEVEL_CRITICAL" "$1"; }

export -f log msg_debug msg_info msg_success msg_warning msg_error msg_critical die

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

prompt_for_confirmation() {
  if [ "$INTERACTIVE_MODE" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
    msg_info "$1"
    read -p "Press Enter to continue..."
  fi
}

export -f prompt_for_confirmation
