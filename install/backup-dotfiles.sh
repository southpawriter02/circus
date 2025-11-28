#!/usr/bin/env bash

# ==============================================================================
#
# Dotfiles Backup
#
# This script will contain the logic for backing up existing dotfiles before
# the new ones are symlinked into place.
#
# UNUSED CODE NOTICE:
#   This script is NOT currently referenced in install.sh's INSTALL_STAGES array.
#   
#   RECOMMENDATION: Either:
#   1. Integrate this functionality by adding it to the INSTALL_STAGES array in
#      install.sh before Stage 09 (dotfiles deployment), OR
#   2. Remove this placeholder if backup functionality is not needed, OR
#   3. Keep for future implementation.
#
# ==============================================================================

#
# This is a placeholder for the dotfiles backup logic.
#
# TODO: Implement the actual backup logic here. This might involve:
# 1. Identifying which dotfiles already exist in the home directory.
# 2. Creating a timestamped backup directory.
# 3. Moving the existing dotfiles into the backup directory.
#

msg_info "Backing up existing dotfiles..."

# For now, we will just print a message indicating that this step is a placeholder.
msg_warning "Placeholder: Dotfiles backup logic has not been implemented yet."
