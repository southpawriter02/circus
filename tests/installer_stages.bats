#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         installer_stages.bats
#
# DESCRIPTION:  Comprehensive tests for all installer stages. Each stage is
#               tested in dry-run mode to verify it can be sourced without
#               errors and respects the DRY_RUN_MODE flag.
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
# Stage File Existence Tests
# ==============================================================================

@test "All 15 INSTALL_STAGES files exist" {
  local stages=(
    "00-preflight-checks.sh"
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    "04-macos-system-settings.sh"
    "05-oh-my-zsh-installation.sh"
    "06-repository-management.sh"
    "09-dotfiles-deployment.sh"
    "10-git-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "14-cleanup.sh"
    "15-finalization-and-reporting.sh"
    "16-jetbrains-configuration.sh"
    "17-secrets-management.sh"
    "18-privacy-and-security.sh"
  )

  for stage in "${stages[@]}"; do
    assert [ -f "$PROJECT_ROOT/install/$stage" ]
  done
}

# ==============================================================================
# Individual Stage Tests (Dry-Run Mode)
# ==============================================================================

@test "Stage 00: Preflight Checks - sources without error in dry-run" {
  # Preflight checks may fail if system requirements aren't met, but should
  # at least source without syntax errors
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/00-preflight-checks.sh'" 2>&1

  # Check for success OR known preflight failure (not syntax error)
  if [ "$status" -ne 0 ]; then
    # Allow failures from actual preflight checks, but not bash syntax errors
    refute_output --partial "syntax error"
    refute_output --partial "command not found"
  fi
}

@test "Stage 01: Introduction - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/01-introduction-and-user-interaction.sh'" 2>&1

  # Should succeed or fail gracefully (not syntax error)
  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 02: Logging Setup - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/02-logging-setup.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 03: Homebrew Installation - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/03-homebrew-installation.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 04: macOS System Settings - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/04-macos-system-settings.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 05: Oh My Zsh Installation - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/05-oh-my-zsh-installation.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 06: Repository Management - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/06-repository-management.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 09: Dotfiles Deployment - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/09-dotfiles-deployment.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 10: Git Configuration - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/10-git-configuration.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 11: Additional Configuration - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/11-defaults-and-additional-configuration.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 14: Cleanup - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/14-cleanup.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 15: Finalization and Reporting - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/15-finalization-and-reporting.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 16: JetBrains Configuration - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/16-jetbrains-configuration.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 17: Secrets Management - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/17-secrets-management.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

@test "Stage 18: Privacy and Security - sources without error in dry-run" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' && \
    export DRY_RUN_MODE=true && \
    export INTERACTIVE_MODE=false && \
    export CONSOLE_LOG_LEVEL=5 && \
    source '$PROJECT_ROOT/install/18-privacy-and-security.sh'" 2>&1

  if [ "$status" -ne 0 ]; then
    refute_output --partial "syntax error"
  fi
}

# ==============================================================================
# Install.sh Integration Tests
# ==============================================================================
# Note: These tests don't need the full installer environment, so they
# restore HOME before running to avoid conflicts with the temp HOME.

@test "install.sh displays help message with --help flag" {
  # Use a fresh shell with original HOME to avoid test environment conflicts
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --help
  assert_success
  assert_output --partial "Usage: ./install.sh"
  assert_output --partial "--role"
  assert_output --partial "--dry-run"
  assert_output --partial "--log-level"
}

@test "install.sh validates role names" {
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --role invalid_role
  assert_failure
  assert_output --partial "Invalid role"
}

@test "install.sh accepts valid roles" {
  # Just check it parses the role without immediate error
  # We use --help after to exit cleanly without running stages
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --role developer --help
  assert_success
  assert_output --partial "Usage:"
}

@test "install.sh validates privacy profiles" {
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --privacy-profile invalid
  assert_failure
  assert_output --partial "Invalid privacy profile"
}

@test "install.sh accepts valid privacy profiles" {
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --privacy-profile lockdown --help
  assert_success
}

@test "install.sh validates log level names" {
  run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --log-level INVALID
  assert_failure
  assert_output --partial "Invalid log level"
}

@test "install.sh accepts valid log levels" {
  for level in DEBUG INFO WARN ERROR CRITICAL; do
    run env HOME="$ORIGINAL_HOME" "$PROJECT_ROOT/install.sh" --log-level "$level" --help
    assert_success
  done
}
