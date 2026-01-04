# ==============================================================================
# Personal Environment Variables
#
# Environment settings for personal use, including preferences for
# personal projects, media, and casual computing.
#
# USAGE:
#   These variables are set when the personal role is active.
# ==============================================================================

# --- Personal Directories -----------------------------------------------------

# Personal projects
export PERSONAL_PROJECTS="${PERSONAL_PROJECTS:-$HOME/Projects/personal}"

# Downloads organization
export DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"

# Media directories
export MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"
export MOVIES_DIR="${MOVIES_DIR:-$HOME/Movies}"
export PICTURES_DIR="${PICTURES_DIR:-$HOME/Pictures}"

# Create directories if they don't exist
[[ -d "$PERSONAL_PROJECTS" ]] || mkdir -p "$PERSONAL_PROJECTS"

# --- Default Applications -----------------------------------------------------

# Preferred browser for personal use
export BROWSER="${BROWSER:-open}"

# Default media player
export VIDEO_PLAYER="${VIDEO_PLAYER:-IINA}"

# --- Gaming & Entertainment ---------------------------------------------------

# Steam (if installed)
export STEAM_DIR="${STEAM_DIR:-$HOME/Library/Application Support/Steam}"

# --- Less Strict Security Settings --------------------------------------------

# Longer session timeout (or disable) for personal machines
unset TMOUT

# --- Personal Cloud Storage ---------------------------------------------------

# iCloud Drive
export ICLOUD_DRIVE="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

# Dropbox (if installed)
export DROPBOX_DIR="${DROPBOX_DIR:-$HOME/Dropbox}"

# Google Drive (if installed)
export GOOGLE_DRIVE="${GOOGLE_DRIVE:-$HOME/Google Drive}"

# --- Media Tools Configuration ------------------------------------------------

# yt-dlp output directory
export YTDLP_OUTPUT_DIR="${YTDLP_OUTPUT_DIR:-$HOME/Downloads/Videos}"

# Preferred video format for yt-dlp
export YTDLP_FORMAT="${YTDLP_FORMAT:-bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best}"

# --- Media Applications -------------------------------------------------------

# Spotify configuration directory
export SPOTIFY_PATH="${SPOTIFY_PATH:-$HOME/Library/Application Support/Spotify}"

# IINA player configuration
export IINA_CONFIG="${IINA_CONFIG:-$HOME/Library/Application Support/com.colliderli.iina}"

# mpv configuration (IINA uses mpv backend)
export MPV_HOME="${MPV_HOME:-$HOME/.config/mpv}"

# Plex Media Server (local server)
export PLEX_MEDIA_SERVER="${PLEX_MEDIA_SERVER:-$HOME/Library/Application Support/Plex Media Server}"
# Plex token (template - retrieve from keychain in practice)
# export PLEX_TOKEN="${PLEX_TOKEN:-$(security find-generic-password -a "$USER" -s "plex-token" -w 2>/dev/null)}"

# --- E-Books & Reading --------------------------------------------------------

# Calibre e-book library
export CALIBRE_LIBRARY="${CALIBRE_LIBRARY:-$HOME/Documents/Calibre Library}"

# Calibre configuration
export CALIBRE_CONFIG="${CALIBRE_CONFIG:-$HOME/Library/Preferences/calibre}"

# Audiobooks directory
export AUDIOBOOK_DIR="${AUDIOBOOK_DIR:-$HOME/Music/Audiobooks}"
[[ -d "$AUDIOBOOK_DIR" ]] || mkdir -p "$AUDIOBOOK_DIR"

# Comics and manga directory
export COMICS_DIR="${COMICS_DIR:-$HOME/Documents/Comics}"

# --- Screenshots & Captures ---------------------------------------------------

# Screenshot save location
export SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
[[ -d "$SCREENSHOT_DIR" ]] || mkdir -p "$SCREENSHOT_DIR"

# Screen recordings directory
export SCREEN_RECORDINGS_DIR="${SCREEN_RECORDINGS_DIR:-$HOME/Movies/Screen Recordings}"
[[ -d "$SCREEN_RECORDINGS_DIR" ]] || mkdir -p "$SCREEN_RECORDINGS_DIR"

# --- Wallpapers & Themes ------------------------------------------------------

# Custom wallpaper directory
export WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
[[ -d "$WALLPAPER_DIR" ]] || mkdir -p "$WALLPAPER_DIR"

# Dynamic wallpapers (macOS)
export DYNAMIC_WALLPAPER_DIR="${DYNAMIC_WALLPAPER_DIR:-$HOME/Library/Application Support/com.apple.mobileAssetDesktop}"

# --- Fonts & Typography -------------------------------------------------------

# User fonts directory
export USER_FONTS_DIR="${USER_FONTS_DIR:-$HOME/Library/Fonts}"

# Font cache directory
export FONTCONFIG_PATH="${FONTCONFIG_PATH:-$HOME/.config/fontconfig}"

# --- Personal Git Configuration -----------------------------------------------

# Personal GitHub username (for quick cloning)
# export GITHUB_USER="your-username"

# Personal email for git (can override work email)
# export GIT_AUTHOR_EMAIL="personal@email.com"
# export GIT_COMMITTER_EMAIL="personal@email.com"

# --- Homebrew for Personal Use ------------------------------------------------

# Allow analytics on personal machine (optional, supports open source)
# unset HOMEBREW_NO_ANALYTICS

# Auto-update is fine on personal machine
unset HOMEBREW_NO_AUTO_UPDATE

# Auto-update frequency (in seconds) - check daily (86400)
export HOMEBREW_AUTO_UPDATE_SECS="${HOMEBREW_AUTO_UPDATE_SECS:-86400}"

# Cask installation options
export HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:---appdir=/Applications --fontdir=/Library/Fonts}"

# Cleanup old versions after upgrade
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS="${HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS:-7}"

# Show install times
export HOMEBREW_DISPLAY_INSTALL_TIMES="${HOMEBREW_DISPLAY_INSTALL_TIMES:-1}"

# --- Language/Locale ----------------------------------------------------------

# Personal locale settings (adjust as needed)
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"

# --- Relaxed Development Settings ---------------------------------------------

# Python: Allow pip install without venv on personal machine
# unset PIP_REQUIRE_VIRTUALENV

# Node: Development mode
export NODE_ENV="${NODE_ENV:-development}"

# --- Personal API Keys (loaded from secure storage) --------------------------

# Load personal API keys from secure file if it exists
# NEVER commit API keys to version control!
PERSONAL_SECRETS="$HOME/.config/circus/personal-secrets.env"
if [[ -f "$PERSONAL_SECRETS" ]]; then
    # shellcheck source=/dev/null
    source "$PERSONAL_SECRETS"
fi

# --- Fun Stuff ----------------------------------------------------------------

# Fortune on new shell (if installed)
# if command -v fortune &>/dev/null; then
#     fortune
# fi

# Cowsay greeting (if installed)
# if command -v cowsay &>/dev/null; then
#     echo "Welcome back!" | cowsay -f tux
# fi

# --- Helper Functions ---------------------------------------------------------

# Open personal projects directory
personal-projects() {
    cd "$PERSONAL_PROJECTS" || return 1
    echo "Personal projects directory: $PERSONAL_PROJECTS"
    ls -la
}

# Show personal directories summary
personal-dirs() {
    echo "=== Personal Directories ==="
    echo ""
    echo "Projects:         $PERSONAL_PROJECTS"
    echo "Downloads:        $DOWNLOADS_DIR"
    echo "Screenshots:      $SCREENSHOT_DIR"
    echo "Wallpapers:       $WALLPAPER_DIR"
    echo ""
    echo "Media:"
    echo "  Music:          $MUSIC_DIR"
    echo "  Movies:         $MOVIES_DIR"
    echo "  Pictures:       $PICTURES_DIR"
    echo "  Audiobooks:     $AUDIOBOOK_DIR"
    echo ""
    echo "E-Books:"
    echo "  Calibre:        $CALIBRE_LIBRARY"
    echo "  Comics:         $COMICS_DIR"
    echo ""
    echo "Cloud Storage:"
    echo "  iCloud:         $ICLOUD_DRIVE"
    echo "  Dropbox:        ${DROPBOX_DIR:-<not set>}"
    echo "  Google Drive:   ${GOOGLE_DRIVE:-<not set>}"
}

# Quick screenshot with timestamp
screenshot() {
    local filename="${SCREENSHOT_DIR}/screenshot-$(date +%Y%m%d-%H%M%S).png"
    screencapture -x "$filename"
    echo "Screenshot saved: $filename"
}

# Screenshot with selection
screenshot-select() {
    local filename="${SCREENSHOT_DIR}/screenshot-$(date +%Y%m%d-%H%M%S).png"
    screencapture -i "$filename"
    echo "Screenshot saved: $filename"
}

# Open Calibre library
calibre-open() {
    if [[ -d "$CALIBRE_LIBRARY" ]]; then
        open "$CALIBRE_LIBRARY"
    else
        echo "Calibre library not found at: $CALIBRE_LIBRARY"
    fi
}
