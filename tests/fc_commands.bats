#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_commands.bats
#
# DESCRIPTION:  This file contains integration tests for the `fc` command-line
#               interface and its subcommands.
#
# ==============================================================================

# Load the new, unified test helper.
load 'test_helper'

# --- Test Setup -------------------------------------------------------------
setup() {
  # Use the $PROJECT_ROOT variable from the helper for robust path handling.
  FC_COMMAND="$PROJECT_ROOT/bin/fc"
}

# ------------------------------------------------------------------------------
# Tests for the main `fc` command
# ------------------------------------------------------------------------------

@test "fc with no arguments should display the main help message" {
  run "$FC_COMMAND"
  assert_success
  assert_output --partial "Usage: fc <command>"
  assert_output --partial "Available commands:"
}

# ------------------------------------------------------------------------------
# Tests for `fc info`
# ------------------------------------------------------------------------------

@test "fc info should run successfully and print system information" {
  run "$FC_COMMAND" info
  assert_success
  assert_output --partial "Hardware Information"
  assert_output --partial "Software Information"
  assert_output --partial "Network Information"
}

# ------------------------------------------------------------------------------
# Tests for `fc bluetooth`
# ------------------------------------------------------------------------------

@test "fc bluetooth status should run successfully" {
  # This test just ensures the command runs without error.
  run "$FC_COMMAND" bluetooth status
  assert_success
}
