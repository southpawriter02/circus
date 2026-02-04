#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_desktop.bats
#
# DESCRIPTION:  Tests for the fc desktop command for desktop organization.
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

@test "fc desktop --help shows usage information" {
  run "$FC_COMMAND" fc-desktop --help
  assert_success
  assert_output --partial "Usage: fc desktop"
}

@test "fc desktop --help shows actions" {
  run "$FC_COMMAND" fc-desktop --help
  assert_success
  assert_output --partial "status"
  assert_output --partial "clean"
  assert_output --partial "organize"
  assert_output --partial "undo"
}

@test "fc desktop --help shows options" {
  run "$FC_COMMAND" fc-desktop --help
  assert_success
  assert_output --partial "--dry-run"
  assert_output --partial "--force"
}

@test "fc desktop with no action shows usage" {
  run "$FC_COMMAND" fc-desktop
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc desktop status runs without error" {
  run "$FC_COMMAND" fc-desktop status
  assert_success
  assert_output --partial "Desktop Status"
}

@test "fc desktop unknown action fails" {
  run "$FC_COMMAND" fc-desktop unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-desktop plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-desktop" ]
}

@test "fc-desktop plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-desktop" ]
}

@test "fc-desktop plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-desktop"
  assert_success
}
