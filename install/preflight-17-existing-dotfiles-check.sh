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

#
# CUSTOMIZATION:
# Add any other dotfiles you want to check for to this array.
# For example:
#
# DOTFILES=(".bash_profile" ".bashrc" ".gitconfig" ".vimrc" ".zshrc")
#
DOTFILES=(".bash_profile" ".bashrc" ".gitconfig" ".vimrc" ".zshrc")

e_msg "Checking for existing dotfiles..."

#
# A flag to track if any existing dotfiles were found.
#
found_dotfiles=false

#
# Iterate through the list of dotfiles.
#
for dotfile in "${DOTFILES[@]}"; do
  #
  # Check if the file exists in the user's home directory.
  #
  if [ -f "$HOME/$dotfile" ]; then
    e_warning "Found an existing $dotfile file."
    found_dotfiles=true
  fi
done

#
# If any dotfiles were found, display a general warning.
#
if [ "$found_dotfiles" = true ]; then
  e_warning "The installation may overwrite or modify your existing dotfiles."
  e_warning "It is recommended to back up your dotfiles before proceeding."
else
  e_success "No existing dotfiles were found."
fi

#
# This check is informational, so we always exit with success.
#
exit 0
