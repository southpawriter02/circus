#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# It is best practice to use `#!/usr/bin/env zsh` instead of a hardcoded
# path like `#!/bin/zsh`. This makes the script more portable, as it
# allows the system's `env` command to find the `zsh` interpreter in the
# user's PATH.
# ------------------------------------------------------------------------------

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FILE:        install.sh                                                    ║
# ║ PROJECT:     Dotfiles Flying Circus                                        ║
# ║ REPOSITORY:  https://github.com/southpawriter02/dotfiles                   ║
# ║ AUTHOR:      southpawriter02 <southpawriter@pm.me>                         ║
# ║                                                                            ║
# ║ DESCRIPTION: This script automates the setup of a new macOS device by      ║
# ║              installing applications, configuring system settings, and     ║
# ║              symlinking dotfiles from this repository.                     ║
# ║                                                                            ║
# ║ LICENSE:     MIT                                                           ║
# ║ COPYRIGHT:   Copyright (c) $(date +'%Y') southpawriter02                   ║
# ║ STATUS:      DRAFT                                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# SECTION: OPTIONS
#
# Description: This section configures the shell's behavior for the script.
# These settings are crucial for writing safe, robust, and predictable scripts.
# ------------------------------------------------------------------------------

set -e
set -u
set -o pipefail

# ------------------------------------------------------------------------------
# SECTION: VARIABLES & CONSTANTS
#
# Description: Define global variables and constants here.
# ------------------------------------------------------------------------------

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$SCRIPT_DIR"

# Helper library
readonly HELPERS_LIB="$DOTFILES_DIR/lib/helpers.sh"

# ------------------------------------------------------------------------------
# SECTION: FUNCTIONS
#
# Description: All logic should be organized into functions.
# ------------------------------------------------------------------------------

###
# @description
#   Prints a usage message for the script and exits.
###
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [options]

Automates the setup of a new macOS device.

OPTIONS:
   -h, --help     Show this help message and exit.
   --no-op        Perform a dry run; show what would be done without
                  making any changes.

EOF
  exit 1
}

###
# @description
#   This is the main function where the script's primary logic resides.
###
main() {
  # ----------------------------------------------------------------------------
  # SUB-SECTION: Argument Parsing
  # ----------------------------------------------------------------------------
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      -h|--help)
        usage
        ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        usage
        ;;
    esac
    shift
  done

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Pre-flight Checks
  # ----------------------------------------------------------------------------
  # Source the helper library
  if [[ -f "$HELPERS_LIB" ]]; then
    # shellcheck source=/dev/null
    source "$HELPERS_LIB"
  else
    echo "Error: Helper library not found at $HELPERS_LIB" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # Check for dependencies
  if ! command -v git &> /dev/null; then
    msg_error "Git is not installed. Please install Git to continue."
    exit 1
  fi

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Script Body
  # ----------------------------------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."

  # Request sudo privileges upfront
  sudo -v
  # Keep-alive: update existing `sudo` time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  msg_info "Backing up existing dotfiles..."
  # TODO: Add backup logic here

  msg_info "Symlinking dotfiles..."
  # TODO: Add symlinking logic here

  msg_info "Setting macOS defaults..."
  # TODO: Run system/macos.sh

  msg_info "Installing Homebrew packages..."
  # TODO: Add Homebrew installation logic here

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Post-flight & Cleanup
  # ----------------------------------------------------------------------------
  msg_success "Setup complete! Please restart your terminal."
}

# ------------------------------------------------------------------------------
# SECTION: SCRIPT EXECUTION
# ------------------------------------------------------------------------------

main "$@"
