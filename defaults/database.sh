#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: PostgreSQL Database Setup
#
# This script handles the post-installation setup for PostgreSQL, including
# initializing the database cluster and creating a default user.
#
# ==============================================================================

main() {
  msg_info "Configuring PostgreSQL..."

  # --- Prerequisite Check ---
  if ! command -v psql >/dev/null 2>&1; then
    msg_warning "`psql` command not found. Skipping PostgreSQL configuration."
    return 1
  fi

  # --- Configuration ---
  # Find the data directory for PostgreSQL installed via Homebrew.
  local pg_data_dir
  if [ -d "/opt/homebrew/var/postgres" ]; then
    pg_data_dir="/opt/homebrew/var/postgres"
  elif [ -d "/usr/local/var/postgres" ]; then
    pg_data_dir="/usr/local/var/postgres"
  else
    msg_error "Could not find PostgreSQL data directory. Cannot proceed."
    return 1
  fi

  # --- Database Initialization ---
  # Check if the data directory is empty. If it is, the database needs to be initialized.
  if [ -z "$(ls -A "$pg_data_dir")" ]; then
    msg_info "PostgreSQL data directory is empty. Initializing database cluster..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would run: initdb -D $pg_data_dir"
    else
      if initdb -D "$pg_data_dir"; then
        msg_success "Database cluster initialized successfully."
      else
        msg_error "Failed to initialize database cluster."
        return 1
      fi
    fi
  else
    msg_info "PostgreSQL database cluster already initialized."
  fi

  # --- Start Service ---
  msg_info "Starting PostgreSQL service..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: brew services start postgresql"
  else
    if brew services start postgresql; then
      msg_success "PostgreSQL service started and enabled to run at login."
    else
      msg_error "Failed to start PostgreSQL service."
    fi
  fi

  # --- Create Default User ---
  # Create a user with the same name as the current macOS user.
  local current_user=$(whoami)
  msg_info "Ensuring PostgreSQL user '$current_user' exists..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would check for and create PostgreSQL user: $current_user"
  else
    # Check if the user already exists before trying to create it.
    if ! psql -t -c '\du' | cut -d \| -f 1 | grep -qw "$current_user"; then
      if createuser --superuser "$current_user"; then
        msg_success "Created PostgreSQL superuser: $current_user"
      else
        msg_error "Failed to create PostgreSQL user: $current_user"
      fi
    else
      msg_info "PostgreSQL user '$current_user' already exists."
    fi
  fi

  msg_success "PostgreSQL configuration complete."
}

main
