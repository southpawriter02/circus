#!/usr/bin/env bats

# ==============================================================================
#
# BATS:         tests/shell_functions.bats
#
# DESCRIPTION:  This file contains unit tests for the custom shell functions
#               defined in profiles/sh/.shell_functions.
#
# ==============================================================================

# --- Setup: Load the script to be tested ---
setup() {
  # The `load` command is a Bats helper that sources a script file.
  load '../profiles/sh/.shell_functions'
}

# ------------------------------------------------------------------------------
# Tests for mkcd()
# ------------------------------------------------------------------------------

@test "mkcd() should create a directory and cd into it" {
  # We mock the `mkdir` and `cd` commands to test the logic.
  run mkcd "test-dir"

  # Assert that the command executed successfully.
  [ "$status" -eq 0 ]
  # Assert that the output contains the correct sequence of commands.
  [[ "$output" == *"mkdir -p test-dir"* ]]
  [[ "$output" == *"cd test-dir"* ]]
}

# ------------------------------------------------------------------------------
# Tests for up()
# ------------------------------------------------------------------------------

@test "up() should default to one level" {
  run up
  [ "$status" -eq 0 ]
  [[ "$output" == *"cd ../"* ]]
}

@test "up() should go up a specified number of levels" {
  run up 3
  [ "$status" -eq 0 ]
  [[ "$output" == *"cd ../../../"* ]]
}

# ------------------------------------------------------------------------------
# Tests for extract()
# ------------------------------------------------------------------------------

@test "extract() should call unzip for .zip files" {
  run extract "archive.zip"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unzip archive.zip"* ]]
}

@test "extract() should call tar for .tar.gz files" {
  run extract "archive.tar.gz"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tar xzf archive.tar.gz"* ]]
}

@test "extract() should handle unknown file types gracefully" {
  run extract "archive.foo"
  [ "$status" -ne 0 ] # Should fail
  [[ "$output" == *"unknown archive format"* ]]
}

# ------------------------------------------------------------------------------
# Tests for myip()
# ------------------------------------------------------------------------------

@test "myip() should call ipconfig and curl" {
  run myip
  [ "$status" -eq 0 ]
  [[ "$output" == *"ipconfig getifaddr en0"* ]]
  [[ "$output" == *"curl -s https://ipinfo.io/ip"* ]]
}
