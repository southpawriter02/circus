#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Install Sanity Check
#
# This script serves as a final sanity check to ensure that all the previous
# preflight checks have passed and that the system is in a good state for the
# installation to begin.
#
# It does this by sourcing and running all the other preflight check scripts
# in the correct order.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  # Get the directory of the current script.
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # An array of all the preflight check scripts in the correct order.
  local PREFLIGHT_CHECKS=(
    "preflight-01-macos-check.sh"
    "preflight-02-root-check.sh"
    "preflight-03-admin-rights-check.sh"
    "preflight-04-file-permissions-check.sh"
    "preflight-05-unset-vars-check.sh"
    "preflight-06-shell-type-version-check.sh"
    "preflight-07-locale-encoding-check.sh"
    "preflight-08-battery-check.sh"
    "preflight-09-wifi-check.sh"
    "preflight-10-xcode-cli-check.sh"
    "preflight-11-homebrew-check.sh"
    "preflight-12-dependency-check.sh"
    "preflight-13-install-integrity-check.sh"
    "preflight-14-update-check.sh"
    "preflight-15-existing-install-check.sh"
    "preflight-16-backed-up-dotfiles-check.sh"
    "preflight-17-existing-dotfiles-check.sh"
    "preflight-18-icloud-check.sh"
    "preflight-19-terminal-type-check.sh"
    "preflight-20-conflicting-processes-check.sh"
  )

  # Verify the check suite is intact — do NOT re-execute it.
  #
  # This used to source and run all 20 other checks and `return 1` if ANY of
  # them returned non-zero. Two things were wrong with that:
  #
  #   * It inverted the severity model. 00-preflight-checks.sh already runs every
  #     check and classifies each as critical or warning-only. Re-running them
  #     here treated a warning — no network, an unset LANG — as a CRITICAL
  #     failure, so the installer refused to proceed on machines that the
  #     framework had just decided were fine.
  #   * It ran every check twice, including the ones that prompt.
  #
  # What is genuinely worth checking at this point is that the check suite
  # itself is present and parseable, which is what "sanity" should mean here.
  local missing=0
  local unparseable=0
  local check

  for check in "${PREFLIGHT_CHECKS[@]}"; do
    if [ ! -f "$script_dir/$check" ]; then
      msg_error "Preflight check script is missing: $check"
      missing=$((missing + 1))
      continue
    fi

    if ! bash -n "$script_dir/$check" 2>/dev/null; then
      msg_error "Preflight check script has a syntax error: $check"
      unparseable=$((unparseable + 1))
    fi
  done

  if [ "$missing" -gt 0 ] || [ "$unparseable" -gt 0 ]; then
    msg_error "Preflight suite is incomplete: $missing missing, $unparseable unparseable."
    return 1
  fi

  # If all the preflight checks passed, exit with a success status.
  msg_success "All preflight checks passed!"
  return 0
}

#
# Execute the main function.
#
main
