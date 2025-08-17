#!/usr/bin/env bash

# ==============================================================================
#
# Stage 5: Repository Management
#
# This script handles the initial setup and maintenance of the dotfiles
# repository itself. Its responsibilities include:
#
#   5.1. Verifying the integrity of the local repository.
#   5.2. Pulling the latest changes from the remote.
#   5.3. Initializing and updating any git submodules.
#
# ==============================================================================

#
# The main logic for the repository management stage.
#
main() {
  msg_info "Stage 5: Repository Management"

  # --- Configuration ----------------------------------------------------------
  # @description: The URL of the remote git repository.
  # @customization: Change this URL to point to your own dotfiles repository.
  local REPO_URL="https://github.com/southpawriter02/dotfiles.git"

  # --- 5.1. Verify repository integrity -------------------------------------
  msg_info "Verifying repository integrity..."
  if [[ -n "$(git status --porcelain)" ]]; then
    msg_warning "You have uncommitted local changes."
    msg_warning "It is recommended to commit or stash your changes before proceeding."
  else
    msg_success "Repository is clean. No uncommitted changes found."
  fi

  # --- 5.2. Pull latest changes ---------------------------------------------
  msg_info "Checking for remote updates..."
  if git fetch >/dev/null 2>&1; then
    local local_commit
    local remote_commit
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse '@{u}')

    if [ "$local_commit" = "$remote_commit" ]; then
      msg_success "Repository is up to date."
    else
      msg_warning "Your local repository is not up to date."
      msg_warning "It is recommended to run 'git pull' to get the latest changes."
    fi
  else
    msg_warning "Could not fetch remote updates. Please check your network connection."
  fi

  # --- 5.3. Initialize submodules -------------------------------------------
  if [ -f ".gitmodules" ]; then
    msg_info "Initializing and updating submodules..."
    if git submodule update --init --recursive; then
      msg_success "Submodules initialized and updated successfully."
    else
      msg_error "Failed to initialize or update submodules."
    fi
  else
    msg_info "No submodules found to initialize."
  fi

  msg_success "Repository management checks complete."
}

#
# Execute the main function.
#
main
