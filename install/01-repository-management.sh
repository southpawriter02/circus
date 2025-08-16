#!/usr/bin/env bash

# ==============================================================================
#
# Stage 1: Repository Management
#
# This script handles the initial setup and maintenance of the dotfiles
# repository itself. Its responsibilities include:
#
#   1.1. Cloning the dotfiles repository if it doesn't exist.
#   1.2. Verifying the integrity of the local repository.
#   1.3. Pulling the latest changes from the remote.
#   1.4. Initializing and updating any git submodules.
#
# ==============================================================================

#
# The main logic for the repository management stage.
#
main() {
  msg_info "Stage 1: Repository Management"

  # --- Configuration ----------------------------------------------------------
  # @description: The URL of the remote git repository.
  # @customization: Change this URL to point to your own dotfiles repository.
  local REPO_URL="https://github.com/southpawriter02/dotfiles.git"

  # @description: The default directory to clone the repository into if the
  #               script is not run from within a cloned repository.
  # @customization: Change this to your preferred default location.
  local DEFAULT_CLONE_DIR="$HOME/Projects/dotfiles"

  # --- 1.1. Clone dotfiles repository -----------------------------------------
  # Check if the script is being run from within a git repository.
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    msg_warning "The script is not being run from a git repository."
    msg_info "Cloning the dotfiles repository to '$DEFAULT_CLONE_DIR'..."

    # Clone the repository.
    if git clone "$REPO_URL" "$DEFAULT_CLONE_DIR"; then
      msg_success "Repository cloned successfully."
      msg_info "Please change to the new directory and re-run the installer:"
      msg_info "cd '$DEFAULT_CLONE_DIR' && ./install.sh"
    else
      msg_error "Failed to clone the repository."
      msg_error "Please check the URL and your network connection."
    fi
    # Exit the script, as the user needs to re-run it from the new location.
    exit 1
  fi

  # --- 1.2. Verify repository integrity -------------------------------------
  msg_info "Verifying repository integrity..."
  if [[ -n "$(git status --porcelain)" ]]; then
    msg_warning "You have uncommitted local changes."
    msg_warning "It is recommended to commit or stash your changes before proceeding."
  else
    msg_success "Repository is clean. No uncommitted changes found."
  fi

  # --- 1.3. Pull latest changes ---------------------------------------------
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

  # --- 1.4. Initialize submodules -------------------------------------------
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
