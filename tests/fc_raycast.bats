#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_raycast.bats
#
# DESCRIPTION:  Tests for the fc raycast command and Raycast script commands.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.."; pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export SCRIPTS_DIR="$PROJECT_ROOT/etc/raycast/scripts"
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc raycast --help shows usage information" {
  run "$FC_COMMAND" fc-raycast --help
  assert_success
  assert_output --partial "Usage: fc raycast"
}

@test "fc raycast --help shows actions" {
  run "$FC_COMMAND" fc-raycast --help
  assert_success
  assert_output --partial "install"
  assert_output --partial "uninstall"
  assert_output --partial "status"
}

@test "fc raycast --help shows available commands" {
  run "$FC_COMMAND" fc-raycast --help
  assert_success
  assert_output --partial "Wi-Fi"
  assert_output --partial "Bluetooth"
  assert_output --partial "Lock"
  assert_output --partial "Caffeine"
}

@test "fc raycast with no action shows usage" {
  run "$FC_COMMAND" fc-raycast
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-raycast plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-raycast" ]
}

@test "fc-raycast plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-raycast" ]
}

@test "fc-raycast plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-raycast"
  assert_success
}

# ==============================================================================
# Script Commands Directory Tests
# ==============================================================================

@test "raycast scripts directory exists" {
  [ -d "$SCRIPTS_DIR" ]
}

@test "fc-env.sh exists" {
  [ -f "$SCRIPTS_DIR/fc-env.sh" ]
}

@test "fc-env.sh is executable" {
  [ -x "$SCRIPTS_DIR/fc-env.sh" ]
}

@test "fc-env.sh has DOTFILES_ROOT placeholder" {
  run grep "__DOTFILES_ROOT__" "$SCRIPTS_DIR/fc-env.sh"
  assert_success
}

# ==============================================================================
# Wi-Fi Script Tests
# ==============================================================================

@test "wifi-on.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/wifi-on.sh" ]
  [ -x "$SCRIPTS_DIR/wifi-on.sh" ]
}

@test "wifi-on.sh has required Raycast metadata" {
  run grep "@raycast.schemaVersion" "$SCRIPTS_DIR/wifi-on.sh"
  assert_success
  run grep "@raycast.title" "$SCRIPTS_DIR/wifi-on.sh"
  assert_success
  run grep "@raycast.mode" "$SCRIPTS_DIR/wifi-on.sh"
  assert_success
}

@test "wifi-off.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/wifi-off.sh" ]
  [ -x "$SCRIPTS_DIR/wifi-off.sh" ]
}

@test "wifi-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/wifi-status.sh" ]
  [ -x "$SCRIPTS_DIR/wifi-status.sh" ]
}

# ==============================================================================
# Bluetooth Script Tests
# ==============================================================================

@test "bluetooth-on.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/bluetooth-on.sh" ]
  [ -x "$SCRIPTS_DIR/bluetooth-on.sh" ]
}

@test "bluetooth-off.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/bluetooth-off.sh" ]
  [ -x "$SCRIPTS_DIR/bluetooth-off.sh" ]
}

@test "bluetooth-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/bluetooth-status.sh" ]
  [ -x "$SCRIPTS_DIR/bluetooth-status.sh" ]
}

# ==============================================================================
# Lock Screen Script Tests
# ==============================================================================

@test "lock-screen.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/lock-screen.sh" ]
  [ -x "$SCRIPTS_DIR/lock-screen.sh" ]
}

@test "lock-screen.sh uses silent mode" {
  run grep "@raycast.mode silent" "$SCRIPTS_DIR/lock-screen.sh"
  assert_success
}

# ==============================================================================
# Caffeine Script Tests
# ==============================================================================

@test "caffeine-on.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/caffeine-on.sh" ]
  [ -x "$SCRIPTS_DIR/caffeine-on.sh" ]
}

@test "caffeine-off.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/caffeine-off.sh" ]
  [ -x "$SCRIPTS_DIR/caffeine-off.sh" ]
}

@test "caffeine-30min.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/caffeine-30min.sh" ]
  [ -x "$SCRIPTS_DIR/caffeine-30min.sh" ]
}

@test "caffeine-60min.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/caffeine-60min.sh" ]
  [ -x "$SCRIPTS_DIR/caffeine-60min.sh" ]
}

@test "caffeine-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/caffeine-status.sh" ]
  [ -x "$SCRIPTS_DIR/caffeine-status.sh" ]
}

# ==============================================================================
# DNS Script Tests
# ==============================================================================

@test "dns-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/dns-status.sh" ]
  [ -x "$SCRIPTS_DIR/dns-status.sh" ]
}

@test "dns-cloudflare.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/dns-cloudflare.sh" ]
  [ -x "$SCRIPTS_DIR/dns-cloudflare.sh" ]
}

@test "dns-google.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/dns-google.sh" ]
  [ -x "$SCRIPTS_DIR/dns-google.sh" ]
}

@test "dns-quad9.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/dns-quad9.sh" ]
  [ -x "$SCRIPTS_DIR/dns-quad9.sh" ]
}

@test "dns-clear.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/dns-clear.sh" ]
  [ -x "$SCRIPTS_DIR/dns-clear.sh" ]
}

# ==============================================================================
# AirDrop Script Tests
# ==============================================================================

@test "airdrop-everyone.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/airdrop-everyone.sh" ]
  [ -x "$SCRIPTS_DIR/airdrop-everyone.sh" ]
}

@test "airdrop-contacts.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/airdrop-contacts.sh" ]
  [ -x "$SCRIPTS_DIR/airdrop-contacts.sh" ]
}

@test "airdrop-off.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/airdrop-off.sh" ]
  [ -x "$SCRIPTS_DIR/airdrop-off.sh" ]
}

@test "airdrop-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/airdrop-status.sh" ]
  [ -x "$SCRIPTS_DIR/airdrop-status.sh" ]
}

# ==============================================================================
# System Script Tests
# ==============================================================================

@test "system-info.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/system-info.sh" ]
  [ -x "$SCRIPTS_DIR/system-info.sh" ]
}

@test "system-info.sh uses fullOutput mode" {
  run grep "@raycast.mode fullOutput" "$SCRIPTS_DIR/system-info.sh"
  assert_success
}

@test "system-healthcheck.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/system-healthcheck.sh" ]
  [ -x "$SCRIPTS_DIR/system-healthcheck.sh" ]
}

@test "system-healthcheck.sh uses fullOutput mode" {
  run grep "@raycast.mode fullOutput" "$SCRIPTS_DIR/system-healthcheck.sh"
  assert_success
}

# ==============================================================================
# Disk Script Tests
# ==============================================================================

@test "disk-status.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/disk-status.sh" ]
  [ -x "$SCRIPTS_DIR/disk-status.sh" ]
}

@test "disk-usage.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/disk-usage.sh" ]
  [ -x "$SCRIPTS_DIR/disk-usage.sh" ]
}

# ==============================================================================
# SSH Script Tests
# ==============================================================================

@test "ssh-list.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/ssh-list.sh" ]
  [ -x "$SCRIPTS_DIR/ssh-list.sh" ]
}

@test "ssh-copy-default.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/ssh-copy-default.sh" ]
  [ -x "$SCRIPTS_DIR/ssh-copy-default.sh" ]
}

# ==============================================================================
# Clipboard Script Tests
# ==============================================================================

@test "clipboard-clear.sh exists and is executable" {
  [ -f "$SCRIPTS_DIR/clipboard-clear.sh" ]
  [ -x "$SCRIPTS_DIR/clipboard-clear.sh" ]
}

# ==============================================================================
# Raycast Metadata Validation Tests
# ==============================================================================

@test "all scripts have Flying Circus package name" {
  for script in "$SCRIPTS_DIR"/*.sh; do
    if [[ "$(basename "$script")" != "fc-env.sh" ]]; then
      run grep "@raycast.packageName Flying Circus" "$script"
      assert_success
    fi
  done
}

@test "all scripts source fc-env.sh" {
  for script in "$SCRIPTS_DIR"/*.sh; do
    if [[ "$(basename "$script")" != "fc-env.sh" ]]; then
      run grep 'source.*fc-env.sh' "$script"
      assert_success
    fi
  done
}

# ==============================================================================
# Status Command Tests
# ==============================================================================

@test "fc raycast status runs and outputs status" {
  run "$FC_COMMAND" fc-raycast status
  # May fail if Raycast is not installed, but should still show output
  assert_output --partial "Raycast"
}

@test "fc raycast status shows scripts check" {
  run "$FC_COMMAND" fc-raycast status
  # Output should mention scripts status (installed or not)
  assert_output --partial "Scripts"
}

# ==============================================================================
# Unknown Action Tests
# ==============================================================================

@test "fc raycast unknown action fails" {
  run "$FC_COMMAND" fc-raycast unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc raycast unknown action shows help hint" {
  run "$FC_COMMAND" fc-raycast unknown_action
  assert_failure
  assert_output --partial "--help"
}
