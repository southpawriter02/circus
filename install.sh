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
# ║ USAGE:       This script should be run via the `init.sh` script in the     ║
# ║              project root. The `init.sh` script handles making this file   ║
# ║              executable and then returns it to a non-executable state.     ║
# ║                                                                            ║
# ║ DESCRIPTION: This script automates the setup of a new macOS device by      ║
# ║              orchestrating a series of modular installation scripts.       ║
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
readonly INSTALL_DIR="$DOTFILES_DIR/install"

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
  # SUB-SECTION: Source Helper Library
  # ----------------------------------------------------------------------------
  if [[ -f "$HELPERS_LIB" ]]; then
    # shellcheck source=/dev/null
    source "$HELPERS_LIB"
  else
    echo "Error: Helper library not found at $HELPERS_LIB" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Installation Stages
  # ----------------------------------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."

  # Define all installation stages in their new, logical order.
  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-preflight-system-checks.sh"
    "04-tool-installation.sh"
    "05-repository-management.sh"
    "06-archive-handling.sh"
    "07-variable-and-path-setup.sh"
    "08-alias-and-function-configuration.sh"
    "09-dotfiles-deployment.sh"
    "10-system-and-app-command-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "12-privacy-and-security.sh"
    "13-cleanup.sh"
    "14-finalization-and-reporting.sh"
  )

  # Iterate through the installation stages and execute them.
  for stage_script in "${INSTALL_STAGES[@]}"; do
    local stage_path="$INSTALL_DIR/$stage_script"
    if [[ -f "$stage_path" ]]; then
      # shellcheck source=/dev/null
      source "$stage_path"
    else
      msg_error "Installation stage script not found: $stage_path"
      msg_error "Please ensure the repository is complete."
      exit 1
    fi
  done
}

# ------------------------------------------------------------------------------
# SECTION: SCRIPT EXECUTION
# ------------------------------------------------------------------------------

main "$@"
