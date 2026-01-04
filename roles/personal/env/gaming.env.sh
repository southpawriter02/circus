# ==============================================================================
# Gaming Environment Variables
#
# Configuration for gaming on macOS including Steam, Wine/CrossOver,
# game capture, and performance settings.
#
# USAGE:
#   These variables are set when the personal role is active.
#   Customize paths and settings based on your gaming setup.
#
# NOTE:
#   macOS gaming has improved with Apple Silicon and Game Porting Toolkit.
#   Many settings here support Wine/CrossOver for Windows games.
# ==============================================================================

# --- Game Directories --------------------------------------------------------

# Steam installation (native macOS)
export STEAM_DIR="${STEAM_DIR:-$HOME/Library/Application Support/Steam}"

# Steam games library
export STEAM_LIBRARY="${STEAM_LIBRARY:-$HOME/Library/Application Support/Steam/steamapps/common}"

# General games directory
export GAMES_DIR="${GAMES_DIR:-$HOME/Games}"

# Game saves backup location
export GAME_SAVES_DIR="${GAME_SAVES_DIR:-$HOME/Documents/Game Saves}"

# Create directories if they don't exist
[[ -d "$GAMES_DIR" ]] || mkdir -p "$GAMES_DIR"
[[ -d "$GAME_SAVES_DIR" ]] || mkdir -p "$GAME_SAVES_DIR"

# --- Wine/CrossOver Configuration --------------------------------------------

# Wine prefix for Windows games
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

# Wine architecture (win32 or win64)
export WINEARCH="${WINEARCH:-win64}"

# CrossOver bottles location
export CX_BOTTLE_PATH="${CX_BOTTLE_PATH:-$HOME/Library/Application Support/CrossOver/Bottles}"

# Disable Wine debugging output (cleaner logs)
export WINEDEBUG="${WINEDEBUG:--all}"

# --- Apple Game Porting Toolkit (GPTK) ---------------------------------------

# GPTK installation path (if using Homebrew)
export GPTK_PATH="${GPTK_PATH:-/usr/local/opt/game-porting-toolkit}"

# GPTK Wine prefix
export GPTK_WINE_PREFIX="${GPTK_WINE_PREFIX:-$HOME/Games/gptk-prefix}"

# --- Graphics & Performance --------------------------------------------------

# DXVK async shader compilation (reduces stuttering)
export DXVK_ASYNC="${DXVK_ASYNC:-1}"

# DXVK HUD (performance overlay)
# Options: fps, frametimes, submissions, drawcalls, pipelines, memory, gpuload, version, api
# export DXVK_HUD="${DXVK_HUD:-fps,frametimes,gpuload}"

# MoltenVK configuration
export MVK_CONFIG_FAST_MATH_ENABLED="${MVK_CONFIG_FAST_MATH_ENABLED:-1}"
export MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS="${MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS:-2}"

# OpenGL shader disk cache
export __GL_SHADER_DISK_CACHE="${__GL_SHADER_DISK_CACHE:-1}"
export __GL_SHADER_DISK_CACHE_PATH="${__GL_SHADER_DISK_CACHE_PATH:-$HOME/.cache/gl-shaders}"

# Mesa threading (for OpenGL games)
export mesa_glthread="${mesa_glthread:-true}"

# --- Game Capture & Recording ------------------------------------------------

# Screenshot and recording location
export GAME_CAPTURE_DIR="${GAME_CAPTURE_DIR:-$HOME/Pictures/Game Captures}"
[[ -d "$GAME_CAPTURE_DIR" ]] || mkdir -p "$GAME_CAPTURE_DIR"

# OBS configuration directory
export OBS_CONFIG="${OBS_CONFIG:-$HOME/Library/Application Support/obs-studio}"

# --- Controller & Input ------------------------------------------------------

# SDL game controller database
export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG:-}"

# Enable SDL game controller support
export SDL_GAMECONTROLLER_IGNORE_DEVICES="${SDL_GAMECONTROLLER_IGNORE_DEVICES:-}"

# --- Emulators ---------------------------------------------------------------

# RetroArch configuration
export RETROARCH_DIR="${RETROARCH_DIR:-$HOME/Library/Application Support/RetroArch}"

# Dolphin (GameCube/Wii) configuration
export DOLPHIN_DIR="${DOLPHIN_DIR:-$HOME/Library/Application Support/Dolphin}"

# RPCS3 (PS3) configuration
export RPCS3_DIR="${RPCS3_DIR:-$HOME/Library/Application Support/rpcs3}"

# Ryujinx (Switch) configuration
export RYUJINX_DIR="${RYUJINX_DIR:-$HOME/Library/Application Support/Ryujinx}"

# ROMs directory
export ROMS_DIR="${ROMS_DIR:-$HOME/Games/ROMs}"

# --- Game-Specific Settings --------------------------------------------------

# Minecraft
export MINECRAFT_DIR="${MINECRAFT_DIR:-$HOME/Library/Application Support/minecraft}"

# Prism Launcher (Minecraft launcher)
export PRISM_DIR="${PRISM_DIR:-$HOME/Library/Application Support/PrismLauncher}"

# Battle.net
export BATTLENET_DIR="${BATTLENET_DIR:-$HOME/Library/Application Support/Battle.net}"

# Epic Games Launcher (via Heroic)
export HEROIC_DIR="${HEROIC_DIR:-$HOME/Library/Application Support/heroic}"

# GOG Galaxy (via Heroic)
export GOG_DIR="${GOG_DIR:-$HOME/Games/GOG}"

# --- Performance Monitoring --------------------------------------------------

# MangoHUD configuration (if using)
# export MANGOHUD="${MANGOHUD:-1}"
# export MANGOHUD_CONFIG="${MANGOHUD_CONFIG:-$HOME/.config/MangoHud/MangoHud.conf}"

# --- Proton/Wine Logging (for debugging) -------------------------------------

# Enable Proton logging (uncomment for troubleshooting)
# export PROTON_LOG="${PROTON_LOG:-1}"
# export PROTON_LOG_DIR="${PROTON_LOG_DIR:-$HOME/.local/share/proton-logs}"

# DXVK logging
# export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-info}"
# export DXVK_LOG_PATH="${DXVK_LOG_PATH:-$HOME/.local/share/dxvk-logs}"

# --- Helper Functions --------------------------------------------------------

# Launch a game with performance overlay
game-overlay() {
    DXVK_HUD=fps,frametimes,gpuload "$@"
}

# Quick screenshot (requires screencapture)
game-screenshot() {
    local filename="${GAME_CAPTURE_DIR}/screenshot-$(date +%Y%m%d-%H%M%S).png"
    screencapture -x "$filename"
    echo "Screenshot saved: $filename"
}

# Show gaming directories
game-dirs() {
    echo "=== Gaming Directories ==="
    echo ""
    echo "GAMES_DIR:        $GAMES_DIR"
    echo "STEAM_DIR:        $STEAM_DIR"
    echo "GAME_SAVES_DIR:   $GAME_SAVES_DIR"
    echo "GAME_CAPTURE_DIR: $GAME_CAPTURE_DIR"
    echo "WINEPREFIX:       $WINEPREFIX"
    echo ""
    echo "Emulators:"
    echo "  RetroArch:      $RETROARCH_DIR"
    echo "  Dolphin:        $DOLPHIN_DIR"
    echo "  ROMs:           $ROMS_DIR"
}
