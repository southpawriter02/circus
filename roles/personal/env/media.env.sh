# ==============================================================================
# Media Environment Variables
#
# Configuration for media management including music, movies, photos,
# video encoding, and media server paths.
#
# USAGE:
#   These variables are set when the personal role is active.
#   Customize paths based on your media organization.
# ==============================================================================

# --- Media Directories -------------------------------------------------------

# Music library
export MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"

# Movies directory
export MOVIES_DIR="${MOVIES_DIR:-$HOME/Movies}"

# TV Shows directory
export TV_SHOWS_DIR="${TV_SHOWS_DIR:-$HOME/Movies/TV Shows}"

# Podcasts directory
export PODCASTS_DIR="${PODCASTS_DIR:-$HOME/Music/Podcasts}"

# Photos directory
export PHOTOS_DIR="${PHOTOS_DIR:-$HOME/Pictures}"

# Videos (home videos, recordings)
export VIDEOS_DIR="${VIDEOS_DIR:-$HOME/Movies/Videos}"

# Media downloads folder
export MEDIA_DOWNLOADS_DIR="${MEDIA_DOWNLOADS_DIR:-$HOME/Downloads/Media}"

# Create directories if they don't exist
[[ -d "$MEDIA_DOWNLOADS_DIR" ]] || mkdir -p "$MEDIA_DOWNLOADS_DIR"
[[ -d "$TV_SHOWS_DIR" ]] || mkdir -p "$TV_SHOWS_DIR"

# --- Media Server Configuration ----------------------------------------------

# Plex Media Server
export PLEX_MEDIA_SERVER="${PLEX_MEDIA_SERVER:-$HOME/Library/Application Support/Plex Media Server}"

# Plex transcoding directory (use fast SSD)
export PLEX_TRANSCODE_DIR="${PLEX_TRANSCODE_DIR:-/tmp/plex-transcode}"

# Jellyfin configuration
export JELLYFIN_DIR="${JELLYFIN_DIR:-$HOME/Library/Application Support/Jellyfin}"

# Emby configuration
export EMBY_DIR="${EMBY_DIR:-$HOME/Library/Application Support/Emby-Server}"

# --- Video Encoding (FFmpeg & HandBrake) -------------------------------------

# FFmpeg thread count (0 = auto)
export FFMPEG_THREADS="${FFMPEG_THREADS:-0}"

# HandBrake presets directory
export HANDBRAKE_PRESETS="${HANDBRAKE_PRESETS:-$HOME/Library/Application Support/HandBrake/UserPresets}"

# Default HandBrake preset
export HANDBRAKE_PRESET="${HANDBRAKE_PRESET:-Fast 1080p30}"

# Hardware acceleration (VideoToolbox on macOS)
export FFMPEG_HWACCEL="${FFMPEG_HWACCEL:-videotoolbox}"

# --- yt-dlp Configuration ----------------------------------------------------

# yt-dlp output template
export YTDL_OUTPUT="${YTDL_OUTPUT:-%(title)s.%(ext)s}"

# yt-dlp download archive (track downloaded videos)
export YTDL_ARCHIVE="${YTDL_ARCHIVE:-$HOME/.config/yt-dlp/archive.txt}"

# yt-dlp configuration file
export YTDL_CONFIG="${YTDL_CONFIG:-$HOME/.config/yt-dlp/config}"

# Default download location for yt-dlp
export YTDL_DOWNLOAD_DIR="${YTDL_DOWNLOAD_DIR:-$MEDIA_DOWNLOADS_DIR}"

# --- Media Players -----------------------------------------------------------

# mpv configuration directory
export MPV_HOME="${MPV_HOME:-$HOME/.config/mpv}"

# VLC plugins path
export VLC_PLUGIN_PATH="${VLC_PLUGIN_PATH:-/Applications/VLC.app/Contents/MacOS/plugins}"

# IINA configuration
export IINA_CONFIG="${IINA_CONFIG:-$HOME/Library/Application Support/com.colliderli.iina}"

# --- Audio Tools -------------------------------------------------------------

# Spotify data directory
export SPOTIFY_PATH="${SPOTIFY_PATH:-$HOME/Library/Application Support/Spotify}"

# Apple Music library
export APPLE_MUSIC_LIBRARY="${APPLE_MUSIC_LIBRARY:-$HOME/Music/Music}"

# Audacity configuration
export AUDACITY_PATH="${AUDACITY_PATH:-$HOME/Library/Application Support/audacity}"

# SoundCloud downloads
export SOUNDCLOUD_DIR="${SOUNDCLOUD_DIR:-$MUSIC_DIR/SoundCloud}"

# --- Image Tools -------------------------------------------------------------

# ImageMagick temporary directory
export MAGICK_TMPDIR="${MAGICK_TMPDIR:-/tmp/imagemagick}"

# EXIF tool configuration
export EXIFTOOL_HOME="${EXIFTOOL_HOME:-$HOME/.ExifTool}"

# --- E-Books & Reading -------------------------------------------------------

# Calibre library path
export CALIBRE_LIBRARY="${CALIBRE_LIBRARY:-$HOME/Documents/Calibre Library}"

# Calibre configuration
export CALIBRE_CONFIG="${CALIBRE_CONFIG:-$HOME/Library/Preferences/calibre}"

# Audiobooks directory
export AUDIOBOOK_DIR="${AUDIOBOOK_DIR:-$HOME/Music/Audiobooks}"

# Comics/Manga directory
export COMICS_DIR="${COMICS_DIR:-$HOME/Documents/Comics}"

# --- Wallpapers & Themes -----------------------------------------------------

# Custom wallpapers directory
export WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
[[ -d "$WALLPAPER_DIR" ]] || mkdir -p "$WALLPAPER_DIR"

# macOS dynamic wallpapers
export DYNAMIC_WALLPAPER_DIR="${DYNAMIC_WALLPAPER_DIR:-$HOME/Library/Application Support/com.apple.mobileAssetDesktop}"

# --- Streaming & Recording ---------------------------------------------------

# OBS Studio configuration
export OBS_CONFIG="${OBS_CONFIG:-$HOME/Library/Application Support/obs-studio}"

# Screen recordings directory
export SCREEN_RECORDINGS_DIR="${SCREEN_RECORDINGS_DIR:-$HOME/Movies/Screen Recordings}"
[[ -d "$SCREEN_RECORDINGS_DIR" ]] || mkdir -p "$SCREEN_RECORDINGS_DIR"

# Twitch/streaming assets
export STREAMING_ASSETS_DIR="${STREAMING_ASSETS_DIR:-$HOME/Documents/Streaming}"

# --- Photo Management --------------------------------------------------------

# darktable configuration
export DARKTABLE_DIR="${DARKTABLE_DIR:-$HOME/.config/darktable}"

# RawTherapee configuration
export RAWTHERAPEE_DIR="${RAWTHERAPEE_DIR:-$HOME/Library/Application Support/RawTherapee}"

# Photo exports directory
export PHOTO_EXPORTS_DIR="${PHOTO_EXPORTS_DIR:-$HOME/Pictures/Exports}"

# --- Helper Functions --------------------------------------------------------

# Convert video with hardware acceleration
ffmpeg-hw() {
    ffmpeg -hwaccel videotoolbox "$@"
}

# Download video with yt-dlp using configured settings
ytdl() {
    yt-dlp -o "${YTDL_DOWNLOAD_DIR}/${YTDL_OUTPUT}" "$@"
}

# Download audio only
ytdl-audio() {
    yt-dlp -x --audio-format mp3 -o "${MUSIC_DIR}/Downloads/%(title)s.%(ext)s" "$@"
}

# Show media directories
media-dirs() {
    echo "=== Media Directories ==="
    echo ""
    echo "Music:              $MUSIC_DIR"
    echo "Movies:             $MOVIES_DIR"
    echo "TV Shows:           $TV_SHOWS_DIR"
    echo "Photos:             $PHOTOS_DIR"
    echo "Media Downloads:    $MEDIA_DOWNLOADS_DIR"
    echo ""
    echo "Servers:"
    echo "  Plex:             $PLEX_MEDIA_SERVER"
    echo "  Jellyfin:         $JELLYFIN_DIR"
    echo ""
    echo "Libraries:"
    echo "  Calibre:          $CALIBRE_LIBRARY"
    echo "  Audiobooks:       $AUDIOBOOK_DIR"
}

# Get video info
video-info() {
    ffprobe -v quiet -print_format json -show_format -show_streams "$1" | jq '.'
}

# Quick thumbnail from video
video-thumb() {
    local video="$1"
    local output="${2:-thumbnail.jpg}"
    ffmpeg -i "$video" -ss 00:00:05 -vframes 1 "$output"
    echo "Thumbnail saved: $output"
}
