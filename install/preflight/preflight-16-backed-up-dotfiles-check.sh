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

#
# Asks the user a yes/no question.
#
# @param string $1 The question to ask the user.
# @param string $2 The default response (optional). Should be 'Y' or 'N'.
#
# @return 0 for "yes", 1 for "no".
#
ask() {
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

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # If you want to change the name of the backup directory, you can modify the
  # path in the line below.
  #
  local BACKUP_DIR="$HOME/.dotfiles-backup"

  msg_info "Checking for backed up dotfiles..."

  if [ -d "$BACKUP_DIR" ]; then
    msg_warning "An existing dotfiles backup was found at: $BACKUP_DIR"
    if ask "Do you want to overwrite the existing backup?" N; then
      msg_info "Overwriting the existing backup..."
      rm -rf "$BACKUP_DIR"
      msg_success "The existing backup has been overwritten."
      return 0
    else
      msg_error "Please manually remove the existing backup and try again."
      return 1
    fi
  fi

  msg_success "No existing dotfiles backup was found."
  return 0
}

#
# Execute the main function.
#
main
