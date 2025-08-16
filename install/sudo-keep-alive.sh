#!/usr/bin/env bash

# ==============================================================================
#
# Sudo Keep-Alive
#
# This script requests sudo privileges upfront and then keeps them alive
# throughout the execution of the main installation script. This prevents the
# user from having to re-enter their password multiple times.
#
# ==============================================================================

#
# Request sudo privileges upfront. The `-v` flag updates the user's cached
# credentials, and if the cache has expired, it will prompt for a password.
#
sudo -v

#
# Keep-alive: update existing `sudo` time stamp until the script has finished.
# This is done by running a harmless command (`sudo -n true`) in a loop in the
# background. The loop will exit if the main script process (identified by `$$`)
# is no longer running.
#
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
