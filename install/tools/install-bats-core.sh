#!/usr/bin/env bash

# ==============================================================================
#
# Tool: bats-core and helpers
#
# This script installs bats-core, the Bash Automated Testing System, and its
# common helper libraries: bats-assert and bats-support.
#
# ==============================================================================

main() {
  if ! command -v brew >/dev/null 2>&1; then
    msg_error "Homebrew is not installed. Cannot install testing tools."
    return 1
  fi

  msg_info "Installing testing tools (bats-core, bats-assert, bats-support)..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: brew tap kaos/shell"
    msg_info "[Dry Run] Would run: brew install bats-core"
    msg_info "[Dry Run] Would run: brew install bats-assert"
  else
    if brew tap kaos/shell && brew install bats-core && brew install bats-assert; then
      msg_success "Testing tools installed successfully."
    else
      msg_error "Failed to install one or more testing tools."
    fi
  fi
}

main
