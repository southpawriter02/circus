#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_clean.bats
#
# DESCRIPTION:  Tests for the fc fc-clean command including orphaned package
#               detection for Homebrew formulae and casks.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Create a temporary directory for test files
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)
}

teardown() {
  # Clean up temporary directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-clean --help shows usage information" {
  run "$FC_COMMAND" fc-clean --help
  assert_success
  assert_output --partial "Usage: fc fc-clean"
  assert_output --partial "brew"
  assert_output --partial "casks"
  assert_output --partial "list"
}

@test "fc fc-clean --help shows options" {
  run "$FC_COMMAND" fc-clean --help
  assert_success
  assert_output --partial "--remove"
  assert_output --partial "--remove-all"
  assert_output --partial "--skip-deps"
}

@test "fc fc-clean --help shows examples" {
  run "$FC_COMMAND" fc-clean --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc fc-clean brew"
}

@test "fc fc-clean --help mentions Brewfile paths" {
  run "$FC_COMMAND" fc-clean --help
  assert_success
  assert_output --partial "Brewfile"
  assert_output --partial "apps.conf"
}

@test "fc fc-clean with no subcommand shows usage" {
  run "$FC_COMMAND" fc-clean
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Brew Subcommand Tests
# ==============================================================================

@test "fc fc-clean brew runs without error" {
  # Skip if brew is not installed
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew
  assert_success
  assert_output --partial "Scanning for orphaned Homebrew formulae"
}

@test "fc fc-clean brew shows installed count" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew
  assert_success
  assert_output --partial "Installed formulae:"
}

@test "fc fc-clean brew shows defined count" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew
  assert_success
  assert_output --partial "Defined in Brewfiles:"
}

@test "fc fc-clean brew shows orphaned count" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew
  assert_success
  assert_output --partial "Orphaned formulae:"
}

@test "fc fc-clean brew --skip-deps works" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew --skip-deps
  assert_success
  assert_output --partial "Scanning"
}

# ==============================================================================
# Casks Subcommand Tests
# ==============================================================================

@test "fc fc-clean casks runs without error" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean casks
  assert_success
  assert_output --partial "Scanning for orphaned Homebrew casks"
}

@test "fc fc-clean casks shows installed count" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean casks
  assert_success
  assert_output --partial "Installed casks:"
}

@test "fc fc-clean casks shows defined count" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean casks
  assert_success
  assert_output --partial "Defined in Brewfiles:"
}

@test "fc fc-clean cask alias works" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean cask
  assert_success
  assert_output --partial "Scanning for orphaned Homebrew casks"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc fc-clean list runs without error" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean list
  assert_success
}

@test "fc fc-clean list --formula shows only formulae" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean list --formula
  assert_success
  # Should not contain cask header
  refute_output --partial "# Orphaned casks"
}

@test "fc fc-clean list --cask shows only casks" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean list --cask
  assert_success
  # Should not contain formula header
  refute_output --partial "# Orphaned formulae"
}

@test "fc fc-clean list --formulae alias works" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean list --formulae
  assert_success
}

@test "fc fc-clean list --casks alias works" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean list --casks
  assert_success
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc fc-clean unknown subcommand fails" {
  run "$FC_COMMAND" fc-clean unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc fc-clean unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-clean unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

@test "fc fc-clean unknown option fails" {
  run "$FC_COMMAND" fc-clean brew --unknown-option
  assert_failure
  assert_output --partial "Unknown option"
}

# ==============================================================================
# Flag Position Tests
# ==============================================================================

@test "fc fc-clean --skip-deps brew works (flags before subcommand)" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean --skip-deps brew
  assert_success
  assert_output --partial "Scanning"
}

@test "fc fc-clean brew --skip-deps works (flags after subcommand)" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew --skip-deps
  assert_success
  assert_output --partial "Scanning"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-clean plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-clean" ]
}

@test "fc-clean plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-clean" ]
}

@test "fc-clean plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-clean"
  assert_success
}

# ==============================================================================
# Integration Tests
# ==============================================================================

@test "fc fc-clean brew suggests fc-apps add for adoption" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean brew
  assert_success
  # Should mention how to add packages to Brewfile
  assert_output --partial "fc fc-apps add"
}

@test "fc fc-clean casks suggests fc-apps add for adoption" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi

  run "$FC_COMMAND" fc-clean casks
  assert_success
  assert_output --partial "fc fc-apps add"
}
