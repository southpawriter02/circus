#!/usr/bin/env zsh
# Light theme prompt - clean and visible on light backgrounds

# Enable colors
autoload -U colors && colors

# Git branch in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{red}(%b)%f'

# Light-friendly prompt
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %F{magenta}❯%f '
RPROMPT='%F{245}%*%f'
