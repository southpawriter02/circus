#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         restic.sh
#
# DESCRIPTION:  Restic backup backend for fc-sync. Uses restic for deduplication,
#               incremental backups, and native remote support.
#
# REQUIREMENTS: restic (brew install restic)
#
# CONFIG:       RESTIC_REPOSITORY - Repository location (local or remote)
#               RESTIC_PASSWORD_FILE - Path to password file
#
# ==============================================================================

# --- Backend Interface Implementation -----------------------------------------

# Returns the human-readable name of this backend
backend_get_name() {
  echo "Restic"
}

# Returns 0 (true) if this backend handles remote storage natively
# Restic supports s3:, sftp:, rest:, and more
backend_handles_remote() {
  return 0
}

# Checks that required dependencies are installed
backend_check_dependencies() {
  local restic_cmd=${RESTIC_CMD:-restic}

  if ! command -v "$restic_cmd" >/dev/null 2>&1; then
    msg_error "restic is not installed."
    echo ""
    msg_info "Install restic with: brew install restic"
    msg_info "Then initialize a repository with: restic init -r /path/to/repo"
    die "restic required for this backend."
  fi
}

# Validates backend-specific configuration
backend_validate_config() {
  if [ -z "$RESTIC_REPOSITORY" ]; then
    msg_error "RESTIC_REPOSITORY is not configured."
    echo ""
    msg_info "To configure the Restic backend:"
    msg_info "  1. Edit config: \$EDITOR $SYNC_CONFIG_FILE"
    msg_info "  2. Set RESTIC_REPOSITORY to your repository path"
    msg_info ""
    msg_info "Examples:"
    msg_info "  Local:  RESTIC_REPOSITORY=\"/path/to/backups\""
    msg_info "  S3:     RESTIC_REPOSITORY=\"s3:s3.amazonaws.com/bucket-name\""
    msg_info "  SFTP:   RESTIC_REPOSITORY=\"sftp:user@host:/path\""
    msg_info "  REST:   RESTIC_REPOSITORY=\"rest:https://user:pass@host/\""
    die "RESTIC_REPOSITORY required."
  fi

  if [ -z "$RESTIC_PASSWORD_FILE" ]; then
    msg_error "RESTIC_PASSWORD_FILE is not configured."
    die "RESTIC_PASSWORD_FILE required."
  fi

  if [ ! -f "$RESTIC_PASSWORD_FILE" ]; then
    msg_error "RESTIC_PASSWORD_FILE not found: $RESTIC_PASSWORD_FILE"
    echo ""
    msg_info "Create a password file with:"
    msg_info "  echo 'your-secure-password' > $RESTIC_PASSWORD_FILE"
    msg_info "  chmod 600 $RESTIC_PASSWORD_FILE"
    die "RESTIC_PASSWORD_FILE not found."
  fi

  # Check password file permissions
  local perms
  perms=$(stat -f '%Lp' "$RESTIC_PASSWORD_FILE" 2>/dev/null || echo "000")
  local other_perms=$((perms % 10))
  if [ "$other_perms" -ge 4 ] 2>/dev/null; then
    msg_warning "RESTIC_PASSWORD_FILE is world-readable. Consider: chmod 600 $RESTIC_PASSWORD_FILE"
  fi

  if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
    die "BACKUP_TARGETS is empty. Configure at least one path in $SYNC_CONFIG_FILE"
  fi
}

# Check if repository exists, initialize if not
ensure_repository() {
  local restic_cmd=${RESTIC_CMD:-restic}

  # Try to list snapshots to check if repo exists
  if ! "$restic_cmd" -r "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" \
      snapshots --json >/dev/null 2>&1; then
    msg_info "Repository not found. Initializing new repository..."
    if "$restic_cmd" -r "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" init; then
      msg_success "Repository initialized at: $RESTIC_REPOSITORY"
    else
      die "Failed to initialize restic repository at: $RESTIC_REPOSITORY"
    fi
  fi
}

# Performs the backup operation
backend_do_backup() {
  local restic_cmd=${RESTIC_CMD:-restic}

  ensure_repository

  msg_info "Creating restic backup..."
  msg_info "  Repository: $RESTIC_REPOSITORY"

  # Build the list of paths to backup
  local backup_paths=()
  for target in "${BACKUP_TARGETS[@]}"; do
    local expanded_target
    eval expanded_target="$target"
    if [ -e "$expanded_target" ]; then
      backup_paths+=("$expanded_target")
      msg_info "  Including: $expanded_target"
    else
      msg_warning "  Skipping (not found): $expanded_target"
    fi
  done

  if [ ${#backup_paths[@]} -eq 0 ]; then
    die "No valid backup targets found."
  fi

  # Build exclude patterns if BACKUP_EXCLUDES is set
  local exclude_args=()
  if [ -n "${BACKUP_EXCLUDES+x}" ] && [ ${#BACKUP_EXCLUDES[@]} -gt 0 ]; then
    for pattern in "${BACKUP_EXCLUDES[@]}"; do
      exclude_args+=(--exclude "$pattern")
    done
  fi

  # Run the backup
  if "$restic_cmd" -r "$RESTIC_REPOSITORY" \
      --password-file "$RESTIC_PASSWORD_FILE" \
      backup "${backup_paths[@]}" "${exclude_args[@]}" \
      --tag "circus" \
      --verbose; then
    msg_success "Restic backup complete."
  else
    die "Restic backup failed."
  fi

  # Show snapshot info
  echo ""
  msg_info "Latest snapshots:"
  "$restic_cmd" -r "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    snapshots --last 3 --tag "circus"

  # Run automatic cleanup (keep last 7 daily, 4 weekly, 6 monthly)
  echo ""
  msg_info "Running automatic cleanup..."
  "$restic_cmd" -r "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    forget \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --tag "circus" \
    --prune
}

# Performs the restore operation
backend_do_restore() {
  local restic_cmd=${RESTIC_CMD:-restic}

  msg_info "Restoring from restic backup..."
  msg_info "  Repository: $RESTIC_REPOSITORY"

  # Check if there are any snapshots
  local snapshot_count
  snapshot_count=$("$restic_cmd" -r "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    snapshots --json --tag "circus" 2>/dev/null | grep -c '"id"' || echo "0")

  if [ "$snapshot_count" -eq 0 ]; then
    die "No backup snapshots found in repository."
  fi

  msg_info "Available snapshots:"
  "$restic_cmd" -r "$RESTIC_REPOSITORY" \
    --password-file "$RESTIC_PASSWORD_FILE" \
    snapshots --tag "circus"

  echo ""
  msg_info "Restoring latest snapshot..."

  # Restore to root (original locations)
  if "$restic_cmd" -r "$RESTIC_REPOSITORY" \
      --password-file "$RESTIC_PASSWORD_FILE" \
      restore latest \
      --tag "circus" \
      --target / \
      --verbose; then
    msg_success "Restic restore complete."
    echo ""
    msg_info "Files have been restored to their original locations."
  else
    die "Restic restore failed."
  fi
}

# Returns the path to the repository (for display purposes)
backend_get_archive_path() {
  echo "$RESTIC_REPOSITORY"
}
