#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_commands.bats
#
# DESCRIPTION:  This file contains integration tests for the `fc` command-line
#               interface, its plugin-based architecture, and its error
#               handling capabilities.
#
# ==============================================================================

# Load the unified test helper.
load 'test_helper'

# --- Test Setup ---------------------------------------------------------------
setup() {
  # Define the path to the main fc executable.
  FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Ensure the plugins are executable for the tests.
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
  assert_output --partial "- info"
  assert_output --partial "- bluetooth"
}

@test "Dispatcher: should fail gracefully for an unknown command" {
  run "$FC_COMMAND" "this-command-does-not-exist"
  assert_failure
  # Check for the standardized error message from our `die` function.
  assert_output --partial "[ERROR   ] Unknown command 'this-command-does-not-exist'."
}

# ------------------------------------------------------------------------------
# Tests for Core Plugin Success and Failure Cases
# ------------------------------------------------------------------------------

# --- `info` plugin ---
@test "Plugin 'info': should run successfully" {
  run "$FC_COMMAND" info
  assert_success
  assert_output --partial "Software:"
  assert_output --partial "Hardware:"
}

# --- `bluetooth` plugin ---
@test "Plugin 'bluetooth': should run successfully when blueutil is present" {
  # Stub the `blueutil` command to simulate its presence.
  stub blueutil
  run "$FC_COMMAND" bluetooth status
  assert_success
  assert_stub_called_with blueutil --power
}

@test "Plugin 'bluetooth': should fail gracefully when blueutil is missing" {
  # Un-stub `blueutil` and ensure it's not in the PATH for this test.
  # The `command -v` check in the plugin should fail.
  unstub blueutil
  PATH="" run "$FC_COMMAND" bluetooth status
  assert_failure
  assert_output --partial "[ERROR   ] The 'blueutil' command is required but not found."
}

# --- `redis` plugin ---
@test "Plugin 'redis': should run successfully when brew is present" {
  # Stub the `brew` command to simulate its presence.
  stub brew
  run "$FC_COMMAND" redis status
  assert_success
  assert_stub_called_with brew services list
}

@test "Plugin 'redis': should fail gracefully when brew is missing" {
  # Un-stub `brew` and ensure it's not in the PATH for this test.
  unstub brew
  PATH="" run "$FC_COMMAND" redis status
  assert_failure
  assert_output --partial "[ERROR   ] The 'brew' command is required but not found."
}

# --- `sync` plugin ---
@test "Plugin 'sync': should fail gracefully when gpg is missing" {
  unstub gpg
  PATH="" run "$FC_COMMAND" sync backup
  assert_failure
  assert_output --partial "[ERROR   ] GPG is not installed."
}
