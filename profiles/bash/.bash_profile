#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         .bash_profile
#
# DESCRIPTION:  This file is executed for login shells. Its primary purpose is
#               to load the user's shell configuration from .bashrc.
#               This ensures a consistent environment for both login and
#               interactive non-login shells.
#
# ==============================================================================

#
# Check if .bashrc exists and is readable, then source it.
# This ensures that the configuration is only loaded if the file is present.
#
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi
