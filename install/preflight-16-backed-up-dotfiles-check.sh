#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Backed Up Dotfiles
#
# This script checks if a dotfiles backup already exists. If a backup is
# found, the user is prompted to either overwrite the existing backup or exit
# the installation process.
#
# ==============================================================================


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo an error message to the console and exit.
#
# @param string $1 The message to echo.
#
function e_error() {
  printf " [31;1m✖[0m %s\n" "$1"
}

#
# Echo a warning message to the console.
#
# @param string $1 The message to echo.
#
function e_warning() {
  printf " [33;1mWarning[0m: %s\n" "$1"
}

#
# Asks the user a yes/no question.
#
# @param string $1 The question to ask the user.
# @param string $2 The default response (optional). Should be 'Y' or 'N'.
#
# @return 0 for "yes", 1 for "no".
#
function ask() {
  # http://djm.me/ask
  while true; do
    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question
    read -p "$1 [$prompt] " REPLY

    # Default?
    if [ -z "$REPLY" ]; then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

#
# CUSTOMIZATION:
# If you want to change the name of the backup directory, you can modify the
# path in the line below.
#
BACKUP_DIR="$HOME/.dotfiles-backup"

e_msg "Checking for backed up dotfiles..."

if [ -d "$BACKUP_DIR" ]; then
  e_warning "An existing dotfiles backup was found at: $BACKUP_DIR"
  if ask "Do you want to overwrite the existing backup?" N; then
    e_msg "Overwriting the existing backup..."
    rm -rf "$BACKUP_DIR"
    e_success "The existing backup has been overwritten."
    exit 0
  else
    e_error "Please manually remove the existing backup and try again."
    exit 1
  fi
fi

e_success "No existing dotfiles backup was found."
exit 0
