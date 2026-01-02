#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/vscode_backends/repo.sh
#
# DESCRIPTION:  Git repository backend for fc-vscode-sync. Stores VS Code
#               settings in a dedicated Git repository.
#
# REQUIRES:
#   - git
#   - Repository with read/write access (SSH key or HTTPS credentials)
#
# ==============================================================================

# --- Backend Interface Functions ----------------------------------------------

# Returns the display name of this backend
vscode_backend_get_name() {
  echo "Git Repository"
}

# Check if backend dependencies are installed
# Returns 0 if all dependencies are available, 1 otherwise
vscode_backend_check_dependencies() {
  if ! command -v git >/dev/null 2>&1; then
    msg_error "Missing dependency for repo backend: git"
    msg_info "Install with: brew install git"
    return 1
  fi

  return 0
}

# Validate backend-specific configuration
# Returns 0 if valid, exits with error otherwise
vscode_backend_validate_config() {
  if [ -z "${VSCODE_REPO_URL:-}" ]; then
    die "VSCODE_REPO_URL is not configured. Set it in $VSCODE_CONFIG_FILE"
  fi

  return 0
}

# Push local files to repository
# Arguments: temp_dir containing files to push
vscode_backend_push() {
  local source_dir="$1"
  local branch="${VSCODE_REPO_BRANCH:-main}"

  local clone_dir
  clone_dir=$(mktemp -d)

  # Ensure cleanup on exit
  trap "rm -rf '$clone_dir'" RETURN

  msg_info "Cloning repository..."

  # Try to clone existing repo
  if ! git clone --depth 1 -b "$branch" "$VSCODE_REPO_URL" "$clone_dir" 2>/dev/null; then
    # Branch might not exist, try without branch specification
    if ! git clone --depth 1 "$VSCODE_REPO_URL" "$clone_dir" 2>/dev/null; then
      die "Failed to clone repository: $VSCODE_REPO_URL"
    fi

    # Create and checkout the branch if it doesn't exist
    cd "$clone_dir" || die "Failed to enter clone directory"
    if ! git checkout "$branch" 2>/dev/null; then
      git checkout -b "$branch"
    fi
  else
    cd "$clone_dir" || die "Failed to enter clone directory"
  fi

  # Copy files from source to clone
  msg_info "Copying settings to repository..."
  for file in "$source_dir"/*; do
    [ -f "$file" ] || continue
    cp "$file" "$clone_dir/"
  done

  # Handle snippets directory if present
  if [ -d "$source_dir/snippets" ]; then
    rm -rf "$clone_dir/snippets"
    cp -r "$source_dir/snippets" "$clone_dir/"
  fi

  # Check if there are changes
  if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
    msg_info "No changes to push"
    return 0
  fi

  # Commit and push
  msg_info "Committing changes..."
  git add -A

  local commit_msg="Update VS Code settings ($(date +%Y-%m-%d\ %H:%M))"
  git commit -m "$commit_msg" || {
    msg_info "No changes to commit"
    return 0
  }

  msg_info "Pushing to remote..."
  if ! git push origin "$branch"; then
    # If push fails, might need to set upstream
    git push -u origin "$branch" || die "Failed to push to repository"
  fi

  msg_success "Pushed settings to repository"
  msg_info "Repository: $VSCODE_REPO_URL"
  msg_info "Branch: $branch"
}

# Pull files from repository to temp directory
# Arguments: temp_dir to store pulled files
# Returns: 0 on success, 1 on failure
vscode_backend_pull() {
  local target_dir="$1"
  local branch="${VSCODE_REPO_BRANCH:-main}"

  local clone_dir
  clone_dir=$(mktemp -d)

  # Ensure cleanup on exit
  trap "rm -rf '$clone_dir'" RETURN

  msg_info "Cloning repository..."

  # Clone the repository
  if ! git clone --depth 1 -b "$branch" "$VSCODE_REPO_URL" "$clone_dir" 2>/dev/null; then
    # Try without branch specification
    if ! git clone --depth 1 "$VSCODE_REPO_URL" "$clone_dir" 2>/dev/null; then
      die "Failed to clone repository: $VSCODE_REPO_URL"
    fi

    # Check if branch exists
    cd "$clone_dir" || die "Failed to enter clone directory"
    if ! git checkout "$branch" 2>/dev/null; then
      die "Branch '$branch' does not exist in repository"
    fi
  fi

  # Copy files to target directory
  for file in "$clone_dir"/*; do
    [ -f "$file" ] || continue

    local filename
    filename=$(basename "$file")

    # Skip git-related files
    case "$filename" in
      .git*|README*|LICENSE*)
        continue
        ;;
    esac

    cp "$file" "$target_dir/"
  done

  # Copy snippets directory if present
  if [ -d "$clone_dir/snippets" ]; then
    cp -r "$clone_dir/snippets" "$target_dir/"
  fi

  msg_success "Fetched settings from repository"
}

# Get remote state for status comparison
# Arguments: temp_dir to store fetched files
vscode_backend_get_status() {
  vscode_backend_pull "$@"
}
