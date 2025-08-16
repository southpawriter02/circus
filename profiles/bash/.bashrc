#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         .bashrc
#
# DESCRIPTION:  This file is executed for interactive non-login shells. It
#               sources the main .bash_init script to load the shell
#               configuration.
#
# ==============================================================================

#
# Check if .bash_init exists and is readable, then source it.
#
if [ -f "$HOME/.bash_init" ]; then
  source "$HOME/.bash_init"
fi
