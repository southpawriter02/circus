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

  # Run the pre-flight sanity check
  msg_info "Running pre-flight checks..."
  local sanity_check_script="$INSTALL_DIR/preflight/preflight-21-install-sanity-check.sh"
  if [[ -f "$sanity_check_script" ]]; then
    # The pre-flight checks have their own messaging, so we just source it.
    # shellcheck source=/dev/null
    source "$sanity_check_script"
  else
    # Use standard echo for this error as we can't be sure msg_error is available.
    echo "Error: Sanity check script not found at $sanity_check_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Script Body
  # ----------------------------------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."

  # Request sudo privileges upfront and keep them alive.
  msg_info "Requesting sudo privileges..."
  local sudo_keep_alive_script="$INSTALL_DIR/sudo-keep-alive.sh"
  if [[ -f "$sudo_keep_alive_script" ]]; then
    # shellcheck source=/dev/null
    source "$sudo_keep_alive_script"
  else
    echo "Error: Sudo keep-alive script not found at $sudo_keep_alive_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # Back up existing dotfiles
  local backup_script="$INSTALL_DIR/backup-dotfiles.sh"
  if [[ -f "$backup_script" ]]; then
    # shellcheck source=/dev/null
    source "$backup_script"
  else
    echo "Error: Backup script not found at $backup_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # Symlink dotfiles
  local symlink_script="$INSTALL_DIR/symlink-dotfiles.sh"
  if [[ -f "$symlink_script" ]]; then
    # shellcheck source=/dev/null
    source "$symlink_script"
  else
    echo "Error: Symlink script not found at $symlink_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # Set macOS defaults
  local macos_defaults_script="$INSTALL_DIR/set-macos-defaults.sh"
  if [[ -f "$macos_defaults_script" ]]; then
    # shellcheck source=/dev/null
    source "$macos_defaults_script"
  else
    echo "Error: macOS defaults script not found at $macos_defaults_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # Install Homebrew packages
  local homebrew_script="$INSTALL_DIR/install-homebrew-packages.sh"
  if [[ -f "$homebrew_script" ]]; then
    # shellcheck source=/dev/null
    source "$homebrew_script"
  else
    echo "Error: Homebrew installation script not found at $homebrew_script" >&2
    echo "Please ensure the repository is complete." >&2
    exit 1
  fi

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Post-flight & Cleanup
  # ----------------------------------------------------------------------------
  msg_success "Setup complete! Please restart your terminal."
}

# ------------------------------------------------------------------------------
# SECTION: SCRIPT EXECUTION
# ------------------------------------------------------------------------------

main "$@"
