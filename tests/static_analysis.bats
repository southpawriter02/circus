#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         static_analysis.bats
#
# DESCRIPTION:  This test file uses the `shellcheck` static analysis tool to
#               find common bugs and vulnerabilities in all shell scripts
#               within the repository.
#
# ==============================================================================

load 'test_helper'

# --- Test Cases ---

@test "All shell scripts should pass static analysis" {
  # First, check if shellcheck is installed.
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck not found. Please install it via Homebrew."
  fi

  # Find all shell scripts in the project. This includes:
  # - .sh files
  # - .bash files
  # - .bats files
  # - The `fc` command, which has no extension.
  # We exclude the .git directory from the search.
  local scripts
  scripts=$(find "$PROJECT_ROOT" -path "$PROJECT_ROOT/.git" -prune -o -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.bats" -o -name "fc" \) -print)

  # Run shellcheck on all found scripts.
  # The `-x` flag makes shellcheck follow `source` statements.
  run shellcheck -x $scripts

  # If shellcheck finds any issues, it will exit with a non-zero status code.
  # `assert_success` will catch this and fail the test, displaying the
  # shellcheck output.
  assert_success
}
