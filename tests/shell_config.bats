#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         shell_config.bats
#
# DESCRIPTION:  Tests for the Zsh shell configuration, including the custom
#               'circus' plugin, aliases, functions, and role-specific settings.
#
# ==============================================================================

load 'test_helper'

# --- Test Setup -------------------------------------------------------------
# This setup function creates a simulated home environment to test the shell
# configuration loading process.

setup() {
  # Create a mock home directory.
  export HOME="$BATS_TMPDIR/home"
  mkdir -p "$HOME"

  # Create the .circus state directory.
  export CIRCUS_STATE_DIR="$HOME/.circus"
  mkdir -p "$CIRCUS_STATE_DIR"

  # Store the real project root in the mock state directory.
  # The plugin will read this to find the roles/.
  echo "$PROJECT_ROOT" > "$CIRCUS_STATE_DIR/root"

  # Source the main plugin file to load all aliases and functions.
  # We source it directly to test its logic in isolation.
  source "$PROJECT_ROOT/profiles/zsh/oh-my-zsh-custom/circus/circus.plugin.zsh"
}

# --- Helper Function to Set Role ---
set_role() {
  echo "$1" > "$CIRCUS_STATE_DIR/role"
  # Re-source the plugin to apply the role.
  source "$PROJECT_ROOT/profiles/zsh/oh-my-zsh-custom/circus/circus.plugin.zsh"
}

# ==============================================================================
# TEST CASES
# ==============================================================================

# --- Core Plugin Tests ------------------------------------------------------

@test "Core: should load a common alias" {
  run alias fwlist
  assert_success
  assert_output "alias fwlist='sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps'"
}

@test "Core: should load a common function" {
  # Check if the function is defined.
  run type mkcd
  assert_success
  # Different shells output different formats for function definitions
  # bash uses "mkcd is a function"
  # zsh uses "mkcd is a shell function"
  assert_output --partial "is a function"
}

# --- Role-Specific Tests ----------------------------------------------------

@test "Roles: should load developer aliases for the 'developer' role" {
  set_role "developer"
  run alias dps
  assert_success
  assert_output "alias dps='docker ps'"
}

@test "Roles: should NOT load developer aliases for the 'personal' role" {
  set_role "personal"
  run alias dps
  assert_failure
  assert_output --partial "alias not found"
}

@test "Roles: should load personal aliases for the 'personal' role" {
  # First, find a personal alias to test.
  # Let's assume there's one in roles/personal/aliases/media.aliases.sh
  # For this test to be robust, let's add one if it doesn't exist.
  local personal_alias_dir="$PROJECT_ROOT/roles/personal/aliases"
  mkdir -p "$personal_alias_dir"
  echo "alias vlc-play='open -a VLC'" > "$personal_alias_dir/media.aliases.sh"

  set_role "personal"
  run alias vlc-play
  assert_success
  assert_output "alias vlc-play='open -a VLC'"
}

@test "Roles: should not load aliases if no role is set" {
  # No role is set by default in the setup.
  run alias dps
  assert_failure
  # Different shells output different messages for missing aliases
  # bash uses "alias: dps: not found"
  # zsh uses "alias: no such alias: dps"
  assert_output --partial "not found"
}
