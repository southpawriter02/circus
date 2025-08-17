#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         shell_functions.bats
#
# DESCRIPTION:  This file contains unit tests for the custom shell functions
#               defined in profiles/sh/.shell_functions.
#
# ==============================================================================

# Load the new, unified test helper.
load 'test_helper'

# --- Test Setup -------------------------------------------------------------
setup() {
  # Use the $PROJECT_ROOT variable from the helper for robust path handling.
  load "$PROJECT_ROOT/profiles/sh/.shell_functions"

  # Mock the external commands used by the functions to isolate the tests.
  # This is a best practice for unit testing.
  stub mkdir
  stub cd
  stub unzip
  stub tar
  stub ipconfig
  stub curl
}

# ------------------------------------------------------------------------------
# Tests for mkcd()
# ------------------------------------------------------------------------------

@test "mkcd() should create a directory and cd into it" {
  run mkcd "test-dir"
  assert_success
  assert_stub_called_with mkdir -p "test-dir"
  assert_stub_called_with cd "test-dir"
}

# ------------------------------------------------------------------------------
# Tests for up()
# ------------------------------------------------------------------------------

@test "up() should default to one level" {
  run up
  assert_success
  assert_stub_called_with cd "../"
}

@test "up() should go up a specified number of levels" {
  run up 3
  assert_success
  assert_stub_called_with cd "../../../"
}

# ------------------------------------------------------------------------------
# Tests for extract()
# ------------------------------------------------------------------------------

@test "extract() should call unzip for .zip files" {
  run extract "archive.zip"
  assert_success
  assert_stub_called_with unzip "archive.zip"
}

@test "extract() should call tar for .tar.gz files" {
  run extract "archive.tar.gz"
  assert_success
  assert_stub_called_with tar xzf "archive.tar.gz"
}

@test "extract() should handle unknown file types gracefully" {
  run extract "archive.foo"
  assert_failure
  assert_output --partial "unknown archive format"
}

# ------------------------------------------------------------------------------
# Tests for myip()
# ------------------------------------------------------------------------------

@test "myip() should call ipconfig and curl" {
  run myip
  assert_success
  assert_stub_called_with ipconfig getifaddr en0
  assert_stub_called_with curl -s https://ipinfo.io/ip
}
