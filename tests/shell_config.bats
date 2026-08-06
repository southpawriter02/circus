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
  # Per-test HOME, not "$BATS_TMPDIR/home".
  #
  # BATS_TMPDIR is shared across the whole run, so the role file written by one
  # test survived into the next test's setup() — which sources the plugin before
  # that test sets its own role. The "personal role must NOT load developer
  # aliases" test therefore saw developer aliases left over from the preceding
  # developer test, and failed for a reason that had nothing to do with the
  # plugin's role logic.
  setup_isolated_home

  # Create the .circus state directory.
  export CIRCUS_STATE_DIR="$HOME/.circus"
  mkdir -p "$CIRCUS_STATE_DIR"

  # Store the real project root in the mock state directory.
  # The plugin will read this to find the roles/.
  echo "$PROJECT_ROOT" > "$CIRCUS_STATE_DIR/root"

  # Source the main plugin file to load all aliases and functions.
  # We source it directly to test its logic in isolation.
  #
  # errexit is disabled around the source deliberately. These files are shell
  # STARTUP files, read by an interactive zsh where `set -e` is never active,
  # and they legitimately use `[[ -d ... ]] && add_to_path` one-liners. Such a
  # line returns non-zero whenever the optional tool is absent, so under errexit
  # the whole plugin aborts on whichever tool this particular machine lacks —
  # here SDKMAN, via env/java.env.sh. Sourcing without errexit matches how these
  # files are actually used.
  set +e
  source "$PROJECT_ROOT/profiles/base/zsh/oh-my-zsh-custom/circus/circus.plugin.zsh"
  set -e
}

teardown() {
  # Restore the real HOME and remove the temporary one.
  teardown_isolated_home
}

# --- Helper Function to Set Role ---
set_role() {
  echo "$1" > "$CIRCUS_STATE_DIR/role"
  # Re-source the plugin to apply the role. See setup() for why errexit is off.
  set +e
  source "$PROJECT_ROOT/profiles/base/zsh/oh-my-zsh-custom/circus/circus.plugin.zsh"
  set -e
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
  # Match only "not found", as the sibling test below already does: bash prints
  # "alias: dps: not found" and zsh "alias: no such alias: dps", so the previous
  # "alias not found" matched neither shell.
  assert_output --partial "not found"
}

@test "Roles: should load personal aliases for the 'personal' role" {
  # Assert against an alias the repository already ships.
  #
  # This test used to `echo "alias vlc-play=..." > roles/personal/aliases/
  # media.aliases.sh`, overwriting a real 108-line source file in the working
  # tree with a single line — on every run. A test must not modify the
  # repository it is testing.
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
