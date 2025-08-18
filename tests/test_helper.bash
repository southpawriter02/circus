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

# NOTE: The test environment has issues with `bats-mock` interfering with the
# `brew` command, which makes it difficult to reliably get the `brew --prefix`.
# For now, we are hardcoding the path to the Homebrew library directory in the
# sandbox environment to ensure the tests can run.
BATS_LIB_PATH="/home/linuxbrew/.linuxbrew/lib"
if [ -d "$BATS_LIB_PATH" ]; then
    source "${BATS_LIB_PATH}/bats-support/load.bash"
    source "${BATS_LIB_PATH}/bats-assert/load.bash"
else
    # Fallback for other environments.
    load "bats-support/load"
    load "bats-assert/load"
fi

load "$PROJECT_ROOT/tests/helpers/bats-mock/stub.bash"

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
