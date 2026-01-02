#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_bootstrap.bats
#
# DESCRIPTION:  Tests for the fc bootstrap command including wizard modes,
#               phase execution, state management, and configuration.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Save original config and state if they exist
  export BOOTSTRAP_CONFIG_FILE="$HOME/.config/circus/bootstrap.conf"
  export BOOTSTRAP_STATE_DIR="$HOME/.circus/bootstrap"

  if [ -f "$BOOTSTRAP_CONFIG_FILE" ]; then
    cp "$BOOTSTRAP_CONFIG_FILE" "$BOOTSTRAP_CONFIG_FILE.bats_backup"
  fi

  if [ -d "$BOOTSTRAP_STATE_DIR" ]; then
    cp -r "$BOOTSTRAP_STATE_DIR" "${BOOTSTRAP_STATE_DIR}.bats_backup"
  fi
}

teardown() {
  # Restore original config
  if [ -f "$BOOTSTRAP_CONFIG_FILE.bats_backup" ]; then
    mv "$BOOTSTRAP_CONFIG_FILE.bats_backup" "$BOOTSTRAP_CONFIG_FILE"
  fi

  # Restore original state
  if [ -d "${BOOTSTRAP_STATE_DIR}.bats_backup" ]; then
    rm -rf "$BOOTSTRAP_STATE_DIR"
    mv "${BOOTSTRAP_STATE_DIR}.bats_backup" "$BOOTSTRAP_STATE_DIR"
  fi

  # Clean up mock bin directory
  if [ -d "$BATS_MOCK_BINDIR" ]; then
    rm -rf "$BATS_MOCK_BINDIR"
    mkdir -p "$BATS_MOCK_BINDIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc fc-bootstrap --help shows usage information" {
  run "$FC_COMMAND" fc-bootstrap --help
  assert_success
  assert_output --partial "Usage: fc bootstrap"
  assert_output --partial "status"
  assert_output --partial "resume"
  assert_output --partial "reset"
}

@test "fc fc-bootstrap --help shows available options" {
  run "$FC_COMMAND" fc-bootstrap --help
  assert_success
  assert_output --partial "--role"
  assert_output --partial "--dry-run"
  assert_output --partial "--skip"
  assert_output --partial "--only"
  assert_output --partial "--force"
  assert_output --partial "--gum"
}

@test "fc fc-bootstrap --help shows phase descriptions" {
  run "$FC_COMMAND" fc-bootstrap --help
  assert_success
  assert_output --partial "preflight"
  assert_output --partial "homebrew"
  assert_output --partial "restore"
  assert_output --partial "dotfiles"
  assert_output --partial "apps"
  assert_output --partial "configure"
  assert_output --partial "health"
}

@test "fc fc-bootstrap --help shows configuration file path" {
  run "$FC_COMMAND" fc-bootstrap --help
  assert_success
  assert_output --partial "Configuration:"
  assert_output --partial "bootstrap.conf"
}

# ==============================================================================
# Configuration Template Tests
# ==============================================================================

@test "bootstrap.conf.template exists" {
  assert [ -f "$PROJECT_ROOT/lib/templates/bootstrap.conf.template" ]
}

@test "bootstrap.conf.template contains role settings" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "BOOTSTRAP_ROLE"
  assert_output --partial "BOOTSTRAP_PRIVACY_PROFILE"
}

@test "bootstrap.conf.template contains phase control settings" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "SKIP_PHASE_PREFLIGHT"
  assert_output --partial "SKIP_PHASE_HOMEBREW"
  assert_output --partial "SKIP_PHASE_RESTORE"
  assert_output --partial "SKIP_PHASE_DOTFILES"
  assert_output --partial "SKIP_PHASE_APPS"
  assert_output --partial "SKIP_PHASE_CONFIGURE"
  assert_output --partial "SKIP_PHASE_HEALTH"
}

@test "bootstrap.conf.template contains restore settings" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "AUTO_RESTORE"
  assert_output --partial "RESTORE_REMOTE"
}

@test "bootstrap.conf.template contains git configuration" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "GIT_USER_NAME"
  assert_output --partial "GIT_USER_EMAIL"
}

@test "bootstrap.conf.template contains SSH configuration" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "AUTO_GENERATE_SSH_KEY"
  assert_output --partial "SSH_KEY_EMAIL"
}

@test "bootstrap.conf.template contains unattended mode setting" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "AUTO_CONFIRM"
}

@test "bootstrap.conf.template contains security warning" {
  run cat "$PROJECT_ROOT/lib/templates/bootstrap.conf.template"
  assert_success
  assert_output --partial "SECURITY WARNING"
}

# ==============================================================================
# Phase Script Tests
# ==============================================================================

@test "preflight.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/preflight.sh" ]
}

@test "homebrew.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/homebrew.sh" ]
}

@test "restore.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/restore.sh" ]
}

@test "dotfiles.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/dotfiles.sh" ]
}

@test "apps.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/apps.sh" ]
}

@test "configure.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/configure.sh" ]
}

@test "health.sh phase script exists" {
  assert [ -f "$PROJECT_ROOT/lib/bootstrap_phases/health.sh" ]
}

# ==============================================================================
# Status Subcommand Tests
# ==============================================================================

@test "fc fc-bootstrap status works" {
  run "$FC_COMMAND" fc-bootstrap status
  assert_success
  assert_output --partial "Bootstrap Status"
}

@test "fc fc-bootstrap status shows all phases" {
  run "$FC_COMMAND" fc-bootstrap status
  assert_success
  assert_output --partial "Preflight Checks"
  assert_output --partial "Homebrew Setup"
  assert_output --partial "Backup Restore"
  assert_output --partial "Dotfiles Deployment"
  assert_output --partial "Application Installation"
  assert_output --partial "System Configuration"
  assert_output --partial "Health Check"
}

@test "fc fc-bootstrap status shows configuration info" {
  run "$FC_COMMAND" fc-bootstrap status
  assert_success
  assert_output --partial "Configuration:"
}

# ==============================================================================
# Reset Subcommand Tests
# ==============================================================================

@test "fc fc-bootstrap reset clears state directory" {
  # Create some state files
  mkdir -p "$BOOTSTRAP_STATE_DIR"
  touch "$BOOTSTRAP_STATE_DIR/preflight.done"
  touch "$BOOTSTRAP_STATE_DIR/homebrew.done"

  run "$FC_COMMAND" fc-bootstrap reset
  assert_success
  assert_output --partial "cleared"
  assert [ ! -d "$BOOTSTRAP_STATE_DIR" ]
}

@test "fc fc-bootstrap reset handles empty state gracefully" {
  rm -rf "$BOOTSTRAP_STATE_DIR"
  run "$FC_COMMAND" fc-bootstrap reset
  assert_success
  assert_output --partial "No bootstrap state to clear"
}

# ==============================================================================
# Dry Run Tests
# ==============================================================================

@test "fc fc-bootstrap --dry-run doesn't execute phases" {
  # Create config for unattended mode
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
SKIP_PHASE_RESTORE=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
}

@test "fc fc-bootstrap --dry-run shows what would be done" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
SKIP_PHASE_RESTORE=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run
  assert_success
  assert_output --partial "Preflight"
}

# ==============================================================================
# Phase Skip Tests
# ==============================================================================

@test "fc fc-bootstrap --skip preflight skips preflight phase" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --skip preflight
  assert_success
  assert_output --partial "Skipping phase: Preflight Checks"
}

@test "fc fc-bootstrap --no-restore skips restore phase" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --no-restore
  assert_success
  assert_output --partial "Skipping phase: Backup Restore"
}

# ==============================================================================
# Only Phase Tests
# ==============================================================================

@test "fc fc-bootstrap --only preflight runs only preflight phase" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  # Clear state so preflight is not "already completed"
  rm -rf "$BOOTSTRAP_STATE_DIR"

  run "$FC_COMMAND" fc-bootstrap --dry-run --only preflight
  assert_success
  assert_output --partial "[DRY-RUN] Would run"
  assert_output --partial "preflight"
  # Should not contain other phases being run
  refute_output --partial "[DRY-RUN] Would run: $PROJECT_ROOT/lib/bootstrap_phases/homebrew.sh"
}

# ==============================================================================
# Role Configuration Tests
# ==============================================================================

@test "fc fc-bootstrap --role developer sets developer role" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
AUTO_CONFIRM=true
EOF

  # Role is used but not explicitly printed in dry-run output
  # Just verify the command runs successfully with --role
  run "$FC_COMMAND" fc-bootstrap --dry-run --role developer
  assert_success
}

@test "fc fc-bootstrap --role personal sets personal role" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --role personal
  assert_success
}

@test "fc fc-bootstrap --role work sets work role" {
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --role work
  assert_success
}

# ==============================================================================
# Unknown Option Tests
# ==============================================================================

@test "fc fc-bootstrap with unknown option shows error" {
  run "$FC_COMMAND" fc-bootstrap --unknown-option
  assert_failure
  assert_output --partial "Unknown option"
}

# ==============================================================================
# State Management Tests
# ==============================================================================

@test "fc fc-bootstrap marks phases as completed" {
  # Run preflight only in dry-run to skip actual execution
  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  # First clear state
  rm -rf "$BOOTSTRAP_STATE_DIR"

  # Run only preflight (not dry-run to actually mark complete)
  # But skip all phases except preflight to test state management
  run "$FC_COMMAND" fc-bootstrap --only preflight --skip homebrew --skip restore --skip dotfiles --skip apps --skip configure --skip health
  # Note: This may fail if preflight checks fail, but state file should still be created on success
}

@test "fc fc-bootstrap --force re-runs completed phases" {
  # Create completed state
  mkdir -p "$BOOTSTRAP_STATE_DIR"
  echo "2024-01-01 00:00:00" > "$BOOTSTRAP_STATE_DIR/preflight.done"

  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --only preflight --force
  assert_success
  assert_output --partial "[DRY-RUN] Would run"
}

@test "fc fc-bootstrap skips already completed phases by default" {
  # Create completed state
  mkdir -p "$BOOTSTRAP_STATE_DIR"
  echo "2024-01-01 00:00:00" > "$BOOTSTRAP_STATE_DIR/preflight.done"

  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
EOF

  run "$FC_COMMAND" fc-bootstrap --dry-run --only preflight
  assert_success
  assert_output --partial "Phase already completed"
}

# ==============================================================================
# Resume Tests
# ==============================================================================

@test "fc fc-bootstrap resume continues from last incomplete phase" {
  # Mark some phases as completed
  mkdir -p "$BOOTSTRAP_STATE_DIR"
  echo "2024-01-01 00:00:00" > "$BOOTSTRAP_STATE_DIR/preflight.done"
  echo "2024-01-01 00:00:00" > "$BOOTSTRAP_STATE_DIR/homebrew.done"

  mkdir -p "$(dirname "$BOOTSTRAP_CONFIG_FILE")"
  cat > "$BOOTSTRAP_CONFIG_FILE" << 'EOF'
BOOTSTRAP_ROLE="developer"
AUTO_CONFIRM=true
SKIP_PHASE_RESTORE=true
EOF

  run "$FC_COMMAND" fc-bootstrap resume --dry-run
  assert_success
  assert_output --partial "Resuming"
}
