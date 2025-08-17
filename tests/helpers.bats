#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         helpers.bats
#
# DESCRIPTION:  This file contains unit tests for the functions in the
#               `lib/helpers.sh` script.
#
# ==============================================================================

# Load the new, unified test helper.
load 'test_helper'

# --- Test Setup -------------------------------------------------------------
setup() {
  # Use the $PROJECT_ROOT variable from the helper for robust path handling.
  load "$PROJECT_ROOT/lib/helpers.sh"
}

# --- Test Cases for logm() --------------------------------------------------

@test "logm() should print an INFO message correctly" {
  run logm "INFO" "This is an info message."
  assert_success
  assert_output --partial "[INFO]"
  assert_output --partial "This is an info message."
}

@test "logm() should fail with an unknown message type" {
  run logm "UNKNOWN" "This should not work."
  assert_failure
  assert_stderr "Unknown message type: UNKNOWN"
}

# --- Test Cases for Wrapper Functions ---------------------------------------

@test "msg_info() should print an INFO message" {
  run msg_info "This is an info message."
  assert_success
  assert_output --partial "[INFO]"
  assert_output --partial "This is an info message."
}

@test "msg_success() should print a SUCCESS message" {
  run msg_success "This is a success message."
  assert_success
  assert_output --partial "[SUCCESS]"
  assert_output --partial "This is a success message."
}

@test "msg_warning() should print a WARN message" {
  run msg_warning "This is a warning message."
  assert_success
  assert_output --partial "[WARN]"
  assert_output --partial "This is a warning message."
}

@test "msg_error() should print an ERROR message to stderr" {
  run msg_error "This is an error message."
  assert_success # The function itself doesn't exit with an error
  assert_output "" # Stdout should be empty
  assert_stderr --partial "[ERROR]"
  assert_stderr --partial "This is an error message."
}
