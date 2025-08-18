#!/usr/bin/env bash

# This is a temporary script to install the dependencies needed for running the test suite.

# --- Initialization ---------------------------------------------------------
# Source the centralized initialization script to set up the environment.
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

# --- Main Logic -------------------------------------------------------------
main() {
    # The installation scripts expect to be run from the root of the project
    cd "$DOTFILES_ROOT"

    msg_info "Installing Homebrew..."
    source "install/tools/install-homebrew.sh"

    msg_info "Installing bats-core..."
    source "install/tools/install-bats-core.sh"

    msg_success "Test dependencies installed."
}

main "$@"
