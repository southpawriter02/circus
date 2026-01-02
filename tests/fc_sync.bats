#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_sync.bats
#
# DESCRIPTION:  Tests for the fc fc-sync command including configuration
#               loading, setup command, and error handling.
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
# Help and Usage Tests
# ==============================================================================

@test "fc fc-sync --help shows usage information" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "Usage: fc fc-sync"
  assert_output --partial "setup"
  assert_output --partial "backup"
  assert_output --partial "restore"
}

@test "fc fc-sync --help shows configuration file path" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "Configuration:"
  assert_output --partial ".config/circus/sync.conf"
}

# ==============================================================================
# Configuration Template Tests
# ==============================================================================

@test "sync.conf.template exists" {
  assert [ -f "$PROJECT_ROOT/lib/templates/sync.conf.template" ]
}

@test "sync.conf.template contains required variables" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "GPG_RECIPIENT_ID"
  assert_output --partial "BACKUP_TARGETS"
  assert_output --partial "BACKUP_DEST_DIR"
  assert_output --partial "BACKUP_ARCHIVE_NAME"
}

@test "sync.conf.template contains security warning" {
  run cat "$PROJECT_ROOT/lib/templates/sync.conf.template"
  assert_success
  assert_output --partial "SECURITY WARNING"
}

# ==============================================================================
# Setup Command Tests
# ==============================================================================

@test "fc fc-sync setup creates config file" {
  rm -f "$SYNC_CONFIG_FILE"
  run "$FC_COMMAND" fc-sync setup
  assert_success
  assert [ -f "$SYNC_CONFIG_FILE" ]
  assert_output --partial "Configuration file created"
}

@test "fc fc-sync setup sets correct permissions" {
  rm -f "$SYNC_CONFIG_FILE"
  run "$FC_COMMAND" fc-sync setup
  assert_success

  # Check permissions are 600
  perms=$(stat -f '%Lp' "$SYNC_CONFIG_FILE")
  [ "$perms" = "600" ]
}

@test "fc fc-sync setup shows next steps" {
  rm -f "$SYNC_CONFIG_FILE"
  run "$FC_COMMAND" fc-sync setup
  assert_success
  assert_output --partial "Next steps"
  assert_output --partial "GPG_RECIPIENT_ID"
  assert_output --partial "gpg --list-keys"
}

@test "fc fc-sync setup detects existing config" {
  # Make sure config exists
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  touch "$SYNC_CONFIG_FILE"
  chmod 600 "$SYNC_CONFIG_FILE"

  run "$FC_COMMAND" fc-sync setup
  assert_success
  assert_output --partial "already exists"
}

# ==============================================================================
# Configuration Validation Tests
# ==============================================================================

@test "fc fc-sync backup fails without GPG_RECIPIENT_ID" {
  # Create config without GPG_RECIPIENT_ID
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
  assert_output --partial "GPG_RECIPIENT_ID is not configured"
}

@test "fc fc-sync backup fails with empty BACKUP_TARGETS" {
  # Create config with empty BACKUP_TARGETS
  mkdir -p "$(dirname "$SYNC_CONFIG_FILE")"
  cat > "$SYNC_CONFIG_FILE" << 'EOF'
GPG_RECIPIENT_ID="test-key-id"
BACKUP_TARGETS=()
EOF
  chmod 600 "$SYNC_CONFIG_FILE"

  # Mock gpg and rsync
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
  assert_output --partial "BACKUP_TARGETS is empty"
}

# ==============================================================================
# Unknown Subcommand Tests
# ==============================================================================

@test "fc fc-sync with unknown subcommand shows error" {
  run "$FC_COMMAND" fc-sync unknown-command
  assert_failure
  assert_output --partial "Unknown subcommand"
}

# ==============================================================================
# Dependency Check Tests
# ==============================================================================

@test "fc fc-sync backup requires gpg" {
  # Override GPG_CMD to a non-existent command
  export GPG_CMD="nonexistent-gpg-command"

  run "$FC_COMMAND" fc-sync backup
  assert_failure
  assert_output --partial "GPG is not installed"
}

@test "fc fc-sync backup requires rsync" {
  # Override RSYNC_CMD to a non-existent command
  # Need to have gpg available first
  export RSYNC_CMD="nonexistent-rsync-command"

  # Only run this test if gpg is actually installed
  if command -v gpg >/dev/null 2>&1; then
    run "$FC_COMMAND" fc-sync backup
    assert_failure
    assert_output --partial "rsync"
  else
    skip "gpg not installed, cannot test rsync dependency check"
  fi
}
