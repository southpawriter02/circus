#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_sync_backends.bats
#
# DESCRIPTION:  Tests for the fc-sync backup backend system including
#               backend loading, configuration validation, and error handling.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Save original config if it exists
  export SYNC_CONFIG_FILE="$HOME/.config/circus/sync.conf"
  if [ -f "$SYNC_CONFIG_FILE" ]; then
    cp "$SYNC_CONFIG_FILE" "$SYNC_CONFIG_FILE.bats_backup"
  fi
}

teardown() {
  # Restore original config
  if [ -f "$SYNC_CONFIG_FILE.bats_backup" ]; then
    mv "$SYNC_CONFIG_FILE.bats_backup" "$SYNC_CONFIG_FILE"
  fi

  # Clean up mock bin directory
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi
}

# ==============================================================================
# Backend Discovery Tests
# ==============================================================================

@test "backup backends directory exists" {
  assert [ -d "$PROJECT_ROOT/lib/backup_backends" ]
}

@test "gpg backend file exists" {
  assert [ -f "$PROJECT_ROOT/lib/backup_backends/gpg.sh" ]
}

@test "restic backend file exists" {
  assert [ -f "$PROJECT_ROOT/lib/backup_backends/restic.sh" ]
}

@test "borg backend file exists" {
  assert [ -f "$PROJECT_ROOT/lib/backup_backends/borg.sh" ]
}

# ==============================================================================
# Help Output Tests
# ==============================================================================

@test "fc fc-sync --help shows available backends" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "gpg"
  assert_output --partial "restic"
  assert_output --partial "borg"
}

@test "fc fc-sync --help shows backend descriptions" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "tar + GPG"
  assert_output --partial "Deduplication"
}

@test "fc fc-sync --help mentions BACKUP_BACKEND config" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "BACKUP_BACKEND"
}

# ==============================================================================
# Configuration Template Tests
# ==============================================================================

@test "sync.conf.template contains BACKUP_BACKEND option" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "BACKUP_BACKEND"
}

@test "sync.conf.template contains Restic settings" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "RESTIC_REPOSITORY"
  assert_output --partial "RESTIC_PASSWORD_FILE"
}

@test "sync.conf.template contains Borg settings" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "BORG_REPOSITORY"
  assert_output --partial "BORG_PASSPHRASE_FILE"
  assert_output --partial "BORG_COMPRESSION"
}

@test "sync.conf.template contains BACKUP_EXCLUDES option" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "BACKUP_EXCLUDES"
}

# ==============================================================================
# Invalid Backend Tests
# ==============================================================================

@test "fc fc-sync backup with invalid backend fails" {
  # Create config with invalid backend
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="nonexistent"
GPG_RECIPIENT_ID="test-key"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "Unknown backup backend"
  assert_output --partial "nonexistent"
}

@test "fc fc-sync backup with invalid backend shows available backends" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="invalid"
GPG_RECIPIENT_ID="test-key"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "gpg"
}

# ==============================================================================
# GPG Backend Tests
# ==============================================================================

@test "gpg backend is default when BACKUP_BACKEND not set" {
  # Create minimal config without BACKUP_BACKEND
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
GPG_RECIPIENT_ID=""
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock gpg and rsync to pass dependency checks
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/gpg"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/gpg"
  chmod +x "$BATS_MOCK_BINDIR/gpg"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/rsync"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/rsync"
  chmod +x "$BATS_MOCK_BINDIR/rsync"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  # Should fail at GPG_RECIPIENT_ID validation (proving GPG backend was loaded)
  assert_output --partial "GPG_RECIPIENT_ID"
}

# ==============================================================================
# Restic Backend Tests
# ==============================================================================

@test "restic backend requires restic command" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="restic"
RESTIC_REPOSITORY="/tmp/test-repo"
RESTIC_PASSWORD_FILE="/tmp/test-password"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Override RESTIC_CMD to a non-existent command
  export RESTIC_CMD="nonexistent-restic-command"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "restic is not installed"
}

@test "restic backend requires RESTIC_REPOSITORY" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="restic"
RESTIC_REPOSITORY=""
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock restic to pass dependency check
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/restic"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/restic"
  chmod +x "$BATS_MOCK_BINDIR/restic"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "RESTIC_REPOSITORY is not configured"
}

@test "restic backend requires RESTIC_PASSWORD_FILE" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="restic"
RESTIC_REPOSITORY="/tmp/test-repo"
RESTIC_PASSWORD_FILE=""
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock restic to pass dependency check
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/restic"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/restic"
  chmod +x "$BATS_MOCK_BINDIR/restic"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "RESTIC_PASSWORD_FILE"
}

# ==============================================================================
# Borg Backend Tests
# ==============================================================================

@test "borg backend requires borg command" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="borg"
BORG_REPOSITORY="/tmp/test-repo"
BORG_PASSPHRASE_FILE="/tmp/test-passphrase"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Override BORG_CMD to a non-existent command
  export BORG_CMD="nonexistent-borg-command"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "borg is not installed"
}

@test "borg backend requires BORG_REPOSITORY" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="borg"
BORG_REPOSITORY=""
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock borg to pass dependency check
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/borg"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/borg"
  chmod +x "$BATS_MOCK_BINDIR/borg"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "BORG_REPOSITORY is not configured"
}

@test "borg backend requires BORG_PASSPHRASE_FILE" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="borg"
BORG_REPOSITORY="/tmp/test-repo"
BORG_PASSPHRASE_FILE=""
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock borg to pass dependency check
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/borg"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/borg"
  chmod +x "$BATS_MOCK_BINDIR/borg"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "BORG_PASSPHRASE_FILE"
}

# ==============================================================================
# Remote Command Backend Awareness Tests
# ==============================================================================

@test "fc fc-sync push with restic backend shows native remote info" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="restic"
RESTIC_REPOSITORY="/tmp/test-repo"
RESTIC_PASSWORD_FILE="/tmp/test-password"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Create mock password file
  echo "test-password" > /tmp/test-password
  chmod 600 /tmp/test-password

  # Mock restic and rclone
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/restic"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/restic"
  chmod +x "$BATS_MOCK_BINDIR/restic"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/rclone"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/rclone"
  chmod +x "$BATS_MOCK_BINDIR/rclone"

  run "$FC_COMMAND" fc-sync --no-confirm push
  assert_success
  assert_output --partial "native remote support"
  assert_output --partial "RESTIC_REPOSITORY"

  rm -f /tmp/test-password
}

@test "fc fc-sync push with borg backend shows native remote info" {
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
BACKUP_BACKEND="borg"
BORG_REPOSITORY="/tmp/test-repo"
BORG_PASSPHRASE_FILE="/tmp/test-passphrase"
BACKUP_TARGETS=("$HOME/.ssh")
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Create mock passphrase file
  echo "test-passphrase" > /tmp/test-passphrase
  chmod 600 /tmp/test-passphrase

  # Mock borg and rclone
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/borg"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/borg"
  chmod +x "$BATS_MOCK_BINDIR/borg"
  echo '#!/bin/bash' > "$BATS_MOCK_BINDIR/rclone"
  echo 'exit 0' >> "$BATS_MOCK_BINDIR/rclone"
  chmod +x "$BATS_MOCK_BINDIR/rclone"

  run "$FC_COMMAND" fc-sync --no-confirm push
  assert_success
  assert_output --partial "native remote support"
  assert_output --partial "BORG_REPOSITORY"

  rm -f /tmp/test-passphrase
}
