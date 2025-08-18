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
}

# ------------------------------------------------------------------------------
# Tests for the Dispatcher Logic
# ------------------------------------------------------------------------------

@test "Dispatcher: should display a dynamic help message with available plugins" {
  run "$FC_COMMAND"
  assert_success
  assert_output --partial "Usage: fc [global options] <command> [command options]"
  assert_output --partial "Available commands:"
  assert_output --partial "fc-info"
  assert_output --partial "fc-bluetooth"
}

@test "Dispatcher: should fail gracefully for an unknown command" {
  run "$FC_COMMAND" "this-command-does-not-exist"
  assert_failure
  # Check for the standardized error message from our `die` function.
  assert_output --partial "Unknown command 'this-command-does-not-exist'"
}

# ------------------------------------------------------------------------------
# Tests for Core Plugin Success and Failure Cases
# ------------------------------------------------------------------------------

# --- `info` plugin ---
@test "Plugin 'info': should run successfully" {
  stub sw_vers "-productName : echo 'macOS'; -productVersion : echo '12.0'; -buildVersion : echo '21A559'"
  stub sysctl "hw.model: echo 'MacBookPro18,1'; machdep.cpu.brand_string: echo 'Apple M1 Pro'; hw.memsize: echo '17179869184'"
  run "$FC_COMMAND" fc-info
  assert_success
  assert_output --partial "macOS"
  assert_output --partial "MacBookPro18,1"
}

# --- `bluetooth` plugin ---
@test "Plugin 'bluetooth': should run successfully when blueutil is present" {
  # Stub the `blueutil` command to simulate its presence and output.
  stub blueutil "--power : echo 1"
  run "$FC_COMMAND" fc-bluetooth status
  assert_success
  assert_output --partial "Bluetooth is On"
}

@test "Plugin 'bluetooth': should fail gracefully when blueutil is missing" {
  # The `command -v` check in the plugin should fail.
  PATH="" run "$FC_COMMAND" fc-bluetooth status
  assert_failure
  assert_output --partial "[ERROR   ] The 'blueutil' command is required but not found."
}

# --- `redis` plugin ---
@test "Plugin 'redis': should run successfully when brew is present" {
  # Stub the `brew` command to simulate its presence and output.
  stub brew "services list : echo 'redis started'"
  run "$FC_COMMAND" fc-redis status
  assert_success
  assert_output --partial "redis started"
}

@test "Plugin 'redis': should fail gracefully when brew is missing" {
  # Un-stub `brew` and ensure it's not in the PATH for this test.
  unstub brew
  PATH="" run "$FC_COMMAND" fc-redis status
  assert_failure
  assert_output --partial "[ERROR   ] The 'brew' command is required but not found."
}

# --- `sync` plugin ---
@test "Plugin 'sync': should run successfully" {
  stub gpg
  run "$FC_COMMAND" fc-sync backup
  assert_success
}
