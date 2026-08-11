#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_backup.bats
#
# DESCRIPTION:  Tests for `fc backup`.
#
#               The plugin previously had exactly one test, in fc_commands.bats,
#               covering only the "rsync is missing" failure. The body — the
#               part that actually copies the user's dotfiles — had none, and
#               could not have had any:
#
#               1. `RSYNC_CMD` only ever gated. main() resolved
#                  rsync_cmd=${RSYNC_CMD:-rsync}, checked THAT existed, then
#                  invoked a literal `rsync` for the copy. Pointing RSYNC_CMD at
#                  another binary silently had no effect, so the copy could not
#                  be redirected at a stub and the backup path was untestable.
#
#               2. The dependency check ran before --help, so `fc backup --help`
#                  on a machine without rsync answered "This command requires
#                  'rsync'" instead of printing usage. The CI smoke job requires
#                  every plugin to answer --help on a bare macOS install; this
#                  passed only because macOS ships rsync.
#
#               With both fixed the whole flow is exercised below against an
#               isolated HOME and a stub rsync.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export PLUGIN="$PROJECT_ROOT/lib/plugins/fc-backup"

  # HOME isolation FIRST: this plugin reads $HOME/<dotfile> and writes into
  # $HOME/Library/Mobile Documents/... Without this the suite would copy the
  # developer's real .gnupg into a backup directory inside their real iCloud.
  setup_isolated_home

  FAKE_BIN="$(mktemp -d)"
  export FAKE_BIN
  export RSYNC_LOG="$FAKE_BIN/rsync.log"
  : > "$RSYNC_LOG"

  # The stub logs its arguments AND performs the copy. Copying matters: a stub
  # that only logs cannot detect a plaintext leak, because nothing ever reaches
  # the destination for a leak test to find. With a real copy, "no secret in the
  # destination" becomes a genuine assertion rather than a vacuous one.
  cat > "$FAKE_BIN/fake_rsync" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$RSYNC_LOG"
# Mirror `rsync -a SRC DEST/`: last argument is the destination.
dest="${!#}"
for arg in "$@"; do
  case "$arg" in
    -*) continue ;;
  esac
  [ "$arg" = "$dest" ] && continue
  cp -R "$arg" "$dest" 2>/dev/null || true
done
exit 0
STUB
  chmod +x "$FAKE_BIN/fake_rsync"

  export PATH="$FAKE_BIN:$PATH"
  export RSYNC_CMD="fake_rsync"

  BACKUP_BASE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups"
  export BACKUP_BASE
}

teardown() {
  if [ -n "${FAKE_BIN:-}" ] && [ -d "$FAKE_BIN" ]; then
    case "$FAKE_BIN" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$FAKE_BIN" ;;
    esac
  fi
  unset FAKE_BIN RSYNC_LOG RSYNC_CMD BACKUP_BASE
  teardown_isolated_home
}

# --- Interface ----------------------------------------------------------------

@test "fc backup --help shows usage information" {
  run "$FC_COMMAND" backup --help
  assert_success
  assert_output --partial "Usage: fc backup"
}

@test "fc backup --help works even when rsync is unavailable" {
  # The regression: the dependency check used to run first, so --help on a
  # machine without rsync failed instead of printing usage.
  RSYNC_CMD="nonexistent_rsync_xyz" run "$FC_COMMAND" backup --help
  assert_success
  assert_output --partial "Usage: fc backup"
  refute_output --partial "requires 'rsync'"
}

@test "fc backup fails with a clear message when rsync is missing" {
  RSYNC_CMD="nonexistent_rsync_xyz" run "$FC_COMMAND" backup
  assert_failure
  assert_output --partial "This command requires 'rsync'"
}

@test "fc-backup plugin sources init.sh" {
  run grep "source.*init.sh" "$PLUGIN"
  assert_success
}

# --- Defect: RSYNC_CMD was checked but never used -----------------------------

@test "fc-backup must not invoke a literal rsync for the copy" {
  # Comments stripped: the fix explains the old literal call in prose.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E '^[[:space:]]*rsync -a'"
  assert_failure
}

@test "fc-backup dispatches the copy through \$rsync_cmd" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E '\"\\\$rsync_cmd\" -a'"
  assert_success
}

@test "fc backup routes the copy through RSYNC_CMD" {
  # The behavioural half: with RSYNC_CMD pointed at a stub, the stub must be
  # what actually runs. Before the fix this log stayed empty while the real
  # rsync copied files.
  printf 'zshrc\n' > "$HOME/.zshrc"
  run "$FC_COMMAND" backup
  assert_success

  run cat "$RSYNC_LOG"
  assert_success
  assert_output --partial ".zshrc"
}

# --- Backup behaviour ---------------------------------------------------------

@test "fc backup copies each dotfile that exists" {
  printf 'zshrc\n'     > "$HOME/.zshrc"
  printf 'gitconfig\n' > "$HOME/.gitconfig"

  run "$FC_COMMAND" backup
  assert_success

  run cat "$RSYNC_LOG"
  assert_output --partial ".zshrc"
  assert_output --partial ".gitconfig"
}

@test "fc backup skips dotfiles that do not exist" {
  printf 'zshrc\n' > "$HOME/.zshrc"

  run "$FC_COMMAND" backup
  assert_success
  assert_output --partial "Skipping '.gitconfig'"
  assert_output --partial "Items backed up: 1"
}

@test "fc backup reports accurate backed-up and skipped counts" {
  printf 'zshrc\n'     > "$HOME/.zshrc"
  printf 'gitconfig\n' > "$HOME/.gitconfig"

  run "$FC_COMMAND" backup
  assert_success
  # Four candidates: .zshrc .zpreztorc .gitconfig .gnupg — two present here.
  assert_output --partial "Items backed up: 2"
  assert_output --partial "Items skipped: 2"
}

@test "fc backup creates a timestamped destination directory" {
  printf 'zshrc\n' > "$HOME/.zshrc"

  run "$FC_COMMAND" backup
  assert_success
  assert_output --partial "dotfiles-backup-"

  run bash -c "ls -d '$BACKUP_BASE'/dotfiles-backup-* 2>/dev/null | wc -l"
  assert_success
  assert [ "$output" -ge 1 ]
}

@test "fc backup succeeds when no dotfiles are present at all" {
  # An empty HOME must not be an error; everything is simply skipped.
  run "$FC_COMMAND" backup
  assert_success
  assert_output --partial "Items backed up: 0"
}

@test "fc backup writes nothing outside HOME" {
  printf 'zshrc\n' > "$HOME/.zshrc"
  run "$FC_COMMAND" backup
  assert_success
  # Every destination handed to rsync must sit under the isolated HOME.
  run bash -c "grep -v '^\$' '$RSYNC_LOG' | grep -vc '$HOME'"
  assert_output "0"
}

# --- Secrets must never reach the destination in plaintext --------------------
#
# The destination is iCloud Drive. `rsync -a` of ~/.gnupg replicated the user's
# private GPG keyring to Apple's servers and to every other Mac on the account,
# in plaintext. These tests pin the fix: sensitive items are streamed from tar
# into a cipher, and refused outright when no cipher is available.

@test "fc-backup classifies .gnupg as sensitive" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E '_is_sensitive_item'"
  assert_success
  run grep -E '^\s*\.gnupg\|' "$PLUGIN"
  assert_success
}

@test "fc backup never hands a sensitive item to rsync" {
  # The core regression. With .gnupg present and rsync stubbed, .gnupg must not
  # appear in the rsync log at all — it takes the encryption path instead.
  mkdir -p "$HOME/.gnupg"
  printf 'PRIVATE-KEY-MATERIAL\n' > "$HOME/.gnupg/private-key.asc"
  printf 'zshrc\n' > "$HOME/.zshrc"

  run "$FC_COMMAND" backup

  run cat "$RSYNC_LOG"
  refute_output --partial ".gnupg"
  assert_output --partial ".zshrc"
}

@test "fc backup leaves no plaintext secret in the destination when encryption fails" {
  # No tty here, so the cipher cannot read a passphrase and encryption fails.
  # The point is what happens next: the item is dropped, never written plain.
  mkdir -p "$HOME/.gnupg"
  printf 'PRIVATE-KEY-MATERIAL\n' > "$HOME/.gnupg/private-key.asc"

  run "$FC_COMMAND" backup

  run bash -c "grep -rl 'PRIVATE-KEY-MATERIAL' '$BACKUP_BASE' 2>/dev/null | wc -l | tr -d ' '"
  assert_output "0"
}

@test "fc backup fails loudly rather than reporting success when a secret is dropped" {
  mkdir -p "$HOME/.gnupg"
  printf 'PRIVATE-KEY-MATERIAL\n' > "$HOME/.gnupg/private-key.asc"

  run "$FC_COMMAND" backup
  assert_failure
  refute_output --partial "Backup complete!"
  assert_output --partial "NOT backed up"
}

@test "fc-backup refuses a sensitive item when no cipher is available" {
  # Fail closed: the refusal path must exist and must not fall back to a copy.
  run grep -E 'REFUSING to back up' "$PLUGIN"
  assert_success
}

@test "fc-backup streams tar into the cipher without a plaintext temp file" {
  # `tar -czf - ... | <cipher>`: the archive only ever exists in the pipe.
  # lib/security.sh's create_encrypted_backup is deliberately not used because
  # it tars to a temp file and removes it with `rm -f`, leaving the plaintext
  # recoverable.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'tar -czf - -C \"\\\$HOME\" \"\\\$item\"'"
  assert_success

  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'create_encrypted_backup'"
  assert_failure
}

@test "fc-backup removes a partial ciphertext rather than leaving a fake backup" {
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -cE 'rm -f \"\\\$out\"'"
  assert_success
  assert [ "$output" -ge 2 ]
}

# --- Destination permissions --------------------------------------------------

@test "fc backup creates the destination directory mode 0700" {
  # Even with every secret encrypted, the filenames disclose what the machine
  # holds, and the default umask would leave this readable by other accounts.
  printf 'zshrc\n' > "$HOME/.zshrc"
  run "$FC_COMMAND" backup
  assert_success

  local dir
  dir="$(find "$BACKUP_BASE" -maxdepth 1 -type d -name 'dotfiles-backup-*' | head -1)"
  assert [ -n "$dir" ]
  run stat -f '%Sp' "$dir"
  assert_output "drwx------"
}

# --- Configurability ----------------------------------------------------------
#
# The usage text always claimed the location and file list were configurable;
# until now they were hardcoded locals.

@test "fc backup honours CIRCUS_BACKUP_DIR" {
  printf 'zshrc\n' > "$HOME/.zshrc"
  local dest="$HOME/custom-backups"
  CIRCUS_BACKUP_DIR="$dest" run "$FC_COMMAND" backup
  assert_success

  run bash -c "ls -d '$dest'/dotfiles-backup-* 2>/dev/null | wc -l | tr -d ' '"
  assert_output "1"
}

@test "fc backup honours CIRCUS_BACKUP_ITEMS" {
  printf 'zshrc\n'  > "$HOME/.zshrc"
  printf 'inputrc\n' > "$HOME/.inputrc"

  CIRCUS_BACKUP_ITEMS=".inputrc" run "$FC_COMMAND" backup
  assert_success
  assert_output --partial "Items backed up: 1"

  run cat "$RSYNC_LOG"
  assert_output --partial ".inputrc"
  refute_output --partial ".zshrc"
}
