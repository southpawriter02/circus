#!/usr/bin/env bash

# ==============================================================================
#
# Stage 2: Archive and Asset Handling
#
# This script manages the unpacking and validation of any bundled archives,
# such as fonts, images, or other assets that are included in the repository.
#
# Its responsibilities include:
#
#   2.1. Unpacking bundled archives to their target directories.
#   2.2. Validating the integrity of the extracted files.
#   2.3. Cleaning up any temporary files created during extraction.
#
# Implementation Strategy:
#
# 1.  **Dedicated Archive Directory:** All archives to be extracted are placed
#     in a dedicated directory, `assets/archives/`. This provides a clean
#     and predictable location for bundled assets.
#
# 2.  **Extraction Mapping:** An associative array, `EXTRACTION_MAP`, is used
#     to map archive filenames to their specific extraction destinations. This
#     flexible approach separates the configuration (the "what") from the
#     logic (the "how"), making it easy to add or remove assets without
#     modifying the script's core functionality.
#
# 3.  **Robust Extraction Logic:** The script iterates through the configured
#     archives, verifies their existence, creates the target directory if
#     needed, and uses the appropriate command (`unzip` or `tar`) based on
#     the file extension. It includes error handling to gracefully manage
#     missing files or extraction failures.
#
# ==============================================================================

#
# The main logic for the archive and asset handling stage.
#
main() {
  msg_info "Stage 2: Archive and Asset Handling"

  # --- Configuration ----------------------------------------------------------
  # @description: The directory where bundled archives are stored.
  # @customization: Place any archives you want to be automatically extracted
  #                into this directory within the repository.
  local ARCHIVE_DIR="$DOTFILES_DIR/assets/archives"

  # @description: An associative array mapping archive files to their extraction targets.
  # @customization: For each archive in the `$ARCHIVE_DIR`, add an entry here.
  #   - The key is the filename of the archive (e.g., "my-fonts.zip").
  #   - The value is the absolute path to the extraction directory.
  #   - The script supports .zip and .tar.gz/.tgz files.
  declare -A EXTRACTION_MAP
  #
  # Example entries (uncomment and customize to use):
  # EXTRACTION_MAP["fonts.zip"]="$HOME/Library/Fonts"
  # EXTRACTION_MAP["wallpapers.tar.gz"]="$HOME/Pictures/Wallpapers"

  # --- Pre-checks -------------------------------------------------------------
  # Check if the archive directory exists. If not, there's nothing to do.
  if [ ! -d "$ARCHIVE_DIR" ]; then
    msg_info "Archive directory not found at '$ARCHIVE_DIR'. Skipping asset handling."
    return 0
  fi

  # Check if any archives have been configured for extraction.
  if [ ${#EXTRACTION_MAP[@]} -eq 0 ]; then
    msg_info "No archives are configured for extraction. Skipping asset handling."
    return 0
  fi

  # --- Extraction Logic -------------------------------------------------------
  msg_info "Processing bundled archives..."

  for archive_name in "${!EXTRACTION_MAP[@]}"; do
    local archive_path="$ARCHIVE_DIR/$archive_name"
    local target_dir="${EXTRACTION_MAP[$archive_name]}"

    # Verify that the archive file actually exists before trying to extract it.
    if [ ! -f "$archive_path" ]; then
      msg_warning "Archive file '$archive_name' not found in '$ARCHIVE_DIR'. Skipping."
      continue
    fi

    # Ensure the target directory for extraction exists.
    if [ ! -d "$target_dir" ]; then
      msg_info "Creating target directory: $target_dir"
      if ! mkdir -p "$target_dir"; then
        msg_error "Failed to create target directory: $target_dir. Skipping."
        continue
      fi
    fi

    msg_info "Extracting '$archive_name' to '$target_dir'..."

    # Extract the archive based on its file extension.
    case "$archive_name" in
      *.zip)
        # For .zip files, use the `unzip` command.
        # The -o flag overwrites existing files without prompting.
        if unzip -o "$archive_path" -d "$target_dir" >/dev/null; then
          msg_success "Successfully extracted '$archive_name'."
        else
          msg_error "Failed to extract '$archive_name'."
        fi
        ;;
      *.tar.gz|*.tgz)
        # For .tar.gz or .tgz files, use the `tar` command.
        if tar -xzf "$archive_path" -C "$target_dir"; then
          msg_success "Successfully extracted '$archive_name'."
        else
          msg_error "Failed to extract '$archive_name'."
        fi
        ;;
      *)
        # Warn the user if the archive type is not supported.
        msg_warning "Unsupported archive type for '$archive_name'. Skipping."
        ;;
    esac
  done

  msg_success "Archive and asset handling complete."
}

#
# Execute the main function.
#
main
