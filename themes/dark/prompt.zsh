#!/usr/bin/env zsh
# Dark theme prompt - minimal and clean

# Enable colors
autoload -U colors && colors

# Git branch in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'

# Minimal dark prompt
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %F{cyan}❯%f '
RPROMPT='%F{240}%*%f'
