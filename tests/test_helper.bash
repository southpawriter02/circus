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
