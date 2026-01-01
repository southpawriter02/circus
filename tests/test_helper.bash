#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         test_helper.bash
#
# DESCRIPTION:  Test helper for the BATS testing framework. This file is
#               sourced by all .bats files and provides common setup,
#               teardown, and helper functions.
#
# ==============================================================================

# --- Project Root ---
# This sets a global variable that points to the root of our project.
# This is useful for sourcing scripts and accessing files within our tests.

export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# --- Load Support Libraries ---
# This loads the BATS support libraries, giving us access to powerful
# setup and teardown functions, as well as a rich set of assertions.

# Load the `bats-mock` library first, as it can interfere with other helpers
# if loaded after them.
load "$PROJECT_ROOT/tests/helpers/bats-mock/stub.bash"

# The BATS helper libraries (`bats-support` and `bats-assert`) have been
# copied into the `tests/helpers` directory to ensure the test suite is
# self-contained and avoids environment-related loading issues.
load "helpers/bats-support/load.bash"
load "helpers/bats-assert/load.bash"

# --- Setup & Teardown ---
# These functions run before and after each test case.
# You can use them to set up a clean environment for each test.

setup() {
  # Runs before each test case
  # Example: Create a temporary directory for testing file operations
  # export TMP_DIR=$(mktemp -d)
  echo "setup() from test_helper"
}

teardown() {
  # Runs after each test case
  # Clean up the mock bin directory to ensure stubs don't leak between tests.
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi
}

# ==============================================================================
# INSTALLER TEST HELPERS
# ==============================================================================

#
# @description Sets up a clean environment for installer stage tests.
#   Creates a temporary HOME directory, enables dry-run mode, and disables
#   interactive prompts to allow automated testing of installer stages.
#
# @usage Call from setup() in installer test files:
#   setup() {
#     setup_installer_test
#   }
#
setup_installer_test() {
  # Create a temporary HOME directory to avoid polluting the real one
  export INSTALLER_TEST_HOME=$(mktemp -d)
  export ORIGINAL_HOME="$HOME"
  export HOME="$INSTALLER_TEST_HOME"

  # Create required subdirectories
  mkdir -p "$INSTALLER_TEST_HOME/.circus"
  mkdir -p "$INSTALLER_TEST_HOME/.config"

  # Enable dry-run mode to prevent actual system changes
  export DRY_RUN_MODE=true

  # Disable interactive prompts
  export INTERACTIVE_MODE=false

  # Suppress console output during tests (log to file only)
  export CONSOLE_LOG_LEVEL=5  # CRITICAL only

  # Set up a test log file
  export LOG_FILE_PATH="$INSTALLER_TEST_HOME/test_install.log"

  # Disable paranoid mode (would suppress all output)
  export PARANOID_MODE=false

  # Source the initialization script to set up the environment
  source "$PROJECT_ROOT/lib/init.sh"
}

#
# @description Cleans up after installer stage tests.
#   Restores the original HOME directory and removes temporary files.
#
# @usage Call from teardown() in installer test files:
#   teardown() {
#     teardown_installer_test
#   }
#
teardown_installer_test() {
  # Restore original HOME
  if [ -n "$ORIGINAL_HOME" ]; then
    export HOME="$ORIGINAL_HOME"
  fi

  # Remove temporary test directory
  if [ -n "$INSTALLER_TEST_HOME" ] && [ -d "$INSTALLER_TEST_HOME" ]; then
    rm -rf "$INSTALLER_TEST_HOME"
  fi

  # Clean up mock bin directory (from parent teardown)
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi
}

#
# @description Runs a single installer stage script in isolation.
#   The stage is sourced after the init.sh environment is set up.
#
# @param $1 The stage filename (e.g., "00-preflight-checks.sh")
# @return The exit status of the stage script
#
# @usage
#   run_installer_stage "00-preflight-checks.sh"
#   assert_success
#
run_installer_stage() {
  local stage_file="$1"
  local stage_path="$PROJECT_ROOT/install/$stage_file"

  if [ ! -f "$stage_path" ]; then
    echo "Stage file not found: $stage_path" >&2
    return 1
  fi

  # Source the stage script (it should respect DRY_RUN_MODE)
  source "$stage_path"
}
