#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         init.sh
#
# DESCRIPTION:  This script acts as a safe entry point for running the main
#               `install.sh` script. It makes the installer executable,
#               runs it, and then returns it to a non-executable state.
#
# USAGE:        ./init.sh
#
# ==============================================================================

# --- Setup ------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the path to the main installation script.
readonly INSTALL_SCRIPT="./install.sh"

# --- Cleanup Trap -----------------------------------------------------------

# The `trap` command sets up a cleanup routine that is guaranteed to run
# when the script exits, regardless of whether it succeeds, fails, or is
# interrupted.
# Here, we ensure that the main installer is always returned to a non-executable
# state.
trap 'chmod -x "$INSTALL_SCRIPT"' EXIT

# --- Main Logic -------------------------------------------------------------

echo "Initializing the Dotfiles Flying Circus installer..."

# Make the main installation script executable.
chmod +x "$INSTALL_SCRIPT"

# Execute the main installer, passing along any arguments provided to this script.
echo "Executing the main installer..."
echo ""
"$INSTALL_SCRIPT" "$@"

# The `trap` command will automatically run on exit to clean up the permissions.
