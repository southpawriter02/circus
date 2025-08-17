#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         helpers.bats
#
# DESCRIPTION:  This file contains unit tests for the functions in the
#               `lib/helpers.sh` script.
#
# ==============================================================================

# --- Test Setup -------------------------------------------------------------
setup() {
  load '../lib/helpers.sh'
}

# --- Test Cases for logm() --------------------------------------------------

@test "logm() should print an INFO message correctly" {
  run logm "INFO" "This is an info message."
  [ "$status" -eq 0 ]
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"This is an info message."* ]]
}

@test "logm() should fail with an unknown message type" {
  run logm "UNKNOWN" "This should not work."
  [ "$status" -ne 0 ]
  [[ "$stderr" == *"Unknown message type: UNKNOWN"* ]]
}

# --- Test Cases for Wrapper Functions ---------------------------------------

@test "msg_info() should print an INFO message" {
  run msg_info "This is an info message."
  [ "$status" -eq 0 ]
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"This is an info message."* ]]
}

@test "msg_success() should print a SUCCESS message" {
  run msg_success "This is a success message."
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SUCCESS]"* ]]
  [[ "$output" == *"This is a success message."* ]]
}

@test "msg_warning() should print a WARN message" {
  run msg_warning "This is a warning message."
  [ "$status" -eq 0 ]
  [[ "$output" == *"[WARN]"* ]]
  [[ "$output" == *"This is a warning message."* ]]
}

@test "msg_error() should print an ERROR message to stderr" {
  run msg_error "This is an error message."
  [ "$status" -eq 0 ] # The function itself doesn't exit with an error
  # Verify the output went to stderr, not stdout
  [ -z "$output" ]
  [[ "$stderr" == *"[ERROR]"* ]]
  [[ "$stderr" == *"This is an error message."* ]]
}
