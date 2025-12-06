#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Shell Type and Version
#
# This script checks the type and version of the user's current shell. The
# dotfiles are often specific to a particular shell (e.g., zsh) and may require
# a minimum version to function correctly.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # You can change the required shell and minimum version by modifying the
  # REQUIRED_SHELL and MINIMUM_VERSION variables.
  #
  local REQUIRED_SHELL="zsh"
  local MINIMUM_VERSION="5.0"

  msg_info "Checking shell type and version..."

  # The `SHELL` environment variable contains the path to the user's default shell.
  # We use `basename` to extract the shell name from the path.
  local current_shell
  current_shell=$(basename "$SHELL")

  if [ "$current_shell" != "$REQUIRED_SHELL" ]; then
    msg_error "Current shell is $current_shell, but $REQUIRED_SHELL is required."
    return 1
  fi

  msg_success "Current shell is $current_shell."

  # Allow command injection for testing
  local shell_version_cmd="${SHELL_VERSION_CMD:-$current_shell}"

  # Get the shell version. The command to get the version can vary between shells.
  # For zsh, `zsh --version` is a common way to get it.
  # We use awk to extract the version number from the output.
  local shell_version
  shell_version=$($shell_version_cmd --version | awk '{print $2}')

  # We use `sort -V` to perform a version number comparison. This handles
  # complex version numbers correctly (e.g., 5.0.8 vs 5.1).
  if [[ "$(printf '%s\n' "$MINIMUM_VERSION" "$shell_version" | sort -V | head -n1)" == "$MINIMUM_VERSION" ]]; then
    msg_success "Shell version is $shell_version (meets minimum requirement of $MINIMUM_VERSION)."
    return 0
  else
    msg_error "Shell version is $shell_version, but version $MINIMUM_VERSION or higher is required."
    return 1
  fi
}

#
# Execute the main function.
#
main
