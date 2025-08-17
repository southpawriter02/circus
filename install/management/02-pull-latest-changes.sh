#!/usr/bin/env bash

# ==============================================================================
#
# Repository Management Step 2: Pull Latest Changes
#
# This script checks for remote updates and, if available, asks the user
# for permission to pull them. This makes the installer self-updating.
#
# ==============================================================================

#
# The main logic for pulling the latest changes.
#
main() {
  msg_info "Checking for remote updates..."

  # First, we fetch the latest data from the remote repository.
  # The `-q` flag makes the command quiet.
  if ! git fetch -q; then
    msg_warning "Could not fetch remote updates. Please check your network connection."
    # We don't exit here, as the user may want to proceed with an offline installation.
    return 0
  fi

  # Now, we compare the local commit with the remote commit.
  # `git rev-parse HEAD` gets the hash of the local commit.
  # `git rev-parse '@{u}'` gets the hash of the upstream (remote) commit.
  local local_commit
  local remote_commit
  local_commit=$(git rev-parse HEAD)
  remote_commit=$(git rev-parse '@{u}')

  if [ "$local_commit" = "$remote_commit" ]; then
    msg_success "Repository is up to date."
  else
    msg_warning "Your local repository is not up to date."
    if ask "Do you want to pull the latest changes now?" Y; then
      if git pull; then
        msg_success "Repository updated successfully."
        msg_info "It is recommended to re-run the installer to ensure all new changes are applied."
        exit 1
      else
        msg_error "Failed to pull the latest changes."
        msg_error "Please run 'git pull' manually and then re-run the installer."
        exit 1
      fi
    else
      msg_warning "Proceeding with the installation without updating."
    fi
  fi
}

#
# Execute the main function.
#
main
