# macOS Terminal Commands Reference

This document provides a reference guide for common macOS terminal commands used throughout this project. It's intended for developers who want to understand, customize, or extend the circus dotfiles.

---

## Power Management (`pmset`)

The `pmset` command controls power management settings.

### Common Commands

```bash
# Display current power settings
pmset -g

# Display power settings for all power sources
pmset -g custom

# Show power assertions (what's keeping Mac awake)
pmset -g assertions

# Show battery/UPS status
pmset -g batt
```

### Settings (require sudo)

```bash
# Set display sleep time (minutes, 0 = never)
sudo pmset -a displaysleep 10

# Set computer sleep time (minutes)
sudo pmset -a sleep 30

# Disable sleep on AC power
sudo pmset -c sleep 0

# Enable wake on network access
sudo pmset -a womp 1

# Power source flags:
#   -a  All power sources
#   -b  Battery only
#   -c  Charger (AC power) only
```

### Key Settings

| Setting | Description |
|---------|-------------|
| `displaysleep` | Minutes until display sleeps |
| `sleep` | Minutes until system sleeps |
| `disksleep` | Minutes until disk sleeps |
| `womp` | Wake on Magic Packet (network) |
| `powernap` | Enable Power Nap |
| `proximitywake` | Wake when iPhone/Watch nearby |

---

## System Configuration (`nvram`)

The `nvram` command manages non-volatile RAM settings.

### Common Commands

```bash
# List all NVRAM variables
nvram -p

# Get specific variable
nvram boot-args

# Set variable (requires sudo)
sudo nvram boot-args="-v"

# Delete variable
sudo nvram -d boot-args
```

### Common Variables

| Variable | Description |
|----------|-------------|
| `boot-args` | Kernel boot arguments |
| `StartupMute` | Mute startup chime (`%01` = mute) |
| `SystemAudioVolume` | System audio volume |

> **Warning:** Incorrect NVRAM changes can affect system boot. Use with caution.

---

## Network Settings (`networksetup`)

The `networksetup` command configures network preferences.

### Display Information

```bash
# List all network services
networksetup -listallnetworkservices

# List hardware ports with device names
networksetup -listallhardwareports

# Get DNS servers
networksetup -getdnsservers Wi-Fi

# Get current Wi-Fi network
networksetup -getairportnetwork en0
```

### Configuration (some require sudo)

```bash
# Set DNS servers
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4

# Clear DNS (use DHCP)
sudo networksetup -setdnsservers Wi-Fi "Empty"

# Turn Wi-Fi on/off
networksetup -setairportpower en0 on

# Connect to Wi-Fi network
networksetup -setairportnetwork en0 "NetworkName" "password"
```

---

## System Defaults (`defaults`)

The `defaults` command reads/writes macOS preferences.

### Common Commands

```bash
# Read all preferences for a domain
defaults read com.apple.dock

# Read specific preference
defaults read com.apple.dock autohide

# Write preference
defaults write com.apple.dock autohide -bool true

# Delete preference
defaults delete com.apple.dock autohide

# List all domains
defaults domains
```

### Common Domains

| Domain | Description |
|--------|-------------|
| `com.apple.dock` | Dock settings |
| `com.apple.finder` | Finder settings |
| `com.apple.screencapture` | Screenshot settings |
| `com.apple.Terminal` | Terminal settings |
| `NSGlobalDomain` | Global system preferences |

### Data Types

```bash
defaults write <domain> <key> -bool true
defaults write <domain> <key> -int 42
defaults write <domain> <key> -float 3.14
defaults write <domain> <key> -string "value"
defaults write <domain> <key> -array "a" "b" "c"
```

---

## Firewall (`socketfilterfw`)

The `socketfilterfw` command manages the application firewall.

```bash
# Path
/usr/libexec/ApplicationFirewall/socketfilterfw

# Check status
sudo socketfilterfw --getglobalstate

# Enable/disable firewall
sudo socketfilterfw --setglobalstate on

# Enable stealth mode
sudo socketfilterfw --setstealthmode on

# Add/remove app
sudo socketfilterfw --add /Applications/App.app
sudo socketfilterfw --remove /Applications/App.app

# List apps
sudo socketfilterfw --listapps
```

---

## Quick Look (`qlmanage`)

The `qlmanage` command manages Quick Look.

```bash
# Preview file
qlmanage -p document.pdf

# Generate thumbnail
qlmanage -t -s 512 image.png -o /tmp/

# Reset Quick Look
qlmanage -r
qlmanage -r cache

# List generators
qlmanage -m

# Debug preview
qlmanage -p -d2 file.md
```

---

## Spotlight (`mdfind`, `mdutil`, `mdls`)

Spotlight indexing and search commands.

### Search (`mdfind`)

```bash
# Basic search
mdfind "query"

# Search by file type
mdfind "kMDItemContentType == 'public.pdf'"

# Search in directory
mdfind -onlyin ~/Documents "query"

# Limit results
mdfind -limit 10 "query"
```

### Indexing (`mdutil`)

```bash
# Check indexing status
mdutil -s /

# Enable/disable indexing
sudo mdutil -i on /
sudo mdutil -i off /

# Erase and rebuild index
sudo mdutil -E /
```

### Metadata (`mdls`)

```bash
# Show file metadata
mdls document.pdf
```

---

## Sleep Prevention (`caffeinate`)

Prevent system sleep temporarily.

```bash
# Prevent sleep indefinitely (Ctrl+C to stop)
caffeinate

# Prevent sleep for duration (seconds)
caffeinate -t 3600

# Prevent display sleep
caffeinate -d

# Run command without sleeping
caffeinate -s long_running_command
```

### Flags

| Flag | Description |
|------|-------------|
| `-d` | Prevent display sleep |
| `-i` | Prevent system idle sleep |
| `-s` | Prevent system sleep (AC only) |
| `-t` | Timeout in seconds |

---

## Security (`security`)

Keychain and certificate management.

```bash
# List keychains
security list-keychains

# Find password
security find-generic-password -s "service" -w

# Find WiFi password
security find-generic-password -D "AirPort network password" -s "SSID" -w

# Add password
security add-generic-password -a "account" -s "service" -w "password"
```

---

## System Integrity Protection (`csrutil`)

SIP status and management (requires Recovery Mode to modify).

```bash
# Check SIP status
csrutil status
```

---

## Useful Aliases

Consider adding these to your shell configuration:

```bash
# Quick disk space check
alias disk='df -h'

# Show listening ports
alias ports='lsof -i -P | grep LISTEN'

# Flush DNS cache
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Show hidden files in Finder
alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
```
