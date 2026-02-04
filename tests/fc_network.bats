#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_network.bats
#
# DESCRIPTION:  Tests for the fc network command for network diagnostics.
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

@test "fc network --help shows usage information" {
  run "$FC_COMMAND" fc-network --help
  assert_success
  assert_output --partial "Usage: fc network"
}

@test "fc network --help shows actions" {
  run "$FC_COMMAND" fc-network --help
  assert_success
  assert_output --partial "status"
  assert_output --partial "diag"
  assert_output --partial "info"
  assert_output --partial "latency"
  assert_output --partial "dns"
  assert_output --partial "port"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc network status runs without error" {
  run "$FC_COMMAND" fc-network status
  assert_success
  assert_output --partial "Network Status"
}

@test "fc network info shows network configuration" {
  run "$FC_COMMAND" fc-network info
  assert_success
  assert_output --partial "Network Configuration"
}

@test "fc network unknown action fails" {
  run "$FC_COMMAND" fc-network unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-network plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-network" ]
}

@test "fc-network plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-network" ]
}

@test "fc-network plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-network"
  assert_success
}
