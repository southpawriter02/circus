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

@test "CONSOLE_LOG_LEVEL=SUCCESS should filter DEBUG and INFO" {
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_SUCCESS

  run msg_debug "This is a debug message."
  assert_success
  assert_output ""

  run msg_info "This is an info message."
  assert_success
  assert_output ""

  run msg_success "This is a success message."
  assert_success
  assert_output --partial "[SUCCESS ]"
}

@test "CONSOLE_LOG_LEVEL=CRITICAL should filter everything except CRITICAL" {
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  run msg_info "This is an info message."
  assert_success
  assert_output ""

  run msg_warning "This is a warning message."
  assert_success
  assert_output ""

  # CRITICAL goes to stderr, capture separately
  local stderr_file
  stderr_file=$(mktemp)
  run bash -c "export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL; source '$PROJECT_ROOT/lib/helpers.sh'; msg_critical 'Critical message' 2>'$stderr_file'"
  assert_success
  assert_output ""

  run cat "$stderr_file"
  assert_output --partial "[CRITICAL]"
  rm "$stderr_file"
}

@test "LOG_FILE_PATH should write messages with correct timestamp format" {
  export LOG_FILE_PATH="/tmp/test.log"
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'Timestamp test'"

  assert_success
  assert [ -f "$LOG_FILE_PATH" ]

  # Verify timestamp format: [YYYY-MM-DD HH:MM:SS]
  run grep -E '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]' "$LOG_FILE_PATH"
  assert_success
  assert_output --partial "[INFO] Timestamp test"
}

@test "LOG_FILE_PATH should append to existing log file" {
  export LOG_FILE_PATH="/tmp/test.log"
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  # Write first message
  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'First message'"
  assert_success

  # Write second message
  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'Second message'"
  assert_success

  # Both messages should be in the log
  run cat "$LOG_FILE_PATH"
  assert_output --partial "First message"
  assert_output --partial "Second message"
}

# --- Test Cases for Log Rotation ----------------------------------------------

@test "Log rotation should rotate when file exceeds max size" {
  export LOG_FILE_PATH="/tmp/test_rotation.log"
  export LOG_MAX_SIZE=100  # Very small for testing (100 bytes)
  export LOG_ROTATE_COUNT=2
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  # Create a log file that exceeds the limit
  head -c 150 /dev/zero | tr '\0' 'x' > "$LOG_FILE_PATH"

  # Write a new message - should trigger rotation
  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'After rotation'"
  assert_success

  # Original file should be rotated to .1
  assert [ -f "${LOG_FILE_PATH}.1" ]

  # New log file should exist with the new message
  assert [ -f "$LOG_FILE_PATH" ]
  run cat "$LOG_FILE_PATH"
  assert_output --partial "After rotation"

  # Clean up
  rm -f "$LOG_FILE_PATH" "${LOG_FILE_PATH}.1" "${LOG_FILE_PATH}.2"
}

@test "Log rotation should shift existing rotated files" {
  export LOG_FILE_PATH="/tmp/test_rotation.log"
  export LOG_MAX_SIZE=50
  export LOG_ROTATE_COUNT=3
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  # Create initial .1 file
  echo "original .1 content" > "${LOG_FILE_PATH}.1"

  # Create a log file that exceeds the limit
  head -c 100 /dev/zero | tr '\0' 'x' > "$LOG_FILE_PATH"

  # Write a new message - should trigger rotation
  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'New message'"
  assert_success

  # .1 should have been shifted to .2
  assert [ -f "${LOG_FILE_PATH}.2" ]
  run cat "${LOG_FILE_PATH}.2"
  assert_output "original .1 content"

  # Current log should now be .1
  assert [ -f "${LOG_FILE_PATH}.1" ]

  # New log file should have the new message
  run cat "$LOG_FILE_PATH"
  assert_output --partial "New message"

  # Clean up
  rm -f "$LOG_FILE_PATH" "${LOG_FILE_PATH}.1" "${LOG_FILE_PATH}.2" "${LOG_FILE_PATH}.3"
}

@test "Log rotation should not rotate when file is under max size" {
  export LOG_FILE_PATH="/tmp/test_rotation.log"
  export LOG_MAX_SIZE=10000  # Large enough that we won't exceed it
  export LOG_ROTATE_COUNT=2
  export CONSOLE_LOG_LEVEL=$LOG_LEVEL_CRITICAL

  # Create a small log file
  echo "small content" > "$LOG_FILE_PATH"

  # Write a new message - should NOT trigger rotation
  run bash -c ". '$PROJECT_ROOT/lib/helpers.sh'; msg_info 'Additional message'"
  assert_success

  # No rotation should have occurred
  assert [ ! -f "${LOG_FILE_PATH}.1" ]

  # Both messages should be in the same file
  run cat "$LOG_FILE_PATH"
  assert_output --partial "small content"
  assert_output --partial "Additional message"

  # Clean up
  rm -f "$LOG_FILE_PATH"
}
