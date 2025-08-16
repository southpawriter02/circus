#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Updates
#
# This script checks if the local dotfiles repository is up to date with the
# remote repository. It is good practice to ensure that the user is installing
# the latest version of the dotfiles.
#
# ==============================================================================


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo a warning message to the console.
#
# @param string $1 The message to echo.
#
function e_warning() {
  printf " [33;1mWarning[0m: %s\n" "$1"
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

e_msg "Checking for updates..."

#
# Get the directory of the current script and navigate to the project root.
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

#
# Fetch the latest changes from the remote repository.
# We redirect output to /dev/null to keep the output clean.
#
if git fetch >/dev/null 2>&1; then
  #
  # Check the git status. The -uno option tells git to not show untracked files.
  #
  git_status=$(git status -uno)

  if [[ $git_status == *"Your branch is up to date"* ]]; then
    e_success "Dotfiles are up to date."
  elif [[ $git_status == *"Your branch is behind"* ]]; then
    e_warning "Your dotfiles are not up to date. It is recommended to pull the latest changes before proceeding."
  else
    e_warning "Could not determine update status. You may have local changes."
  fi
else
    e_warning "Could not fetch updates. Please check your internet connection."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
