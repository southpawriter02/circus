#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_history.bats
#
# DESCRIPTION:  Tests for the fc history command for enhanced shell history.
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

@test "fc history --help shows usage information" {
  run "$FC_COMMAND" fc-history --help
  assert_success
  assert_output --partial "Usage: fc history"
}

@test "fc history --help shows actions" {
  run "$FC_COMMAND" fc-history --help
  assert_success
  assert_output --partial "search"
  assert_output --partial "stats"
  assert_output --partial "top"
  assert_output --partial "clean"
  assert_output --partial "setup"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc history stats runs without error" {
  run "$FC_COMMAND" fc-history stats
  assert_success
  assert_output --partial "History Statistics"
}

@test "fc history top shows commands" {
  run "$FC_COMMAND" fc-history top --count 5
  assert_success
  assert_output --partial "Top 5 Commands"
}

@test "fc history unknown action fails" {
  run "$FC_COMMAND" fc-history unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-history plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-history" ]
}

@test "fc-history plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-history" ]
}

@test "fc-history plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-history"
  assert_success
}
