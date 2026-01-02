#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_healthcheck.bats
#
# DESCRIPTION:  Tests for the fc healthcheck command for system health checks.
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

@test "fc healthcheck --help shows usage information" {
  run "$FC_COMMAND" fc-healthcheck --help
  assert_success
  assert_output --partial "Usage: fc healthcheck"
}

@test "fc healthcheck --help shows available checks" {
  run "$FC_COMMAND" fc-healthcheck --help
  assert_success
  assert_output --partial "symlinks"
  assert_output --partial "deps"
  assert_output --partial "ssh"
  assert_output --partial "git"
}

@test "fc healthcheck --help shows examples" {
  run "$FC_COMMAND" fc-healthcheck --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc healthcheck ssh"
}

@test "fc healthcheck --list shows available checks" {
  run "$FC_COMMAND" fc-healthcheck --list
  assert_success
  assert_output --partial "Available Health Checks"
  assert_output --partial "symlinks"
  assert_output --partial "deps"
  assert_output --partial "ssh"
  assert_output --partial "git"
}

# ==============================================================================
# All Checks Tests
# ==============================================================================

@test "fc healthcheck runs without error" {
  run "$FC_COMMAND" fc-healthcheck
  assert_success
  assert_output --partial "System Health Check"
}

@test "fc healthcheck shows summary" {
  run "$FC_COMMAND" fc-healthcheck
  assert_success
  assert_output --partial "Summary:"
}

@test "fc healthcheck includes all four checks" {
  run "$FC_COMMAND" fc-healthcheck
  assert_success
  assert_output --partial "SSH Permissions"
  assert_output --partial "Git Configuration"
  assert_output --partial "Broken Symlinks"
  assert_output --partial "Dependencies"
}

# ==============================================================================
# Individual Check Tests
# ==============================================================================

@test "fc healthcheck symlinks runs without error" {
  run "$FC_COMMAND" fc-healthcheck symlinks
  assert_success
  assert_output --partial "Broken Symlinks"
}

@test "fc healthcheck deps runs without error" {
  run "$FC_COMMAND" fc-healthcheck deps
  assert_success
  assert_output --partial "Dependencies"
}

@test "fc healthcheck ssh runs without error" {
  run "$FC_COMMAND" fc-healthcheck ssh
  assert_success
  assert_output --partial "SSH Permissions"
}

@test "fc healthcheck git runs without error" {
  run "$FC_COMMAND" fc-healthcheck git
  assert_success
  assert_output --partial "Git Configuration"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc healthcheck unknown check fails" {
  run "$FC_COMMAND" fc-healthcheck unknown_check
  assert_failure
  assert_output --partial "Unknown check"
}

@test "fc healthcheck unknown check shows help hint" {
  run "$FC_COMMAND" fc-healthcheck unknown_check
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-healthcheck plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-healthcheck" ]
}

@test "fc-healthcheck plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-healthcheck" ]
}

@test "fc-healthcheck plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-healthcheck"
  assert_success
}

@test "fc-healthcheck plugin defines check functions" {
  run grep "check_symlinks\|check_deps\|check_ssh\|check_git" "$PROJECT_ROOT/lib/plugins/fc-healthcheck"
  assert_success
}
