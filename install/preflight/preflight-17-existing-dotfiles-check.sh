#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Existing Dotfiles
#
# This script checks for the presence of existing dotfiles in the user's home
# directory. The installation process may overwrite or modify these files, so
# it is important to warn the user about this.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # Add any other dotfiles you want to check for to this array.
  # For example:
  #
  # DOTFILES=(".bash_profile" ".bashrc" ".gitconfig" ".vimrc" ".zshrc")
  #
  local DOTFILES=(".bash_profile" ".bashrc" ".gitconfig" ".vimrc" ".zshrc")

  msg_info "Checking for existing dotfiles..."

  # A flag to track if any existing dotfiles were found.
  local found_dotfiles=false

  # Iterate through the list of dotfiles.
  for dotfile in "${DOTFILES[@]}"; do
    # Check if the file exists in the user's home directory.
    if [ -f "$HOME/$dotfile" ]; then
      msg_warning "Found an existing $dotfile file."
      found_dotfiles=true
    fi
  done

  # If any dotfiles were found, display a general warning.
  if [ "$found_dotfiles" = true ]; then
    msg_warning "The installation may overwrite or modify your existing dotfiles."
    msg_warning "It is recommended to back up your dotfiles before proceeding."
  else
    msg_success "No existing dotfiles were found."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
