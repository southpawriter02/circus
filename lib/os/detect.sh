#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/os/detect.sh
#
# DESCRIPTION:  Platform detection functions for cross-platform support.
#               Detects macOS, Linux, and WSL environments.
#
# USAGE:
#   source "$LIB_DIR/os/detect.sh"
#   if is_macos; then echo "Running on macOS"; fi
#   if is_linux; then echo "Running on Linux"; fi
#
# ==============================================================================

# Cache the detected OS to avoid repeated detection
_DETECTED_OS=""
_DETECTED_DISTRO=""

# ------------------------------------------------------------------------------
# SECTION: OS DETECTION
# ------------------------------------------------------------------------------

#
# @description
#   Detects the current operating system.
#
# @return "macos", "linux", "wsl", or "unknown"
#
detect_os() {
    # Return cached value if available
    if [[ -n "$_DETECTED_OS" ]]; then
        echo "$_DETECTED_OS"
        return
    fi
    
    case "$(uname -s)" in
        Darwin)
            _DETECTED_OS="macos"
            ;;
        Linux)
            # Check for WSL
            if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
                _DETECTED_OS="wsl"
            else
                _DETECTED_OS="linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            _DETECTED_OS="windows"
            ;;
        *)
            _DETECTED_OS="unknown"
            ;;
    esac
    
    echo "$_DETECTED_OS"
}

#
# @description
#   Detects the Linux distribution.
#
# @return Distribution ID (e.g., "ubuntu", "fedora", "arch") or "unknown"
#
detect_distro() {
    # Return cached value if available
    if [[ -n "$_DETECTED_DISTRO" ]]; then
        echo "$_DETECTED_DISTRO"
        return
    fi
    
    # Only applicable on Linux
    if [[ "$(detect_os)" != "linux" && "$(detect_os)" != "wsl" ]]; then
        _DETECTED_DISTRO="n/a"
        echo "$_DETECTED_DISTRO"
        return
    fi
    
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        _DETECTED_DISTRO="${ID:-unknown}"
    elif [[ -f /etc/lsb-release ]]; then
        # shellcheck source=/dev/null
        . /etc/lsb-release
        _DETECTED_DISTRO="${DISTRIB_ID:-unknown}"
        _DETECTED_DISTRO="${_DETECTED_DISTRO,,}"  # lowercase
    elif command -v lsb_release &>/dev/null; then
        _DETECTED_DISTRO="$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    else
        _DETECTED_DISTRO="unknown"
    fi
    
    echo "$_DETECTED_DISTRO"
}

#
# @description
#   Gets a friendly name for the current OS.
#
# @return Human-readable OS name
#
get_os_name() {
    case "$(detect_os)" in
        macos)
            echo "macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
            ;;
        linux)
            if [[ -f /etc/os-release ]]; then
                # shellcheck source=/dev/null
                . /etc/os-release
                echo "${PRETTY_NAME:-Linux}"
            else
                echo "Linux"
            fi
            ;;
        wsl)
            echo "WSL ($(detect_distro))"
            ;;
        *)
            echo "Unknown OS"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# SECTION: CONVENIENCE BOOLEAN FUNCTIONS
# ------------------------------------------------------------------------------

#
# @description Check if running on macOS
# @return 0 (true) if macOS, 1 (false) otherwise
#
is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

#
# @description Check if running on Linux (including WSL)
# @return 0 (true) if Linux or WSL, 1 (false) otherwise
#
is_linux() {
    local os
    os="$(detect_os)"
    [[ "$os" == "linux" || "$os" == "wsl" ]]
}

#
# @description Check if running on WSL specifically
# @return 0 (true) if WSL, 1 (false) otherwise
#
is_wsl() {
    [[ "$(detect_os)" == "wsl" ]]
}

# ------------------------------------------------------------------------------
# SECTION: DISTRO-SPECIFIC CHECKS
# ------------------------------------------------------------------------------

#
# @description Check if running on a Debian-based distro
# @return 0 (true) if Debian/Ubuntu/Pop/Mint, 1 (false) otherwise
#
is_debian_based() {
    local distro
    distro="$(detect_distro)"
    [[ "$distro" == "debian" || "$distro" == "ubuntu" || "$distro" == "pop" || \
       "$distro" == "linuxmint" || "$distro" == "elementary" ]]
}

#
# @description Check if running on a RHEL-based distro
# @return 0 (true) if Fedora/RHEL/CentOS/Rocky, 1 (false) otherwise
#
is_rhel_based() {
    local distro
    distro="$(detect_distro)"
    [[ "$distro" == "fedora" || "$distro" == "rhel" || "$distro" == "centos" || \
       "$distro" == "rocky" || "$distro" == "almalinux" ]]
}

#
# @description Check if running on Arch Linux or derivatives
# @return 0 (true) if Arch/Manjaro/EndeavourOS, 1 (false) otherwise
#
is_arch_based() {
    local distro
    distro="$(detect_distro)"
    [[ "$distro" == "arch" || "$distro" == "manjaro" || "$distro" == "endeavouros" ]]
}

# ------------------------------------------------------------------------------
# SECTION: FEATURE AVAILABILITY CHECKS
# ------------------------------------------------------------------------------

#
# @description Check if a command/feature requires macOS
# @param $1 Feature name (for error message)
# @return Dies with error message if not on macOS
#
require_macos() {
    local feature="${1:-This feature}"
    if ! is_macos; then
        die "$feature is only available on macOS"
    fi
}

#
# @description Check if a command/feature requires Linux
# @param $1 Feature name (for error message)
# @return Dies with error message if not on Linux
#
require_linux() {
    local feature="${1:-This feature}"
    if ! is_linux; then
        die "$feature is only available on Linux"
    fi
}

# Export all functions
export -f detect_os detect_distro get_os_name
export -f is_macos is_linux is_wsl
export -f is_debian_based is_rhel_based is_arch_based
export -f require_macos require_linux
