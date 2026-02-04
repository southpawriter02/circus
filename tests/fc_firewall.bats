#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_firewall.bats
#
# DESCRIPTION:  Tests for the fc firewall command for macOS firewall management.
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

@test "fc firewall --help shows basic actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "on"
  assert_output --partial "off"
  assert_output --partial "status"
}

@test "fc firewall --help shows app management actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "list-apps"
  assert_output --partial "add"
  assert_output --partial "remove"
  assert_output --partial "allow"
  assert_output --partial "block"
}

@test "fc firewall --help shows configuration actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "apply-rules"
  assert_output --partial "export"
  assert_output --partial "setup"
}

@test "fc firewall --help shows advanced options" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "stealth-on"
  assert_output --partial "stealth-off"
  assert_output --partial "block-all"
}

@test "fc firewall with no action shows usage" {
  run "$FC_COMMAND" fc-firewall
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Validation Tests
# ==============================================================================

@test "fc firewall add requires app path" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall add
  assert_failure
  assert_output --partial "required"
}

@test "fc firewall add validates app exists" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall add "/nonexistent/app.app"
  assert_failure
  assert_output --partial "not found"
}

@test "fc firewall unknown action fails" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

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

@test "fc-firewall contains socketfilterfw reference" {
  run grep "socketfilterfw" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}
