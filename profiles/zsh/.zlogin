#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zlogin
#
# DESCRIPTION:  This file is sourced for login shells, after .zshrc. It is a
#               good place for commands that should be executed only once at
#               the beginning of a session, like displaying a welcome message.
#
# ==============================================================================

# --- Configuration ---
local fortunes_file="$DOTFILES_DIR/etc/fortunes.txt"

# --- Function to print the welcome message ---
print_welcome_message() {
  # 1. Clear the screen to provide a clean slate.
  clear

  # 2. Print the main banner.
  # Using %F for color and %b for bold.
  echo "%F{cyan}%b
  ██████╗ ██╗██████╗  ██████╗██╗   ██╗███████╗
  ██╔══██╗██║██╔══██╗██╔════╝██║   ██║██╔════╝
  ██║  ██║██║██████╔╝██║     ██║   ██║███████╗
  ██║  ██║██║██╔══██╗██║     ██║   ██║╚════██║
  ██████╔╝██║██║  ██║╚██████╗╚██████╔╝███████║
  ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
  %f%b0"
  echo "%F{yellow}            Dotfiles Flying Circus%f\n"

  # 3. Print a random fortune if the file exists.
  if [ -f "$fortunes_file" ]; then
    local fortune
    fortune=$(shuf -n 1 "$fortunes_file")
    echo "  %F{magenta}“%f%F{white}$fortune%f%F{magenta}”%f\n"
  fi
}

# --- Execute the function ---
print_welcome_message
