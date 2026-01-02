#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_wifi.bats
#
# DESCRIPTION:  Tests for the fc wifi command for managing the Wi-Fi adapter.
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

@test "fc wifi --help shows usage information" {
  run "$FC_COMMAND" fc-wifi --help
  assert_success
  assert_output --partial "Usage: fc wifi"
}

@test "fc wifi --help shows actions" {
  run "$FC_COMMAND" fc-wifi --help
  assert_success
  assert_output --partial "on"
  assert_output --partial "off"
  assert_output --partial "status"
}

@test "fc wifi --help shows examples" {
  run "$FC_COMMAND" fc-wifi --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc wifi on"
  assert_output --partial "fc wifi status"
}

@test "fc wifi with no action shows usage" {
  run "$FC_COMMAND" fc-wifi
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc wifi status runs without error" {
  # This test requires actual Wi-Fi hardware
  # Skip if no Wi-Fi hardware is present
  if ! networksetup -listallhardwareports | grep -q 'Wi-Fi'; then
    skip "No Wi-Fi hardware found"
  fi

  run "$FC_COMMAND" fc-wifi status
  assert_success
  assert_output --partial "Wi-Fi"
}

@test "fc wifi unknown action fails" {
  run "$FC_COMMAND" fc-wifi unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc wifi unknown action shows help hint" {
  run "$FC_COMMAND" fc-wifi unknown_action
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-wifi plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-wifi" ]
}

@test "fc-wifi plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-wifi" ]
}

@test "fc-wifi plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-wifi"
  assert_success
}

@test "fc-wifi plugin uses networksetup" {
  run grep "networksetup" "$PROJECT_ROOT/lib/plugins/fc-wifi"
  assert_success
}
