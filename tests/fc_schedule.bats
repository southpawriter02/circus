#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_schedule.bats
#
# DESCRIPTION:  Tests for the fc fc-schedule command including install,
#               uninstall, and status subcommands.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Create a temporary directory for test files
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)

  # Store original plist location for cleanup
  export PLIST_DEST="$HOME/Library/LaunchAgents/com.southpawriter02.circus.backup.plist"
  export SCHEDULE_LABEL="com.southpawriter02.circus.backup"

  # Backup existing plist if present
  if [ -f "$PLIST_DEST" ]; then
    cp "$PLIST_DEST" "$PLIST_DEST.bats_backup"
    # Unload if loaded
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    rm -f "$PLIST_DEST"
  fi
}

teardown() {
  # Clean up temporary directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi

  # Unload and remove test plist if it exists
  if [ -f "$PLIST_DEST" ]; then
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    rm -f "$PLIST_DEST"
  fi

  # Restore original plist if it was backed up
  if [ -f "$PLIST_DEST.bats_backup" ]; then
    mv "$PLIST_DEST.bats_backup" "$PLIST_DEST"
    launchctl load "$PLIST_DEST" 2>/dev/null || true
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-schedule --help shows usage information" {
  run "$FC_COMMAND" fc-schedule --help
  assert_success
  assert_output --partial "Usage: fc fc-schedule"
  assert_output --partial "install"
  assert_output --partial "uninstall"
  assert_output --partial "status"
}

@test "fc fc-schedule with no arguments shows usage" {
  run "$FC_COMMAND" fc-schedule
  assert_success
  assert_output --partial "Usage: fc fc-schedule"
}

@test "fc fc-schedule --help shows frequency options" {
  run "$FC_COMMAND" fc-schedule --help
  assert_success
  assert_output --partial "--frequency"
  assert_output --partial "daily"
  assert_output --partial "weekly"
}

@test "fc fc-schedule --help shows examples" {
  run "$FC_COMMAND" fc-schedule --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc fc-schedule install"
}

# ==============================================================================
# Status Subcommand Tests
# ==============================================================================

@test "fc fc-schedule status works when not installed" {
  run "$FC_COMMAND" fc-schedule status
  assert_success
  assert_output --partial "Installed:  No"
  assert_output --partial "fc fc-schedule install"
}

@test "fc fc-schedule status shows status header" {
  run "$FC_COMMAND" fc-schedule status
  assert_success
  assert_output --partial "Scheduled Backup Status"
}

# ==============================================================================
# Install Subcommand Tests
# ==============================================================================

@test "fc fc-schedule install fails without sync config" {
  # Temporarily move the config file
  local config_file="$HOME/.config/circus/sync.conf"
  if [ -f "$config_file" ]; then
    mv "$config_file" "$config_file.bats_temp"
  fi

  run "$FC_COMMAND" fc-schedule install

  # Restore config
  if [ -f "$config_file.bats_temp" ]; then
    mv "$config_file.bats_temp" "$config_file"
  fi

  assert_failure
  assert_output --partial "fc-sync is not configured"
}

@test "fc fc-schedule install with invalid frequency fails" {
  run "$FC_COMMAND" fc-schedule install --frequency monthly
  assert_failure
  assert_output --partial "Invalid frequency"
}

# ==============================================================================
# Uninstall Subcommand Tests
# ==============================================================================

@test "fc fc-schedule uninstall works when not installed" {
  run "$FC_COMMAND" fc-schedule uninstall
  assert_success
  assert_output --partial "not installed"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc fc-schedule unknown subcommand fails" {
  run "$FC_COMMAND" fc-schedule unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc fc-schedule unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-schedule unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Plist Template Tests
# ==============================================================================

@test "plist template exists" {
  [ -f "$PROJECT_ROOT/etc/launchd/com.southpawriter02.circus.backup.plist.template" ]
}

@test "plist template contains required placeholders" {
  local template="$PROJECT_ROOT/etc/launchd/com.southpawriter02.circus.backup.plist.template"
  run grep "__DOTFILES_ROOT__" "$template"
  assert_success

  run grep "__START_INTERVAL__" "$template"
  assert_success

  run grep "__HOME__" "$template"
  assert_success
}

@test "plist template has correct label" {
  local template="$PROJECT_ROOT/etc/launchd/com.southpawriter02.circus.backup.plist.template"
  run grep "com.southpawriter02.circus.backup" "$template"
  assert_success
}

@test "plist template uses --no-confirm flag" {
  local template="$PROJECT_ROOT/etc/launchd/com.southpawriter02.circus.backup.plist.template"
  run grep "\-\-no-confirm" "$template"
  assert_success
}

# ==============================================================================
# fc-sync --no-confirm Tests
# ==============================================================================

@test "fc fc-sync --help shows --no-confirm option" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "--no-confirm"
}

@test "fc fc-sync --no-confirm is documented for automated use" {
  run "$FC_COMMAND" fc-sync --help
  assert_success
  assert_output --partial "automated"
}
