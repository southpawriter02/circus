#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_maintenance.bats
#
# DESCRIPTION:  Tests for the fc fc-maintenance command including setup, list,
#               run, and default maintenance execution.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Isolate HOME so this file cannot read or write the real ~/.config/circus.
  setup_isolated_home

  # Create a temporary directory for test files
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)

  # Store original config location for cleanup
  export MAINTENANCE_CONFIG_FILE="$HOME/.config/circus/maintenance.conf"

  # Backup existing config if present
  if [ -f "$MAINTENANCE_CONFIG_FILE" ]; then
    cp "$MAINTENANCE_CONFIG_FILE" "$MAINTENANCE_CONFIG_FILE.bats_backup"
  fi
}

teardown() {
  # Restore the real HOME and remove the temporary one.
  teardown_isolated_home

  # Clean up temporary directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi

  # Restore original config
  if [ -f "$MAINTENANCE_CONFIG_FILE.bats_backup" ]; then
    mv "$MAINTENANCE_CONFIG_FILE.bats_backup" "$MAINTENANCE_CONFIG_FILE"
  elif [ -f "$MAINTENANCE_CONFIG_FILE" ]; then
    # Remove test config if no backup existed
    rm -f "$MAINTENANCE_CONFIG_FILE"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-maintenance --help shows usage information" {
  run "$FC_COMMAND" fc-maintenance --help
  assert_success
  assert_output --partial "Usage: fc fc-maintenance"
  assert_output --partial "setup"
  assert_output --partial "list"
  assert_output --partial "run"
}

@test "fc fc-maintenance --help shows options" {
  run "$FC_COMMAND" fc-maintenance --help
  assert_success
  assert_output --partial "--all"
  assert_output --partial "--dry-run"
  assert_output --partial "--include-trash"
}

@test "fc fc-maintenance --help shows examples" {
  run "$FC_COMMAND" fc-maintenance --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc fc-maintenance --dry-run"
}

@test "fc fc-maintenance --help shows configuration path" {
  run "$FC_COMMAND" fc-maintenance --help
  assert_success
  assert_output --partial "Configuration:"
  assert_output --partial "maintenance.conf"
}

# ==============================================================================
# Setup Subcommand Tests
# ==============================================================================

@test "fc fc-maintenance setup creates config file" {
  # Remove existing config
  rm -f "$MAINTENANCE_CONFIG_FILE"

  run "$FC_COMMAND" fc-maintenance setup
  assert_success
  assert_output --partial "Configuration file created"
  [ -f "$MAINTENANCE_CONFIG_FILE" ]
}

@test "fc fc-maintenance setup shows next steps" {
  rm -f "$MAINTENANCE_CONFIG_FILE"

  run "$FC_COMMAND" fc-maintenance setup
  assert_success
  assert_output --partial "Next steps"
  assert_output --partial "Edit the config"
}

@test "fc fc-maintenance setup detects existing config" {
  # Create a config file first
  mkdir -p "$(dirname "$MAINTENANCE_CONFIG_FILE")"
  echo "# test" > "$MAINTENANCE_CONFIG_FILE"

  run "$FC_COMMAND" fc-maintenance setup
  assert_success
  assert_output --partial "already exists"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc fc-maintenance list shows available tasks" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "Available Maintenance Tasks"
}

# The brew-* task names became OS-agnostic pkg-* names in 1883309, when Linux
# support was added; these tests were not updated at the time.
@test "fc fc-maintenance list shows pkg-cleanup task" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "pkg-cleanup"
}

@test "fc fc-maintenance list shows npm-cache task" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "npm-cache"
}

@test "fc fc-maintenance list shows trash task" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "trash"
}

@test "fc fc-maintenance list shows enabled/disabled status" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "[enabled]"
}

@test "fc fc-maintenance list shows sudo requirement" {
  run "$FC_COMMAND" fc-maintenance list
  assert_success
  assert_output --partial "requires sudo"
}

# ==============================================================================
# Run Subcommand Tests
# ==============================================================================

@test "fc fc-maintenance run requires task name" {
  run "$FC_COMMAND" fc-maintenance run
  assert_failure
  assert_output --partial "Task name required"
}

@test "fc fc-maintenance run with unknown task fails" {
  run "$FC_COMMAND" fc-maintenance run unknown-task
  assert_failure
  assert_output --partial "Unknown task"
}

@test "fc fc-maintenance run with unknown task shows list hint" {
  run "$FC_COMMAND" fc-maintenance run unknown-task
  assert_failure
  # The plugin prints the canonical invocation, `fc maintenance list`, not the
  # `fc fc-maintenance` form used to invoke it here.
  assert_output --partial "fc maintenance list"
}

@test "fc fc-maintenance run pkg-cleanup --dry-run works" {
  run "$FC_COMMAND" fc-maintenance --dry-run run pkg-cleanup
  assert_success
  assert_output --partial "[DRY-RUN]"
  # The message is package-manager agnostic since the Linux support work.
  assert_output --partial "package cleanup"
}

# ==============================================================================
# Default Maintenance Execution Tests
# ==============================================================================

@test "fc fc-maintenance --dry-run shows preview" {
  run "$FC_COMMAND" fc-maintenance --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  assert_output --partial "System Maintenance"
}

@test "fc fc-maintenance --dry-run does not execute tasks" {
  run "$FC_COMMAND" fc-maintenance --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  # Should show "Would" language
  assert_output --partial "Would"
}

@test "fc fc-maintenance --all includes more tasks" {
  run "$FC_COMMAND" fc-maintenance --all --dry-run
  assert_success
  # Should include tasks that are disabled by default
  assert_output --partial "DNS"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc fc-maintenance unknown subcommand fails" {
  run "$FC_COMMAND" fc-maintenance unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc fc-maintenance unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-maintenance unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Template Tests
# ==============================================================================

@test "maintenance.conf.template exists" {
  [ -f "$PROJECT_ROOT/lib/templates/maintenance.conf.template" ]
}

@test "maintenance.conf.template has task configuration" {
  run grep "TASK_BREW_CLEANUP" "$PROJECT_ROOT/lib/templates/maintenance.conf.template"
  assert_success
}

@test "maintenance.conf.template has LOG_RETENTION_DAYS" {
  run grep "LOG_RETENTION_DAYS" "$PROJECT_ROOT/lib/templates/maintenance.conf.template"
  assert_success
}

@test "maintenance.conf.template has BREW_PRUNE_DAYS" {
  run grep "BREW_PRUNE_DAYS" "$PROJECT_ROOT/lib/templates/maintenance.conf.template"
  assert_success
}

# ==============================================================================
# Integration Tests
# ==============================================================================

@test "fc fc-maintenance run dns-flush --dry-run previews the flush" {
  run "$FC_COMMAND" fc-maintenance --dry-run run dns-flush
  assert_success
  assert_output --partial "[DRY-RUN]"
  # Asserts behaviour, not a platform-specific binary: DNS clearing goes through
  # os_clear_dns since the cross-platform work, so `dscacheutil` is no longer
  # named here and asserting it would fail on Linux.
  assert_output --partial "DNS"
}

@test "fc fc-maintenance run trash --dry-run works" {
  run "$FC_COMMAND" fc-maintenance --dry-run run trash
  assert_success
  assert_output --partial "Trash"
}

@test "fc fc-maintenance --include-trash --dry-run includes trash task" {
  run "$FC_COMMAND" fc-maintenance --include-trash --dry-run
  assert_success
  assert_output --partial "Trash"
}
