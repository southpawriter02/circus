# shellcheck shell=bash

BATS_MOCK_TMPDIR="${BATS_TMPDIR}"
BATS_MOCK_BINDIR="${BATS_MOCK_TMPDIR}/bin"

PATH="$BATS_MOCK_BINDIR:$PATH"

stub() {
  local program="$1"
  local prefix
  # `printf '%s'`, not `echo`: echo appends a newline, and `tr -cs '[:alnum:]' '_'`
  # translates that non-alphanumeric character into an underscore. The prefix for
  # `brew` therefore came out as "BREW_" and this exported BREW__STUB_PLAN, while
  # binstub (which derives PROGRAM without a trailing newline) looked for
  # BREW_STUB_PLAN. The variable it needs was never set, so binstub's
  # `[ -e "${!_STUB_PLAN}" ] || exit 1` bailed and EVERY stub in the suite was
  # inert — returning 1 with no output regardless of the plan.
  prefix="$(printf '%s' "$program" | tr '[:lower:]' '[:upper:]' | tr -cs '[:alnum:]' '_')"
  shift

  export "${prefix}_STUB_PLAN"="${BATS_MOCK_TMPDIR}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${BATS_MOCK_TMPDIR}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${BATS_MOCK_BINDIR}"
  ln -sf "${BASH_SOURCE[0]%stub.bash}binstub" "${BATS_MOCK_BINDIR}/${program}"

  touch "${BATS_MOCK_TMPDIR}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${BATS_MOCK_TMPDIR}/${program}-stub-plan"; done
}

stub_repeated() {
  local program="$1"
  # printf, not echo — see stub() above. Here the trailing newline survived the
  # `tr a-z- A-Z_` mapping and produced an invalid variable name, so
  # ${prefix}_STUB_NOINDEX was never actually set and repeated stubs behaved
  # like ordinary sequential ones.
  # shellcheck disable=SC2155
  local prefix="$(printf '%s' "$program" | tr a-z- A-Z_)"
  export "${prefix}_STUB_NOINDEX"=1
  stub "$@"
}

unstub() {
  local program="$1"
  local prefix
  prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${BATS_MOCK_BINDIR}/${program}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  rm -f "$path"
  rm -f "${BATS_MOCK_TMPDIR}/${program}-stub-plan" "${BATS_MOCK_TMPDIR}/${program}-stub-run"
  return "$STATUS"
}
