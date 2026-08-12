#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_power.bats
#
# DESCRIPTION:  Tests for `fc power`, which had none.
#
#               The plugin applied its four built-in profiles with 27 bare
#               `sudo pmset` calls while the custom-profile path directly below
#               them used run_sudo. The same command therefore mutated through
#               two different paths — one that honours DRY_RUN_MODE and one that
#               does not — depending only on whether the chosen profile was
#               built in or user-defined.
#
#               That also made the built-in profiles untestable: a bare `sudo`
#               cannot be redirected at a stub, so nothing could assert what a
#               profile actually applies without changing the machine's real
#               power settings.
#
# ==============================================================================

load "test_helper"

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export PLUGIN="$PROJECT_ROOT/lib/plugins/fc-power"

  # Every test runs inert. Without this a passing suite would rewrite the
  # developer's real power management settings.
  export DRY_RUN_MODE=true
  setup_isolated_home
}

teardown() {
  unset DRY_RUN_MODE
  teardown_isolated_home
}

# --- Interface ----------------------------------------------------------------

@test "fc power --help shows usage information" {
  run "$FC_COMMAND" power --help
  assert_success
  assert_output --partial "Usage: fc power"
}

@test "fc power list shows the built-in profiles" {
  run "$FC_COMMAND" power list
  assert_success
  assert_output --partial "default"
  assert_output --partial "battery-saver"
  assert_output --partial "max-performance"
  assert_output --partial "presentation"
}

@test "fc power rejects an unknown action" {
  run "$FC_COMMAND" power not-a-real-action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc-power plugin sources init.sh" {
  run grep "source.*init.sh" "$PLUGIN"
  assert_success
}

# --- The regression: bare sudo bypassed DRY_RUN_MODE --------------------------

@test "fc-power issues no bare sudo calls" {
  # Comments stripped: the explanation above the conversion names `sudo`.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E '^[[:space:]]*sudo '"
  assert_failure
}

@test "fc-power routes power changes through run_sudo" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -c '^[[:space:]]*run_sudo pmset'"
  assert_success
  assert [ "$output" -ge 20 ]
}

@test "run_sudo makes fc power switch inert under DRY_RUN_MODE" {
  # The behavioural half. Before the change these calls ran for real regardless
  # of the flag, so this could not have been asserted at all.
  run "$FC_COMMAND" power switch default
  assert_success
  assert_output --partial "[Dry Run] Would run: sudo pmset"
  refute_output --partial "unexpected error occurred"
}

# --- What each built-in profile actually applies ------------------------------
#
# Now assertable, because run_sudo reports the command instead of executing it.

@test "the default profile restores standard sleep timings" {
  run "$FC_COMMAND" power switch default
  assert_success
  assert_output --partial "pmset -a displaysleep 10"
  assert_output --partial "pmset -a disksleep 10"
}

@test "battery-saver enables low power mode and shorter sleeps" {
  run "$FC_COMMAND" power switch battery-saver
  assert_success
  assert_output --partial "pmset -b lowpowermode 1"
  assert_output --partial "pmset -a displaysleep 2"
}

@test "max-performance disables sleep entirely" {
  run "$FC_COMMAND" power switch max-performance
  assert_success
  assert_output --partial "pmset -a displaysleep 0"
  assert_output --partial "pmset -a sleep 0"
  assert_output --partial "pmset -a lowpowermode 0"
}

@test "presentation keeps the display awake" {
  run "$FC_COMMAND" power switch presentation
  assert_success
  assert_output --partial "pmset -a displaysleep 0"
}

@test "no profile switch executes a real pmset under dry run" {
  # Guards the property the whole change is about, across every built-in
  # profile: everything reported, nothing run.
  for profile in default battery-saver max-performance presentation; do
    run "$FC_COMMAND" power switch "$profile"
    assert_success
    assert_output --partial "[Dry Run]"
  done
}
