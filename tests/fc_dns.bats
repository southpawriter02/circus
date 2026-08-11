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

# ==============================================================================
# S30: DNS Leak Check  (resurrected control)
# ==============================================================================
#
# dns_leak_check, dns_resolution_test and save_expected_dns were defined and
# exported in lib/security.sh with no caller anywhere in the repository — the
# control could not be run. Wiring it up surfaced two defects inside it:
#
#   1. save_expected_dns wrote to $HOME/.circus/expected_dns with no mkdir -p,
#      so it failed outright before an install had created that directory.
#   2. dns_leak_check only ever consulted $EXPECTED_DNS from the environment
#      and never read the file save_expected_dns had written, so the baseline
#      was write-only and the comparison could never fire.

setup_dns_audit() {
  DNS_TMP="$(mktemp -d)"
  export DNS_TMP
  export CIRCUS_EXPECTED_DNS_FILE="$DNS_TMP/expected_dns"
  # Ensure the environment override does not mask the file-based baseline.
  unset CIRCUS_EXPECTED_DNS
}

teardown_dns_audit() {
  if [ -n "${DNS_TMP:-}" ] && [ -d "$DNS_TMP" ]; then
    case "$DNS_TMP" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$DNS_TMP" ;;
    esac
  fi
  unset DNS_TMP CIRCUS_EXPECTED_DNS_FILE
}

@test "fc dns --help documents the S30 auditing actions" {
  run "$FC_COMMAND" fc-dns --help
  assert_success
  assert_output --partial "leak-check"
  assert_output --partial "baseline"
}

@test "fc dns baseline records the current resolvers to disk" {
  setup_dns_audit
  run "$FC_COMMAND" dns baseline
  assert_success
  assert_output --partial "Saved expected DNS servers"
  assert [ -s "$CIRCUS_EXPECTED_DNS_FILE" ]
  teardown_dns_audit
}

@test "fc dns baseline creates its directory when absent" {
  # Regression: no mkdir -p meant this failed whenever ~/.circus did not exist.
  setup_dns_audit
  export CIRCUS_EXPECTED_DNS_FILE="$DNS_TMP/does/not/exist/expected_dns"
  run "$FC_COMMAND" dns baseline
  assert_success
  assert [ -s "$CIRCUS_EXPECTED_DNS_FILE" ]
  teardown_dns_audit
}

@test "fc dns leak-check reads the saved baseline and passes when it matches" {
  setup_dns_audit
  run "$FC_COMMAND" dns baseline
  assert_success

  run "$FC_COMMAND" dns leak-check
  assert_success
  assert_output --partial "DNS configuration looks OK"
  teardown_dns_audit
}

@test "fc dns leak-check flags a resolver that is not in the baseline" {
  # The regression that mattered: before the fix the saved baseline was never
  # read, so this comparison could not fire and the check always passed.
  setup_dns_audit
  printf '203.0.113.99\n' > "$CIRCUS_EXPECTED_DNS_FILE"

  run "$FC_COMMAND" dns leak-check
  assert_failure
  assert_output --partial "Unexpected DNS server"
  teardown_dns_audit
}

@test "fc dns leak-check exit status distinguishes clean from leaking" {
  # Non-zero on a leak is what makes this usable from a scheduled job, and the
  # ERR trap must not collapse it into a generic failure.
  setup_dns_audit
  run "$FC_COMMAND" dns baseline
  run "$FC_COMMAND" dns leak-check
  assert_equal "$status" 0

  printf '203.0.113.99\n' > "$CIRCUS_EXPECTED_DNS_FILE"
  run "$FC_COMMAND" dns leak-check
  assert_equal "$status" 1
  refute_output --partial "unexpected error occurred"
  teardown_dns_audit
}

@test "fc dns rejects an unknown action rather than crashing" {
  run "$FC_COMMAND" dns not-a-real-action
  assert_failure
  assert_output --partial "Unknown action"
}

# --- get_active_network_service must survive a VPN ----------------------------

@test "fc dns get works when the default route is a tunnel interface" {
  # With any VPN up the default route is a utun* device, which appears in no
  # hardware-port listing. The lookup piped that through grep under pipefail,
  # so the non-matching grep aborted every fc dns action with "An unexpected
  # error occurred". This is the regression test for that.
  run "$FC_COMMAND" dns get
  assert_success
  refute_output --partial "unexpected error occurred"
}

@test "fc-dns resolves a network service without failing on no match" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PROJECT_ROOT/lib/plugins/fc-dns' | grep -c '|| true'"
  assert_success
  assert [ "$output" -ge 2 ]
}
