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
      topics/*|lib/plugins/template) continue ;;
    esac
    files+=("$f")
  done < <(git ls-files -z '*.sh' 'lib/plugins/fc-*' 'bin/*')

  [ "${#files[@]}" -gt 0 ] || fail "no shell scripts found to analyse"

  # -S warning matches the CI job. .shellcheckrc supplies the disables.
  run shellcheck -S warning -f gcc "${files[@]}"

  # Any finding fails the test and prints shellcheck's output.
  assert_success
}
