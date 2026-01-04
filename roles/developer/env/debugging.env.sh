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

# --- macOS/Darwin Debugging --------------------------------------------------

# LLDB debugging server log file (for Xcode/LLDB debugging)
# export LLDB_DEBUGSERVER_LOG_FILE="${LLDB_DEBUGSERVER_LOG_FILE:-/tmp/lldb-debugserver.log}"

# Swift implicit Objective-C entry point debugging
# export SWIFT_DEBUG_IMPLICIT_OBJC_ENTRY_POINT="${SWIFT_DEBUG_IMPLICIT_OBJC_ENTRY_POINT:-1}"

# --- Memory Debugging (macOS) ------------------------------------------------

# Enable malloc stack logging (records allocation backtraces)
# Use with: malloc_history, leaks, or Instruments
# export MallocStackLogging="${MallocStackLogging:-1}"

# Full stack logging (more detailed but slower)
# export MallocStackLoggingNoCompact="${MallocStackLoggingNoCompact:-1}"

# Fill allocated memory with 0xAA and freed memory with 0x55
# Helps detect use-after-free and uninitialized memory
# export MallocScribble="${MallocScribble:-1}"

# Add guard pages to detect buffer overflows
# export MallocGuardEdges="${MallocGuardEdges:-1}"

# Check heap consistency on every allocation (very slow)
# export MallocCheckHeapStart="${MallocCheckHeapStart:-1000}"
# export MallocCheckHeapEach="${MallocCheckHeapEach:-100}"

# --- Objective-C Debugging ---------------------------------------------------

# Enable NSZombie objects (detect messages to deallocated objects)
# Only use during debugging, not production
# export NSZombieEnabled="${NSZombieEnabled:-YES}"

# Log all Objective-C method calls (extremely verbose)
# export NSObjCMessageLoggingEnabled="${NSObjCMessageLoggingEnabled:-YES}"

# Disable Objective-C tagged pointers (for debugging)
# export OBJC_DISABLE_TAGGED_POINTERS="${OBJC_DISABLE_TAGGED_POINTERS:-1}"

# Print class information on load
# export OBJC_PRINT_CLASS_SETUP="${OBJC_PRINT_CLASS_SETUP:-YES}"

# --- Dynamic Linker Debugging ------------------------------------------------

# Print libraries as they are loaded
# export DYLD_PRINT_LIBRARIES="${DYLD_PRINT_LIBRARIES:-1}"

# Print API calls to dyld
# export DYLD_PRINT_APIS="${DYLD_PRINT_APIS:-1}"

# Print binding information (symbol resolution)
# export DYLD_PRINT_BINDINGS="${DYLD_PRINT_BINDINGS:-1}"

# Print initialization order
# export DYLD_PRINT_INITIALIZERS="${DYLD_PRINT_INITIALIZERS:-1}"

# Print segment information
# export DYLD_PRINT_SEGMENTS="${DYLD_PRINT_SEGMENTS:-1}"

# Print statistics about dyld operations
# export DYLD_PRINT_STATISTICS="${DYLD_PRINT_STATISTICS:-1}"

# --- Electron/Chromium Debugging ---------------------------------------------

# Enable Electron logging
# export ELECTRON_ENABLE_LOGGING="${ELECTRON_ENABLE_LOGGING:-1}"

# Enable Electron stack dumps on crash
# export ELECTRON_ENABLE_STACK_DUMPING="${ELECTRON_ENABLE_STACK_DUMPING:-1}"

# Enable Chromium remote debugging
# export ELECTRON_DEBUG_PORT="${ELECTRON_DEBUG_PORT:-9229}"

# --- React Native Debugging --------------------------------------------------

# React Native packager port
# export REACT_NATIVE_PACKAGER_PORT="${REACT_NATIVE_PACKAGER_PORT:-8081}"

# Enable React Native debugging
# export RCT_ENABLE_DEBUGGER="${RCT_ENABLE_DEBUGGER:-1}"

# --- Flutter Debugging -------------------------------------------------------

# Flutter verbose mode
# export FLUTTER_VERBOSE="${FLUTTER_VERBOSE:-1}"

# Dart VM debugging port
# export DART_VM_OPTIONS="--observe --enable-vm-service:8181"

# --- Database Debugging ------------------------------------------------------

# PostgreSQL debug output
# export PGOPTIONS="-c client_min_messages=DEBUG1"

# MySQL debug mode
# export MYSQL_DEBUG="${MYSQL_DEBUG:-d:t:O,/tmp/mysql.trace}"

# SQLite verbose debugging
# export SQLITE_DEBUG="${SQLITE_DEBUG:-1}"

# --- Network Debugging -------------------------------------------------------

# Enable libcurl debug callback
# export CURLOPT_VERBOSE="${CURLOPT_VERBOSE:-1}"

# mitmproxy CA certificate path (for HTTPS debugging)
# export SSL_CERT_FILE="${HOME}/.mitmproxy/mitmproxy-ca-cert.pem"
# export REQUESTS_CA_BUNDLE="${HOME}/.mitmproxy/mitmproxy-ca-cert.pem"

# --- AWS SDK Debugging -------------------------------------------------------

# AWS SDK debug logging
# export AWS_DEBUG="${AWS_DEBUG:-1}"

# Boto3 (Python AWS SDK) debug logging
# export BOTO_CONFIG_DEBUG="${BOTO_CONFIG_DEBUG:-1}"

# --- Additional Debug Helper Functions ---------------------------------------

# Enable Rust debug for a command
rust_debug() {
    RUST_BACKTRACE=full RUST_LOG=trace "$@"
}

# Enable Go debug for a command
go_debug() {
    GODEBUG=gctrace=1 "$@"
}

# Memory debug for a macOS command
mem_debug() {
    MallocStackLogging=1 MallocScribble=1 "$@"
}

# LLDB quick attach to process by name
lldb_attach() {
    local process_name="$1"
    lldb -n "$process_name"
}

# Print all environment variables matching a pattern
envgrep() {
    env | grep -i "$1" | sort
}

# Show all debug-related environment variables
show_debug_vars() {
    echo "=== Debug Environment Variables ==="
    envgrep "debug\|trace\|verbose\|log"
}
