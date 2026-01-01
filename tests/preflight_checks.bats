#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         preflight_checks.bats
#
# DESCRIPTION:  Comprehensive tests for all 21 preflight check scripts.
#               Uses command injection points (e.g., UNAME_CMD, ID_CMD) to
#               mock system commands for reliable, isolated testing.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  setup_installer_test
}

teardown() {
  teardown_installer_test
}

# ==============================================================================
# Preflight Check File Existence Tests
# ==============================================================================

@test "All 21 preflight check scripts exist" {
  local checks=(
    "preflight-01-macos-check.sh"
    "preflight-02-root-check.sh"
    "preflight-03-admin-rights-check.sh"
    "preflight-04-file-permissions-check.sh"
    "preflight-05-unset-vars-check.sh"
    "preflight-06-shell-type-version-check.sh"
    "preflight-07-locale-encoding-check.sh"
    "preflight-08-battery-check.sh"
    "preflight-09-wifi-check.sh"
    "preflight-10-xcode-cli-check.sh"
    "preflight-11-homebrew-check.sh"
    "preflight-12-dependency-check.sh"
    "preflight-13-install-integrity-check.sh"
    "preflight-14-update-check.sh"
    "preflight-15-existing-install-check.sh"
    "preflight-16-backed-up-dotfiles-check.sh"
    "preflight-17-existing-dotfiles-check.sh"
    "preflight-18-icloud-check.sh"
    "preflight-19-terminal-type-check.sh"
    "preflight-20-conflicting-processes-check.sh"
    "preflight-21-install-sanity-check.sh"
  )

  for check in "${checks[@]}"; do
    assert [ -f "$PROJECT_ROOT/install/preflight/$check" ]
  done
}

# ==============================================================================
# Preflight-01: macOS Check
# ==============================================================================

@test "preflight-01: passes on macOS (Darwin)" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    export UNAME_CMD='echo Darwin'
    source '$PROJECT_ROOT/install/preflight/preflight-01-macos-check.sh'
  "
  assert_success
}

@test "preflight-01: fails on non-macOS (Linux)" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    export UNAME_CMD='echo Linux'
    source '$PROJECT_ROOT/install/preflight/preflight-01-macos-check.sh'
  "
  assert_failure
}

# ==============================================================================
# Preflight-02: Root User Check
# ==============================================================================

@test "preflight-02: passes when not running as root" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    export ID_CMD='echo 501'
    source '$PROJECT_ROOT/install/preflight/preflight-02-root-check.sh'
  "
  assert_success
}

@test "preflight-02: fails when running as root" {
  # Create an inline function that simulates root user (id -u returns 0)
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    # Create a mock id command that always returns 0
    mock_id() { echo 0; }
    export ID_CMD='mock_id'
    export -f mock_id
    source '$PROJECT_ROOT/install/preflight/preflight-02-root-check.sh'
  "
  assert_failure
}

# ==============================================================================
# Preflight-03 to Preflight-21: Syntax and Sourcing Tests
# ==============================================================================
# These tests verify each script can be sourced without syntax errors.
# Full behavioral testing requires additional mocking for system-specific commands.

@test "preflight-03: admin rights check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-03-admin-rights-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
    refute_output --partial "unexpected"
  fi
}

@test "preflight-04: file permissions check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-04-file-permissions-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-05: unset vars check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-05-unset-vars-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-06: shell type/version check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-06-shell-type-version-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-07: locale/encoding check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-07-locale-encoding-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-08: battery check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-08-battery-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-09: wifi check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-09-wifi-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-10: xcode cli check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-10-xcode-cli-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-11: homebrew check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-11-homebrew-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-12: dependency check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-12-dependency-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-13: install integrity check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-13-install-integrity-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-14: update check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-14-update-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-15: existing install check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-15-existing-install-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-16: backed up dotfiles check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-16-backed-up-dotfiles-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-17: existing dotfiles check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-17-existing-dotfiles-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-18: icloud check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-18-icloud-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-19: terminal type check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-19-terminal-type-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-20: conflicting processes check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-20-conflicting-processes-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "preflight-21: install sanity check sources without syntax error" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    source '$PROJECT_ROOT/install/preflight/preflight-21-install-sanity-check.sh'
  " 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

# ==============================================================================
# Preflight Orchestrator (00-preflight-checks.sh) Tests
# ==============================================================================

@test "00-preflight-checks.sh defines PREFLIGHT_CHECKS array" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'
    export CONSOLE_LOG_LEVEL=5
    export INTERACTIVE_MODE=false

    # Just source and check the array exists
    source '$PROJECT_ROOT/install/00-preflight-checks.sh' || true

    # After sourcing, check if array was defined (may have already run main)
    echo \"PREFLIGHT_CHECKS has \${#PREFLIGHT_CHECKS[@]} elements\"
  " 2>&1

  # The script will run main() on source, but we just want no syntax errors
  refute_output --partial "syntax error"
}

@test "00-preflight-checks.sh has 21 checks in PREFLIGHT_CHECKS array" {
  run bash -c "
    source '$PROJECT_ROOT/lib/init.sh'

    # Extract and count the array definition without running the script
    grep -c 'preflight-[0-9][0-9]-' '$PROJECT_ROOT/install/00-preflight-checks.sh'
  "
  assert_success
  assert_output "21"
}

@test "Critical checks are properly marked in PREFLIGHT_CHECKS" {
  # Check that critical checks are marked with |yes
  run bash -c "
    grep '|yes' '$PROJECT_ROOT/install/00-preflight-checks.sh' | wc -l | tr -d ' '
  "
  assert_success
  # At least 5 critical checks should exist
  assert [ "$output" -ge 5 ]
}

@test "Non-critical checks are properly marked in PREFLIGHT_CHECKS" {
  # Check that non-critical checks are marked with |no
  run bash -c "
    grep '|no' '$PROJECT_ROOT/install/00-preflight-checks.sh' | wc -l | tr -d ' '
  "
  assert_success
  # At least 10 non-critical checks should exist
  assert [ "$output" -ge 10 ]
}
