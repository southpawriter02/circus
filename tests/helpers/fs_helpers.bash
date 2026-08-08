# ==============================================================================
#
# FILE:         fs_helpers.bash
#
# DESCRIPTION:  File system assertion helpers for Bats tests.
#
# ==============================================================================

assert_file_exist() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "File does not exist: $file"
  fi
}

assert_dir_exist() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "Directory does not exist: $dir"
  fi
}
