#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: MariaDB Database Setup
#
# This script handles the post-installation setup for MariaDB, including
# starting the service and instructing the user on security setup.
#
# ==============================================================================

main() {
  msg_info "Configuring MariaDB..."

  # --- Prerequisite Check ---
  if ! command -v mariadb >/dev/null 2>&1; then
    msg_warning "`mariadb` command not found. Skipping MariaDB configuration."
    return 1
  fi

  # --- Start Service ---
  msg_info "Starting MariaDB service..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: brew services start mariadb"
  else
    if brew services start mariadb; then
      msg_success "MariaDB service started and enabled to run at login."
    else
      msg_error "Failed to start MariaDB service."
    fi
  fi

  # --- Security Instructions ---
  msg_info "
  ==============================================================================
  IMPORTANT: MariaDB Security Setup
  ==============================================================================
  For a secure MariaDB installation, you MUST run the `mysql_secure_installation`
  command manually after this script completes.

  This interactive script will guide you through setting the root password,
  removing anonymous users, disallowing remote root login, and removing the
  test database.

  To run it, open a new terminal and execute:

      mysql_secure_installation

  ==============================================================================
  "

  msg_success "MariaDB configuration complete (manual security step required)."
}

main
