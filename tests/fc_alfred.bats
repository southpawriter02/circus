#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_alfred.bats
#
# DESCRIPTION:  Tests for the fc alfred command and Alfred workflow.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export WORKFLOW_DIR="$PROJECT_ROOT/etc/alfred/workflows/Flying Circus"
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc alfred --help shows usage information" {
  run "$FC_COMMAND" fc-alfred --help
  assert_success
  assert_output --partial "Usage: fc alfred"
}

@test "fc alfred --help shows actions" {
  run "$FC_COMMAND" fc-alfred --help
  assert_success
  assert_output --partial "install"
  assert_output --partial "uninstall"
  assert_output --partial "status"
}

@test "fc alfred --help shows available keywords" {
  run "$FC_COMMAND" fc-alfred --help
  assert_success
  assert_output --partial "wifi"
  assert_output --partial "bluetooth"
  assert_output --partial "lock"
  assert_output --partial "caffeine"
}

@test "fc alfred with no action shows usage" {
  run "$FC_COMMAND" fc-alfred
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-alfred plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-alfred" ]
}

@test "fc-alfred plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-alfred" ]
}

@test "fc-alfred plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-alfred"
  assert_success
}

# ==============================================================================
# Workflow Structure Tests
# ==============================================================================

@test "workflow source directory exists" {
  [ -d "$WORKFLOW_DIR" ]
}

@test "workflow info.plist exists" {
  [ -f "$WORKFLOW_DIR/info.plist" ]
}

@test "workflow scripts directory exists" {
  [ -d "$WORKFLOW_DIR/scripts" ]
}

@test "workflow fc-wrapper.sh exists" {
  [ -f "$WORKFLOW_DIR/scripts/fc-wrapper.sh" ]
}

@test "workflow fc-wrapper.sh is executable" {
  [ -x "$WORKFLOW_DIR/scripts/fc-wrapper.sh" ]
}

# ==============================================================================
# Script Filter Tests
# ==============================================================================

@test "wifi.sh script filter exists" {
  [ -f "$WORKFLOW_DIR/scripts/wifi.sh" ]
}

@test "wifi.sh script filter is executable" {
  [ -x "$WORKFLOW_DIR/scripts/wifi.sh" ]
}

@test "wifi.sh outputs valid JSON" {
  run "$WORKFLOW_DIR/scripts/wifi.sh"
  assert_success
  # Check for JSON structure
  assert_output --partial '"items"'
  assert_output --partial '"uid"'
  assert_output --partial '"title"'
}

@test "bluetooth.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/bluetooth.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/bluetooth.sh" ]
}

@test "bluetooth.sh outputs valid JSON" {
  run "$WORKFLOW_DIR/scripts/bluetooth.sh"
  assert_success
  assert_output --partial '"items"'
}

@test "caffeine.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/caffeine.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/caffeine.sh" ]
}

@test "caffeine.sh outputs valid JSON" {
  run "$WORKFLOW_DIR/scripts/caffeine.sh"
  assert_success
  assert_output --partial '"items"'
}

@test "dns.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/dns.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/dns.sh" ]
}

@test "dns.sh outputs valid JSON" {
  run "$WORKFLOW_DIR/scripts/dns.sh"
  assert_success
  assert_output --partial '"items"'
}

@test "airdrop.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/airdrop.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/airdrop.sh" ]
}

@test "disk.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/disk.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/disk.sh" ]
}

@test "ssh.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/ssh.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/ssh.sh" ]
}

@test "keychain.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/keychain.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/keychain.sh" ]
}

@test "clipboard.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/clipboard.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/clipboard.sh" ]
}

@test "fc-commands.sh script filter exists and is executable" {
  [ -f "$WORKFLOW_DIR/scripts/fc-commands.sh" ]
  [ -x "$WORKFLOW_DIR/scripts/fc-commands.sh" ]
}

# ==============================================================================
# info.plist Validation Tests
# ==============================================================================

@test "info.plist has correct bundle ID" {
  run /usr/libexec/PlistBuddy -c "Print :bundleid" "$WORKFLOW_DIR/info.plist"
  assert_success
  assert_output "com.flyingcircus.alfred"
}

@test "info.plist has workflow name" {
  run /usr/libexec/PlistBuddy -c "Print :name" "$WORKFLOW_DIR/info.plist"
  assert_success
  assert_output "Flying Circus"
}

@test "info.plist has version" {
  run /usr/libexec/PlistBuddy -c "Print :version" "$WORKFLOW_DIR/info.plist"
  assert_success
  assert_output "1.0.0"
}

@test "info.plist has description" {
  run /usr/libexec/PlistBuddy -c "Print :description" "$WORKFLOW_DIR/info.plist"
  assert_success
  assert_output --partial "fc"
}

# ==============================================================================
# Status Command Tests
# ==============================================================================

@test "fc alfred status runs and outputs status" {
  run "$FC_COMMAND" fc-alfred status
  # May fail if Alfred is not installed, but should still show output
  assert_output --partial "Alfred"
}

@test "fc alfred status shows workflow check" {
  run "$FC_COMMAND" fc-alfred status
  # Output should mention workflow status (installed or not)
  assert_output --partial "Workflow"
}

# ==============================================================================
# Unknown Action Tests
# ==============================================================================

@test "fc alfred unknown action fails" {
  run "$FC_COMMAND" fc-alfred unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc alfred unknown action shows help hint" {
  run "$FC_COMMAND" fc-alfred unknown_action
  assert_failure
  assert_output --partial "--help"
}
