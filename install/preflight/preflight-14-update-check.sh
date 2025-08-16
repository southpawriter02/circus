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

#
# The main logic of the script.
#
main() {
  msg_info "Checking for updates..."

  # Get the directory of the current script and navigate to the project root.
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/../.."

  # Fetch the latest changes from the remote repository.
  # We redirect output to /dev/null to keep the output clean.
  if git fetch >/dev/null 2>&1; then
    # Check the git status. The -uno option tells git to not show untracked files.
    local git_status
    git_status=$(git status -uno)

    if [[ $git_status == *"Your branch is up to date"* ]]; then
      msg_success "Dotfiles are up to date."
    elif [[ $git_status == *"Your branch is behind"* ]]; then
      msg_warning "Your dotfiles are not up to date. It is recommended to pull the latest changes before proceeding."
    else
      msg_warning "Could not determine update status. You may have local changes."
    fi
  else
      msg_warning "Could not fetch updates. Please check your internet connection."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
