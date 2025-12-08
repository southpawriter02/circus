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
  assert_output --partial "Available Commands"
  assert_output --partial "info"
  assert_output --partial "bluetooth"
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
  # Force the script to think it's running on macOS so it uses sw_vers and sysctl
  export OS_NAME="Darwin"

  # Point directly to the stubs to avoid PATH issues
  export SW_VERS_CMD="$BATS_MOCK_BINDIR/sw_vers"
  export SYSCTL_CMD="$BATS_MOCK_BINDIR/sysctl"

  stub sw_vers \
    "-productName : echo macOS" \
    "-productVersion : echo 14.5" \
    "-buildVersion : echo 23F79"

  stub sysctl \
    "-n hw.model : echo MacBookPro18,1" \
    "-n machdep.cpu.brand_string : echo Apple M1 Pro" \
    "-n hw.memsize : echo 17179869184"

  run "$FC_COMMAND" info
  assert_success
  # The new UI format includes these values in a table
  assert_output --partial "14.5"
  assert_output --partial "Apple M1 Pro"
}

# --- `bluetooth` plugin ---
@test "Plugin 'bluetooth': should run successfully when blueutil is present" {
  # Stub the `blueutil` command to simulate its presence and output.
  export BLUEUTIL_CMD="$BATS_MOCK_BINDIR/blueutil"
  stub blueutil \
    "--power : echo 1"
  run "$FC_COMMAND" bluetooth status
  assert_success
  assert_output --partial "Bluetooth is currently on."
}

@test "Plugin 'bluetooth': should fail gracefully when blueutil is missing" {
  # Stub `command -v` to simulate the command not being found.
  stub "command -v blueutil" "return 1"
  run "$FC_COMMAND" bluetooth status
  assert_failure
  assert_output --partial "The 'blueutil' command is required but not found."
}

# --- `redis` plugin ---
@test "Plugin 'redis': should run successfully when brew is present" {
  # Stub the `brew` command to simulate its presence and output.
  export BREW_CMD="$BATS_MOCK_BINDIR/brew"
  stub brew \
    "services list : echo 'redis    started'"
  run "$FC_COMMAND" redis status
  assert_success
  assert_output --partial "redis    started"
}

@test "Plugin 'redis': should fail gracefully when brew is missing" {
  # Inject non-existent command
  export BREW_CMD="non-existent-brew-cmd"

  run "$FC_COMMAND" redis status
  assert_failure
  assert_output --partial "The 'brew' command is required but not found."
}

# --- `backup` plugin ---
@test "Plugin 'backup': should fail gracefully when rsync is missing" {
  touch ~/.zshrc
  # Inject a non-existent command to simulate missing dependency
  export RSYNC_CMD="non-existent-rsync-cmd"

  run "$FC_COMMAND" backup
  assert_failure
  assert_output --partial "This command requires 'rsync'. Please install it first."
}

# --- `sync` plugin ---
@test "Plugin 'sync': should fail gracefully when gpg is missing" {
  export GPG_RECIPIENT_ID="test-key"
  # Inject non-existent command
  export GPG_CMD="non-existent-gpg-cmd"

  run "$FC_COMMAND" sync backup
  assert_failure
  assert_output --partial "GPG is not installed."
  unset GPG_RECIPIENT_ID
}

@test "Plugin 'sync': should fail gracefully when rsync is missing" {
  export GPG_RECIPIENT_ID="test-key"
  # GPG exists (default), but rsync missing
  export RSYNC_CMD="non-existent-rsync-cmd"

  run "$FC_COMMAND" sync backup
  assert_failure
  assert_output --partial "This command requires 'rsync'. Please install it first."
  unset GPG_RECIPIENT_ID
}

@test "Plugin 'sync': should run successfully when dependencies are present" {
  export GPG_RECIPIENT_ID="test-key"
  touch ~/.zshrc

  # Inject dependencies
  export GPG_CMD="$BATS_MOCK_BINDIR/gpg"
  export RSYNC_CMD="$BATS_MOCK_BINDIR/rsync"
  export MKTEMP_CMD="$BATS_MOCK_BINDIR/mktemp"
  export TAR_CMD="$BATS_MOCK_BINDIR/tar"

  # Stub the commands
  stub gpg ": return 0"
  stub rsync ": return 0"
  stub mktemp ": echo '/tmp/backup-dir'"
  stub tar ": return 0"

  run "$FC_COMMAND" sync backup
  assert_success
  # Unset the variable to not affect other tests
  unset GPG_RECIPIENT_ID
}
