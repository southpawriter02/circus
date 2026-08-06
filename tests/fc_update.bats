#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_update.bats
#
# DESCRIPTION:  Tests for the fc update command including version tracking,
#               update checking, dry-run mode, and migration system.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  # Use the standard test setup
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
}

teardown() {
  # Clean up mock bin directory
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-update --help shows usage information" {
  run "$FC_COMMAND" fc-update --help
  assert_success
  assert_output --partial "Usage: fc update"
  assert_output --partial "--version"
  assert_output --partial "--check"
  assert_output --partial "--dry-run"
  assert_output --partial "--skip-migrations"
}

# ==============================================================================
# Version Tests
# ==============================================================================

@test "fc fc-update --version shows version number" {
  # Read the expected version from .version instead of hardcoding it, so this
  # does not have to be edited on every release.
  local expected
  expected=$(tr -d '[:space:]' < "$PROJECT_ROOT/.version")
  run "$FC_COMMAND" fc-update --version
  assert_success
  assert_output --partial "Dotfiles Flying Circus v"
  assert_output --partial "$expected"
}

@test ".version file exists at repository root" {
  assert [ -f "$PROJECT_ROOT/.version" ]
}

@test ".version file contains valid semantic version" {
  run cat "$PROJECT_ROOT/.version"
  assert_success
  # Check it matches X.Y.Z pattern
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# ==============================================================================
# Version Comparison Helper Tests
# ==============================================================================
#
# Two things these tests must respect:
#
# 1. Do NOT `source lib/init.sh` into the test body. It pulls in helpers.sh's
#    `set -Eeo pipefail` and ERR trap, and that trap calls `exit 1`. A failing
#    assertion then kills the test process before bats can record a result, so
#    the failure is reported as "Executed N instead of expected M" rather than as
#    a failing test. Eight tests in this file were invisible for that reason.
#
# 2. version_compare and version_in_range return non-zero as DATA (like `cmp`),
#    so they must be called inside a conditional. Called bare under `set -e`,
#    the shell exits before `echo $?` ever runs.
#
# The `if ...; then echo 0; else echo $?; fi` form satisfies both: `set -e` is
# suppressed inside the condition, and the else branch still sees the real code.

# Emit the exit status of a helper invocation without tripping `set -e`.
version_status() {
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; if $1; then echo 0; else echo \$?; fi"
}

@test "version_compare: equal versions return 0" {
  version_status "version_compare '1.0.0' '1.0.0'"
  assert_output "0"
}

@test "version_compare: first greater returns 1" {
  version_status "version_compare '2.0.0' '1.0.0'"
  assert_output "1"
}

@test "version_compare: first less returns 2" {
  version_status "version_compare '1.0.0' '2.0.0'"
  assert_output "2"
}

@test "version_compare: minor version comparison works" {
  version_status "version_compare '1.2.0' '1.1.0'"
  assert_output "1"
}

@test "version_compare: patch version comparison works" {
  version_status "version_compare '1.0.1' '1.0.0'"
  assert_output "1"
}

# ==============================================================================
# Version Range Tests
# ==============================================================================

@test "version_in_range: migration in upgrade path returns 0" {
  # Upgrading from 1.0.0 to 1.2.0, migration 1.0.0->1.1.0 should run
  version_status "version_in_range '1.0.0' '1.1.0' '1.0.0' '1.2.0'"
  assert_output "0"
}

@test "version_in_range: migration before upgrade path returns 1" {
  # Upgrading from 1.1.0 to 1.2.0, migration 1.0.0->1.1.0 should NOT run
  version_status "version_in_range '1.0.0' '1.1.0' '1.1.0' '1.2.0'"
  assert_output "1"
}

@test "version_in_range: migration after upgrade path returns 1" {
  # Upgrading from 1.0.0 to 1.1.0, migration 1.2.0->1.3.0 should NOT run
  version_status "version_in_range '1.2.0' '1.3.0' '1.0.0' '1.1.0'"
  assert_output "1"
}

# ==============================================================================
# get_current_version Tests
# ==============================================================================

@test "get_current_version returns version from .version file" {
  # Compare against .version itself rather than a hardcoded literal. This test
  # asserted "1.0.0" while the file said 1.6.0, so it broke on the first release
  # after it was written — and the failure was invisible (see the note above).
  local expected
  expected=$(tr -d '[:space:]' < "$PROJECT_ROOT/.version")
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; export DOTFILES_ROOT='$PROJECT_ROOT'; get_current_version"
  assert_success
  assert_output "$expected"
}

# ==============================================================================
# Unknown Option Tests
# ==============================================================================

@test "fc fc-update with unknown option shows error" {
  run "$FC_COMMAND" fc-update --unknown-flag 2>&1
  assert_failure
  assert_output --partial "Unknown option"
}

# ==============================================================================
# Migration Directory Tests
# ==============================================================================

@test "migrations directory exists" {
  assert [ -d "$PROJECT_ROOT/migrations" ]
}

@test "migrations README.md exists" {
  assert [ -f "$PROJECT_ROOT/migrations/README.md" ]
}

# ==============================================================================
# Documentation Tests
# ==============================================================================

@test "CHANGELOG.md exists" {
  assert [ -f "$PROJECT_ROOT/CHANGELOG.md" ]
}

@test "docs/UPDATING.md exists" {
  assert [ -f "$PROJECT_ROOT/docs/UPDATING.md" ]
}

@test "docs/specs/fc-update.md documents new flags" {
  run cat "$PROJECT_ROOT/docs/specs/fc-update.md"
  assert_success
  assert_output --partial "--check"
  assert_output --partial "--dry-run"
  assert_output --partial "--skip-migrations"
  assert_output --partial "--version"
}

# ==============================================================================
# System Update Feature Tests (Feature 22)
# ==============================================================================

@test "fc fc-update --help shows update target flags" {
  run "$FC_COMMAND" fc-update --help
  assert_success
  assert_output --partial "--all"
  assert_output --partial "--os"
  assert_output --partial "--packages"
  assert_output --partial "--self"
}

@test "fc fc-update --help shows Update Targets section" {
  run "$FC_COMMAND" fc-update --help
  assert_success
  assert_output --partial "Update Targets"
}

@test "fc fc-update --help shows examples with new flags" {
  run "$FC_COMMAND" fc-update --help
  assert_success
  assert_output --partial "fc update --packages"
  assert_output --partial "fc update --os"
  assert_output --partial "fc update --self"
}

@test "fc fc-update --os flag is recognized" {
  # Use dry-run to avoid actually running updates
  run "$FC_COMMAND" fc-update --os --dry-run
  assert_success
  assert_output --partial "macOS"
  # Should NOT include packages or self
  refute_output --partial "=== Updating Homebrew Packages ==="
  refute_output --partial "=== Updating Dotfiles Repository ==="
}

@test "fc fc-update --packages flag is recognized" {
  run "$FC_COMMAND" fc-update --packages --dry-run
  assert_success
  assert_output --partial "Homebrew"
  # Should NOT include macOS or self
  refute_output --partial "=== Checking for macOS Updates ==="
  refute_output --partial "=== Updating Dotfiles Repository ==="
}

@test "fc fc-update --self flag is recognized" {
  run "$FC_COMMAND" fc-update --self --dry-run
  assert_success
  assert_output --partial "Dotfiles Repository"
  # Should NOT include packages or macOS
  refute_output --partial "=== Updating Homebrew Packages ==="
  refute_output --partial "=== Checking for macOS Updates ==="
}

@test "fc fc-update --all flag runs all update types" {
  run "$FC_COMMAND" fc-update --all --dry-run
  assert_success
  assert_output --partial "Homebrew"
  assert_output --partial "macOS"
  assert_output --partial "Dotfiles"
}

@test "fc fc-update with no flags defaults to --all" {
  run "$FC_COMMAND" fc-update --dry-run
  assert_success
  assert_output --partial "Homebrew"
  assert_output --partial "macOS"
  assert_output --partial "Dotfiles"
}

@test "fc fc-update --dry-run with --packages shows outdated check" {
  run "$FC_COMMAND" fc-update --packages --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  assert_output --partial "brew update"
}

@test "fc fc-update --dry-run with --os shows softwareupdate check" {
  run "$FC_COMMAND" fc-update --os --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  assert_output --partial "softwareupdate"
}

@test "fc fc-update --dry-run with --self previews a fast-forward-only update" {
  run "$FC_COMMAND" fc-update --self --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  # Self-update fast-forwards rather than rebasing, so a force-pushed upstream
  # fails visibly instead of silently rewriting local history.
  assert_output --partial "merge --ff-only"
  refute_output --partial "pull --rebase"
}

@test "fc fc-update multiple target flags can be combined" {
  run "$FC_COMMAND" fc-update --packages --self --dry-run
  assert_success
  assert_output --partial "Homebrew"
  assert_output --partial "Dotfiles"
  # Should NOT include macOS since only --packages and --self were specified
  refute_output --partial "=== Checking for macOS Updates ==="
}
