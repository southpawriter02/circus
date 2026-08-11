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
