#!/usr/bin/env bats

# ==============================================================================
#
# BATS:         tests/fc_commands.bats
#
# DESCRIPTION:  This file contains integration tests for the `fc` command-line
#               interface and its subcommands.
#
# ==============================================================================

# --- Setup: Define the path to the main executable ---
setup() {
  FC_COMMAND="./bin/fc"
}

# ------------------------------------------------------------------------------
# Tests for the main `fc` command
# ------------------------------------------------------------------------------

@test "fc with no arguments should display the main help message" {
  run $FC_COMMAND

  # Assert that the command executed successfully.
  [ "$status" -eq 0 ]

  # Assert that the output contains the expected help text.
  [[ "$output" == *"Usage: fc <command>"* ]]
  [[ "$output" == *"Available commands:"* ]]
}

# ------------------------------------------------------------------------------
# Tests for `fc info`
# ------------------------------------------------------------------------------

@test "fc info should run successfully and print system information" {
  run $FC_COMMAND info

  [ "$status" -eq 0 ]

  # Assert that the output contains the expected section headers.
  [[ "$output" == *"Hardware Information"* ]]
  [[ "$output" == *"Software Information"* ]]
  [[ "$output" == *"Network Information"* ]]
}

# ------------------------------------------------------------------------------
# Tests for `fc bluetooth`
# ------------------------------------------------------------------------------

@test "fc bluetooth status should run successfully" {
  # This test just ensures the command runs without error.
  run $FC_COMMAND bluetooth status
  [ "$status" -eq 0 ]
}
