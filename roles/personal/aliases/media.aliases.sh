# ==============================================================================
# Media Aliases
#
# Aliases for media playback, streaming, and entertainment on personal machines.
#
# USAGE:
#   These aliases are automatically loaded when the personal role is active.
# ==============================================================================

# --- Video Players ------------------------------------------------------------

# VLC Media Player
alias vlc='open -a VLC'
alias vlc-play='open -a VLC'

# IINA (modern macOS video player)
alias iina='open -a IINA'

# --- Music & Audio ------------------------------------------------------------

# Apple Music
alias music='open -a Music'

# Spotify
alias spotify='open -a Spotify'

# --- Streaming Services -------------------------------------------------------

# Open streaming services in browser
alias netflix='open "https://netflix.com"'
alias youtube='open "https://youtube.com"'
alias prime='open "https://primevideo.com"'
alias disney='open "https://disneyplus.com"'
alias hbo='open "https://max.com"'

# --- Podcasts & Audiobooks ----------------------------------------------------

# Apple Podcasts
alias podcasts='open -a Podcasts'

# Overcast (popular podcast app)
alias overcast='open -a Overcast'

# --- Screen Recording ---------------------------------------------------------

# Start QuickTime screen recording
alias screenrec='open -a "QuickTime Player" && osascript -e "tell application \"QuickTime Player\" to activate"'

# Screenshot with delay (5 seconds)
alias screenshot5='screencapture -T 5 ~/Desktop/screenshot-$(date +%Y%m%d-%H%M%S).png'

# --- Image Viewing ------------------------------------------------------------

# Preview images
alias preview='open -a Preview'

# Quick Look a file
alias ql='qlmanage -p 2>/dev/null'

# --- Media Conversion (requires ffmpeg) ---------------------------------------

# Convert video to MP4
tomp4() {
    local input="$1"
    local output="${input%.*}.mp4"
    ffmpeg -i "$input" -c:v libx264 -c:a aac "$output"
}

# Extract audio from video
toaudio() {
    local input="$1"
    local output="${input%.*}.mp3"
    ffmpeg -i "$input" -vn -acodec libmp3lame -q:a 2 "$output"
}

# Create GIF from video
togif() {
    local input="$1"
    local output="${input%.*}.gif"
    ffmpeg -i "$input" -vf "fps=10,scale=480:-1:flags=lanczos" -c:v gif "$output"
}

# --- Download Helpers (requires yt-dlp) ---------------------------------------

# Download YouTube video (best quality)
alias ytdl='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"'

# Download YouTube audio only (MP3)
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0'

# Download YouTube playlist
alias ytpl='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" -o "%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s"'

# --- Photo Management ---------------------------------------------------------

# Open Photos
alias photos='open -a Photos'

# Open photo library location
alias photolib='open ~/Pictures'

# --- eBook & Reading ----------------------------------------------------------

# Apple Books
alias books='open -a Books'

# Kindle
alias kindle='open -a Kindle'
