#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         borg.sh
#
# DESCRIPTION:  Borg backup backend for fc-sync. Uses borg for deduplication,
#               compression, and native SSH remote support.
#
# REQUIREMENTS: borg (brew install borgbackup)
#
# CONFIG:       BORG_REPOSITORY - Repository location (local or remote)
#               BORG_PASSPHRASE_FILE - Path to passphrase file
#               BORG_COMPRESSION - Compression algorithm (default: zstd)
#
# ==============================================================================

# --- Backend Interface Implementation -----------------------------------------

# Returns the human-readable name of this backend
backend_get_name() {
  echo "Borg"
}

# Returns 0 (true) if this backend handles remote storage natively
# Borg supports ssh:// remotes directly
backend_handles_remote() {
  return 0
}

# Checks that required dependencies are installed
backend_check_dependencies() {
  local borg_cmd=${BORG_CMD:-borg}

  if ! command -v "$borg_cmd" >/dev/null 2>&1; then
    msg_error "borg is not installed."
    echo ""
    msg_info "Install borg with: brew install borgbackup"
    msg_info "Then initialize a repository with: borg init -e repokey /path/to/repo"
    die "borg required for this backend."
  fi
}

# Validates backend-specific configuration
backend_validate_config() {
  if [ -z "$BORG_REPOSITORY" ]; then
    msg_error "BORG_REPOSITORY is not configured."
    echo ""
    msg_info "To configure the Borg backend:"
    msg_info "  1. Edit config: \$EDITOR $SYNC_CONFIG_FILE"
    msg_info "  2. Set BORG_REPOSITORY to your repository path"
    msg_info ""
    msg_info "Examples:"
    msg_info "  Local:  BORG_REPOSITORY=\"/path/to/backups\""
    msg_info "  SSH:    BORG_REPOSITORY=\"ssh://user@host/path/to/repo\""
    msg_info "  SSH:    BORG_REPOSITORY=\"user@host:/path/to/repo\""
    die "BORG_REPOSITORY required."
  fi

  if [ -z "$BORG_PASSPHRASE_FILE" ]; then
    msg_error "BORG_PASSPHRASE_FILE is not configured."
    die "BORG_PASSPHRASE_FILE required."
  fi

  if [ ! -f "$BORG_PASSPHRASE_FILE" ]; then
    msg_error "BORG_PASSPHRASE_FILE not found: $BORG_PASSPHRASE_FILE"
    echo ""
    msg_info "Create a passphrase file with:"
    msg_info "  echo 'your-secure-passphrase' > $BORG_PASSPHRASE_FILE"
    msg_info "  chmod 600 $BORG_PASSPHRASE_FILE"
    die "BORG_PASSPHRASE_FILE not found."
  fi

  # Check passphrase file permissions
  local perms
  perms=$(stat -f '%Lp' "$BORG_PASSPHRASE_FILE" 2>/dev/null || echo "000")
  local other_perms=$((perms % 10))
  if [ "$other_perms" -ge 4 ] 2>/dev/null; then
    msg_warning "BORG_PASSPHRASE_FILE is world-readable. Consider: chmod 600 $BORG_PASSPHRASE_FILE"
  fi

  if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
    die "BACKUP_TARGETS is empty. Configure at least one path in $SYNC_CONFIG_FILE"
  fi
}

# Set up borg environment (passphrase)
setup_borg_env() {
  export BORG_PASSPHRASE
  BORG_PASSPHRASE=$(cat "$BORG_PASSPHRASE_FILE")

  # Disable interactive prompts
  export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes
  export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
}

# Check if repository exists, initialize if not
ensure_repository() {
  local borg_cmd=${BORG_CMD:-borg}

  setup_borg_env

  # Try to get repo info to check if it exists
  if ! "$borg_cmd" info "$BORG_REPOSITORY" >/dev/null 2>&1; then
    msg_info "Repository not found. Initializing new repository..."
    if "$borg_cmd" init --encryption=repokey "$BORG_REPOSITORY"; then
      msg_success "Repository initialized at: $BORG_REPOSITORY"
      echo ""
      msg_warning "IMPORTANT: Back up your repository key!"
      msg_info "Export it with: borg key export $BORG_REPOSITORY /path/to/key-backup"
    else
      die "Failed to initialize borg repository at: $BORG_REPOSITORY"
    fi
  fi
}

# Performs the backup operation
backend_do_backup() {
  local borg_cmd=${BORG_CMD:-borg}
  local compression=${BORG_COMPRESSION:-zstd}

  ensure_repository
  setup_borg_env

  msg_info "Creating borg backup..."
  msg_info "  Repository: $BORG_REPOSITORY"
  msg_info "  Compression: $compression"

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

  # Create archive name with timestamp
  local archive_name="circus-$(date +%Y%m%d-%H%M%S)"

  # Run the backup
  if "$borg_cmd" create \
      --compression "$compression" \
      --stats \
      --show-rc \
      --verbose \
      "${exclude_args[@]}" \
      "$BORG_REPOSITORY::$archive_name" \
      "${backup_paths[@]}"; then
    msg_success "Borg backup complete: $archive_name"
  else
    die "Borg backup failed."
  fi

  # Run automatic pruning
  echo ""
  msg_info "Pruning old archives..."
  "$borg_cmd" prune \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --stats \
    "$BORG_REPOSITORY"

  # Compact the repository
  echo ""
  msg_info "Compacting repository..."
  "$borg_cmd" compact "$BORG_REPOSITORY" 2>/dev/null || true

  # Show archive list
  echo ""
  msg_info "Recent archives:"
  "$borg_cmd" list --last 5 "$BORG_REPOSITORY"
}

# Performs the restore operation
backend_do_restore() {
  local borg_cmd=${BORG_CMD:-borg}

  setup_borg_env

  msg_info "Restoring from borg backup..."
  msg_info "  Repository: $BORG_REPOSITORY"

  # Check if there are any archives
  local archive_count
  archive_count=$("$borg_cmd" list --short "$BORG_REPOSITORY" 2>/dev/null | wc -l | tr -d ' ')

  if [ "$archive_count" -eq 0 ]; then
    die "No backup archives found in repository."
  fi

  msg_info "Available archives:"
  "$borg_cmd" list "$BORG_REPOSITORY"

  echo ""
  msg_info "Restoring latest archive..."

  # Get the latest archive name
  local latest_archive
  latest_archive=$("$borg_cmd" list --short --last 1 "$BORG_REPOSITORY" 2>/dev/null)

  if [ -z "$latest_archive" ]; then
    die "Could not determine latest archive."
  fi

  msg_info "Extracting: $latest_archive"

  # Extract to root (original locations)
  # Note: borg extract must be run from the target directory
  local current_dir
  current_dir=$(pwd)

  cd / || die "Could not change to root directory"

  if "$borg_cmd" extract \
      --verbose \
      "$BORG_REPOSITORY::$latest_archive"; then
    msg_success "Borg restore complete."
    echo ""
    msg_info "Files have been restored to their original locations."
  else
    cd "$current_dir" || true
    die "Borg restore failed."
  fi

  cd "$current_dir" || true
}

# Returns the path to the repository (for display purposes)
backend_get_archive_path() {
  echo "$BORG_REPOSITORY"
}
