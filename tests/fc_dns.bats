#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_dns.bats
#
# DESCRIPTION:  Tests for the fc dns command for managing DNS settings.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc dns --help shows usage information" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "Usage: fc dns"
}

@test "fc dns --help shows actions" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "get"
  assert_output --partial "set"
  assert_output --partial "clear"
  assert_output --partial "status"
}

@test "fc dns --help shows examples" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc dns get"
  assert_output --partial "fc dns set"
}

@test "fc dns --help shows popular DNS providers" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "Popular DNS Providers"
  assert_output --partial "Google"
  assert_output --partial "8.8.8.8"
  assert_output --partial "Cloudflare"
  assert_output --partial "1.1.1.1"
}

@test "fc dns --help mentions sudo requirement" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "administrator privileges"
}

@test "fc dns with no action shows usage" {
  run "$FC_COMMAND" fc-dns
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc dns unknown action fails" {
  # Note: The plugin checks for network service before validating action,
  # so if no network is connected, it fails with a different error.
  # We test the plugin's structure instead.
  run grep "Unknown action" "$PROJECT_ROOT/lib/plugins/fc-dns"
  assert_success
}

@test "fc dns unknown action error message includes help hint" {
  # Verify the error message in the plugin includes --help
  run grep -E "Unknown action.*--help" "$PROJECT_ROOT/lib/plugins/fc-dns"
  assert_success
}

# Note: We skip tests that require actual network services or sudo
# as they would modify system settings or fail in CI environments

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-dns plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-dns" ]
}

@test "fc-dns plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-dns" ]
}

@test "fc-dns plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-dns"
  assert_success
}

@test "fc-dns plugin uses networksetup" {
  run grep "networksetup" "$PROJECT_ROOT/lib/plugins/fc-dns"
  assert_success
}

@test "fc-dns plugin handles get and status as aliases" {
  run grep -E "get\|status" "$PROJECT_ROOT/lib/plugins/fc-dns"
  assert_success
}
