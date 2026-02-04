#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_uninstall.bats
#
# DESCRIPTION:  Tests for the fc uninstall command for complete app removal.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc uninstall --help shows usage information" {
  run "$FC_COMMAND" fc-uninstall --help
  assert_success
  assert_output --partial "Usage: fc uninstall"
}

@test "fc uninstall --help shows actions" {
  run "$FC_COMMAND" fc-uninstall --help
  assert_success
  assert_output --partial "list"
  assert_output --partial "scan"
}

@test "fc uninstall --help shows options" {
  run "$FC_COMMAND" fc-uninstall --help
  assert_success
  assert_output --partial "--force"
  assert_output --partial "--keep-prefs"
}

@test "fc uninstall with no action shows usage" {
  run "$FC_COMMAND" fc-uninstall
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc uninstall scan runs without error" {
  run "$FC_COMMAND" fc-uninstall scan
  assert_success
  assert_output --partial "Application"
}

@test "fc uninstall list nonexistent-app fails" {
  run "$FC_COMMAND" fc-uninstall list "ThisAppDoesNotExist12345"
  assert_failure
  assert_output --partial "not found"
}

@test "fc uninstall without --force shows dry-run message" {
  # Skip if Safari doesn't exist
  if [[ ! -d "/Applications/Safari.app" ]]; then
    skip "Safari not installed"
  fi
  
  run "$FC_COMMAND" fc-uninstall Safari
  assert_success
  assert_output --partial "dry run"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-uninstall plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-uninstall" ]
}

@test "fc-uninstall plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-uninstall" ]
}

@test "fc-uninstall plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-uninstall"
  assert_success
}
