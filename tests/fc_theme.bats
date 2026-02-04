#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_theme.bats
#
# DESCRIPTION:  Tests for the fc theme command for shell theme management.
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

@test "fc theme --help shows usage information" {
  run "$FC_COMMAND" fc-theme --help
  assert_success
  assert_output --partial "Usage: fc theme"
}

@test "fc theme --help shows actions" {
  run "$FC_COMMAND" fc-theme --help
  assert_success
  assert_output --partial "list"
  assert_output --partial "apply"
  assert_output --partial "current"
  assert_output --partial "create"
}

@test "fc theme with no action shows usage" {
  run "$FC_COMMAND" fc-theme
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc theme list shows available themes" {
  run "$FC_COMMAND" fc-theme list
  assert_success
  assert_output --partial "Available Themes"
}

@test "fc theme list shows dark theme" {
  run "$FC_COMMAND" fc-theme list
  assert_success
  assert_output --partial "dark"
}

@test "fc theme list shows light theme" {
  run "$FC_COMMAND" fc-theme list
  assert_success
  assert_output --partial "light"
}

@test "fc theme current runs without error" {
  run "$FC_COMMAND" fc-theme current
  assert_success
}

@test "fc theme apply nonexistent fails" {
  run "$FC_COMMAND" fc-theme apply "nonexistent-theme-12345"
  assert_failure
  assert_output --partial "not found"
}

@test "fc theme unknown action fails" {
  run "$FC_COMMAND" fc-theme unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Theme Directory Tests
# ==============================================================================

@test "themes directory exists" {
  [ -d "$PROJECT_ROOT/themes" ]
}

@test "dark theme exists" {
  [ -d "$PROJECT_ROOT/themes/dark" ]
}

@test "light theme exists" {
  [ -d "$PROJECT_ROOT/themes/light" ]
}

@test "dark theme has theme.conf" {
  [ -f "$PROJECT_ROOT/themes/dark/theme.conf" ]
}

@test "dark theme has colors.sh" {
  [ -f "$PROJECT_ROOT/themes/dark/colors.sh" ]
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-theme plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-theme" ]
}

@test "fc-theme plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-theme" ]
}
