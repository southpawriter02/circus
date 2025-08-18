#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         project_structure.bats
#
# DESCRIPTION:  Tests to validate the basic structure of the dotfiles project.
#
# ==============================================================================

# Source the test helper to get access to our setup, teardown, and helper functions.
load 'test_helper'
# Explicitly load bats-assert because it seems to be failing in this file.
source "/home/linuxbrew/.linuxbrew/lib/bats-assert/load.bash"

# --- Test Cases ---

@test "Project should have an install.sh script" {
  assert_file_exist "$PROJECT_ROOT/install.sh"
}

@test "Project should have a roles directory" {
  assert_dir_exist "$PROJECT_ROOT/roles"
}

@test "Project should have a developer role" {
  assert_dir_exist "$PROJECT_ROOT/roles/developer"
}

@test "Project should have a personal role" {
  assert_dir_exist "$PROJECT_ROOT/roles/personal"
}

@test "Project should have a work role" {
  assert_dir_exist "$PROJECT_ROOT/roles/work"
}
