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
#
# Description: Define global variables for the logging system. These can be
# overridden in the main script if needed.
# ------------------------------------------------------------------------------

# Set the verbosity level. Higher numbers mean more detailed logs.
# 0: NONE, 1: EMERGENCY, 2: ALERT, 3: CRIT, 4: ERROR, 5: WARN, 6: NOTICE, 7: INFO, 8: DEBUG
: ${VERBOSITY:=7}

# Set the base path for the log file. The date will be appended to this.
: ${LOG_FILE_BASE:="$HOME/.dotfiles-log"}

# Set the maximum size for a log file in bytes before it is rotated.
: ${MAX_LOG_FILE_SIZE:=1048576} # 1MB

# ------------------------------------------------------------------------------
# SECTION: LOGGING FUNCTIONS
#
# Description: A centralized logging function and a set of wrappers for
# different log levels.
# ------------------------------------------------------------------------------

###
# @description
#   A centralized function for logging messages to the console and a log file.
# @param $1
#   The message type (e.g., INFO, WARN, ERROR).
# @param $2
#   The message body.
###
logm() {
    # Get the message type and body from the function arguments
    local MESSAGE_TYPE=$1
    local MESSAGE_BODY=$2

    # Determine the log level of the message type
    local LOG_LEVEL
    local COLOR_CODE
    
    # Set the log level and color code based on the message type
    case $MESSAGE_TYPE in
        NONE)      LOG_LEVEL=0; COLOR_CODE="\033[1;37m" ;; # White
        EMERGENCY) LOG_LEVEL=1; COLOR_CODE="\033[1;41m" ;; # White on Red BG
        ALERT)     LOG_LEVEL=2; COLOR_CODE="\033[1;35m" ;; # Magenta
        CRIT)      LOG_LEVEL=3; COLOR_CODE="\033[1;31m" ;; # Red
        ERROR)     LOG_LEVEL=4; COLOR_CODE="\033[0;31m" ;; # Light Red
        WARN)      LOG_LEVEL=5; COLOR_CODE="\033[1;33m" ;; # Yellow
        NOTICE)    LOG_LEVEL=6; COLOR_CODE="\033[1;36m" ;; # Cyan
        INFO)      LOG_LEVEL=7; COLOR_CODE="\033[1;34m" ;; # Blue
        DEBUG)     LOG_LEVEL=8; COLOR_CODE="\033[0;37m" ;; # Light Gray
        *) echo "Unknown message type: $MESSAGE_TYPE" >&2; return 1 ;;
    esac

    # Check if the message should be logged based on the verbosity level
    if (( LOG_LEVEL <= VERBOSITY )); then
        local DATE_TIME=$(date "+%Y-%m-%d %H:%M:%S")
        local LOG_MESSAGE="$DATE_TIME [$MESSAGE_TYPE] $MESSAGE_BODY"
        local DATE=$(date "+%Y-%m-%d")
        local LOG_FILE="$LOG_FILE_BASE-$DATE.log"

        # Check if the log file size exceeds the maximum and rotate if necessary
        if [ -e "$LOG_FILE" ] && (( $(stat -f%z "$LOG_FILE") > MAX_LOG_FILE_SIZE )); then
            local TIME=$(date "+%H-%M-%S")
            mv "$LOG_FILE" "$LOG_FILE_BASE-$DATE-$TIME.log"
            touch "$LOG_FILE"
        fi

        # Append the message to the log file and print to the console
        echo "$LOG_MESSAGE" >> "$LOG_FILE"
        echo -e "${COLOR_CODE}${LOG_MESSAGE}\033[0m"
    fi
}

###
# @description Wrapper functions for each log level for convenience.
###
msg_info()    { logm "INFO" "$1"; }
msg_success() { logm "NOTICE" "$1"; }
msg_warning() { logm "WARN" "$1"; }
msg_error()   { logm "ERROR" "$1" >&2; }
msg_debug()   { logm "DEBUG" "$1"; }
