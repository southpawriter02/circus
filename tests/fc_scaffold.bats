#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_scaffold.bats
#
# DESCRIPTION:  Tests for the fc scaffold command for project scaffolding.
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

@test "fc scaffold --help shows usage information" {
  run "$FC_COMMAND" fc-scaffold --help
  assert_success
  assert_output --partial "Usage: fc scaffold"
}

@test "fc scaffold --help shows actions" {
  run "$FC_COMMAND" fc-scaffold --help
  assert_success
  assert_output --partial "new"
  assert_output --partial "list"
  assert_output --partial "show"
  assert_output --partial "create-template"
}

@test "fc scaffold --help shows options" {
  run "$FC_COMMAND" fc-scaffold --help
  assert_success
  assert_output --partial "--author"
  assert_output --partial "--dir"
  assert_output --partial "--force"
}

@test "fc scaffold with no action shows usage" {
  run "$FC_COMMAND" fc-scaffold
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc scaffold list shows templates" {
  run "$FC_COMMAND" fc-scaffold list
  assert_success
  assert_output --partial "python-cli"
}

@test "fc scaffold show python-cli shows details" {
  run "$FC_COMMAND" fc-scaffold show python-cli
  assert_success
  assert_output --partial "Template: python-cli"
}

@test "fc scaffold show nonexistent fails" {
  run "$FC_COMMAND" fc-scaffold show "nonexistent-template-12345"
  assert_failure
  assert_output --partial "not found"
}

@test "fc scaffold unknown action fails" {
  run "$FC_COMMAND" fc-scaffold unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Template Directory Tests
# ==============================================================================

@test "templates directory exists" {
  [ -d "$PROJECT_ROOT/templates" ]
}

@test "projects templates directory exists" {
  [ -d "$PROJECT_ROOT/templates/projects" ]
}

@test "python-cli template exists" {
  [ -d "$PROJECT_ROOT/templates/projects/python-cli" ]
}

@test "python-cli has template.conf" {
  [ -f "$PROJECT_ROOT/templates/projects/python-cli/template.conf" ]
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-scaffold plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-scaffold" ]
}

@test "fc-scaffold plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-scaffold" ]
}

@test "fc-scaffold plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-scaffold"
  assert_success
}
