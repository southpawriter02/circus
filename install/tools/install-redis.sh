#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Redis
#
# This script checks for the presence of Redis and installs it if it is
# missing. Redis is an in-memory data structure store.
#
# ==============================================================================

#
# The main logic for installing Redis.
#
main() {
  msg_info "Checking for Redis..."

  # Check if the redis-server command is already available.
  if command -v "redis-server" >/dev/null 2>&1; then
    msg_success "Redis is already installed."
    return 0
  fi

  msg_warning "Redis is not installed."
  msg_info "The installer will now attempt to install Redis using Homebrew."

  # Install Redis using the `brew` command.
  if brew install redis; then
    msg_success "Redis installed successfully."
    # Optional: Start Redis as a service.
    # brew services start redis
  else
    msg_error "Redis installation failed."
    msg_error "Please ensure Homebrew is installed correctly and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
