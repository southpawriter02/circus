#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_apps.bats
#
# DESCRIPTION:  Tests for the fc fc-apps command including setup, list,
#               install, and add subcommands.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Create a temporary directory for test files
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)

  # Store original config location for cleanup
  export APPS_CONFIG_FILE="$HOME/.config/circus/apps.conf"

  # Backup existing config if present
  if [ -f "$APPS_CONFIG_FILE" ]; then
    cp "$APPS_CONFIG_FILE" "$APPS_CONFIG_FILE.bats_backup"
  fi
}

teardown() {
  # Clean up temporary directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi

  # Restore original config
  if [ -f "$APPS_CONFIG_FILE.bats_backup" ]; then
    mv "$APPS_CONFIG_FILE.bats_backup" "$APPS_CONFIG_FILE"
  elif [ -f "$APPS_CONFIG_FILE" ]; then
    # Remove test config if no backup existed
    rm -f "$APPS_CONFIG_FILE"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-apps --help shows usage information" {
  run "$FC_COMMAND" fc-apps --help
  assert_success
  assert_output --partial "Usage: fc fc-apps"
  assert_output --partial "setup"
  assert_output --partial "list"
  assert_output --partial "install"
  assert_output --partial "add"
}

@test "fc fc-apps with no arguments shows usage" {
  run "$FC_COMMAND" fc-apps
  assert_success
  assert_output --partial "Usage: fc fc-apps"
}

@test "fc fc-apps --help shows examples" {
  run "$FC_COMMAND" fc-apps --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc fc-apps setup"
  assert_output --partial "fc fc-apps add --cask"
}

@test "fc fc-apps --help shows configuration path" {
  run "$FC_COMMAND" fc-apps --help
  assert_success
  assert_output --partial "Configuration:"
  assert_output --partial "apps.conf"
}

# ==============================================================================
# Setup Subcommand Tests
# ==============================================================================

@test "fc fc-apps setup creates config file" {
  # Remove existing config
  rm -f "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps setup
  assert_success
  assert_output --partial "Configuration file created"
  [ -f "$APPS_CONFIG_FILE" ]
}

@test "fc fc-apps setup shows next steps" {
  rm -f "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps setup
  assert_success
  assert_output --partial "Next steps"
  assert_output --partial "Edit the config"
}

@test "fc fc-apps setup detects existing config" {
  # Create a config file first
  mkdir -p "$(dirname "$APPS_CONFIG_FILE")"
  echo "# test" > "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps setup
  assert_success
  assert_output --partial "already exists"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc fc-apps list works when no config exists" {
  rm -f "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps list
  assert_success
  assert_output --partial "No configuration file found"
  assert_output --partial "fc fc-apps setup"
}

@test "fc fc-apps list shows empty config message" {
  mkdir -p "$(dirname "$APPS_CONFIG_FILE")"
  echo "# Empty config with only comments" > "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps list
  assert_success
  assert_output --partial "No applications configured"
}

# ==============================================================================
# Install Subcommand Tests
# ==============================================================================

@test "fc fc-apps install requires config" {
  rm -f "$APPS_CONFIG_FILE"

  run "$FC_COMMAND" fc-apps install
  assert_failure
  assert_output --partial "No configuration file found"
}

# ==============================================================================
# Add Subcommand Tests
# ==============================================================================

@test "fc fc-apps add requires type flag" {
  run "$FC_COMMAND" fc-apps add
  assert_failure
  assert_output --partial "Application type required"
}

@test "fc fc-apps add --brew requires app name" {
  run "$FC_COMMAND" fc-apps add --brew
  assert_failure
  assert_output --partial "Application name required"
}

@test "fc fc-apps add --cask requires app name" {
  run "$FC_COMMAND" fc-apps add --cask
  assert_failure
  assert_output --partial "Application name required"
}

@test "fc fc-apps add --mas requires app name" {
  run "$FC_COMMAND" fc-apps add --mas
  assert_failure
  assert_output --partial "Application name required"
}

@test "fc fc-apps add --mas requires app id" {
  run "$FC_COMMAND" fc-apps add --mas "Test App"
  assert_failure
  assert_output --partial "Mac App Store ID required"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc fc-apps unknown subcommand fails" {
  run "$FC_COMMAND" fc-apps unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc fc-apps unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-apps unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Template Tests
# ==============================================================================

@test "apps.conf.template exists" {
  [ -f "$PROJECT_ROOT/lib/templates/apps.conf.template" ]
}

@test "apps.conf.template has brew examples" {
  run grep "brew" "$PROJECT_ROOT/lib/templates/apps.conf.template"
  assert_success
}

@test "apps.conf.template has cask examples" {
  run grep "cask" "$PROJECT_ROOT/lib/templates/apps.conf.template"
  assert_success
}

@test "apps.conf.template has mas examples" {
  run grep "mas" "$PROJECT_ROOT/lib/templates/apps.conf.template"
  assert_success
}

@test "apps.conf.template has usage instructions" {
  run grep "fc fc-apps install" "$PROJECT_ROOT/lib/templates/apps.conf.template"
  assert_success
}

# ==============================================================================
# Brewfile Tests
# ==============================================================================

@test "base Brewfile includes mas" {
  run grep "mas" "$PROJECT_ROOT/Brewfile"
  assert_success
}
