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

# --- Test Cases for Wrapper Functions ---------------------------------------

@test "msg_info() should print an INFO message" {
  run msg_info "This is an info message."
  assert_success
  assert_output --partial "[INFO    ]"
  assert_output --partial "This is an info message."
}

@test "msg_success() should print a SUCCESS message" {
  run msg_success "This is a success message."
  assert_success
  assert_output --partial "[SUCCESS ]"
  assert_output --partial "This is a success message."
}

@test "msg_warning() should print a WARN message" {
  run msg_warning "This is a warning message."
  assert_success
  assert_output --partial "[WARN    ]"
  assert_output --partial "This is a warning message."
}

@test "msg_error() should print an ERROR message to stderr" {
  local stderr_file
  stderr_file=$(mktemp)
  # Run in a subshell to capture stderr separately
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; msg_error 'This is an error message' 2>'$stderr_file'"

  assert_success
  assert_output "" # stdout should be empty

  # Check the content of the stderr file
  run cat "$stderr_file"
  assert_output --partial "[ERROR   ]"
  assert_output --partial "This is an error message"
  rm "$stderr_file"
}

@test "msg_debug() should not print by default" {
  # Default log level is INFO, so DEBUG should be suppressed.
  run msg_debug "This is a debug message."
  assert_success
  assert_output ""
}

@test "msg_critical() should print a CRITICAL message to stderr" {
  local stderr_file
  stderr_file=$(mktemp)
  # Run in a subshell to capture stderr separately
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; msg_critical 'This is a critical message' 2>'$stderr_file'"

  assert_success
  assert_output "" # stdout should be empty

  # Check the content of the stderr file
  run cat "$stderr_file"
  assert_output --partial "[CRITICAL]"
  assert_output --partial "This is a critical message"
  rm "$stderr_file"
}

# --- Test Cases for Log Level Filtering -------------------------------------

@test "CONSOLE_LOG_LEVEL=WARN should only show WARN and above" {
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_WARN

  run msg_info "This is an info message."
  assert_success
  assert_output ""

  run msg_warning "This is a warning message."
  assert_success
  assert_output --partial "[WARN    ]"

  # msg_error prints to stderr
  local stderr_file
  stderr_file=$(mktemp)
  # Run in a subshell to capture stderr separately
  run bash -c "export CONSOLE_LOG_LEVEL=$LOG_LEVEL_WARN; source '$PROJECT_ROOT/lib/helpers.sh'; msg_error 'This is an error message.' 2>'$stderr_file'"
  assert_success
  assert_output "" # stdout should be empty

  run cat "$stderr_file"
  assert_output --partial "[ERROR   ]"
  rm "$stderr_file"
}

@test "CONSOLE_LOG_LEVEL=DEBUG should show all messages" {
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_DEBUG

  run msg_debug "This is a debug message."
  assert_success
  assert_output --partial "[DEBUG   ]"

  run msg_info "This is an info message."
  assert_success
  assert_output --partial "[INFO    ]"
}

# --- Test Cases for File Logging --------------------------------------------

teardown() {
  # Clean up the temporary log file after each test.
  rm -f /tmp/test.log
}

@test "LOG_FILE_PATH should write all messages to a file" {
  export LOG_FILE_PATH="/tmp/test.log"
  # Set console level high so we can ensure messages are logged to file
  # but not to the console.
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'File test'; msg_warning 'File warning'"

  # Nothing should be printed to the console.
  assert_success
  assert_output ""

  # The log file should exist and contain the messages.
  assert [ -f "$LOG_FILE_PATH" ]

  run cat "$LOG_FILE_PATH"
  assert_success
  assert_output --partial "[INFO] File test"
  assert_output --partial "[WARN] File warning"
}
