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

# NOTE: the interactive `ask()` helper that used to live here was removed.
# Preflight checks run inside a captured subshell, so a prompt is invisible
# to the user — see main() below.


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
    # Report only. This check must NOT prompt, and must NOT delete anything.
    #
    # Preflight checks are executed inside `check_output=$( ... 2>&1 )` by
    # 00-preflight-checks.sh, which captures both stdout and stderr. `read -p`
    # writes its prompt to stderr, so the question was swallowed into the
    # capture and never shown: the installer appeared to hang on a blank line,
    # and whatever the user typed blind was fed to `rm -rf "$BACKUP_DIR"` —
    # an unrecoverable delete of their dotfiles backup, gated on a question they
    # could not see.
    #
    # A check reports; it does not take destructive action on the user's behalf.
    msg_warning "An existing dotfiles backup was found at: $BACKUP_DIR"
    msg_info "Nothing has been changed. If you want a fresh backup, remove it yourself:"
    msg_info "  rm -rf \"$BACKUP_DIR\""
    return 0
  fi

  msg_success "No existing dotfiles backup was found."
  return 0
}

#
# Execute the main function.
#
main
