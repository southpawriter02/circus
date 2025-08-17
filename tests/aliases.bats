#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         aliases.bats
#
# DESCRIPTION:  Tests to validate that shell aliases are correctly defined and
#               loaded for both the base configuration and specific roles.
#
# ==============================================================================

load 'test_helper'

# --- Test Setup -------------------------------------------------------------
# In this setup function, we simulate the loading of aliases for a specific
# role. This allows us to test the alias files in isolation.

setup() {
  # Source all alias files from the 'developer' role.
  for alias_file in "$PROJECT_ROOT"/roles/developer/aliases/*.sh; do
    if [ -f "$alias_file" ]; then
      source "$alias_file"
    fi
  done
}

# --- Test Cases -------------------------------------------------------------

@test "Developer Aliases: should load a Docker alias" {
  # The `alias` command, when given a name, will print the alias definition
  # if it exists, and fail otherwise.
  run alias dps
  assert_success
  assert_output "alias dps='docker ps'"
}

@test "Developer Aliases: should load a web development alias" {
  run alias npmi
  assert_success
  assert_output "alias npmi='npm install'"
}

@test "Developer Aliases: should NOT load an alias from a different role" {
  # This is a negative test case. It ensures that the aliases for one role
  # are properly isolated and don't leak into others.
  # The `spotify-play` alias belongs to the 'personal' role.
  run alias spotify-play
  assert_failure
  assert_output --partial "alias not found"
}
