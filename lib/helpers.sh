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
# SECTION: COLORS
#
# Description: Defines ANSI color codes for colored output. This makes logs
# and messages more readable.
# ------------------------------------------------------------------------------

# Using readonly ensures these variables cannot be changed.
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_BOLD='\033[1m'

# ------------------------------------------------------------------------------
# SECTION: LOGGING FUNCTIONS
#
# Description: A set of functions for printing formatted and colored messages
# to the console.
# ------------------------------------------------------------------------------

###
# @description
#   A generic message function that handles the actual printing.
# @param $1
#   The color to use for the message.
# @param $2
#   The message string to print.
###
msg() {
  local color="$1"
  local message="$2"
  # Print the message with the specified color, then reset the color.
  echo -e "${color}${message}${COLOR_RESET}"
}

###
# @description
#   Prints an informational message.
# @param $1
#   The message string.
###
msg_info() {
  msg "${COLOR_BLUE}" "INFO: $1"
}

###
# @description
#   Prints a success message.
# @param $1
#   The message string.
###
msg_success() {
  msg "${COLOR_GREEN}" "SUCCESS: $1"
}

###
# @description
#   Prints a warning message.
# @param $1
#   The message string.
###
msg_warning() {
  msg "${COLOR_YELLOW}" "WARNING: $1"
}

###
# @description
#   Prints an error message to stderr.
# @param $1
#   The message string.
###
msg_error() {
  # Error messages should go to stderr.
  msg "${COLOR_RED}" "ERROR: $1" >&2
}
