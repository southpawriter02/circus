# ==============================================================================
# Debugging Environment Variables
#
# Environment settings for debugging various languages and frameworks.
# Enable verbose output and debugging tools as needed.
#
# USAGE:
#   These variables are set when the developer role is active.
#   Uncomment specific sections as needed for debugging sessions.
# ==============================================================================

# --- Node.js Debugging --------------------------------------------------------

# Node.js inspector (enable Chrome DevTools debugging)
# export NODE_OPTIONS="--inspect"
# export NODE_OPTIONS="--inspect-brk"  # Break on first line

# Node.js environment
export NODE_ENV="${NODE_ENV:-development}"

# Debug specific Node.js modules
# export DEBUG="express:*,http:*"
# export DEBUG="*"  # Debug all modules

# --- Python Debugging ---------------------------------------------------------

# Enable Python traceback for segfaults (Python 3.3+)
export PYTHONFAULTHANDLER="${PYTHONFAULTHANDLER:-1}"

# Python development mode (extra warnings and checks)
export PYTHONDEVMODE="${PYTHONDEVMODE:-1}"

# Python verbose imports (uncomment to debug import issues)
# export PYTHONVERBOSE="1"

# Python don't write bytecode (cleaner debugging)
# Already set in python.env.sh but ensure for debugging
export PYTHONDONTWRITEBYTECODE="${PYTHONDONTWRITEBYTECODE:-1}"

# Python hash seed (set to specific value for reproducible debugging)
# export PYTHONHASHSEED="0"

# --- Go Debugging -------------------------------------------------------------

# Go race detector (enable for debugging race conditions)
# Build with: go build -race
# export GORACE="halt_on_error=1"

# Go garbage collector debugging
# export GODEBUG="gctrace=1"

# Go scheduler tracing
# export GODEBUG="schedtrace=1000"

# --- Rust Debugging -----------------------------------------------------------

# Rust backtrace (full stack traces on panic)
export RUST_BACKTRACE="${RUST_BACKTRACE:-1}"

# Rust log level for debugging
# export RUST_LOG="debug"
# export RUST_LOG="trace"  # Maximum verbosity

# --- Java/JVM Debugging -------------------------------------------------------

# Enable Java assertions
# export JAVA_OPTS="-ea"

# Java remote debugging (attach debugger on port 5005)
# export JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

# JVM garbage collection logging
# export JAVA_OPTS="-Xlog:gc*:file=gc.log"

# --- Ruby Debugging -----------------------------------------------------------

# Ruby debug mode
# export RUBY_DEBUG="1"

# Ruby verbose warnings
# export RUBYOPT="-W"

# --- Docker Debugging ---------------------------------------------------------

# Docker debug mode
# export DOCKER_DEBUG="1"

# Docker build output
export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"
export BUILDKIT_PROGRESS="${BUILDKIT_PROGRESS:-plain}"

# --- Kubernetes Debugging -----------------------------------------------------

# kubectl verbose logging (0-9, higher = more verbose)
# export KUBECTL_LOG_LEVEL="6"

# --- HTTP Debugging -----------------------------------------------------------

# curl verbose mode (global, use sparingly)
# export CURL_DEBUG="1"

# HTTPie debug
# export HTTPIE_CONFIG_DIR="$XDG_CONFIG_HOME/httpie"

# --- SSL/TLS Debugging --------------------------------------------------------

# OpenSSL debug (very verbose, use for TLS issues)
# export OPENSSL_DEBUG_MEMORY="on"

# Node.js TLS debugging
# export NODE_DEBUG="tls,https"

# --- Git Debugging ------------------------------------------------------------

# Git trace for debugging
# export GIT_TRACE="1"
# export GIT_TRACE_PACK_ACCESS="1"
# export GIT_TRACE_PACKET="1"
# export GIT_TRACE_PERFORMANCE="1"
# export GIT_TRACE_SETUP="1"

# Git curl verbose (for debugging HTTPS issues)
# export GIT_CURL_VERBOSE="1"

# --- Shell Debugging ----------------------------------------------------------

# Zsh debugging
# export ZSH_DEBUG="1"

# Print shell commands before execution (useful for debugging scripts)
# set -x

# Exit on error (strict mode)
# set -e

# Treat unset variables as errors
# set -u

# Pipe failures
# set -o pipefail

# --- Quick Debug Toggle Functions ---------------------------------------------

# Enable verbose debugging for a command
debug_run() {
    (
        set -x
        "$@"
    )
}

# Enable Node.js debugging for a command
node_debug() {
    NODE_DEBUG=* "$@"
}

# Enable Python verbose for a command
python_debug() {
    PYTHONVERBOSE=1 python3 "$@"
}

# Enable curl verbose for a command
curl_debug() {
    curl -v "$@"
}
