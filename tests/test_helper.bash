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

# --- Load Support Libraries ---
# This loads the BATS support libraries, giving us access to powerful
# setup and teardown functions, as well as a rich set of assertions.

load '/usr/local/lib/bats-support/load.bash'
load '/usr/local/lib/bats-assert/load.bash'

# --- Project Root ---
# This sets a global variable that points to the root of our project.
# This is useful for sourcing scripts and accessing files within our tests.

export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

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
  # Example: Clean up the temporary directory
  # rm -rf "$TMP_DIR"
  echo "teardown() from test_helper"
}
