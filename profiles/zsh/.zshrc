#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zshrc
#
# DESCRIPTION:  This is the primary configuration file for interactive Zsh
#               shells. It is sourced after .zshenv and is the main entry
#               point for configuring the interactive shell environment.
#
# ==============================================================================

#
# Source all modular configuration files.
#
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"
[ -f "$HOME/.zoptions" ] && . "$HOME/.zoptions"
[ -f "$HOME/.zprompt" ] && . "$HOME/.zprompt"
[ -f "$HOME/.zcompletions" ] && . "$HOME/.zcompletions"
[ -f "$HOME/.githelpers" ] && . "$HOME/.githelpers"

# Source all modular environment files from the dedicated env directory.
if [ -d "$HOME/.config/shell/env" ]; then
  for env_file in "$HOME"/.config/shell/env/*.sh; do
    if [ -r "$env_file" ]; then
      . "$env_file"
    fi
  done
fi

# Source all modular alias files from the dedicated aliases directory.
if [ -d "$HOME/.config/shell/aliases" ]; then
  for alias_file in "$HOME"/.config/shell/aliases/*.sh; do
    if [ -r "$alias_file" ]; then
      . "$alias_file"
    fi
  done
fi

# --- NVM (Node Version Manager) Setup ---------------------------------------
# Lazily load nvm to keep shell startup fast.
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

# --- Local Overrides --------------------------------------------------------
# Source local, user-specific configurations last, to allow for overrides.
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
