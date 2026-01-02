#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_dotfiles.bats
#
# DESCRIPTION:  Tests for the fc fc-dotfiles command including add, list,
#               and edit subcommands.
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

@test "fc fc-dotfiles --help shows usage information" {
  run "$FC_COMMAND" fc-dotfiles --help
  assert_success
  assert_output --partial "Usage: fc fc-dotfiles"
  assert_output --partial "add"
  assert_output --partial "list"
  assert_output --partial "edit"
}

@test "fc fc-dotfiles --help shows examples" {
  run "$FC_COMMAND" fc-dotfiles --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial ".vimrc"
}

@test "fc fc-dotfiles with no arguments shows help" {
  run "$FC_COMMAND" fc-dotfiles
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc fc-dotfiles list runs successfully" {
  run "$FC_COMMAND" fc-dotfiles list
  assert_success
  assert_output --partial "Managed dotfiles:"
}

@test "fc fc-dotfiles list shows bash directory files" {
  run "$FC_COMMAND" fc-dotfiles list
  assert_success
  assert_output --partial "bash/"
}

@test "fc fc-dotfiles list shows git directory files" {
  run "$FC_COMMAND" fc-dotfiles list
  assert_success
  assert_output --partial "git/"
}

@test "fc fc-dotfiles list shows zsh directory files" {
  run "$FC_COMMAND" fc-dotfiles list
  assert_success
  assert_output --partial "zsh/"
}

# ==============================================================================
# Add Subcommand Tests
# ==============================================================================

@test "fc fc-dotfiles add requires file argument" {
  run "$FC_COMMAND" fc-dotfiles add
  assert_failure
  assert_output --partial "Usage:"
}

@test "fc fc-dotfiles add fails for nonexistent file" {
  run "$FC_COMMAND" fc-dotfiles add /nonexistent/file/path
  assert_failure
  assert_output --partial "not found"
}

@test "fc fc-dotfiles add fails for symlink" {
  # Create a symlink to test
  local test_file="$TEST_TEMP_DIR/testfile"
  local test_link="$TEST_TEMP_DIR/testlink"
  echo "test content" > "$test_file"
  ln -s "$test_file" "$test_link"

  run "$FC_COMMAND" fc-dotfiles add "$test_link"
  assert_failure
  assert_output --partial "already a symlink"
}

# ==============================================================================
# Edit Subcommand Tests
# ==============================================================================

@test "fc fc-dotfiles edit requires name argument" {
  run "$FC_COMMAND" fc-dotfiles edit
  assert_failure
  assert_output --partial "Usage:"
}

@test "fc fc-dotfiles edit fails for nonexistent dotfile" {
  run "$FC_COMMAND" fc-dotfiles edit "nonexistent_dotfile_xyz123"
  assert_failure
  assert_output --partial "No dotfile found"
}

# ==============================================================================
# Unknown Subcommand Tests
# ==============================================================================

@test "fc fc-dotfiles with unknown subcommand shows error" {
  run "$FC_COMMAND" fc-dotfiles unknown-subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

# ==============================================================================
# Profiles Directory Tests
# ==============================================================================

@test "profiles directory exists" {
  assert [ -d "$PROJECT_ROOT/profiles" ]
}

@test "profiles/base directory exists" {
  assert [ -d "$PROJECT_ROOT/profiles/base" ]
}

@test "profiles/base/bash directory exists" {
  assert [ -d "$PROJECT_ROOT/profiles/base/bash" ]
}

@test "profiles/base/git directory exists" {
  assert [ -d "$PROJECT_ROOT/profiles/base/git" ]
}

@test "profiles/base/zsh directory exists" {
  assert [ -d "$PROJECT_ROOT/profiles/base/zsh" ]
}
