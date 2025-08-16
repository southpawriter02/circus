#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Install Integrity
#
# This script performs an integrity check of the installation files. It does
# this by calculating the SHA-256 checksum of each preflight script and
# comparing it to a list of known checksums.
#
# This helps to ensure that the installation files have not been corrupted or
# tampered with.
#
# ==============================================================================


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo an error message to the console and exit.
#
# @param string $1 The message to echo.
#
function e_error() {
  printf " [31;1m✖[0m %s\n" "$1"
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

e_msg "Performing install integrity check..."

#
# CUSTOMIZATION:
# If you modify any of the preflight scripts, you will need to update their
# checksums in this associative array. You can generate a new checksum using
# the following command from within the 'install' directory:
#
# shasum -a 256 <script_name>
#
declare -A CHECKSUMS
CHECKSUMS["preflight-01-macos-check.sh"]="2a3e6a7b3a3e4b3d2818318e7b1de2a8e8d2b00c2e3919f43f1e48003a2751f2"
CHECKSUMS["preflight-02-root-check.sh"]="f1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"
CHECKSUMS["preflight-03-admin-rights-check.sh"]="a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"
CHECKSUMS["preflight-04-file-permissions-check.sh"]="b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2"
CHECKSUMS["preflight-05-unset-vars-check.sh"]="c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2"
CHECKSUMS["preflight-06-shell-type-version-check.sh"]="d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2"
CHECKSUMS["preflight-07-locale-encoding-check.sh"]="e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2"
CHECKSUMS["preflight-08-battery-check.sh"]="f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2"
CHECKSUMS["preflight-09-wifi-check.sh"]="a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3"
CHECKSUMS["preflight-10-xcode-cli-check.sh"]="b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3"
CHECKSUMS["preflight-11-homebrew-check.sh"]="c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3"
CHECKSUMS["preflight-12-dependency-check.sh"]="d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3"

# A flag to track if any integrity issues are found.
integrity_issue=false

# Get the directory of the current script.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Iterate through the checksums.
for script in "${!CHECKSUMS[@]}"; do
  script_path="$script_dir/$script"

  if [ -f "$script_path" ]; then
    # Calculate the checksum of the script.
    checksum=$(shasum -a 256 "$script_path" | awk '{print $1}')

    # Compare the calculated checksum with the expected checksum.
    if [ "$checksum" == "${CHECKSUMS[$script]}" ]; then
      e_success "$script: OK"
    else
      e_error "$script: FAILED (checksum mismatch)"
      integrity_issue=true
    fi
  else
    e_error "$script: FAILED (file not found)"
    integrity_issue=true
  fi
done

# If any integrity issues were found, exit with an error status.
if [ "$integrity_issue" = true ]; then
  e_error "Install integrity check failed. Please re-download the installation files."
  exit 1
fi

e_success "Install integrity check passed."
exit 0
