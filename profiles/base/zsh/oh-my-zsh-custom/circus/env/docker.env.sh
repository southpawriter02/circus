# ==============================================================================
# Docker Configuration
#
# Environment variables for Docker and container development.
# ==============================================================================

# --- BuildKit -----------------------------------------------------------------

# Enable BuildKit (much faster builds with better caching)
export DOCKER_BUILDKIT=1

# Use BuildKit for docker-compose / docker compose
export COMPOSE_DOCKER_CLI_BUILD=1

# --- Docker CLI Behavior ------------------------------------------------------

# Disable Docker scan suggestions after builds
export DOCKER_SCAN_SUGGEST=false

# Default platform for multi-arch builds
# export DOCKER_DEFAULT_PLATFORM=linux/amd64

# --- Docker Config Directory --------------------------------------------------

# Docker configuration directory
export DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.docker}"

# --- Compose Configuration ----------------------------------------------------

# Docker Compose project separator (default: -)
# export COMPOSE_PROJECT_SEPARATOR="_"

# Parallel build workers
export COMPOSE_PARALLEL_LIMIT=4

# --- Container Development ----------------------------------------------------

# Testcontainers - reuse containers between test runs
export TESTCONTAINERS_REUSE_ENABLE=true

# --- Colima Configuration (Docker Desktop alternative) -----------------------

# Colima socket (if using Colima instead of Docker Desktop)
# export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"

# --- Podman Configuration (Docker alternative) -------------------------------

# Uncomment if using Podman as Docker replacement
# alias docker=podman
# export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
