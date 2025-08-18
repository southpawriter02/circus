#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_commands.bats
#
# DESCRIPTION:  This file contains integration tests for the `fc` command-line
#               interface and its plugin-based architecture.
#
# ==============================================================================

# Load the unified test helper.
load 'test_helper'

# --- Test Setup -------------------------------------------------------------
setup() {
  # Define the path to the main fc executable.
  FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # For testing, we need to ensure the plugins are executable.
  # The user is expected to do this manually, but tests should be self-contained.
  chmod +x "$PROJECT_ROOT"/lib/plugins/*
}

# ------------------------------------------------------------------------------
# Tests for the Dispatcher Logic
# ------------------------------------------------------------------------------

@test "Dispatcher: should display a dynamic help message with available plugins" {
  run "$FC_COMMAND"
  assert_success
  assert_output --partial "Usage: fc <command>"
  assert_output --partial "Available commands:"
  # Check that some of our migrated plugins are listed.
  assert_output --partial "- info"
  assert_output --partial "- sync"
  assert_output --partial "- bluetooth"
}

@test "Dispatcher: should reject an unknown command" {
  run "$FC_COMMAND" "this-command-does-not-exist"
  # The dispatcher should exit with a non-zero status code.
  assert_failure
  assert_output --partial "Error: Unknown command 'this-command-does-not-exist'"
}

# ------------------------------------------------------------------------------
# Tests for Core Plugins
# ------------------------------------------------------------------------------

@test "Plugin 'info': should run successfully and print system information" {
  run "$FC_COMMAND" info
  assert_success
  # Check for section headers to confirm the script ran.
  assert_output --partial "Software:"
  assert_output --partial "Hardware:"
}

@test "Plugin 'bluetooth': should run successfully" {
  # This is a simple test to ensure the plugin can be executed.
  # We stub the actual `blueutil` command to avoid hardware interaction.
  stub blueutil
  run "$FC_COMMAND" bluetooth status
  assert_success
  assert_stub_called_with blueutil --power
}

@test "Plugin 'sync': should display usage when called with no subcommand" {
    run "$FC_COMMAND" sync
    assert_success # The sync script itself handles the no-subcommand case gracefully.
    assert_output --partial "Usage: fc sync <subcommand>"
    assert_output --partial "Manages the encrypted backup and restoration"
}
