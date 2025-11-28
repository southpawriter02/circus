#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: MariaDB Database Setup
#
# DESCRIPTION:
#   This script handles the post-installation setup for MariaDB, a popular
#   open-source relational database that's a drop-in replacement for MySQL.
#   It starts the database service and provides instructions for security setup.
#
# REQUIRES:
#   - MariaDB installed via Homebrew (brew install mariadb)
#   - Homebrew services (brew services)
#
# REFERENCES:
#   - MariaDB Knowledge Base
#     https://mariadb.com/kb/en/
#   - MariaDB on Homebrew
#     https://formulae.brew.sh/formula/mariadb
#   - mysql_secure_installation Documentation
#     https://mariadb.com/kb/en/mysql_secure_installation/
#   - MariaDB Configuration Files
#     https://mariadb.com/kb/en/configuring-mariadb-with-option-files/
#
# PATHS:
#   Configuration: /opt/homebrew/etc/my.cnf (Apple Silicon)
#                  /usr/local/etc/my.cnf (Intel)
#   Data:          /opt/homebrew/var/mysql or /usr/local/var/mysql
#   Socket:        /tmp/mysql.sock
#
# PORTS:
#   Default: 3306
#
# NOTES:
#   - MariaDB runs as a Homebrew service (launchd agent)
#   - mysql_secure_installation MUST be run manually for security
#   - Default root password is empty after installation
#   - MariaDB is compatible with MySQL clients and libraries
#
# ==============================================================================

main() {
  msg_info "Configuring MariaDB..."

  # --- Prerequisite Check ---
  # Verify that MariaDB is installed
  if ! command -v mariadb >/dev/null 2>&1; then
    msg_warning "\`mariadb\` command not found. Skipping MariaDB configuration."
    return 1
  fi

  # ==============================================================================
  # Start MariaDB Service
  # ==============================================================================
  #
  # Homebrew services manages launchd agents for background services.
  # Using `brew services start` will:
  # 1. Start the service immediately
  # 2. Configure it to start automatically at login
  #
  # The service runs as the current user, not as root, which is more secure
  # for development environments.

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

  # ==============================================================================
  # Security Setup Instructions
  # ==============================================================================
  #
  # IMPORTANT: mysql_secure_installation must be run manually!
  #
  # This interactive script performs several security-hardening steps:
  # 1. Set the root password (essential for security)
  # 2. Remove anonymous users (prevent unauthenticated access)
  # 3. Disallow remote root login (prevent network attacks)
  # 4. Remove test database (remove unnecessary data)
  # 5. Reload privilege tables (apply changes)
  #
  # This cannot be automated because it requires interactive password input.

  msg_info "
  ==============================================================================
  IMPORTANT: MariaDB Security Setup
  ==============================================================================
  For a secure MariaDB installation, you MUST run the \`mysql_secure_installation\`
  command manually after this script completes.

  This interactive script will guide you through:
  
    1. Setting the root password (currently empty!)
    2. Removing anonymous users
    3. Disallowing remote root login
    4. Removing the test database
    5. Reloading privilege tables
  
  To run it, open a new terminal and execute:

      mysql_secure_installation

  After securing MariaDB, you can connect using:

      mariadb -u root -p

  ==============================================================================
  "

  msg_success "MariaDB configuration complete (manual security step required)."
}

main
