#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_firewall.bats
#
# DESCRIPTION:  Tests for the fc firewall command for macOS firewall management.
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

@test "fc firewall --help shows usage information" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "Usage: fc firewall"
}

@test "fc firewall --help shows basic actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "on"
  assert_output --partial "off"
  assert_output --partial "status"
}

@test "fc firewall --help shows app management actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "list-apps"
  assert_output --partial "add"
  assert_output --partial "remove"
  assert_output --partial "allow"
  assert_output --partial "block"
}

@test "fc firewall --help shows configuration actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "apply-rules"
  assert_output --partial "export"
  assert_output --partial "setup"
}

@test "fc firewall --help shows advanced options" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "stealth-on"
  assert_output --partial "stealth-off"
  assert_output --partial "block-all"
}

@test "fc firewall with no action shows usage" {
  run "$FC_COMMAND" fc-firewall
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Validation Tests
# ==============================================================================

@test "fc firewall add requires app path" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall add
  assert_failure
  assert_output --partial "required"
}

@test "fc firewall add validates app exists" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall add "/nonexistent/app.app"
  assert_failure
  assert_output --partial "not found"
}

@test "fc firewall unknown action fails" {
  # Skip on non-macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    skip "macOS only"
  fi
  
  run "$FC_COMMAND" fc-firewall unknown_action
  assert_failure
  assert_output --partial "Unknown action"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-firewall plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-firewall" ]
}

@test "fc-firewall plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-firewall" ]
}

@test "fc-firewall plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}

@test "fc-firewall contains socketfilterfw reference" {
  run grep "socketfilterfw" "$PROJECT_ROOT/lib/plugins/fc-firewall"
  assert_success
}

# ==============================================================================
# S29: Firewall Rule Auditor  (resurrected control)
# ==============================================================================
#
# get_firewall_rules, firewall_baseline_save, firewall_check and firewall_status
# were defined and exported in lib/security.sh with no caller anywhere in the
# repository. Meanwhile fc-firewall carried its own 490 lines of status logic.
# The drift detector existed and simply had no way to be run.

setup_fw_audit() {
  FW_TMP="$(mktemp -d)"
  export FW_TMP
  export CIRCUS_FIREWALL_BASELINE="$FW_TMP/firewall_baseline.txt"
}

teardown_fw_audit() {
  if [ -n "${FW_TMP:-}" ] && [ -d "$FW_TMP" ]; then
    case "$FW_TMP" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$FW_TMP" ;;
    esac
  fi
  unset FW_TMP CIRCUS_FIREWALL_BASELINE
}

@test "fc firewall --help documents the S29 auditing actions" {
  run "$FC_COMMAND" fc-firewall --help
  assert_success
  assert_output --partial "baseline"
  assert_output --partial "audit"
}

@test "fc firewall baseline records a baseline with owner-only permissions" {
  setup_fw_audit
  run "$FC_COMMAND" firewall baseline
  assert_success
  assert_output --partial "baseline saved"
  assert [ -s "$CIRCUS_FIREWALL_BASELINE" ]

  run stat -f '%Sp' "$CIRCUS_FIREWALL_BASELINE"
  assert_output "-rw-------"
  teardown_fw_audit
}

@test "fc firewall audit reports no baseline with status 2" {
  # Three outcomes must stay distinct: 0 match, 1 drift, 2 no baseline. A bare
  # call would have let the ERR trap collapse 2 into a generic exit 1.
  setup_fw_audit
  run "$FC_COMMAND" firewall audit
  assert_equal "$status" 2
  assert_output --partial "No firewall baseline found"
  assert_output --partial "fc firewall baseline"
  teardown_fw_audit
}

@test "fc firewall audit passes with status 0 when rules match the baseline" {
  setup_fw_audit
  run "$FC_COMMAND" firewall baseline
  assert_success

  run "$FC_COMMAND" firewall audit
  assert_equal "$status" 0
  assert_output --partial "match baseline"
  teardown_fw_audit
}

@test "fc firewall audit detects drift with status 1" {
  setup_fw_audit
  run "$FC_COMMAND" firewall baseline
  printf 'ALLOW /Applications/Definitely-Not-Malware.app\n' >> "$CIRCUS_FIREWALL_BASELINE"

  run "$FC_COMMAND" firewall audit
  assert_equal "$status" 1
  assert_output --partial "have changed"
  refute_output --partial "unexpected error occurred"
  teardown_fw_audit
}

@test "fc firewall audit suggests a command the user can actually run" {
  # It used to print `diff <(get_firewall_rules) ...` — an internal library
  # function that does not exist as a command in the user's shell.
  setup_fw_audit
  run "$FC_COMMAND" firewall baseline
  printf 'ALLOW /Applications/Definitely-Not-Malware.app\n' >> "$CIRCUS_FIREWALL_BASELINE"

  run "$FC_COMMAND" firewall audit
  assert_output --partial "fc firewall rules"
  refute_output --partial "diff <(get_firewall_rules)"
  teardown_fw_audit
}

@test "fc firewall rules emits the rule set used for comparison" {
  run "$FC_COMMAND" firewall rules
  assert_success
  refute_output ""
}

@test "fc-firewall delegates auditing to lib/security.sh rather than reimplementing it" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PROJECT_ROOT/lib/plugins/fc-firewall' | grep -E 'firewall_baseline_save|firewall_check'"
  assert_success
}
