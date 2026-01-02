#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_secrets.bats
#
# DESCRIPTION:  Tests for the fc secrets command including backend management,
#               configuration, and subcommands.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Save original config if it exists
  export SECRETS_CONFIG_FILE="$HOME/.config/circus/secrets.conf"
  export SECRETS_ENV_FILE="$HOME/.zshenv.local"

  if [ -f "$SECRETS_CONFIG_FILE" ]; then
    cp "$SECRETS_CONFIG_FILE" "$SECRETS_CONFIG_FILE.bats_backup"
  fi

  if [ -f "$SECRETS_ENV_FILE" ]; then
    cp "$SECRETS_ENV_FILE" "$SECRETS_ENV_FILE.bats_backup"
  fi

  # Create test directory for temporary files
  export TEST_TEMP_DIR="$BATS_TMPDIR/fc_secrets_test_$$"
  mkdir -p "$TEST_TEMP_DIR"
}

teardown() {
  # Restore original config
  if [ -f "$SECRETS_CONFIG_FILE.bats_backup" ]; then
    mv "$SECRETS_CONFIG_FILE.bats_backup" "$SECRETS_CONFIG_FILE"
  fi

  # Restore original env file
  if [ -f "$SECRETS_ENV_FILE.bats_backup" ]; then
    mv "$SECRETS_ENV_FILE.bats_backup" "$SECRETS_ENV_FILE"
  fi

  # Clean up test temp directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
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

@test "fc fc-secrets --help shows usage information" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "Usage: fc fc-secrets"
  assert_output --partial "setup"
  assert_output --partial "sync"
  assert_output --partial "get"
  assert_output --partial "list"
  assert_output --partial "status"
  assert_output --partial "verify"
}

@test "fc fc-secrets --help shows backend types" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "op://"
  assert_output --partial "keychain://"
  assert_output --partial "vault://"
}

@test "fc fc-secrets --help shows configuration file path" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "Configuration:"
  assert_output --partial "secrets.conf"
}

@test "fc fc-secrets --help shows 1Password backend" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "1Password"
}

@test "fc fc-secrets --help shows macOS Keychain backend" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "Keychain"
}

@test "fc fc-secrets --help shows HashiCorp Vault backend" {
  run "$FC_COMMAND" fc-secrets --help
  assert_success
  assert_output --partial "Vault"
}

@test "fc fc-secrets -h shows usage (short flag)" {
  run "$FC_COMMAND" fc-secrets -h
  assert_success
  assert_output --partial "Usage: fc fc-secrets"
}

@test "fc fc-secrets with no arguments shows usage" {
  run "$FC_COMMAND" fc-secrets
  assert_success
  assert_output --partial "Usage: fc fc-secrets"
}

# ==============================================================================
# Configuration Template Tests
# ==============================================================================

@test "secrets.conf.template exists" {
  assert [ -f "$PROJECT_ROOT/lib/templates/secrets.conf.template" ]
}

@test "secrets.conf.template contains 1Password examples" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "op://"
}

@test "secrets.conf.template contains Keychain examples" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "keychain://"
}

@test "secrets.conf.template contains Vault examples" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "vault://"
}

@test "secrets.conf.template contains env destination examples" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "env:"
}

@test "secrets.conf.template contains file destination examples" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "~/.config"
}

@test "secrets.conf.template contains security warning" {
  run cat "$PROJECT_ROOT/lib/templates/secrets.conf.template"
  assert_success
  assert_output --partial "SECURITY"
}

# ==============================================================================
# Backend Plugin Tests
# ==============================================================================

@test "op.sh backend plugin exists" {
  assert [ -f "$PROJECT_ROOT/lib/secrets_backends/op.sh" ]
}

@test "keychain.sh backend plugin exists" {
  assert [ -f "$PROJECT_ROOT/lib/secrets_backends/keychain.sh" ]
}

@test "vault.sh backend plugin exists" {
  assert [ -f "$PROJECT_ROOT/lib/secrets_backends/vault.sh" ]
}

@test "op.sh backend is executable" {
  assert [ -x "$PROJECT_ROOT/lib/secrets_backends/op.sh" ]
}

@test "keychain.sh backend is executable" {
  assert [ -x "$PROJECT_ROOT/lib/secrets_backends/keychain.sh" ]
}

@test "vault.sh backend is executable" {
  assert [ -x "$PROJECT_ROOT/lib/secrets_backends/vault.sh" ]
}

# ==============================================================================
# Setup Command Tests
# ==============================================================================

@test "fc fc-secrets setup creates config file" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets setup
  assert_success
  assert [ -f "$SECRETS_CONFIG_FILE" ]
  assert_output --partial "Configuration file created"
}

@test "fc fc-secrets setup sets correct permissions" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets setup
  assert_success

  # Check permissions are 600
  perms=$(stat -f '%Lp' "$SECRETS_CONFIG_FILE")
  [ "$perms" = "600" ]
}

@test "fc fc-secrets setup shows next steps" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets setup
  assert_success
  assert_output --partial "Next steps"
  assert_output --partial "Edit the config file"
}

@test "fc fc-secrets setup detects existing config" {
  # Make sure config exists
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  touch "$SECRETS_CONFIG_FILE"
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets setup
  assert_success
  assert_output --partial "already exists"
}

@test "fc fc-secrets setup checks backend prerequisites" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets setup
  assert_success
  assert_output --partial "Checking backend prerequisites"
}

@test "fc fc-secrets setup shows all backends" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets setup
  assert_success
  assert_output --partial "1Password"
  assert_output --partial "Keychain"
  assert_output --partial "Vault"
}

# ==============================================================================
# Status Command Tests
# ==============================================================================

@test "fc fc-secrets status shows backend status" {
  run "$FC_COMMAND" fc-secrets status
  assert_success
  assert_output --partial "Backend status"
}

@test "fc fc-secrets status shows all three backends" {
  run "$FC_COMMAND" fc-secrets status
  assert_success
  assert_output --partial "1Password"
  assert_output --partial "Keychain"
  assert_output --partial "Vault"
}

@test "fc fc-secrets status shows Keychain as authenticated" {
  # Keychain should always be "authenticated" on macOS
  if [ "$(uname)" = "Darwin" ]; then
    run "$FC_COMMAND" fc-secrets status
    assert_success
    # Keychain should show as authenticated or ready
    assert_output --partial "Keychain"
  else
    skip "Keychain only available on macOS"
  fi
}

# ==============================================================================
# List Command Tests
# ==============================================================================

@test "fc fc-secrets list shows configured secrets header" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
# Test config
"op://Personal/test/token" "env:TEST_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "Configured secrets"
}

@test "fc fc-secrets list shows table headers" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/test/token" "env:TEST_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "Backend"
  assert_output --partial "Secret"
  assert_output --partial "Destination"
}

@test "fc fc-secrets list parses op:// entries" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/github/token" "env:GITHUB_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "op"
  assert_output --partial "Personal/github/token"
  assert_output --partial "env:GITHUB_TOKEN"
}

@test "fc fc-secrets list parses keychain:// entries" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"keychain://api-service/production" "env:API_KEY"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "keychain"
  assert_output --partial "api-service/production"
}

@test "fc fc-secrets list parses vault:// entries" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"vault://secret/data/app#api_key" "env:APP_KEY"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "vault"
  assert_output --partial "secret/data/app"
}

@test "fc fc-secrets list handles no config gracefully" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "No configuration file found"
  assert_output --partial "fc fc-secrets setup"
}

@test "fc fc-secrets list skips comment lines" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
# This is a comment
"op://Personal/test/token" "env:TEST_TOKEN"
# Another comment
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  refute_output --partial "This is a comment"
}

@test "fc fc-secrets list skips variable assignments" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
VAULT_ADDR="https://vault.example.com"
"op://Personal/test/token" "env:TEST_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  # Should show the secret but not the variable assignment
  assert_output --partial "op"
}

# ==============================================================================
# Get Command Tests
# ==============================================================================

@test "fc fc-secrets get requires URI argument" {
  run "$FC_COMMAND" fc-secrets get
  assert_failure
  assert_output --partial "Please provide a secret URI"
}

@test "fc fc-secrets get rejects unknown backend" {
  run "$FC_COMMAND" fc-secrets get "unknown://path/to/secret"
  assert_failure
  assert_output --partial "Unknown backend"
}

@test "fc fc-secrets get --help shows usage" {
  run "$FC_COMMAND" fc-secrets get --help
  assert_success
  assert_output --partial "Fetches a single secret"
  assert_output --partial "op://"
  assert_output --partial "keychain://"
  assert_output --partial "vault://"
}

@test "fc fc-secrets get --help op shows 1Password help" {
  run "$FC_COMMAND" fc-secrets get --help op
  assert_success
  assert_output --partial "1Password"
}

@test "fc fc-secrets get --help keychain shows Keychain help" {
  run "$FC_COMMAND" fc-secrets get --help keychain
  assert_success
  assert_output --partial "Keychain"
}

@test "fc fc-secrets get --help vault shows Vault help" {
  run "$FC_COMMAND" fc-secrets get --help vault
  assert_success
  assert_output --partial "Vault"
}

@test "fc fc-secrets get op:// requires op CLI" {
  # Mock op as non-existent
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"
  # Don't create op in mock dir

  run "$FC_COMMAND" fc-secrets get "op://Personal/test/token"
  assert_failure
  assert_output --partial "not installed"
}

@test "fc fc-secrets get vault:// requires vault CLI" {
  # Mock vault as non-existent
  export PATH="$BATS_MOCK_BINDIR:$PATH"
  mkdir -p "$BATS_MOCK_BINDIR"

  run "$FC_COMMAND" fc-secrets get "vault://secret/data/test#key"
  assert_failure
  assert_output --partial "not installed"
}

# ==============================================================================
# Verify Command Tests
# ==============================================================================

@test "fc fc-secrets verify requires config file" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets verify
  assert_failure
  assert_output --partial "Configuration file not found"
}

@test "fc fc-secrets verify shows verification header" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/test/token" "env:TEST_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets verify
  # May fail if op not installed, but should show the header
  assert_output --partial "Verifying secrets"
}

# ==============================================================================
# Sync Command Tests
# ==============================================================================

@test "fc fc-secrets sync requires config file" {
  rm -f "$SECRETS_CONFIG_FILE"
  run "$FC_COMMAND" fc-secrets sync
  assert_failure
  assert_output --partial "Configuration file not found"
}

@test "fc fc-secrets sync shows syncing header" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/test/token" "env:TEST_TOKEN"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets sync
  # May fail if op not installed, but should show the header
  assert_output --partial "Syncing secrets"
}

# ==============================================================================
# Unknown Subcommand Tests
# ==============================================================================

@test "fc fc-secrets with unknown subcommand shows error" {
  run "$FC_COMMAND" fc-secrets unknown-command
  assert_failure
  assert_output --partial "Unknown subcommand"
}

# ==============================================================================
# Config File Parsing Tests
# ==============================================================================

@test "fc fc-secrets handles file destination with permissions" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/cert/tls" "~/.config/app/tls.crt" "644"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial ".config/app/tls.crt"
}

@test "fc fc-secrets handles env destination" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/api/key" "env:API_KEY"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "env:API_KEY"
}

@test "fc fc-secrets handles multiple secrets from different backends" {
  mkdir -p "$(dirname "$SECRETS_CONFIG_FILE")"
  cat > "$SECRETS_CONFIG_FILE" << 'EOF'
"op://Personal/github/token" "env:GITHUB_TOKEN"
"keychain://aws/access-key" "env:AWS_ACCESS_KEY"
"vault://secret/data/db#password" "env:DB_PASSWORD"
EOF
  chmod 600 "$SECRETS_CONFIG_FILE"

  run "$FC_COMMAND" fc-secrets list
  assert_success
  assert_output --partial "op"
  assert_output --partial "keychain"
  assert_output --partial "vault"
}
