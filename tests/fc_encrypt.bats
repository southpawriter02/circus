#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_encrypt.bats
#
# DESCRIPTION:  Tests for `fc encrypt`, which had none.
#
#               Two defects found while writing them, both in the --delete path
#               and both pinned by regression tests below:
#
#               1. The original was removed with `rm -f` (files) and `rm -rf`
#                  (folders). That unlinks the plaintext while its contents stay
#                  on disk — precisely what the repository's own S15 secure
#                  delete exists to prevent. lib/security.sh defines and exports
#                  secure_delete and secure_delete_dir, and no plugin was using
#                  either of them.
#
#               2. Nothing verified the ciphertext before destroying the only
#                  copy of the plaintext. A tool can exit 0 having written an
#                  empty or truncated file (a full disk does exactly that), and
#                  --delete is unrecoverable.
#
# COVERAGE NOTE: encryption itself is not driven end to end. Both gpg
#               --symmetric and `openssl enc` read a passphrase from the
#               terminal, and this plugin exposes no way to supply one
#               non-interactively, so a test cannot produce real ciphertext
#               without a pty. The guards around the destructive step are
#               therefore tested directly, and secure_delete's actual behaviour
#               is verified against real files below.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export PLUGIN="$PROJECT_ROOT/lib/plugins/fc-encrypt"
  SCRATCH="$(mktemp -d)"
  export SCRATCH
}

teardown() {
  if [ -n "${SCRATCH:-}" ] && [ -d "$SCRATCH" ]; then
    case "$SCRATCH" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$SCRATCH" ;;
    esac
  fi
  unset SCRATCH
}

# --- Interface ----------------------------------------------------------------

@test "fc encrypt --help shows usage information" {
  run "$FC_COMMAND" encrypt --help
  assert_success
  assert_output --partial "Usage: fc encrypt"
}

@test "fc encrypt --help documents every action" {
  run "$FC_COMMAND" encrypt --help
  assert_success
  assert_output --partial "file"
  assert_output --partial "decrypt"
  assert_output --partial "folder"
  assert_output --partial "text"
}

@test "fc encrypt --help warns that --delete removes the original" {
  run "$FC_COMMAND" encrypt --help
  assert_success
  assert_output --partial "--delete"
}

@test "fc encrypt with no action shows usage" {
  run "$FC_COMMAND" encrypt
  assert_success
  assert_output --partial "Usage: fc encrypt"
}

@test "fc encrypt rejects an unknown action" {
  run "$FC_COMMAND" encrypt not-a-real-action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc-encrypt plugin sources init.sh" {
  run grep "source.*init.sh" "$PLUGIN"
  assert_success
}

# --- Input guards -------------------------------------------------------------

@test "fc encrypt file rejects a missing path argument" {
  run "$FC_COMMAND" encrypt file
  assert_failure
  assert_output --partial "provide a file"
}

@test "fc encrypt file rejects a nonexistent file" {
  run "$FC_COMMAND" encrypt file "$SCRATCH/does-not-exist.txt"
  assert_failure
  assert_output --partial "File not found"
}

@test "fc encrypt folder rejects a missing path argument" {
  run "$FC_COMMAND" encrypt folder
  assert_failure
  assert_output --partial "provide a folder"
}

@test "fc encrypt folder rejects a nonexistent folder" {
  run "$FC_COMMAND" encrypt folder "$SCRATCH/no-such-folder"
  assert_failure
  assert_output --partial "Folder not found"
}

@test "fc encrypt decrypt rejects a nonexistent file" {
  run "$FC_COMMAND" encrypt decrypt "$SCRATCH/does-not-exist.gpg"
  assert_failure
}

# --- Defect 1: plaintext was unlinked, not shredded ---------------------------

@test "fc-encrypt must not remove the original with plain rm" {
  # Comment lines stripped: the fixes explain the old `rm -f` / `rm -rf` in
  # prose, and a naive grep reads that as the bug still being present.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E '^[[:space:]]*rm -[rf]'"
  assert_failure
}

@test "fc-encrypt shreds the original file via S15 secure_delete" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'secure_delete \"\\\$input_path\"'"
  assert_success
}

@test "fc-encrypt shreds the original folder via S15 secure_delete_dir" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'secure_delete_dir \"\\\$input_path\"'"
  assert_success
}

@test "secure_delete and secure_delete_dir are reachable from a plugin" {
  # They are defined in lib/security.sh and exported there. If that export is
  # dropped the plugin's --delete path dies at the point of no return, with the
  # plaintext already the only copy.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               type -t secure_delete; type -t secure_delete_dir"
  assert_success
  assert_line --index 0 "function"
  assert_line --index 1 "function"
}

@test "secure_delete removes a file and reports success" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               printf 'secret\n' > '$SCRATCH/plain.txt'
               secure_delete '$SCRATCH/plain.txt' >/dev/null 2>&1"
  assert_success
  assert [ ! -e "$SCRATCH/plain.txt" ]
}

@test "secure_delete_dir removes a directory and its contents" {
  mkdir -p "$SCRATCH/secretdir"
  printf 'secret\n' > "$SCRATCH/secretdir/a.txt"
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               secure_delete_dir '$SCRATCH/secretdir' >/dev/null 2>&1"
  assert_success
  assert [ ! -e "$SCRATCH/secretdir" ]
}

@test "secure_delete reports failure for a nonexistent file" {
  # The --delete path treats a failed shred as fatal, so this status matters.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               secure_delete '$SCRATCH/never-existed' >/dev/null 2>&1"
  assert_failure
}

@test "get_secure_delete_tool always names a usable strategy" {
  # Returns srm/shred/gshred when present and "fallback" otherwise; "fallback"
  # is a real implementation (dd overwrite), not a no-op.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1; get_secure_delete_tool"
  assert_success
  case "$output" in
    srm|shred|gshred|fallback) ;;
    *) fail "unexpected secure delete tool: $output" ;;
  esac
}

# --- Defect 2: original destroyed without checking the ciphertext -------------

@test "fc-encrypt verifies the ciphertext before deleting the original" {
  # Both destructive paths must refuse when the output is missing or empty.
  run bash -c "grep -c 'Refusing to delete the original' '$PLUGIN'"
  assert_success
  assert [ "$output" -ge 2 ]
}

@test "fc-encrypt guards on a non-empty output file" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -cE '! -s \"\\\$output_path\"'"
  assert_success
  assert [ "$output" -ge 2 ]
}
