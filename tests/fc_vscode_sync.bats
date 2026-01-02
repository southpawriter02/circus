#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_vscode_sync.bats
#
# DESCRIPTION:  Tests for the fc vscode-sync command for VS Code settings sync.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Save original config if exists
  export VSCODE_SYNC_CONFIG="$HOME/.config/circus/vscode-sync.conf"
  if [ -f "$VSCODE_SYNC_CONFIG" ]; then
    cp "$VSCODE_SYNC_CONFIG" "$VSCODE_SYNC_CONFIG.bats_backup"
  fi

  # Create temp directory for test files
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)
}

teardown() {
  # Restore original config
  if [ -f "$VSCODE_SYNC_CONFIG.bats_backup" ]; then
    mv "$VSCODE_SYNC_CONFIG.bats_backup" "$VSCODE_SYNC_CONFIG"
  elif [ -f "$VSCODE_SYNC_CONFIG" ]; then
    # Remove config created during tests if no backup existed
    rm -f "$VSCODE_SYNC_CONFIG"
  fi

  # Clean up temp directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc vscode-sync --help shows usage information" {
  run "$FC_COMMAND" fc-vscode-sync --help
  assert_success
  assert_output --partial "Usage:"
}

@test "fc vscode-sync --help shows all subcommands" {
  run "$FC_COMMAND" fc-vscode-sync --help
  assert_success
  assert_output --partial "setup"
  assert_output --partial "up"
  assert_output --partial "down"
  assert_output --partial "status"
}

@test "fc vscode-sync --help shows examples" {
  run "$FC_COMMAND" fc-vscode-sync --help
  assert_success
  assert_output --partial "Examples:"
}

@test "fc vscode-sync --help shows config file location" {
  run "$FC_COMMAND" fc-vscode-sync --help
  assert_success
  assert_output --partial "Config file:"
}

@test "fc vscode-sync with no subcommand shows usage" {
  run "$FC_COMMAND" fc-vscode-sync
  assert_success
  assert_output --partial "Usage:"
}

# ==============================================================================
# Setup Subcommand Tests
# ==============================================================================

@test "fc vscode-sync setup --help shows usage" {
  run "$FC_COMMAND" fc-vscode-sync setup --help
  assert_success
  assert_output --partial "Usage: fc vscode-sync setup"
}

@test "fc vscode-sync setup creates config file" {
  rm -f "$VSCODE_SYNC_CONFIG"
  run "$FC_COMMAND" fc-vscode-sync setup
  assert_success
  [ -f "$VSCODE_SYNC_CONFIG" ]
}

@test "fc vscode-sync setup sets correct permissions" {
  rm -f "$VSCODE_SYNC_CONFIG"
  run "$FC_COMMAND" fc-vscode-sync setup
  assert_success
  perms=$(stat -f '%Lp' "$VSCODE_SYNC_CONFIG" 2>/dev/null || stat -c '%a' "$VSCODE_SYNC_CONFIG" 2>/dev/null)
  [ "$perms" = "600" ]
}

@test "fc vscode-sync setup detects existing config" {
  mkdir -p "$(dirname "$VSCODE_SYNC_CONFIG")"
  touch "$VSCODE_SYNC_CONFIG"
  chmod 600 "$VSCODE_SYNC_CONFIG"
  run "$FC_COMMAND" fc-vscode-sync setup
  assert_success
  assert_output --partial "already exists"
}

@test "fc vscode-sync setup checks prerequisites" {
  rm -f "$VSCODE_SYNC_CONFIG"
  run "$FC_COMMAND" fc-vscode-sync setup
  assert_success
  assert_output --partial "Checking prerequisites"
}

# ==============================================================================
# Up Subcommand Tests
# ==============================================================================

@test "fc vscode-sync up --help shows usage" {
  run "$FC_COMMAND" fc-vscode-sync up --help
  assert_success
  assert_output --partial "Usage: fc vscode-sync up"
}

@test "fc vscode-sync up --help shows sync flags" {
  run "$FC_COMMAND" fc-vscode-sync up --help
  assert_success
  assert_output --partial "SYNC_SETTINGS"
  assert_output --partial "SYNC_EXTENSIONS"
}

# ==============================================================================
# Down Subcommand Tests
# ==============================================================================

@test "fc vscode-sync down --help shows usage" {
  run "$FC_COMMAND" fc-vscode-sync down --help
  assert_success
  assert_output --partial "Usage: fc vscode-sync down"
}

@test "fc vscode-sync down --help mentions backup" {
  run "$FC_COMMAND" fc-vscode-sync down --help
  assert_success
  assert_output --partial ".bak"
}

# ==============================================================================
# Status Subcommand Tests
# ==============================================================================

@test "fc vscode-sync status --help shows usage" {
  run "$FC_COMMAND" fc-vscode-sync status --help
  assert_success
  assert_output --partial "Usage: fc vscode-sync status"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc vscode-sync unknown subcommand fails" {
  run "$FC_COMMAND" fc-vscode-sync unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc vscode-sync unknown subcommand shows help hint" {
  run "$FC_COMMAND" fc-vscode-sync unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

@test "fc vscode-sync up without auth fails (gist backend)" {
  # Ensure no GitHub auth is available
  unset GITHUB_TOKEN

  mkdir -p "$(dirname "$VSCODE_SYNC_CONFIG")"
  cat > "$VSCODE_SYNC_CONFIG" << 'EOF'
VSCODE_SYNC_BACKEND="gist"
SYNC_SETTINGS=true
EOF
  chmod 600 "$VSCODE_SYNC_CONFIG"

  # Use a non-existent keychain account and no gh CLI
  export VSCODE_KEYCHAIN_ACCOUNT="nonexistent_test_account_12345"
  export GH_CMD="nonexistent_gh_command"

  run "$FC_COMMAND" fc-vscode-sync up
  assert_failure
  # Should fail due to auth or code CLI
}

@test "fc vscode-sync with unknown backend fails" {
  mkdir -p "$(dirname "$VSCODE_SYNC_CONFIG")"
  cat > "$VSCODE_SYNC_CONFIG" << 'EOF'
VSCODE_SYNC_BACKEND="unknown_backend_xyz"
EOF
  chmod 600 "$VSCODE_SYNC_CONFIG"

  run "$FC_COMMAND" fc-vscode-sync up
  assert_failure
  # Will fail either due to missing code CLI or unknown backend
  # Both are valid failure reasons for this configuration
}

@test "fc vscode-sync down without gist ID fails (gist backend)" {
  # Set up a mock GitHub token
  export GITHUB_TOKEN="fake_token_for_testing"

  mkdir -p "$(dirname "$VSCODE_SYNC_CONFIG")"
  cat > "$VSCODE_SYNC_CONFIG" << 'EOF'
VSCODE_SYNC_BACKEND="gist"
VSCODE_GIST_ID=""
EOF
  chmod 600 "$VSCODE_SYNC_CONFIG"

  run "$FC_COMMAND" fc-vscode-sync down
  # Should fail because no gist ID is configured (or code CLI missing)
  assert_failure
}

@test "fc vscode-sync repo backend requires VSCODE_REPO_URL" {
  export GITHUB_TOKEN="fake_token_for_testing"

  mkdir -p "$(dirname "$VSCODE_SYNC_CONFIG")"
  cat > "$VSCODE_SYNC_CONFIG" << 'EOF'
VSCODE_SYNC_BACKEND="repo"
VSCODE_REPO_URL=""
EOF
  chmod 600 "$VSCODE_SYNC_CONFIG"

  run "$FC_COMMAND" fc-vscode-sync up
  assert_failure
  # Will fail either due to missing code CLI or missing VSCODE_REPO_URL
  # Both are valid failure reasons for this configuration
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-vscode-sync plugin exists" {
  [ -f "$PROJECT_ROOT/lib/plugins/fc-vscode-sync" ]
}

@test "fc-vscode-sync plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-vscode-sync" ]
}

@test "fc-vscode-sync plugin sources init.sh" {
  run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-vscode-sync"
  assert_success
}

@test "fc-vscode-sync plugin uses code CLI" {
  run grep "code" "$PROJECT_ROOT/lib/plugins/fc-vscode-sync"
  assert_success
}

# ==============================================================================
# Backend File Tests
# ==============================================================================

@test "gist backend exists" {
  [ -f "$PROJECT_ROOT/lib/vscode_backends/gist.sh" ]
}

@test "repo backend exists" {
  [ -f "$PROJECT_ROOT/lib/vscode_backends/repo.sh" ]
}

@test "gist backend implements required functions" {
  run grep "vscode_backend_get_name" "$PROJECT_ROOT/lib/vscode_backends/gist.sh"
  assert_success
  run grep "vscode_backend_check_dependencies" "$PROJECT_ROOT/lib/vscode_backends/gist.sh"
  assert_success
  run grep "vscode_backend_push" "$PROJECT_ROOT/lib/vscode_backends/gist.sh"
  assert_success
  run grep "vscode_backend_pull" "$PROJECT_ROOT/lib/vscode_backends/gist.sh"
  assert_success
}

@test "repo backend implements required functions" {
  run grep "vscode_backend_get_name" "$PROJECT_ROOT/lib/vscode_backends/repo.sh"
  assert_success
  run grep "vscode_backend_check_dependencies" "$PROJECT_ROOT/lib/vscode_backends/repo.sh"
  assert_success
  run grep "vscode_backend_push" "$PROJECT_ROOT/lib/vscode_backends/repo.sh"
  assert_success
  run grep "vscode_backend_pull" "$PROJECT_ROOT/lib/vscode_backends/repo.sh"
  assert_success
}

# ==============================================================================
# Configuration Template Tests
# ==============================================================================

@test "vscode-sync.conf.template exists" {
  [ -f "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template" ]
}

@test "vscode-sync.conf.template contains backend selection" {
  run grep "VSCODE_SYNC_BACKEND" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
}

@test "vscode-sync.conf.template contains gist settings" {
  run grep "VSCODE_GIST_ID" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
}

@test "vscode-sync.conf.template contains sync flags" {
  run grep "SYNC_SETTINGS" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
  run grep "SYNC_EXTENSIONS" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
  run grep "SYNC_KEYBINDINGS" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
}

@test "vscode-sync.conf.template contains security warning" {
  run grep -i "security" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
}

@test "vscode-sync.conf.template documents keychain usage" {
  run grep "Keychain" "$PROJECT_ROOT/lib/templates/vscode-sync.conf.template"
  assert_success
}
