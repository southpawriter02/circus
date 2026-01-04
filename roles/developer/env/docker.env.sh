# ==============================================================================
# Docker Development Environment Variables
#
# Configuration for Docker and Docker Compose development workflows.
# These settings optimize the Docker experience for local development.
#
# USAGE:
#   These variables are set when the developer role is active.
#   Customize values based on your development needs.
#
# REFERENCES:
#   - Docker CLI environment variables:
#     https://docs.docker.com/engine/reference/commandline/cli/#environment-variables
#   - Docker Compose environment variables:
#     https://docs.docker.com/compose/environment-variables/envvars/
#   - BuildKit documentation:
#     https://docs.docker.com/build/buildkit/
# ==============================================================================

# --- BuildKit Settings --------------------------------------------------------

# Enable BuildKit for improved build performance and features
# BuildKit provides better caching, parallel builds, and build secrets
export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"

# Use Docker CLI for Compose builds (enables BuildKit in docker-compose)
export COMPOSE_DOCKER_CLI_BUILD="${COMPOSE_DOCKER_CLI_BUILD:-1}"

# BuildKit progress output format
# Options: auto, plain, tty
# plain = Show all build output (useful for CI/debugging)
# tty = Interactive progress bars (default for terminals)
export BUILDKIT_PROGRESS="${BUILDKIT_PROGRESS:-auto}"

# BuildKit inline cache metadata (useful for CI caching)
# Embeds cache metadata in the image for later reuse
# export BUILDKIT_INLINE_CACHE="${BUILDKIT_INLINE_CACHE:-1}"

# --- Docker CLI Settings ------------------------------------------------------

# Disable Docker scan suggestions after builds
# Reduces noise in terminal output
export DOCKER_SCAN_SUGGEST="${DOCKER_SCAN_SUGGEST:-false}"

# Disable Docker CLI hints and tips
# Cleaner output for experienced users
export DOCKER_CLI_HINTS="${DOCKER_CLI_HINTS:-false}"

# Default platform for multi-architecture builds
# Useful when running on Apple Silicon but targeting Linux AMD64
# export DOCKER_DEFAULT_PLATFORM="${DOCKER_DEFAULT_PLATFORM:-linux/amd64}"

# Docker configuration directory
export DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.docker}"

# --- Docker Compose Settings --------------------------------------------------

# Default separator for container names
# Default is '-', can change to '_' for compatibility
export COMPOSE_PATH_SEPARATOR="${COMPOSE_PATH_SEPARATOR:-:}"

# HTTP timeout for Docker Compose operations (in seconds)
# Increase for slower networks or large image pulls
export COMPOSE_HTTP_TIMEOUT="${COMPOSE_HTTP_TIMEOUT:-120}"

# Disable ANSI output (useful for CI environments)
# export COMPOSE_ANSI="${COMPOSE_ANSI:-never}"

# Number of parallel operations for Compose
# Increase for faster builds on multi-core systems
export COMPOSE_PARALLEL_LIMIT="${COMPOSE_PARALLEL_LIMIT:-8}"

# Default Compose file names to look for
# export COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml:docker-compose.override.yml}"

# --- Security Settings --------------------------------------------------------

# Enable Docker Content Trust for image verification
# When enabled, only signed images can be pulled/pushed
# export DOCKER_CONTENT_TRUST="${DOCKER_CONTENT_TRUST:-1}"

# Docker Content Trust server (Notary)
# export DOCKER_CONTENT_TRUST_SERVER="${DOCKER_CONTENT_TRUST_SERVER:-https://notary.docker.io}"

# --- Build Performance --------------------------------------------------------

# Temporary directory for Docker builds
# Use a fast SSD location for better performance
# export DOCKER_TMPDIR="${DOCKER_TMPDIR:-/tmp/docker-builds}"

# BuildKit cache directory (for local cache)
# export BUILDX_CACHE_DIR="${BUILDX_CACHE_DIR:-$HOME/.docker/buildx-cache}"

# Maximum number of concurrent build operations
export DOCKER_BUILDKIT_PROGRESS_OUTPUT="${DOCKER_BUILDKIT_PROGRESS_OUTPUT:-auto}"

# --- Docker Host Settings -----------------------------------------------------

# Docker daemon socket location (uncomment to customize)
# For Docker Desktop on macOS, this is typically the default
# export DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker.sock}"

# For Docker in Colima (alternative to Docker Desktop):
# export DOCKER_HOST="${DOCKER_HOST:-unix://$HOME/.colima/default/docker.sock}"

# For remote Docker daemon over TCP (use with TLS):
# export DOCKER_HOST="${DOCKER_HOST:-tcp://remote-host:2376}"
# export DOCKER_TLS_VERIFY="${DOCKER_TLS_VERIFY:-1}"
# export DOCKER_CERT_PATH="${DOCKER_CERT_PATH:-$HOME/.docker/certs}"

# --- Registry Settings --------------------------------------------------------

# Default registry for image operations
# export DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"

# Disable credential helper (use file-based auth)
# export DOCKER_CREDENTIAL_HELPER="${DOCKER_CREDENTIAL_HELPER:-none}"

# --- Logging & Debugging ------------------------------------------------------

# Enable Docker daemon debug mode (for troubleshooting)
# Note: This affects the daemon, not just the CLI
# export DOCKER_DEBUG="${DOCKER_DEBUG:-1}"

# Log level for Docker CLI
# Options: debug, info, warn, error, fatal
# export DOCKER_LOG_LEVEL="${DOCKER_LOG_LEVEL:-info}"

# --- Buildx Settings ----------------------------------------------------------

# Default Buildx builder name
# export BUILDX_BUILDER="${BUILDX_BUILDER:-default}"

# Enable experimental Buildx features
export DOCKER_BUILDX="${DOCKER_BUILDX:-1}"

# --- Container Runtime Settings -----------------------------------------------

# Default container runtime (for containerd integration)
# export DOCKER_RUNTIME="${DOCKER_RUNTIME:-runc}"

# Default isolation mode (Windows containers)
# export DOCKER_ISOLATION="${DOCKER_ISOLATION:-default}"
