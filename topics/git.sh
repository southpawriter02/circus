#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# This file is intended to be sourced by .zshrc, so the shebang is for
# linting and consistency purposes only.
# ------------------------------------------------------------------------------

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FILE:        topics/git.sh                                                 ║
# ║ PROJECT:     Dotfiles Flying Circus                                        ║
# ║ REPOSITORY:  https://github.com/southpawriter02/dotfiles                   ║
# ║ AUTHOR:      southpawriter02 <southpawriter@pm.me>                         ║
# ║                                                                            ║
# ║ DESCRIPTION: This file contains configurations specific to Git. It defines ║
# ║              a set of useful aliases to streamline common Git commands.    ║
# ║              This file is sourced by the main .zshrc.                      ║
# ║                                                                            ║
# ║ LICENSE:     MIT                                                           ║
# ║ COPYRIGHT:   Copyright (c) $(date +'%Y') southpawriter02                   ║
# ║ STATUS:      DRAFT                                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# SECTION: GIT CONFIGURATION
#
# Description: Basic Git user configuration. It's often best to set this
#              globally in your ~/.gitconfig, but it's here for completeness.
# ------------------------------------------------------------------------------

# It is recommended to set your Git user name and email in your global
# .gitconfig file. You can do this by running:
#
# git config --global user.name "Your Name"
# git config --global user.email "your.email@example.com"

# ------------------------------------------------------------------------------
# SECTION: GIT ALIASES
#
# Description: A collection of shorthand aliases for common Git commands.
# ------------------------------------------------------------------------------

# General
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gb='git branch'
alias gbr='git branch -r'
alias gba='git branch -a'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log --oneline --decorate --graph'
alias gll='git log --stat'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gpu='git pull'
alias gr='git restore'
alias grs='git restore --staged'
alias gs='git status -sb' # short, branch info
alias gst='git status'
alias gsh='git show'
alias gss='git stash'
alias gsp='git stash pop'
alias gsl='git stash list'

# ------------------------------------------------------------------------------
# SECTION: GIT FUNCTIONS
#
# Description: More complex Git operations wrapped in shell functions.
# ------------------------------------------------------------------------------

# Example function: git update (fetch, prune, and pull)
gupdate() {
  git fetch --prune && git pull
}
