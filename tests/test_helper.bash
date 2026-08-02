#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         test_helper.bash
#
# DESCRIPTION:  Test helper for the BATS testing framework. This file is
#               sourced by all .bats files and provides common setup,
#               teardown, and helper functions.
#
# ==============================================================================

# --- Project Root ---
# This sets a global variable that points to the root of our project.
# This is useful for sourcing scripts and accessing files within our tests.

export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# --- Load Support Libraries ---
# This loads the BATS support libraries, giving us access to powerful
# setup and teardown functions, as well as a rich set of assertions.

# Load the `bats-mock` library first, as it can interfere with other helpers
# if loaded after them.
load "$PROJECT_ROOT/tests/helpers/bats-mock/stub.bash"

# The BATS helper libraries (`bats-support` and `bats-assert`) have been
# copied into the `tests/helpers` directory to ensure the test suite is
# self-contained and avoids environment-related loading issues.
load "helpers/bats-support/load.bash"
load "helpers/bats-assert/load.bash"

# --- Setup & Teardown ---
# These functions run before and after each test case.
# You can use them to set up a clean environment for each test.

setup() {
  # Runs before each test case
  # Example: Create a temporary directory for testing file operations
  # export TMP_DIR=$(mktemp -d)
  echo "setup() from test_helper"
}

teardown() {
  # Runs after each test case
  # Clean up the mock bin directory to ensure stubs don't leak between tests.
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi

  # Also clear the stub PLAN and RUN files, not just the shim directory.
  #
  # `stub` APPENDS its expectations to "${BATS_MOCK_TMPDIR}/<prog>-stub-plan",
  # and BATS_MOCK_TMPDIR is BATS_TMPDIR — shared across the whole run and
  # persisting between runs. Removing only the bindir let those plans accumulate
  # (brew-stub-plan reached ~1KB of stale expectations), so binstub matched a
  # leftover entry instead of the current one, exited 1, and stubbed tests
  # failed for reasons unrelated to the code under test.
  if [ -n "${BATS_MOCK_TMPDIR:-}" ] && [ -d "$BATS_MOCK_TMPDIR" ]; then
    rm -f "$BATS_MOCK_TMPDIR"/*-stub-plan "$BATS_MOCK_TMPDIR"/*-stub-run 2>/dev/null || true
  fi
}

# ==============================================================================
# HOME ISOLATION
# ==============================================================================

#
# @description Point HOME at a per-test temporary directory.
#
#   Many plugins derive their config path from $HOME (~/.config/circus/sync.conf,
#   ~/.circus/bootstrap, ~/.zshenv.local). Without this, running the suite writes
#   into the developer's real home: a `fc sync` test left a borg backup config
#   pointing at /tmp behind, silently changing which backend real backups would
#   use, and a `fc bootstrap` test left AUTO_CONFIRM=true.
#
#   Backing the files up and restoring them in teardown is not sufficient — if a
#   test aborts, the restore never runs and the user keeps the test's config.
#   Isolating HOME means the tests cannot reach those files at all.
#
# @usage Call FIRST in setup(), before any $HOME-derived path is computed:
#   setup()    { setup_isolated_home; ... }
#   teardown() { ...; teardown_isolated_home; }
#
setup_isolated_home() {
  export ORIGINAL_HOME="${ORIGINAL_HOME:-$HOME}"
  export ISOLATED_TEST_HOME
  ISOLATED_TEST_HOME=$(mktemp -d)
  export HOME="$ISOLATED_TEST_HOME"
  mkdir -p "$HOME/.config" "$HOME/.circus"
}

#
# @description Restore the real HOME and remove the temporary one.
#
teardown_isolated_home() {
  if [ -n "${ORIGINAL_HOME:-}" ]; then
    export HOME="$ORIGINAL_HOME"
  fi

  # Only ever delete inside a known temp root, so a mangled or empty variable
  # cannot turn this into an rm -rf of something real.
  if [ -n "${ISOLATED_TEST_HOME:-}" ] && [ -d "$ISOLATED_TEST_HOME" ]; then
    case "$ISOLATED_TEST_HOME" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*)
        rm -rf "$ISOLATED_TEST_HOME"
        ;;
    esac
  fi
  unset ISOLATED_TEST_HOME
}

# ==============================================================================
# INSTALLER TEST HELPERS
# ==============================================================================

#
# @description Sets up a clean environment for installer stage tests.
#   Creates a temporary HOME directory, enables dry-run mode, and disables
#   interactive prompts to allow automated testing of installer stages.
#
# @usage Call from setup() in installer test files:
#   setup() {
#     setup_installer_test
#   }
#
setup_installer_test() {
  # Create a temporary HOME directory to avoid polluting the real one
  export INSTALLER_TEST_HOME=$(mktemp -d)
  export ORIGINAL_HOME="$HOME"
  export HOME="$INSTALLER_TEST_HOME"

  # Create required subdirectories
  mkdir -p "$INSTALLER_TEST_HOME/.circus"
  mkdir -p "$INSTALLER_TEST_HOME/.config"

  # Enable dry-run mode to prevent actual system changes
  export DRY_RUN_MODE=true

  # Disable interactive prompts
  export INTERACTIVE_MODE=false

  # Suppress console output during tests (log to file only)
  export CONSOLE_LOG_LEVEL=5  # CRITICAL only

  # Set up a test log file
  export LOG_FILE_PATH="$INSTALLER_TEST_HOME/test_install.log"

  # Disable paranoid mode (would suppress all output)
  export PARANOID_MODE=false

  # init.sh pulls in helpers.sh, which installs its own `trap ... ERR` calling
  # error_handler -> exit 1. That REPLACES the ERR trap bats-core installs to
  # report failures, so a failing assertion exited the test process before bats
  # could record anything: real failures surfaced as "Executed N instead of
  # expected M" rather than as failing tests. Five tests in
  # installer_stages.bats were invisible for exactly this reason.
  #
  # More importantly, lib/ui.sh installs a bare `trap ui_cleanup EXIT`, which
  # REPLACES the EXIT trap bats uses to report each test's result. With that gone
  # a failing test emitted nothing at all, which is why these showed up as
  # unexecuted rather than as failures.
  #
  # So snapshot both of bats' traps before sourcing, and restore them after.
  # Do NOT `set +e` as an alternative: it would let execution continue past a
  # failed assertion so the test's result became that of its LAST assertion,
  # silently converting these failures into false passes.
  local bats_err_trap bats_exit_trap
  bats_err_trap=$(trap -p ERR)
  bats_exit_trap=$(trap -p EXIT)

  # Source the initialization script to set up the environment
  source "$PROJECT_ROOT/lib/init.sh"

  if [ -n "$bats_err_trap" ]; then eval "$bats_err_trap"; else trap - ERR; fi
  if [ -n "$bats_exit_trap" ]; then eval "$bats_exit_trap"; else trap - EXIT; fi
}

#
# @description Cleans up after installer stage tests.
#   Restores the original HOME directory and removes temporary files.
#
# @usage Call from teardown() in installer test files:
#   teardown() {
#     teardown_installer_test
#   }
#
teardown_installer_test() {
  # Restore original HOME
  if [ -n "$ORIGINAL_HOME" ]; then
    export HOME="$ORIGINAL_HOME"
  fi

  # Remove temporary test directory
  if [ -n "$INSTALLER_TEST_HOME" ] && [ -d "$INSTALLER_TEST_HOME" ]; then
    rm -rf "$INSTALLER_TEST_HOME"
  fi

  # Clean up mock bin directory (from parent teardown)
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi

  # Also clear the stub PLAN and RUN files, not just the shim directory.
  #
  # `stub` APPENDS its expectations to "${BATS_MOCK_TMPDIR}/<prog>-stub-plan",
  # and BATS_MOCK_TMPDIR is BATS_TMPDIR — shared across the whole run and
  # persisting between runs. Removing only the bindir let those plans accumulate
  # (brew-stub-plan reached ~1KB of stale expectations), so binstub matched a
  # leftover entry instead of the current one, exited 1, and stubbed tests
  # failed for reasons unrelated to the code under test.
  if [ -n "${BATS_MOCK_TMPDIR:-}" ] && [ -d "$BATS_MOCK_TMPDIR" ]; then
    rm -f "$BATS_MOCK_TMPDIR"/*-stub-plan "$BATS_MOCK_TMPDIR"/*-stub-run 2>/dev/null || true
  fi
}

#
# @description Runs a single installer stage script in isolation.
#   The stage is sourced after the init.sh environment is set up.
#
# @param $1 The stage filename (e.g., "00-preflight-checks.sh")
# @return The exit status of the stage script
#
# @usage
#   run_installer_stage "00-preflight-checks.sh"
#   assert_success
#
run_installer_stage() {
  local stage_file="$1"
  local stage_path="$PROJECT_ROOT/install/$stage_file"

  if [ ! -f "$stage_path" ]; then
    echo "Stage file not found: $stage_path" >&2
    return 1
  fi

  # Source the stage script (it should respect DRY_RUN_MODE)
  source "$stage_path"
}
