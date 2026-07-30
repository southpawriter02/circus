#!/usr/bin/env bash

# ==============================================================================
#
# Tool: bats-core and helpers
#
# This script installs bats-core, the Bash Automated Testing System.
#
# It deliberately installs ONLY bats-core, from homebrew/core.
#
# The helper libraries (bats-assert, bats-support, bats-mock) are vendored in
# tests/helpers/ and loaded from there by tests/test_helper.bash, so there is
# nothing to install for them. This script previously ran
# `brew tap kaos/shell` to get bats-assert: tapping clones a third-party
# repository and `brew install` then executes its Ruby formula code, so that
# handed arbitrary code execution to an account outside the trusted taps for a
# dependency the test suite does not actually use.
#
# ==============================================================================

main() {
  if ! command -v brew >/dev/null 2>&1; then
    msg_error "Homebrew is not installed. Cannot install testing tools."
    return 1
  fi

  msg_info "Installing testing tools (bats-core)..."
  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would run: brew install bats-core"
  else
    if brew install bats-core; then
      msg_success "Testing tools installed successfully."
      msg_info "Helper libraries are vendored in tests/helpers/ — nothing to install."
    else
      msg_error "Failed to install bats-core."
    fi
  fi
}

main
