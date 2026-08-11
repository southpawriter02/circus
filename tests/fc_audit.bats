#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_audit.bats
#
# DESCRIPTION:  Tests for `fc audit`, which had none.
#
#               Covers the existing system checks and, in particular, the log
#               viewers resurrected from lib/security.sh.
#
#               S21 (security event log), S23 (failed operations) and S28
#               (network request log) each defined and exported a set of viewer
#               functions that nothing in the repository called. The producing
#               side was live — security_event() had already written 33 events
#               to ~/.circus/security_audit.log on this machine — but there was
#               no way to read any of it back. A security log nobody can read is
#               not an audit trail.
#
# ISOLATION:    Every test points the three log paths at a temporary directory.
#               `fc audit clear-failures` DELETES a log, so a test that used the
#               real path would destroy the developer's audit history.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
  export PROJECT_ROOT
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export FC_COMMAND="$PROJECT_ROOT/bin/fc"
  export PLUGIN="$PROJECT_ROOT/lib/plugins/fc-audit"

  AUDIT_TMP="$(mktemp -d)"
  export AUDIT_TMP
  export CIRCUS_SECURITY_LOG="$AUDIT_TMP/security_audit.log"
  export CIRCUS_FAILED_OPS="$AUDIT_TMP/failed_ops.log"
  export CIRCUS_NETWORK_LOG="$AUDIT_TMP/network_requests.log"
}

teardown() {
  if [ -n "${AUDIT_TMP:-}" ] && [ -d "$AUDIT_TMP" ]; then
    case "$AUDIT_TMP" in
      /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) rm -rf "$AUDIT_TMP" ;;
    esac
  fi
  unset AUDIT_TMP CIRCUS_SECURITY_LOG CIRCUS_FAILED_OPS CIRCUS_NETWORK_LOG
}

# Write a small, known security log.
seed_security_log() {
  cat > "$CIRCUS_SECURITY_LOG" <<'LOG'
[2026-01-01 00:00:01] [info] [100] user=test category=boot action=started details="one"
[2026-01-01 00:00:02] [warning] [101] user=test category=sudo action=prompt details="two"
[2026-01-01 00:00:03] [critical] [102] user=test category=alert action=breach details="three"
[2026-01-01 00:00:04] [info] [103] user=test category=boot action=finished details="four"
LOG
}

# --- Interface ----------------------------------------------------------------

@test "fc audit --help shows usage information" {
  run "$FC_COMMAND" audit --help
  assert_success
  assert_output --partial "Usage: fc audit"
}

@test "fc audit --help documents the resurrected log viewers" {
  run "$FC_COMMAND" audit --help
  assert_success
  assert_output --partial "events"
  assert_output --partial "failures"
  assert_output --partial "network"
}

@test "fc audit rejects an unknown action" {
  run "$FC_COMMAND" audit not-a-real-action
  assert_failure
  assert_output --partial "Unknown action"
}

@test "fc-audit plugin sources init.sh" {
  run grep "source.*init.sh" "$PLUGIN"
  assert_success
}

@test "fc-audit delegates log viewing to lib/security.sh" {
  # The point of the exercise: call the library rather than reimplement it.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'security_audit_view|view_failed_operations|view_network_requests'"
  assert_success
}

# --- S21: security event log --------------------------------------------------

@test "fc audit events shows recorded security events" {
  seed_security_log
  run "$FC_COMMAND" audit events
  assert_success
  assert_output --partial "breach"
}

@test "fc audit events is graceful when no log exists" {
  run "$FC_COMMAND" audit events
  assert_success
  assert_output --partial "No security audit log"
}

@test "fc audit events honours a line count" {
  seed_security_log
  run "$FC_COMMAND" audit events 1
  assert_success
  # Only the most recent entry.
  assert_output --partial "finished"
  refute_output --partial "started"
}

@test "fc audit events-by filters on severity" {
  seed_security_log
  run "$FC_COMMAND" audit events-by critical
  assert_success
  assert_output --partial "breach"
  refute_output --partial "started"
}

@test "fc audit events-by requires a severity argument" {
  seed_security_log
  run "$FC_COMMAND" audit events-by
  assert_failure
  assert_output --partial "specify a severity"
}

@test "fc audit events-by reports no matches without failing" {
  # grep exits 1 when it matches nothing. That is an ordinary result here, not
  # an error, and must not surface as a crash.
  seed_security_log
  run "$FC_COMMAND" audit events-by error
  assert_success
  assert_output --partial "No 'error' events recorded"
  refute_output --partial "unexpected error occurred"
}

@test "fc audit event-stats summarises the log" {
  seed_security_log
  run "$FC_COMMAND" audit event-stats
  assert_success
  assert_output --partial "Statistics"
}

# --- S23: failed operations ---------------------------------------------------

@test "fc audit failures is graceful when nothing has failed" {
  run "$FC_COMMAND" audit failures
  assert_success
  assert_output --partial "No failed operations"
}

@test "fc audit failures shows recorded failures" {
  printf '[2026-01-01 00:00:01] category=net op=download error="timeout"\n' > "$CIRCUS_FAILED_OPS"
  run "$FC_COMMAND" audit failures
  assert_success
  assert_output --partial "timeout"
}

@test "fc audit clear-failures removes the failed operations log" {
  printf '[2026-01-01 00:00:01] category=net op=download error="timeout"\n' > "$CIRCUS_FAILED_OPS"
  assert [ -f "$CIRCUS_FAILED_OPS" ]

  run "$FC_COMMAND" audit clear-failures
  assert_success
  assert [ ! -f "$CIRCUS_FAILED_OPS" ]
}

@test "fc audit clear-failures is safe to run twice" {
  run "$FC_COMMAND" audit clear-failures
  assert_success
  run "$FC_COMMAND" audit clear-failures
  assert_success
}

# --- S28: network request log -------------------------------------------------

@test "fc audit network is graceful when nothing is logged" {
  run "$FC_COMMAND" audit network
  assert_success
  assert_output --partial "No network requests"
}

@test "fc audit network shows recorded requests" {
  printf '[2026-01-01 00:00:01] url=https://example.com status=200\n' > "$CIRCUS_NETWORK_LOG"
  run "$FC_COMMAND" audit network
  assert_success
  assert_output --partial "example.com"
}

@test "fc audit network-stats summarises the request log" {
  printf '[2026-01-01 00:00:01] url=https://example.com status=200\n' > "$CIRCUS_NETWORK_LOG"
  run "$FC_COMMAND" audit network-stats
  assert_success
  assert_output --partial "Statistics"
}

# --- Existing system checks still work ----------------------------------------

@test "fc audit quick completes without aborting" {
  # Regression: the check_* helpers report a BAD finding by returning non-zero,
  # and every capture was an unguarded `x=$(check_y)`. Under set -e that aborted
  # the audit — so `quick` and `run` crashed precisely when they had something
  # to warn about, and only completed on a machine where every check passed.
  run "$FC_COMMAND" audit quick
  refute_output --partial "unexpected error occurred"
  assert_output --partial "SIP:"
  assert_output --partial "Firewall:"
}

@test "fc audit run completes all eight checks and scores them" {
  run "$FC_COMMAND" audit run
  refute_output --partial "unexpected error occurred"
  assert_output --partial "Score:"
  # The sections after the firewall check are the ones that were unreachable
  # whenever an earlier check reported a problem.
  assert_output --partial "Authentication:"
  assert_output --partial "Network:"
}

@test "fc-audit guards every check_* capture against a bad finding" {
  run bash -c "grep -cE '^[[:space:]]*[a-z_]+=\\\$\\(check_[a-z_]+\\)[[:space:]]*$' '$PLUGIN' || true"
  assert_output "0"
}

@test "check_firewall treats block-all mode as enabled" {
  # socketfilterfw State = 2 is "blocking all non-essential incoming
  # connections" — the STRICTEST setting — and its text contains no "enabled".
  # `grep -qi enabled` therefore reported a locked-down machine as unprotected.
  run bash -c "grep -vE '^[[:space:]]*#' '$PLUGIN' | grep -E 'State = 2'"
  assert_success
}

@test "check_firewall and check_stealth do not match on the word enabled" {
  # The specific defect. Neither socketfilterfw state string nor the stealth
  # string ("Firewall stealth mode is on") contains "enabled".
  run bash -c "sed -n '/^check_firewall()/,/^}/p' '$PLUGIN' | grep -vE '^[[:space:]]*#' | grep -E 'grep -qi \"?enabled'"
  assert_failure

  run bash -c "sed -n '/^check_stealth()/,/^}/p' '$PLUGIN' | grep -vE '^[[:space:]]*#' | grep -E 'grep -qi \"?enabled'"
  assert_failure
}

@test "fc audit sip reports System Integrity Protection state" {
  run "$FC_COMMAND" audit sip
  refute_output --partial "unexpected error occurred"
}

# ==============================================================================
# S13 / S17 / S18 / S25  (resurrected controls)
# ==============================================================================

@test "fc audit --help documents the file and package actions" {
  run "$FC_COMMAND" audit --help
  assert_success
  assert_output --partial "permissions"
  assert_output --partial "integrity"
  assert_output --partial "manifest-create"
  assert_output --partial "taps"
}

# --- S13: config file permissions --------------------------------------------

@test "fc audit permissions scans a directory" {
  run "$FC_COMMAND" audit permissions "$PROJECT_ROOT/configs"
  assert_success
  assert_output --partial "Scanning for insecure config permissions"
}

@test "fc audit permissions defaults to the repository configs directory" {
  # scan_config_permissions takes a MANDATORY directory and reports
  # "Directory not found: " with an empty path when called without one, so the
  # plugin must supply a default rather than pass through an empty argument.
  run "$FC_COMMAND" audit permissions
  assert_success
  refute_output --partial "Directory not found: "
}

# --- S17: script integrity manifest ------------------------------------------

@test "fc audit integrity reports no manifest with status 2 and guidance" {
  export CIRCUS_HASH_MANIFEST="$AUDIT_TMP/hashes.sha256"
  run "$FC_COMMAND" audit integrity
  assert_equal "$status" 2
  assert_output --partial "manifest-create"
}

@test "fc audit manifest-create then integrity verifies clean" {
  # The round trip that never worked: verify_script_integrity split manifest
  # lines on whitespace, so every path containing a space was truncated and
  # reported MISSING. A freshly generated manifest failed its own verification,
  # declaring the whole tree tampered with on every run.
  export CIRCUS_HASH_MANIFEST="$AUDIT_TMP/hashes.sha256"

  run "$FC_COMMAND" audit manifest-create
  assert_success
  assert [ -s "$CIRCUS_HASH_MANIFEST" ]

  run "$FC_COMMAND" audit integrity
  assert_equal "$status" 0
  assert_output --partial "0 modified, 0 missing"
}

@test "fc audit integrity tracks paths containing spaces" {
  # The repository ships etc/alfred/workflows/Flying Circus/... — the specific
  # paths that used to come back as "etc/alfred/workflows/Flying".
  export CIRCUS_HASH_MANIFEST="$AUDIT_TMP/hashes.sha256"
  run "$FC_COMMAND" audit manifest-create
  assert_success

  run grep -c "Flying Circus" "$CIRCUS_HASH_MANIFEST"
  assert_success
  assert [ "$output" -ge 1 ]

  run "$FC_COMMAND" audit integrity
  refute_output --partial "MISSING"
}

@test "fc audit integrity still detects a modified script" {
  export CIRCUS_HASH_MANIFEST="$AUDIT_TMP/hashes.sha256"
  run "$FC_COMMAND" audit manifest-create
  assert_success

  # Corrupt one recorded hash, leaving its path intact.
  run bash -c "
    awk 'BEGIN{done=0} /^#/ {print; next} NF==0 {print; next}
         { if (!done) { sub(/^[0-9a-f]+/, \"0000000000000000000000000000000000000000000000000000000000000000\"); done=1 } print }
        ' '$CIRCUS_HASH_MANIFEST' > '$CIRCUS_HASH_MANIFEST.new' && mv '$CIRCUS_HASH_MANIFEST.new' '$CIRCUS_HASH_MANIFEST'"
  assert_success

  run "$FC_COMMAND" audit integrity
  assert_equal "$status" 1
  assert_output --partial "MODIFIED"
}

@test "fc audit manifest shows the recorded manifest" {
  export CIRCUS_HASH_MANIFEST="$AUDIT_TMP/hashes.sha256"
  run "$FC_COMMAND" audit manifest-create
  run "$FC_COMMAND" audit manifest
  assert_success
  assert_output --partial "Manifest"
}

@test "lib/security.sh points users at a runnable command for the manifest" {
  # It used to say "Generate one with: generate_hash_manifest" — an internal
  # shell function, not a command available in the user's shell.
  run bash -c "grep -n 'generate_hash_manifest' '$PROJECT_ROOT/lib/security.sh' | grep -vE '^[0-9]+:(#|generate_hash_manifest\(\)|export -f)' | grep -E 'Generate|Create'"
  assert_failure
}

# --- S18 / S25 ----------------------------------------------------------------

@test "fc audit taps lists Homebrew taps" {
  if ! command -v brew >/dev/null 2>&1; then
    skip "Homebrew not installed"
  fi
  run "$FC_COMMAND" audit taps
  assert_success
  assert_output --partial "Taps"
}

@test "fc audit health-report emits a Markdown report" {
  run "$FC_COMMAND" audit health-report
  assert_success
  assert_output --partial "# Security Health Report"
}

# ==============================================================================
# S26 / S28: download allowlist and network logging  (resurrected controls)
# ==============================================================================
#
# is_allowed_domain and log_network_request were defined and exported with no
# caller: nothing was gated, and the network log that `fc audit network` reads
# was never written to.
#
# They are now wired into helpers.sh:fetch_verified_script — the one place in
# the repository that downloads code and then executes it (the Homebrew and
# Oh My Zsh installers).
#
# secure_download was NOT used as the vehicle. It downloaded with a bare
# `curl -fsSL`: no HTTPS enforcement, no TLS floor, no checksum — weaker than
# the path already in use. It now delegates to fetch_verified_script instead.

@test "fetch_verified_script refuses a domain outside the allowlist" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               fetch_verified_script 'https://evil.example.com/payload.sh' '$AUDIT_TMP/p.sh' </dev/null"
  assert_failure
  assert_output --partial "not on the allowlist"
}

@test "fetch_verified_script writes no file when a domain is refused" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               fetch_verified_script 'https://evil.example.com/payload.sh' '$AUDIT_TMP/p.sh' </dev/null >/dev/null 2>&1"
  assert [ ! -e "$AUDIT_TMP/p.sh" ]
}

@test "fetch_verified_script does not prompt when a domain is refused" {
  # secure_download used a bare `read` here, which hangs forever under an
  # unattended install or a scheduled job — the cases where downloading
  # unreviewed code matters most. Closing stdin must not change the outcome.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               fetch_verified_script 'https://evil.example.com/payload.sh' '$AUDIT_TMP/p.sh' </dev/null"
  assert_failure
  refute_output --partial "Download anyway"
}

@test "the allowlist admits the domains the installers actually use" {
  # Regression guard: gating the download path must not break a real install.
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               for u in https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
                        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh; do
                 is_allowed_domain \"\$u\" || exit 1
               done"
  assert_success
}

@test "CIRCUS_ALLOWED_DOMAINS extends the allowlist" {
  run bash -c "CIRCUS_ALLOWED_DOMAINS='example.com' bash -c '
                 source \"$PROJECT_ROOT/lib/init.sh\" >/dev/null 2>&1
                 set +e; trap - ERR
                 is_allowed_domain https://example.com/x'"
  assert_success
}

@test "a refused download is recorded as a security event" {
  export CIRCUS_SECURITY_LOG="$AUDIT_TMP/sec.log"
  run bash -c "CIRCUS_SECURITY_LOG='$AUDIT_TMP/sec.log' bash -c '
                 source \"$PROJECT_ROOT/lib/init.sh\" >/dev/null 2>&1
                 set +e; trap - ERR
                 fetch_verified_script https://evil.example.com/p.sh \"$AUDIT_TMP/p.sh\" </dev/null >/dev/null 2>&1'"
  run grep -c "blocked_download" "$AUDIT_TMP/sec.log"
  assert_success
  assert [ "$output" -ge 1 ]
}

@test "secure_download delegates rather than downloading with weaker flags" {
  # It must not carry its own curl invocation any more.
  run bash -c "sed -n '/^secure_download()/,/^}/p' '$PROJECT_ROOT/lib/security.sh' | grep -vE '^[[:space:]]*#' | grep -E 'curl|wget'"
  assert_failure

  run bash -c "sed -n '/^secure_download()/,/^}/p' '$PROJECT_ROOT/lib/security.sh' | grep -E 'fetch_verified_script'"
  assert_success
}

@test "secure_download no longer prompts to bypass the allowlist" {
  run bash -c "sed -n '/^secure_download()/,/^}/p' '$PROJECT_ROOT/lib/security.sh' | grep -vE '^[[:space:]]*#' | grep -E 'read -r -p'"
  assert_failure
}

@test "fetch_verified_script keeps HTTPS enforcement and a TLS floor" {
  # The properties that would have been lost by switching to secure_download.
  run bash -c "sed -n '/^fetch_verified_script()/,/^}/p' '$PROJECT_ROOT/lib/helpers.sh' | grep -E \"proto '=https'\""
  assert_success
  run bash -c "sed -n '/^fetch_verified_script()/,/^}/p' '$PROJECT_ROOT/lib/helpers.sh' | grep -E 'tlsv1.2'"
  assert_success
}

# --- S11: secure temp files ---------------------------------------------------

@test "secure_mktemp creates an owner-only file with a clean name" {
  # BSD mktemp treats a -t argument as a PREFIX and appends its own suffix, so
  # the X-template survived literally: "circus.XXXXXXXXXX.HYsqJqiZhq".
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               f=\$(secure_mktemp circustest)
               printf '%s %s\n' \"\$(stat -f '%Sp' \"\$f\")\" \"\$(basename \"\$f\")\"
               rm -f \"\$f\""
  assert_success
  assert_output --partial "-rw-------"
  refute_output --partial "XXXXXXXXXX"
}

@test "secure_mktemp_dir creates an owner-only directory with a clean name" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               d=\$(secure_mktemp_dir circustest)
               printf '%s %s\n' \"\$(stat -f '%Sp' \"\$d\")\" \"\$(basename \"\$d\")\"
               rm -rf \"\$d\""
  assert_success
  assert_output --partial "drwx------"
  refute_output --partial "XXXXXXXXXX"
}

@test "fc audit domains shows the effective allowlist" {
  run "$FC_COMMAND" audit domains
  assert_success
  assert_output --partial "raw.githubusercontent.com"
}

@test "fc audit domains reflects CIRCUS_ALLOWED_DOMAINS" {
  CIRCUS_ALLOWED_DOMAINS="github.com example.com" run "$FC_COMMAND" audit domains
  assert_success
  assert_output --partial "example.com"
}

# ==============================================================================
# S12: symlink-attack prevention on security baselines
# ==============================================================================
#
# safe_write, atomic_write and safe_append had no caller. Two defects inside
# them had therefore never surfaced:
#
#   1. `echo "$content"` consumes a leading -n/-e as an OPTION, so
#      safe_write "-n" wrote a zero-byte file and discarded the content —
#      data loss in the function whose job is writing safely.
#   2. atomic_write chmod-ed the destination to 600 unconditionally, silently
#      changing a 644 file's permissions as a side effect of updating it.
#
# The check is now applied to the three files that DEFINE what is trusted: the
# firewall baseline, the expected-DNS baseline and the script hash manifest. A
# symlink planted at any of them would let an attacker choose the trusted state
# and have the auditor certify their changes as clean.

@test "safe_write preserves content beginning with a dash" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               safe_write '-n' '$AUDIT_TMP/dash.txt' >/dev/null 2>&1
               cat '$AUDIT_TMP/dash.txt'"
  assert_success
  # assert_equal, not assert_output: bats-assert parses a leading "-n" as one of
  # its own options — the very bug this test is about, reproduced in the test.
  assert_equal "$output" "-n"
}

@test "safe_append preserves content beginning with a dash" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               safe_append '-e' '$AUDIT_TMP/app.txt' >/dev/null 2>&1
               cat '$AUDIT_TMP/app.txt'"
  assert_success
  assert_equal "$output" "-e"
}

@test "atomic_write preserves an existing file's permissions" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               printf 'pre\n' > '$AUDIT_TMP/perm.txt'
               chmod 644 '$AUDIT_TMP/perm.txt'
               atomic_write 'x' '$AUDIT_TMP/perm.txt' >/dev/null 2>&1
               stat -f '%Sp' '$AUDIT_TMP/perm.txt'"
  assert_success
  assert_output "-rw-r--r--"
}

@test "atomic_write creates new files owner-only" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               atomic_write 'x' '$AUDIT_TMP/fresh.txt' >/dev/null 2>&1
               stat -f '%Sp' '$AUDIT_TMP/fresh.txt'"
  assert_success
  assert_output "-rw-------"
}

@test "safe_write refuses to write through a symlink" {
  run bash -c "source '$PROJECT_ROOT/lib/init.sh' >/dev/null 2>&1
               set +e; trap - ERR
               ln -sf '$AUDIT_TMP/target' '$AUDIT_TMP/link'
               safe_write 'pwned' '$AUDIT_TMP/link'"
  assert_failure
  assert [ ! -e "$AUDIT_TMP/target" ]
}

@test "fc firewall baseline refuses a planted symlink" {
  ln -sf "$AUDIT_TMP/attacker_target" "$AUDIT_TMP/fw_link.txt"
  CIRCUS_FIREWALL_BASELINE="$AUDIT_TMP/fw_link.txt" run "$FC_COMMAND" firewall baseline
  assert_failure
  assert_output --partial "Refusing"
  assert [ ! -e "$AUDIT_TMP/attacker_target" ]
}

@test "fc dns baseline refuses a planted symlink" {
  ln -sf "$AUDIT_TMP/dns_attacker_target" "$AUDIT_TMP/dns_link"
  CIRCUS_EXPECTED_DNS_FILE="$AUDIT_TMP/dns_link" run "$FC_COMMAND" dns baseline
  assert_failure
  assert [ ! -e "$AUDIT_TMP/dns_attacker_target" ]
}

@test "fc audit manifest-create refuses a planted symlink" {
  ln -sf "$AUDIT_TMP/man_attacker_target" "$AUDIT_TMP/man_link"
  CIRCUS_HASH_MANIFEST="$AUDIT_TMP/man_link" run "$FC_COMMAND" audit manifest-create
  assert_failure
  assert [ ! -e "$AUDIT_TMP/man_attacker_target" ]
}

@test "the baselines still write normally when no symlink is present" {
  CIRCUS_FIREWALL_BASELINE="$AUDIT_TMP/fw_ok.txt" run "$FC_COMMAND" firewall baseline
  assert_success
  assert [ -s "$AUDIT_TMP/fw_ok.txt" ]
}
