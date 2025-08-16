#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         helpers.bats
#
# DESCRIPTION:  This file contains unit tests for the functions in the
#               `lib/helpers.sh` script. It uses the Bats (Bash Automated
#               Testing System) framework.
#
# ==============================================================================

# --- Test Setup -------------------------------------------------------------
#
# The `setup` function is a special function that Bats runs before each
# test case in the file. It's the perfect place to load the script you want
# to test and set up any common environment for your tests.
#
setup() {
  # The `load` command is a Bats helper that sources a script file, making
  # its functions available to the test cases.
  # We use a relative path from the project root to load our helpers library.
  load '../lib/helpers.sh'
}

# --- Test Cases -------------------------------------------------------------
#
# Each test case is defined as a standard shell function and is decorated
# with the `@test` annotation. The string following `@test` is the
# description of the test, which is displayed when the test suite is run.
#

@test "logm() should print an INFO message correctly" {
  # The `run` command is the core of a Bats test. It executes the command
  # you provide and captures its exit status and output into special
  # variables: `$status` and `$output`.
  run logm "INFO" "This is an info message."

  # An assertion is a check that verifies the outcome of the `run` command.
  # If an assertion fails, the test case fails.

  # Assert that the command executed successfully (exit status 0).
  [ "$status" -eq 0 ]

  # Assert that the output contains the correct log level string.
  # We use `[[ ... ]]` for powerful string matching.
  [[ "$output" == *"[INFO]"* ]]

  # Assert that the output contains the correct message body.
  [[ "$output" == *"This is an info message."* ]]
}

@test "logm() should fail with an unknown message type" {
  # We run the function with an invalid log level.
  run logm "UNKNOWN" "This should not work."

  # Assert that the command failed (non-zero exit status).
  [ "$status" -ne 0 ]

  # Assert that the command printed an error message to standard error.
  # Bats captures standard error in the `$stderr` variable.
  [[ "$stderr" == *"Unknown message type: UNKNOWN"* ]]
}
