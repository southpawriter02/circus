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
[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"
[ -f "$HOME/.zoptions" ] && . "$HOME/.zoptions"
[ -f "$HOME/.zprompt" ] && . "$HOME/.zprompt"
[ -f "$HOME/.zcompletions" ] && . "$HOME/.zcompletions"
[ -f "$HOME/.githelpers" ] && . "$HOME/.githelpers"

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
