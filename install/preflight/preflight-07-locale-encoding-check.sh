#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Locale and Encoding
#
# This script checks the system's locale and encoding settings. It is important
# to ensure that the system is using a UTF-8 encoding to avoid issues with
# special characters and internationalization.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking locale and encoding..."

  # The `locale` command prints information about the current locale settings.
  # We check if the output contains "UTF-8" to determine the encoding.
  if locale | grep -q "UTF-8"; then
    msg_success "Locale and encoding are set to UTF-8."
    return 0
  else
    msg_error "Locale and encoding are not set to UTF-8. Please reconfigure your system."
    return 1
  fi
}

#
# Execute the main function.
#
main
