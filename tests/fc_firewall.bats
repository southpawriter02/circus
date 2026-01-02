#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_firewall.bats
#
# DESCRIPTION:  Tests for the fc firewall command for managing the macOS
#               application firewall.
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

@test "fc firewall --help shows usage information" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "Usage: fc firewall"
}

@test "fc firewall --help shows actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "on"
  assert_output --partial "off"
  assert_output --partial "status"
}

@test "fc firewall --help shows examples" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc firewall on"
  assert_output --partial "fc firewall status"
}

@test "fc firewall --help mentions sudo requirement" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "sudo"
}

@test "fc firewall with no action shows usage" {
  run "$FC_COMMAND" fc-firewall
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc firewall unknown action fails" {
  run "$FC_COMMAND" fc-firewall unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc firewall unknown action shows help hint" {
  run "$FC_COMMAND" fc-firewall unknown_action
  assert_failure
  assert_output --partial "--help"
}

# Note: We skip tests that require sudo as they would fail in CI environments
# and we don't want to modify actual firewall settings during tests

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-firewall plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-firewall" ]
}

@test "fc-firewall plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-firewall" ]
}

@test "fc-firewall plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}

@test "fc-firewall plugin uses socketfilterfw" {
  run grep "socketfilterfw" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}

@test "fc-firewall plugin defines FIREWALL_CMD" {
  run grep "FIREWALL_CMD" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}
