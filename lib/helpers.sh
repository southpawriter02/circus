#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# It is best practice to use `#!/usr/bin/env zsh` instead of a hardcoded
# path like `#!/bin/zsh`. This makes the script more portable, as it
# allows the system's `env` command to find the `zsh` interpreter in the
# user's PATH.
# ------------------------------------------------------------------------------

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FILE:        lib/helpers.sh                                                ║
# ║ PROJECT:     Dotfiles Flying Circus                                        ║
# ║ REPOSITORY:  https://github.com/southpawriter02/dotfiles                   ║
# ║ AUTHOR:      southpawriter02 <southpawriter@pm.me>                         ║
# ║                                                                            ║
# ║ DESCRIPTION: This file contains helper functions for logging, messaging,   ║
# ║              and user interaction. It is intended to be sourced by other   ║
# ║              scripts in this repository.                                   ║
# ║                                                                            ║
# ║ LICENSE:     MIT                                                           ║
# ║ COPYRIGHT:   Copyright (c) $(date +'%Y') southpawriter02                   ║
# ║ STATUS:      DRAFT                                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# SECTION: LOGGING CONFIGURATION
# ------------------------------------------------------------------------------

# This variable is set by `02-logging-setup.sh` to the full path of the log
# file for the current installation run. It should not be set manually.
LOG_FILE_PATH=""

# ------------------------------------------------------------------------------
# SECTION: LOGGING FUNCTIONS
# ------------------------------------------------------------------------------

###
# @description
#   A centralized function for logging messages. It prints a colored message
#   to the console and appends a plain, timestamped version to the log file
#   (if LOG_FILE_PATH is set).
# @param $1
#   The message type (e.g., INFO, WARN, ERROR, DEBUG, CRITICAL).
# @param $2
#   The message body.
###
logm() {
    local MESSAGE_TYPE=$1
    local MESSAGE_BODY=$2
    local COLOR_CODE

    # Set the color code based on the message type.
    case $MESSAGE_TYPE in
        INFO)      COLOR_CODE="\033[1;34m" ;; # Blue
        SUCCESS)   COLOR_CODE="\033[1;32m" ;; # Green
        WARN)      COLOR_CODE="\033[1;33m" ;; # Yellow
        ERROR)     COLOR_CODE="\033[0;31m" ;; # Light Red
        CRITICAL)  COLOR_CODE="\033[1;41m" ;; # White on Red BG
        DEBUG)     COLOR_CODE="\033[0;37m" ;; # Light Gray
        *)         echo "Unknown message type: $MESSAGE_TYPE" >&2; return 1 ;;
    esac

    # Always print the colored message to the console.
    local CONSOLE_MESSAGE="[${MESSAGE_TYPE}] ${MESSAGE_BODY}"
    echo -e "${COLOR_CODE}${CONSOLE_MESSAGE}\033[0m"

    # Write a plain, timestamped version to the log file if it has been set.
    if [[ -n "$LOG_FILE_PATH" ]]; then
        local DATE_TIME
        DATE_TIME=$(date "+%Y-%m-%d %H:%M:%S")
        local LOG_MESSAGE="$DATE_TIME [${MESSAGE_TYPE}] ${MESSAGE_BODY}"
        # Append the message to the log file.
        echo "$LOG_MESSAGE" >> "$LOG_FILE_PATH"
    fi
}

###
# @description Wrapper functions for each log level for convenience.
###
msg_info()    { logm "INFO"    "$1"; }
msg_success() { logm "SUCCESS" "$1"; }
msg_warning() { logm "WARN"    "$1"; }
msg_error()   { logm "ERROR"   "$1" >&2; } # Direct errors to stderr
msg_critical(){ logm "CRITICAL""$1" >&2; } # Direct critical errors to stderr
msg_debug()   { logm "DEBUG"   "$1"; }
