#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         gpg.sh
#
# DESCRIPTION:  GPG backup backend for fc-sync. Uses tar + gpg for encrypted
#               backup archives. This is the default backend.
#
# ==============================================================================

# --- Backend Interface Implementation -----------------------------------------

# Returns the human-readable name of this backend
backend_get_name() {
  echo "GPG (tar + gpg)"
}

# Returns 0 (true) if this backend handles remote storage natively, 1 (false) otherwise
# GPG backend uses rclone for remote, so returns false
backend_handles_remote() {
  return 1
}

# Checks that required dependencies are installed
backend_check_dependencies() {
  local gpg_cmd=${GPG_CMD:-gpg}
  local rsync_cmd=${RSYNC_CMD:-rsync}

  if ! command -v "$gpg_cmd" >/dev/null 2>&1; then
    die "GPG is not installed. Please run 'brew install gpg-suite'."
  fi

  if ! command -v "$rsync_cmd" >/dev/null 2>&1; then
    die "This command requires 'rsync'. Please install it first."
  fi
}

# Validates backend-specific configuration
backend_validate_config() {
  if [ -z "$GPG_RECIPIENT_ID" ]; then
    msg_error "GPG_RECIPIENT_ID is not configured."
    echo ""
    msg_info "To configure fc-sync:"
    msg_info "  1. Run setup:     fc fc-sync setup"
    msg_info "  2. Edit config:   \$EDITOR $SYNC_CONFIG_FILE"
    msg_info "  3. Set your GPG key ID (find with: gpg --list-keys --keyid-format LONG)"
    die "Configuration required. See instructions above."
  fi

  if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
    die "BACKUP_TARGETS is empty. Configure at least one path in $SYNC_CONFIG_FILE"
  fi
}

# Performs the backup operation
backend_do_backup() {
  local brew_cmd=${BREW_CMD:-brew}
  local tar_cmd=${TAR_CMD:-tar}
  local mktemp_cmd=${MKTEMP_CMD:-mktemp}
  local gpg_cmd=${GPG_CMD:-gpg}

  local temp_backup_dir
  temp_backup_dir=$($mktemp_cmd -d)
  msg_info "Created temporary backup directory: $temp_backup_dir"

  msg_info "Creating application inventory..."
  # Only run brew if it's available (it's optional for basic backup)
  if command -v "$brew_cmd" >/dev/null 2>&1; then
    "$brew_cmd" bundle dump --force --file="$temp_backup_dir/Brewfile.dump"
  else
    msg_warning "Homebrew not found, skipping application inventory."
  fi

  msg_info "Backing up critical files..."
  for target in "${BACKUP_TARGETS[@]}"; do
    local expanded_target
    eval expanded_target="$target"
    if [ -e "$expanded_target" ]; then
      rsync -a "$expanded_target" "$temp_backup_dir/"
    fi
  done

  msg_info "Creating and encrypting backup archive..."
  local final_archive_path="$BACKUP_DEST_DIR/$BACKUP_ARCHIVE_NAME"
  "$tar_cmd" -czf - -C "$temp_backup_dir" . | "$gpg_cmd" -e -r "$GPG_RECIPIENT_ID" -o "$final_archive_path"

  msg_info "Cleaning up temporary files..."
  rm -rf "$temp_backup_dir"

  msg_success "Encrypted backup created at: $final_archive_path"
}

# Performs the restore operation
backend_do_restore() {
  local brew_cmd=${BREW_CMD:-brew}
  local gpg_cmd=${GPG_CMD:-gpg}

  local encrypted_archive_path="$BACKUP_DEST_DIR/$BACKUP_ARCHIVE_NAME"

  if [ ! -f "$encrypted_archive_path" ]; then
    die "Encrypted backup archive not found at: $encrypted_archive_path"
  fi

  local temp_restore_dir
  temp_restore_dir=$(mktemp -d)
  msg_info "Decrypting backup... You may be prompted for your GPG passphrase."

  # The `set -e` option in helpers.sh will cause the script to exit if gpg fails.
  # The global error trap will provide a detailed error message.
  "$gpg_cmd" -d "$encrypted_archive_path" | tar -xzf - -C "$temp_restore_dir"
  msg_success "Decryption and extraction successful."

  msg_info "Restoring applications from inventory..."
  # Only restore apps if brew is available
  if command -v "$brew_cmd" >/dev/null 2>&1; then
    "$brew_cmd" bundle install --file="$temp_restore_dir/Brewfile.dump"
  else
    msg_warning "Homebrew not found, skipping application restoration."
  fi

  msg_info "Restoring critical files..."
  for target in "${BACKUP_TARGETS[@]}"; do
    local backup_source="$temp_restore_dir/$(basename "$target")"
    local restore_dest
    eval restore_dest="$target"
    if [ -e "$backup_source" ]; then
      rsync -a "$backup_source" "$(dirname "$restore_dest")"
    fi
  done

  msg_info "Cleaning up temporary files..."
  rm -rf "$temp_restore_dir"

  msg_success "System restoration complete."
}

# Returns the path to the backup archive
backend_get_archive_path() {
  echo "$BACKUP_DEST_DIR/$BACKUP_ARCHIVE_NAME"
}
