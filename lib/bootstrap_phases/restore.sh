#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        restore
#
# DESCRIPTION:  Optionally restore from a previous fc sync backup.
#               This restores applications, configurations, and settings
#               from a previous machine.
#
# ==============================================================================

# --- Check if Restore is Enabled ---
if [ "$AUTO_RESTORE" != true ]; then
  msg_info "Backup restore not requested. Skipping phase."
  return 0
fi

# --- Check for Local Backup ---
check_local_backup() {
  local backup_path="${BACKUP_DEST_DIR:-$HOME}/${BACKUP_ARCHIVE_NAME:-circus_backup.tar.gz.gpg}"

  if [ -f "$backup_path" ]; then
    msg_info "Local backup found: $backup_path"
    return 0
  else
    return 1
  fi
}

# --- Pull from Remote if Configured ---
pull_remote_backup() {
  if [ -n "$RESTORE_REMOTE" ]; then
    msg_info "Pulling backup from remote: $RESTORE_REMOTE"

    # Check if rclone is available
    if ! command -v rclone >/dev/null 2>&1; then
      msg_warning "rclone not installed. Installing..."
      brew install rclone
    fi

    # Try to pull using fc sync
    if [ -x "$DOTFILES_ROOT/bin/fc" ]; then
      "$DOTFILES_ROOT/bin/fc" fc-sync pull
    else
      msg_warning "fc command not available. Skipping remote pull."
      return 1
    fi
  fi
}

# --- Run Restore ---
run_restore() {
  msg_info "Restoring from backup..."
  msg_info "You may be prompted for your GPG passphrase."
  echo ""

  if [ -x "$DOTFILES_ROOT/bin/fc" ]; then
    "$DOTFILES_ROOT/bin/fc" fc-sync --no-confirm restore
    msg_success "Backup restored successfully."
  else
    msg_error "fc command not available."
    msg_info "You can manually restore later with: fc sync restore"
    return 1
  fi
}

# --- Main Restore Phase ---
msg_info "Checking for backup to restore..."
echo ""

# First check for local backup
if check_local_backup; then
  run_restore
elif [ -n "$RESTORE_REMOTE" ]; then
  # Try to pull from remote
  if pull_remote_backup && check_local_backup; then
    run_restore
  else
    msg_warning "Could not retrieve backup from remote."
    msg_info "Continuing without restore."
  fi
else
  msg_warning "No backup found locally and no remote configured."
  msg_info "Continuing without restore."
fi

echo ""
msg_success "Restore phase complete."
