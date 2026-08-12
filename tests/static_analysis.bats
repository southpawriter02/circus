#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         static_analysis.bats
#
# DESCRIPTION:  Runs shellcheck across the repository's shell scripts.
#
#               This test was previously `skip`ped unconditionally, with the
#               note "failing with a large number of errors that are out of
#               scope". It is enabled now that those findings have been dealt
#               with: the genuine ones were fixed, and the handful of
#               intentional patterns carry inline `# shellcheck disable`
#               directives explaining why.
#
#               Severity and repo-wide suppressions live in .shellcheckrc so
#               that this test and the CI job enforce exactly the same rules.
#
# ==============================================================================

load 'test_helper'

# --- Test Cases ---

@test "All shell scripts should pass static analysis" {
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck not found. Install it with: brew install shellcheck"
  fi

  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  # Build the file list with git, NUL-delimited.
  #
  # The previous version used `find` and then passed an unquoted $scripts to
  # shellcheck. That split on whitespace, so every path containing a space —
  # etc/alfred/workflows/Flying Circus/... — was passed as two nonexistent
  # filenames. shellcheck reported "does not exist" for those and silently
  # analysed nothing for them.
  #
  # Two exclusions:
  #   topics/*             - zsh, which shellcheck cannot parse (SC1071)
  #   lib/plugins/template - a scaffold containing deliberate placeholders
  local files=()
  local f
  while IFS= read -r -d '' f; do
    case "$f" in
      # Vendored upstream libraries: not ours to fix, and their findings would
      # drown out ours. bats-mock is NOT excluded -- we patch it.
      topics/*|lib/plugins/template) continue ;;
      tests/helpers/bats-assert/*|tests/helpers/bats-support/*|tests/helpers/bats-core/*) continue ;;
    esac
    files+=("$f")
  #
  # The test harness is in scope too. It was omitted at first, and that is
  # exactly where an unlinted defect cost the most: an `echo` in stub.bash
  # appended a newline to a variable-name prefix, so every stub in the suite
  # exported a name the stub binary never read and silently did nothing.
  done < <(git ls-files -z '*.sh' '*.bash' 'lib/plugins/fc-*' 'bin/*' \
             'tests/helpers/bats-mock/stub' 'tests/helpers/bats-mock/binstub')

  [ "${#files[@]}" -gt 0 ] || fail "no shell scripts found to analyse"

  # -S warning matches the CI job. .shellcheckrc supplies the disables.
  run shellcheck -S warning -f gcc "${files[@]}"

  # Any finding fails the test and prints shellcheck's output.
  assert_success
}

# ==============================================================================
# GitHub Actions workflow validity
# ==============================================================================
#
# The workflow file is the one thing in this repository that cannot fail loudly.
# A single stray character at column 1 inside a `run: |` block terminates the
# block scalar, makes the whole file unparseable, and GitHub then runs NO jobs
# at all — no smoke test, no bats suite, no installer dry run, no shellcheck.
# Every guard the CI file describes silently stops existing, and a green
# "nothing to report" is indistinguishable from a working pipeline.
#
# This actually happened: `.github/workflows/ci.yml` carried a literal "@2" at
# the start of line 156 and parsed as invalid YAML.
#
# Ruby is used as the parser because it ships with macOS and both GitHub runner
# images, and YAML is in its standard library — unlike Python, where pyyaml is
# not guaranteed to be present.

@test "every GitHub Actions workflow is valid YAML" {
  if ! command -v ruby >/dev/null 2>&1; then
    skip "ruby not available to parse YAML"
  fi

  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  local failed=0
  for wf in .github/workflows/*.yml .github/workflows/*.yaml; do
    [ -f "$wf" ] || continue
    if ! ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$wf" 2>/dev/null; then
      echo "invalid YAML: $wf" >&2
      ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$wf" 2>&1 | head -3 >&2
      failed=1
    fi
  done

  [ "$failed" -eq 0 ]
}

@test "every workflow declares at least one job" {
  # A file can parse as YAML and still define nothing runnable.
  if ! command -v ruby >/dev/null 2>&1; then
    skip "ruby not available to parse YAML"
  fi

  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  for wf in .github/workflows/*.yml .github/workflows/*.yaml; do
    [ -f "$wf" ] || continue
    run ruby -ryaml -e 'd = YAML.load_file(ARGV[0]); exit((d["jobs"] || {}).empty? ? 1 : 0)' "$wf"
    [ "$status" -eq 0 ] || fail "no jobs defined in $wf"
  done
}

@test "the CI workflow still defines the jobs it documents" {
  # Each of these exists because its absence let a specific class of breakage
  # ship unnoticed; losing one to an edit should fail here rather than quietly
  # reduce coverage.
  if ! command -v ruby >/dev/null 2>&1; then
    skip "ruby not available to parse YAML"
  fi

  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  run ruby -ryaml -e 'puts (YAML.load_file(".github/workflows/ci.yml")["jobs"] || {}).keys.sort.join(",")'
  assert_success
  assert_output "installer,shellcheck,smoke,tests"
}

@test "no workflow run-block line starts at column 1" {
  # The specific corruption: a line at column 1 inside a `run: |` block ends the
  # block scalar early. Catch it directly, so the failure names the cause rather
  # than only reporting "invalid YAML".
  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  local offenders
  offenders=$(grep -nE '^[^[:space:]#]' .github/workflows/*.yml 2>/dev/null \
              | grep -vE ':(name|on|jobs|concurrency|env|permissions|defaults):' || true)

  if [ -n "$offenders" ]; then
    echo "unexpected column-1 content in a workflow:" >&2
    echo "$offenders" >&2
    return 1
  fi
}

# ==============================================================================
# Dry-run integrity of the defaults/ tree
# ==============================================================================
#
# install/11-defaults-and-additional-configuration.sh sources every
# defaults/**/*.sh except defaults/profiles/, so anything mutating at the top
# level of one of those files runs during `./install.sh --dry-run`.
#
# The CI file already records this class of defect: energy.sh once made 17 real
# `sudo pmset` calls during a "dry" run. The installer job only asserts the dry
# run exits 0, so a mutation that succeeds is indistinguishable from one that
# was correctly skipped.
#
# Most files route through run_defaults(), which checks the flag itself. The
# exception was defaults/system/login.sh, whose direct `sudo defaults delete`
# really did remove the system autoLoginUser key on every dry run.

@test "no mutating command in the sourced defaults tree escapes a dry-run guard" {
  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  local offenders=""

  while IFS= read -r file; do
    [ -f "$file" ] || continue

    while IFS=: read -r ln _; do
      [ -n "$ln" ] || continue
      # 40 lines, not 12. A guard commonly sits at the top of an if/else whose
      # body runs long: auto_updates.sh puts `launchctl load` inside the else of
      # a DRY_RUN_MODE check ~16 lines above, and a 12-line window reported it
      # as unguarded. The window only has to be wide enough to reach the
      # enclosing check; a file with no guard at all is caught regardless.
      local start=$((ln - 40))
      [ "$start" -lt 1 ] && start=1
      # A guard is DRY_RUN_MODE appearing as CODE in the enclosing block just
      # above. Comment lines are stripped first: the explanation sitting above a
      # guarded call names DRY_RUN_MODE in prose, and counting that made this
      # check pass against an unguarded call — verified by mutation.
      if ! sed -n "${start},${ln}p" "$file" | grep -vE '^[[:space:]]*#' \
           | grep -qE 'DRY_RUN_MODE|run_sudo|run_defaults|run_socketfilterfw'; then
        offenders+="  $file:$ln"$'\n'
      fi
      # Matches the command ANYWHERE on the line, not just at the start.
      # `if sudo tmutil enable; then` and `x=$(sudo ...)` are both shapes this
      # tree actually uses, and a line-anchored pattern silently skipped them —
      # so the check passed while three files went unexamined.
      #
      # The leading [^_[:alnum:]-] guard means run_sudo/run_defaults do NOT
      # match: those ARE the dry-run-aware wrappers.
      #
      # Comment lines are filtered AFTER numbering, not before: numbering a
      # pre-filtered stream yields line numbers that do not correspond to the
      # file, so the guard lookup below would read the wrong lines entirely.
      #
      # Message text is excluded — several files legitimately print advice like
      # "Use 'sudo systemsetup -settimezone ...'" without running anything.
    done < <(grep -nE '(^|[^_[:alnum:]-])(sudo|defaults write|defaults delete|systemsetup|pmset|spctl|launchctl|chflags|nvram)[[:space:]]' "$file" 2>/dev/null \
             | grep -vE '^[0-9]+:[[:space:]]*#' \
             | grep -vE 'msg_info|msg_warning|msg_success|msg_error|echo ')

  done < <(find "$PROJECT_ROOT/defaults" -path '*/profiles/*' -prune -o -name '*.sh' -print | sed "s|$PROJECT_ROOT/||")

  if [ -n "$offenders" ]; then
    echo "mutating commands reachable from a dry run without a DRY_RUN_MODE guard:" >&2
    printf '%s' "$offenders" >&2
    echo "route these through run_defaults/run_sudo, or guard them explicitly" >&2
    return 1
  fi
}

@test "defaults/system/login.sh guards its direct sudo calls" {
  # The specific regression, named so a failure points at the cause.
  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"
  # Comments stripped — the rationale above the guard names DRY_RUN_MODE too.
  run bash -c "grep -vE '^[[:space:]]*#' defaults/system/login.sh | grep -c 'DRY_RUN_MODE'"
  assert_success
  assert [ "$output" -ge 1 ]
}

@test "run_defaults and run_sudo both honour DRY_RUN_MODE" {
  # These are the two helpers the defaults tree relies on for dry-run safety;
  # if either stops checking the flag, the whole tree silently starts mutating.
  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  run bash -c "sed -n '/^run_defaults()/,/^}/p' lib/helpers.sh | grep -vE '^[[:space:]]*#' | grep -c 'DRY_RUN_MODE'"
  assert_success
  assert [ "$output" -ge 1 ]

  run bash -c "sed -n '/^run_sudo()/,/^}/p' lib/helpers.sh | grep -vE '^[[:space:]]*#' | grep -c 'DRY_RUN_MODE'"
  assert_success
  assert [ "$output" -ge 1 ]
}

# ==============================================================================
# README accuracy
# ==============================================================================
#
# The README's status table distinguishes controls that are wired into a command
# (✅ Active) from ones that exist but nothing calls (🔌 Available). That
# distinction is only useful while it is true, and it drifts silently: a control
# gets wired up and the table still says Available, or a table entry names a
# command that was renamed or never existed.
#
# This checks the half that is mechanically verifiable — every `fc <command>`
# the README mentions must actually resolve to a plugin.

@test "every fc command named in the README exists as a plugin" {
  cd "$PROJECT_ROOT" || fail "could not enter \$PROJECT_ROOT"

  local missing=""
  local cmd

  # Only inside inline code spans: `fc audit permissions`. Prose such as
  # "Run 'fc <command> --help'" mentions fc followed by a placeholder word, and
  # matching bare text would flag `fc command` / `fc commands` as missing.
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    case "$cmd" in
      -*|'') continue ;;
    esac
    if [ ! -x "lib/plugins/fc-$cmd" ]; then
      missing+="  fc $cmd"$'\n'
    fi
  done < <(grep -ohE '`fc [a-z][a-z0-9-]*' README.md \
           | sed 's/^`fc //' | sort -u)

  if [ -n "$missing" ]; then
    echo "README references commands with no matching plugin:" >&2
    printf '%s' "$missing" >&2
    return 1
  fi
}
