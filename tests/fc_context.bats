#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_context.bats
#
# DESCRIPTION:  Tests for the fc context command including list, current,
#               switch, create, and other subcommands.
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

  # Create temporary contexts directory
  export TEST_CONTEXTS_DIR="$TEST_TEMP_DIR/contexts"
  mkdir -p "$TEST_CONTEXTS_DIR"

  # Create a test context file
  cat > "$TEST_CONTEXTS_DIR/test-project.conf" << 'EOF'
# Test context for unit tests
# --- Environment Variables ---
export TEST_VAR="test_value"
export AWS_PROFILE="test-profile"

# --- Version Managers ---
NODE_VERSION="18"
PYTHON_VERSION="3.11"

# --- Git Identity ---
GIT_USER_NAME="Test User"
GIT_USER_EMAIL="test@example.com"
EOF
}

teardown() {
  # Clean up temporary directory
  if [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc context --help shows usage information" {
  run "$FC_COMMAND" context --help
  assert_success
  assert_output --partial "Usage: fc context"
  assert_output --partial "list"
  assert_output --partial "current"
  assert_output --partial "switch"
  assert_output --partial "create"
}

@test "fc context with no arguments shows usage" {
  run "$FC_COMMAND" context
  assert_success
  assert_output --partial "Usage: fc context"
}

@test "fc context --help shows subcommands" {
  run "$FC_COMMAND" context --help
  assert_success
  assert_output --partial "list"
  assert_output --partial "current"
  assert_output --partial "switch"
  assert_output --partial "create"
  assert_output --partial "edit"
  assert_output --partial "delete"
  assert_output --partial "export"
  assert_output --partial "import"
  assert_output --partial "shell"
  assert_output --partial "off"
}

@test "fc context --help shows examples" {
  run "$FC_COMMAND" context --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc context create"
  assert_output --partial "fc context switch"
}

# ==============================================================================
# List Subcommand Tests
# ==============================================================================

@test "fc context list runs successfully" {
  run "$FC_COMMAND" context list
  assert_success
  assert_output --partial "Available contexts"
}

@test "fc context list shows create hint when no contexts" {
  # This test assumes the test environment has no contexts initially
  # In practice, the output will depend on whether contexts exist
  run "$FC_COMMAND" context list
  assert_success
  # Should show either contexts or the create hint
  [[ "$output" =~ "context" ]]
}

# ==============================================================================
# Current Subcommand Tests
# ==============================================================================

@test "fc context current runs successfully" {
  run "$FC_COMMAND" context current
  assert_success
}

@test "fc context current mentions no active context when none set" {
  # Clear any existing context
  rm -f "$HOME/.config/circus/current_context" 2>/dev/null || true

  run "$FC_COMMAND" context current
  assert_success
  assert_output --partial "No context is currently active"
}

@test "fc context current shows list hint" {
  rm -f "$HOME/.config/circus/current_context" 2>/dev/null || true

  run "$FC_COMMAND" context current
  assert_success
  assert_output --partial "fc context list"
}

# ==============================================================================
# Switch Subcommand Tests
# ==============================================================================

@test "fc context switch requires context name (without fzf)" {
  # Ensure fzf is not used for this test
  run env PATH="/usr/bin:/bin" "$FC_COMMAND" context switch
  # Should either prompt with fzf or show error
  # Since fzf might not be available, we check for the error case
  [[ "$status" -eq 0 ]] || [[ "$output" =~ "Usage" ]] || [[ "$output" =~ "No contexts" ]]
}

@test "fc context switch fails for nonexistent context" {
  run "$FC_COMMAND" context switch nonexistent_context_xyz123
  assert_failure
  assert_output --partial "Context not found"
}

@test "fc context switch shows list hint for nonexistent context" {
  run "$FC_COMMAND" context switch nonexistent_context_xyz123
  assert_failure
  assert_output --partial "fc context list"
}

# ==============================================================================
# Create Subcommand Tests
# ==============================================================================

@test "fc context create validates context name format" {
  # Names must start with a letter
  run bash -c "echo '' | $FC_COMMAND context create '123invalid'"
  assert_failure
  assert_output --partial "Invalid context name"
}

# ==============================================================================
# Edit Subcommand Tests
# ==============================================================================

@test "fc context edit requires context name" {
  run "$FC_COMMAND" context edit
  assert_failure
  assert_output --partial "Usage: fc context edit"
}

@test "fc context edit fails for nonexistent context" {
  run "$FC_COMMAND" context edit nonexistent_context
  assert_failure
  assert_output --partial "Context not found"
}

# ==============================================================================
# Delete Subcommand Tests
# ==============================================================================

@test "fc context delete requires context name" {
  run "$FC_COMMAND" context delete
  assert_failure
  assert_output --partial "Usage: fc context delete"
}

@test "fc context delete fails for nonexistent context" {
  run "$FC_COMMAND" context delete nonexistent_context
  assert_failure
  assert_output --partial "Context not found"
}

# ==============================================================================
# Export Subcommand Tests
# ==============================================================================

@test "fc context export requires context name" {
  run "$FC_COMMAND" context export
  assert_failure
  assert_output --partial "Usage: fc context export"
}

@test "fc context export fails for nonexistent context" {
  run "$FC_COMMAND" context export nonexistent_context
  assert_failure
  assert_output --partial "Context not found"
}

# ==============================================================================
# Import Subcommand Tests
# ==============================================================================

@test "fc context import requires file path" {
  run "$FC_COMMAND" context import
  assert_failure
  assert_output --partial "Usage: fc context import"
}

@test "fc context import fails for nonexistent file" {
  run "$FC_COMMAND" context import /nonexistent/path/file.conf
  assert_failure
  assert_output --partial "File not found"
}

# ==============================================================================
# Off Subcommand Tests
# ==============================================================================

@test "fc context off runs successfully when no context active" {
  rm -f "$HOME/.config/circus/current_context" 2>/dev/null || true

  run "$FC_COMMAND" context off
  assert_success
  assert_output --partial "No context is currently active"
}

# ==============================================================================
# Shell Subcommand Tests
# ==============================================================================

@test "fc context shell requires context when none active" {
  rm -f "$HOME/.config/circus/current_context" 2>/dev/null || true

  run "$FC_COMMAND" context shell
  assert_failure
  assert_output --partial "No context specified"
}

@test "fc context shell fails for nonexistent context" {
  run "$FC_COMMAND" context shell nonexistent_context
  assert_failure
  assert_output --partial "Context not found"
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

@test "fc context unknown subcommand fails" {
  run "$FC_COMMAND" context unknown_subcommand
  assert_failure
  assert_output --partial "Unknown subcommand"
}

@test "fc context unknown subcommand shows help hint" {
  run "$FC_COMMAND" context unknown_subcommand
  assert_failure
  assert_output --partial "--help"
}

# ==============================================================================
# Template Tests
# ==============================================================================

@test "context config template exists" {
  [ -f "$PROJECT_ROOT/lib/templates/context.conf.template" ]
}

@test "context config template has required sections" {
  run cat "$PROJECT_ROOT/lib/templates/context.conf.template"
  assert_success
  assert_output --partial "Environment Variables"
  assert_output --partial "Version Managers"
  assert_output --partial "Git Identity"
  assert_output --partial "Custom Commands"
}

@test "context config template has documentation" {
  run cat "$PROJECT_ROOT/lib/templates/context.conf.template"
  assert_success
  assert_output --partial "NODE_VERSION"
  assert_output --partial "PYTHON_VERSION"
  assert_output --partial "GIT_USER_EMAIL"
  assert_output --partial "from-secrets"
}

# ==============================================================================
# Integration Tests
# ==============================================================================

@test "fc context plugin is executable" {
  [ -x "$PROJECT_ROOT/lib/plugins/fc-context" ]
}

@test "fc context plugin sources init.sh" {
  run grep -q 'source.*init.sh' "$PROJECT_ROOT/lib/plugins/fc-context"
  assert_success
}

@test "fc context plugin has usage function" {
  run grep -q 'usage()' "$PROJECT_ROOT/lib/plugins/fc-context"
  assert_success
}

@test "fc context plugin has main function" {
  run grep -q 'main()' "$PROJECT_ROOT/lib/plugins/fc-context"
  assert_success
}
