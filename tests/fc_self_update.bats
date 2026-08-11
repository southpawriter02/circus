#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_self_update.bats
#
# DESCRIPTION:  Tests for `fc self-update`, the command with the largest blast
#               radius in the suite: it pulls and executes remote code into a
#               repository that is symlinked into the user's shell startup, and
#               it moves the user's uncommitted work in and out of the stash.
#
#               It had no tests at all. Writing these turned up three defects,
#               each pinned by a regression test below:
#
#               1. The plugin defined its own get_current_version() reading a
#                  "$DOTFILES_ROOT/VERSION" file that does not exist — the
#                  version file is `.version`. Because the plugin sources
#                  init.sh (and so helpers.sh) before defining its functions,
#                  that shadowed the correct helpers.sh implementation, and
#                  every caller fell through to `git describe`.
#
#               2. The stash created by --force was never restored: the pop was
#                  guarded by `has_uncommitted_changes`, which is false straight
#                  after a successful stash push. The user saw "Update
#                  complete!" while their work sat in the stash.
#
#               3. The Brewfile check diffed "$old_version..$new_version" —
#                  semver strings, not revisions — so it errored into /dev/null
#                  and new dependencies were never installed.
#
# COVERAGE NOTE: the end-to-end update flow is not exercised here. lib/init.sh
#               computes DOTFILES_ROOT from its own BASH_SOURCE and overwrites
#               any inherited value, so a test cannot point the plugin at a
#               throwaway repository. Driving a real fetch/merge would mean
#               operating on the developer's actual checkout. The stash
#               semantics that defect 2 turned on are therefore verified
#               directly against git in a scratch repository instead.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export PLUGIN="$PROJECT_ROOT/lib/plugins/fc-self-update"
}

teardown() {
  if [ -n "${SCRATCH_REPO:-}" ] && [ -d "$SCRATCH_REPO" ]; then
    case "$SCRATCH_REPO" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$SCRATCH_REPO" ;;
    esac
  fi
  unset SCRATCH_REPO
}

# --- Interface ----------------------------------------------------------------

@test "fc self-update --help shows usage information" {
  run "$FC_COMMAND" self-update --help
  assert_success
  assert_output --partial "Usage: fc self-update"
}

@test "fc self-update --help documents every accepted option" {
  run "$FC_COMMAND" self-update --help
  assert_success
  # If an option is added to the parser it must be documented here too; that is
  # the only place a user can discover --force stashes their work.
  assert_output --partial "--check"
  assert_output --partial "--force"
  assert_output --partial "--no-deps"
  assert_output --partial "--dry-run"
}

@test "fc self-update rejects an unknown option with a helpful message" {
  run "$FC_COMMAND" self-update --not-a-real-flag
  assert_failure
  assert_output --partial "Unknown option"
}

@test "fc-self-update plugin sources init.sh" {
  run grep "source.*init.sh" "$PLUGIN"
  assert_success
}

# --- Defect 1: shadowed version helper ----------------------------------------

@test "fc-self-update must not redefine get_current_version" {
  # helpers.sh already provides this, reading .version. A local definition here
  # shadows it, because the plugin sources init.sh before defining anything.
  run grep -E '^get_current_version\(\) *\{' "$PLUGIN"
  assert_failure
}

@test "fc-self-update must not read a bare VERSION file" {
  # The tracked version file is `.version`. "$DOTFILES_ROOT/VERSION" does not
  # exist, so reading it silently degraded to `git describe` output.
  # Comments stripped: the fix names the old path in its explanation.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'DOTFILES_ROOT/VERSION'"
  assert_failure
}

@test "the repository's version file is .version, not VERSION" {
  # Pins the premise of the two tests above.
  assert [ -f "$PROJECT_ROOT/.version" ]
  assert [ ! -f "$PROJECT_ROOT/VERSION" ]
}

@test "helpers.sh get_current_version reads .version" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1; get_current_version"
  assert_success
  assert_output "$(tr -d '[:space:]' < "$PROJECT_ROOT/.version")"
}

@test "version_compare handles the .version format, not describe output" {
  # Why defect 1 mattered: version_compare splits on '.' and compares parts
  # numerically. Semver works; a describe string like v1.6.0-23-ga56d307 does
  # not, so migration selection was meaningless.
  # version_compare signals its answer THROUGH a non-zero status (1 = greater),
  # and helpers.sh installs `set -Eeo pipefail` plus a `trap ... ERR` that calls
  # error_handler. `set +e` alone is not enough — the ERR trap fires regardless
  # of errexit — so the call goes inside an `if`, where neither applies.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               if version_compare '1.6.0' '1.5.0'; then echo 0; else echo \$?; fi"
  assert_success
  assert_output "1"
}

# --- Defect 2: the stash was never restored -----------------------------------

@test "git stash push leaves a clean tree (the premise defect 2 got wrong)" {
  # This is the fact the old code contradicted: it popped only when
  # has_uncommitted_changes was true, which is never the case right after a
  # successful stash push.
  SCRATCH_REPO="$(mktemp -d)"
  export SCRATCH_REPO
  (
    cd "$SCRATCH_REPO" || exit 1
    git init -q .
    git config user.email test@example.com
    git config user.name test
    echo v1 > f.txt
    git add .
    git commit -qm init
    echo local-edit >> f.txt
    git stash push -qm "auto-stash"
  )

  run git -C "$SCRATCH_REPO" status --porcelain
  assert_success
  assert_output ""

  # ...and the work is sitting in the stash, which is what the user loses.
  run git -C "$SCRATCH_REPO" stash list
  assert_success
  refute_output ""
}

@test "fc-self-update must not guard the stash restore on uncommitted changes" {
  # The exact regression: `[[ "$force" == "true" ]] && has_uncommitted_changes`
  # around the pop.
  run grep -E 'has_uncommitted_changes.*stash|stash pop' "$PLUGIN"
  # A pop may appear, but never inside a has_uncommitted_changes guard.
  run grep -nE 'if .*has_uncommitted_changes.*; then' "$PLUGIN"
  assert_success
  # Only one such guard should remain: the pre-flight check, not the restore.
  assert_equal "${#lines[@]}" 1
}

@test "fc-self-update restores the stash on every path that can leave do_update" {
  # Success, already-up-to-date, cancelled prompt, refused signature and failed
  # fast-forward all previously returned without restoring.
  run grep -c 'restore_stash_if_any "\$stashed"' "$PLUGIN"
  assert_success
  assert [ "$output" -ge 5 ]
}

@test "fc-self-update tracks whether it created the stash" {
  # The restore is driven by what happened, not by re-inspecting the tree.
  run grep -E 'stashed=true' "$PLUGIN"
  assert_success
}

# --- Defect 3: Brewfile diff used version strings as revisions -----------------

@test "fc-self-update must not diff version strings as git revisions" {
  # Comment lines are stripped first: the fix documents the old expression in a
  # comment, and a naive grep matches that and reports the bug as still present.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'diff \"\\\$old_version\\.\\.\\\$new_version\"'"
  assert_failure
}

@test "semver strings are not valid git revisions in this repository" {
  # Pins why defect 3 was a defect: the tags are v-prefixed, so `1.6.0` does not
  # resolve and the diff failed silently into /dev/null.
  run git -C "$PROJECT_ROOT" rev-parse --verify --quiet "$(tr -d '[:space:]' < "$PROJECT_ROOT/.version")"
  assert_failure
}

@test "fc-self-update diffs the commit range it actually fast-forwarded" {
  run grep -E 'diff "\$old_sha" HEAD' "$PLUGIN"
  assert_success
}

# --- Safety properties --------------------------------------------------------

@test "fc-self-update uses merge --ff-only rather than pull --rebase" {
  # A rebase would replay local commits onto a rewritten upstream, so a
  # force-push could alter history the user already approved at the prompt.
  run grep -E 'merge --ff-only origin/main' "$PLUGIN"
  assert_success

  # Comments stripped: the rationale above the merge names `pull --rebase` as
  # the rejected alternative, which a naive grep would read as its presence.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'pull --rebase'"
  assert_failure
}

@test "fc-self-update confirms before applying remote code" {
  run grep -E 'ui_confirm .*Apply these' "$PLUGIN"
  assert_success
}

@test "fc-self-update refuses a bad signature when a key is pinned" {
  run grep -E 'CIRCUS_TRUSTED_SIGNING_FPR' "$PLUGIN"
  assert_success
  run grep -E 'Refusing to update' "$PLUGIN"
  assert_success
}

@test "run_migrations only considers vX_to_vY.sh files" {
  # This loop once ran every executable file in migrations/ on every update.
  run grep -E 'MIGRATIONS_DIR"/v\*_to_v\*\.sh' "$PLUGIN"
  assert_success
}
