#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_focus.bats
#
# DESCRIPTION:  Tests for the fc focus command for distraction-free work.
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

@test "fc focus --help shows usage information" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "Usage: fc focus"
}

@test "fc focus --help shows start action" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "start"
  assert_output --partial "duration"
}

@test "fc focus --help shows stop action" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "stop"
}

@test "fc focus --help shows status action" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "status"
}

@test "fc focus --help shows setup action" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "setup"
}

@test "fc focus --help shows duration formats" {
  run "$FC_COMMAND" fc-focus --help
  assert_success
  assert_output --partial "30m"
  assert_output --partial "2h"
}

@test "fc focus with no action shows usage" {
  run "$FC_COMMAND" fc-focus
  assert_success
  assert_output --partial "Usage:"
}

@test "fc focus unknown action fails" {
  run "$FC_COMMAND" fc-focus unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-focus plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-focus" ]
}

@test "fc-focus plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-focus" ]
}

@test "fc-focus plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-focus"
  assert_success
}

@test "fc-focus contains hosts file handling" {
  run grep "HOSTS_FILE" "$PROJECT_ROOT/lib/plugins/fc-focus"
  assert_success
}

@test "fc-focus contains focus markers" {
  run grep "FOCUS_MARKER" "$PROJECT_ROOT/lib/plugins/fc-focus"
  assert_success
}
