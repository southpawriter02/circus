#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_profile.bats
#
# DESCRIPTION:  Tests for the fc fc-profile command including list, current,
#               and switch subcommands.
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

@test "fc fc-profile --help shows usage information" {
  run "$FC_COMMAND" fc-profile --help
  assert_success
  assert_output --partial "Usage: fc fc-profile"
  assert_output --partial "list"
  assert_output --partial "current"
  assert_output --partial "switch"
}

@test "fc fc-profile with no arguments shows usage" {
  run "$FC_COMMAND" fc-profile
  assert_success
  assert_output --partial "Usage: fc fc-profile"
}

@test "fc fc-profile --help shows examples" {
  run "$FC_COMMAND" fc-profile --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc fc-profile switch work"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc fc-profile list shows available profiles header" {
  run "$FC_COMMAND" fc-profile list
  assert_success
  assert_output --partial "Available profiles"
}

@test "fc fc-profile list shows work profile" {
  run "$FC_COMMAND" fc-profile list
  assert_success
  assert_output --partial "work"
}

@test "fc fc-profile list shows personal profile" {
  run "$FC_COMMAND" fc-profile list
  assert_success
  assert_output --partial "personal"
}

@test "fc fc-profile list shows switch hint" {
  run "$FC_COMMAND" fc-profile list
  assert_success
  assert_output --partial "fc fc-profile switch"
}

# ==============================================================================
# Current Subcommand Tests
# ==============================================================================

@test "fc fc-profile current runs successfully" {
  run "$FC_COMMAND" fc-profile current
  assert_success
}

@test "fc fc-profile current mentions base dotfiles when no profile active" {
  # This assumes no profile is active (which is the default state)
  run "$FC_COMMAND" fc-profile current
  assert_success
  # Should mention either the current profile or that no profile is active
  [[ "$output" =~ "Current profile" ]] || [[ "$output" =~ "No profile" ]]
}

# ==============================================================================
# Switch Subcommand Tests
# ==============================================================================

@test "fc fc-profile switch requires profile argument" {
  run "$FC_COMMAND" fc-profile switch
  assert_failure
  assert_output --partial "Usage: fc fc-profile switch"
}

@test "fc fc-profile switch fails for nonexistent profile" {
  run "$FC_COMMAND" fc-profile switch nonexistent_profile_xyz123
  assert_failure
  assert_output --partial "Profile not found"
}

@test "fc fc-profile switch fails for nonexistent profile with list hint" {
  run "$FC_COMMAND" fc-profile switch nonexistent_profile_xyz123
  assert_failure
  assert_output --partial "fc fc-profile list"
}

# ==============================================================================
# Directory Structure Tests
# ==============================================================================

@test "profiles/base directory exists" {
  [ -d "$PROJECT_ROOT/profiles/base" ]
}

@test "profiles/base/git directory exists" {
  [ -d "$PROJECT_ROOT/profiles/base/git" ]
}

@test "profiles/base/zsh directory exists" {
  [ -d "$PROJECT_ROOT/profiles/base/zsh" ]
}

@test "profiles/base/bash directory exists" {
  [ -d "$PROJECT_ROOT/profiles/base/bash" ]
}

@test "profiles/work directory exists" {
  [ -d "$PROJECT_ROOT/profiles/work" ]
}

@test "profiles/personal directory exists" {
  [ -d "$PROJECT_ROOT/profiles/personal" ]
}

@test "profiles/work has .gitconfig override" {
  [ -f "$PROJECT_ROOT/profiles/work/.gitconfig" ]
}

@test "profiles/personal has .gitconfig override" {
  [ -f "$PROJECT_ROOT/profiles/personal/.gitconfig" ]
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc fc-profile unknown subcommand fails" {
  run "$FC_COMMAND" fc-profile unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc fc-profile unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-profile unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}
