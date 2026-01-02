#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_ssh.bats
#
# DESCRIPTION:  Tests for the fc ssh command for SSH key management.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Create a temporary directory for test SSH keys
  export TEST_SSH_DIR
  TEST_SSH_DIR=$(mktemp -d)
}

teardown() {
  # Clean up temporary directory
  if [ -d "$TEST_SSH_DIR" ]; then
    rm -rf "$TEST_SSH_DIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc ssh --help shows usage information" {
  run "$FC_COMMAND" fc-ssh --help
  assert_success
  assert_output --partial "Usage: fc ssh"
}

@test "fc ssh --help shows all subcommands" {
  run "$FC_COMMAND" fc-ssh --help
  assert_success
  assert_output --partial "generate"
  assert_output --partial "add"
  assert_output --partial "copy"
  assert_output --partial "list"
}

@test "fc ssh --help shows examples" {
  run "$FC_COMMAND" fc-ssh --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc ssh generate"
}

@test "fc ssh with no subcommand shows usage" {
  run "$FC_COMMAND" fc-ssh
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Generate Subcommand Tests
# ==============================================================================

@test "fc ssh generate --help shows usage" {
  run "$FC_COMMAND" fc-ssh generate --help
  assert_success
  assert_output --partial "Usage: fc ssh generate"
  assert_output --partial "--email"
  assert_output --partial "--no-passphrase"
}

@test "fc ssh generate --help shows examples" {
  run "$FC_COMMAND" fc-ssh generate --help
  assert_success
  assert_output --partial "Examples:"
}

# ==============================================================================
# Add Subcommand Tests
# ==============================================================================

@test "fc ssh add --help shows usage" {
  run "$FC_COMMAND" fc-ssh add --help
  assert_success
  assert_output --partial "Usage: fc ssh add"
}

@test "fc ssh add without key name fails" {
  run "$FC_COMMAND" fc-ssh add
  assert_failure
  assert_output --partial "Usage:"
}

@test "fc ssh add with nonexistent key fails" {
  run "$FC_COMMAND" fc-ssh add nonexistent_key_12345
  assert_failure
  assert_output --partial "not found"
}

# ==============================================================================
# Copy Subcommand Tests
# ==============================================================================

@test "fc ssh copy --help shows usage" {
  run "$FC_COMMAND" fc-ssh copy --help
  assert_success
  assert_output --partial "Usage: fc ssh copy"
}

@test "fc ssh copy with nonexistent key fails" {
  run "$FC_COMMAND" fc-ssh copy nonexistent_key_12345
  assert_failure
  assert_output --partial "not found"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc ssh list --help shows usage" {
  run "$FC_COMMAND" fc-ssh list --help
  assert_success
  assert_output --partial "Usage: fc ssh list"
}

@test "fc ssh list runs without error" {
  run "$FC_COMMAND" fc-ssh list
  assert_success
  assert_output --partial "SSH Keys"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc ssh unknown subcommand fails" {
  run "$FC_COMMAND" fc-ssh unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc ssh unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-ssh unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

@test "fc ssh generate unknown option fails" {
  run "$FC_COMMAND" fc-ssh generate --unknown-option
  assert_failure
  assert_output --partial "Unknown option"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-ssh plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-ssh" ]
}

@test "fc-ssh plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-ssh" ]
}

@test "fc-ssh plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-ssh"
  assert_success
}

@test "fc-ssh plugin uses ssh-keygen" {
  run grep "ssh-keygen" "$PROJECT_ROOT/lib/plugins/fc-ssh"
  assert_success
}

@test "fc-ssh plugin uses ssh-add" {
  run grep "ssh-add" "$PROJECT_ROOT/lib/plugins/fc-ssh"
  assert_success
}

@test "fc-ssh plugin uses apple-use-keychain" {
  run grep "apple-use-keychain" "$PROJECT_ROOT/lib/plugins/fc-ssh"
  assert_success
}

# ==============================================================================
# Old Plugin Removal Tests
# ==============================================================================

@test "fc-ssh-keygen plugin no longer exists" {
  [ ! -f "$PROJECT_ROOT/lib/plugins/fc-ssh-keygen" ]
}
