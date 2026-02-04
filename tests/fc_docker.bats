#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_docker.bats
#
# DESCRIPTION:  Tests for the fc docker command for Docker cleanup utilities.
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

@test "fc docker --help shows usage information" {
  run "$FC_COMMAND" fc-docker --help
  assert_success
  assert_output --partial "Usage: fc docker"
}

@test "fc docker --help shows actions" {
  run "$FC_COMMAND" fc-docker --help
  assert_success
  assert_output --partial "status"
  assert_output --partial "clean"
  assert_output --partial "images"
  assert_output --partial "containers"
  assert_output --partial "volumes"
}

@test "fc docker --help shows options" {
  run "$FC_COMMAND" fc-docker --help
  assert_success
  assert_output --partial "--force"
  assert_output --partial "--dry-run"
}

@test "fc docker with no action shows usage" {
  run "$FC_COMMAND" fc-docker
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests (require Docker)
# ==============================================================================

@test "fc docker status fails gracefully without Docker" {
  # This test checks behavior when Docker is not available
  if command -v docker &>/dev/null && docker info &>/dev/null; then
    skip "Docker is running, testing status command"
    run "$FC_COMMAND" fc-docker status
    assert_success
  else
    run "$FC_COMMAND" fc-docker status
    assert_failure
    assert_output --partial "Docker"
  fi
}

@test "fc docker unknown action fails" {
  run "$FC_COMMAND" fc-docker unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-docker plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-docker" ]
}

@test "fc-docker plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-docker" ]
}

@test "fc-docker plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-docker"
  assert_success
}
