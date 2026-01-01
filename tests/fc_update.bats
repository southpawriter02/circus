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
  run "$FC_COMMAND" fc-update --version
  assert_success
  assert_output --partial "Dotfiles Flying Circus v"
  assert_output --partial "1.0.0"
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

@test "version_compare: equal versions return 0" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_compare '1.0.0' '1.0.0'; echo \$?"
  assert_output "0"
}

@test "version_compare: first greater returns 1" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_compare '2.0.0' '1.0.0'; echo \$?"
  assert_output "1"
}

@test "version_compare: first less returns 2" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_compare '1.0.0' '2.0.0'; echo \$?"
  assert_output "2"
}

@test "version_compare: minor version comparison works" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_compare '1.2.0' '1.1.0'; echo \$?"
  assert_output "1"
}

@test "version_compare: patch version comparison works" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_compare '1.0.1' '1.0.0'; echo \$?"
  assert_output "1"
}

# ==============================================================================
# Version Range Tests
# ==============================================================================

@test "version_in_range: migration in upgrade path returns 0" {
  source "$PROJECT_ROOT/lib/init.sh"
  # Upgrading from 1.0.0 to 1.2.0, migration 1.0.0->1.1.0 should run
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_in_range '1.0.0' '1.1.0' '1.0.0' '1.2.0'; echo \$?"
  assert_output "0"
}

@test "version_in_range: migration before upgrade path returns 1" {
  source "$PROJECT_ROOT/lib/init.sh"
  # Upgrading from 1.1.0 to 1.2.0, migration 1.0.0->1.1.0 should NOT run
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_in_range '1.0.0' '1.1.0' '1.1.0' '1.2.0'; echo \$?"
  assert_output "1"
}

@test "version_in_range: migration after upgrade path returns 1" {
  source "$PROJECT_ROOT/lib/init.sh"
  # Upgrading from 1.0.0 to 1.1.0, migration 1.2.0->1.3.0 should NOT run
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; version_in_range '1.2.0' '1.3.0' '1.0.0' '1.1.0'; echo \$?"
  assert_output "1"
}

# ==============================================================================
# get_current_version Tests
# ==============================================================================

@test "get_current_version returns version from .version file" {
  source "$PROJECT_ROOT/lib/init.sh"
  run bash -c "source '$PROJECT_ROOT/lib/helpers.sh'; export DOTFILES_ROOT='$PROJECT_ROOT'; get_current_version"
  assert_success
  assert_output "1.0.0"
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
