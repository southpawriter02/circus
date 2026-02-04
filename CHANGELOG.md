# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **7 New FC Commands** - Comprehensive additions to the `fc` command suite:

  **Batch 1 - System & Network:**
  - `fc uninstall` - Complete macOS app removal (app bundle, preferences, caches, containers)
  - `fc theme` - Shell theme management with dark/light themes and custom theme support
  - `fc network` - Network diagnostics suite (status, diag, latency, DNS, port check)

  **Batch 2 - Productivity & Development:**
  - `fc docker` - Docker cleanup utility (status, clean --all/--hard, resource management)
  - `fc desktop` - Desktop organizer (archive to dated folders, organize by type, undo)
  - `fc history` - Enhanced shell history search with fzf integration
  - `fc scaffold` - Project scaffolding with template variable substitution

  **Supporting Files:**
  - Built-in themes: `themes/dark/`, `themes/light/`
  - Python CLI template: `templates/projects/python-cli/`
  - BATS tests for all 7 commands
  - COMMANDS.md documentation (341 lines added)

- **Enhanced `fc firewall`** - Granular per-app firewall rule management (Feature #29):
  - `list-apps` - List all applications with firewall rules
  - `add/remove <app>` - Add or remove apps from firewall
  - `allow/block <app>` - Control incoming connections per app
  - `apply-rules` - Apply rules from `~/.config/circus/firewall.conf`
  - `export` - Export current rules to stdout
  - `stealth-on/off` - Control stealth mode
  - `block-all/unblock-all` - Global connection blocking

- **New `fc focus`** - Focus mode for distraction-free work (Feature #47):
  - `start [duration]` - Start timed focus session (e.g., 30m, 2h)
  - `stop` - End focus session early
  - `status` - Show remaining time
  - Blocks distracting websites via `/etc/hosts`
  - Quits specified applications (configurable)
  - Auto-restores when session ends

- **New `fc config`** - Declarative YAML configuration system (Feature #17):
  - `apply <file>` - Apply a YAML configuration file
  - `validate <file>` - Validate YAML syntax
  - `show <file>` - Display configuration summary
  - `convert <role>` - Guide for converting shell roles to YAML
  - New engine: `lib/yaml_config.sh`
  - Proof-of-concept: `roles/personal/config.yaml`
  - Guide: `docs/YAML_CONFIGURATION.md`

- **New `fc power`** - Power management profiles (Feature #34):
  - `switch <profile>` - Switch power profile (default, battery-saver, max-performance, presentation)
  - `status` - Show current power settings
  - `save <name>` - Save custom profile
  - Uses `pmset` for system power control

- **New `fc audio`** - Audio device control (Feature #49):
  - `volume [level]` - Get or set volume (0-100)
  - `mute/unmute/toggle` - Mute control
  - `set-output/set-input <device>` - Switch audio devices with fuzzy matching
  - Requires `switchaudio-osx` for device switching

- **New `fc display`** - Display management (Feature #50):
  - `list/info` - Show connected displays
  - `save-layout/apply-layout <name>` - Save and restore monitor arrangements
  - `mirror/extend` - Display modes
  - Requires `displayplacer` for advanced features

- **New `fc app-settings`** - Application settings management (Feature #40):
  - `apply [category] [app]` - Apply defaults scripts
  - `list [category]` - List available settings
  - `show <category> <app>` - Preview what a script does
  - `categories` - List categories (applications, system, interface, accessibility)

- **New `fc self-update`** - Framework self-update mechanism (Feature #42):
  - `--check` - Check for available updates
  - `--force` - Update even with uncommitted changes
  - `--dry-run` - Preview without changing
  - Handles stashing, migrations, and dependency updates

- **New `fc notify`** - macOS notification integration (Feature #43):
  - Send native macOS notifications from scripts
  - Supports terminal-notifier and osascript backends
  - Style presets: `--success`, `--error`, `--warning`
  - Configurable via `~/.config/circus/notify.conf`
  - Actions: `test`, `config`, `enable`, `disable`

- **New `fc snapshot`** - APFS snapshot management for safe rollbacks:
  - `create [name]` - Create snapshot before major changes
  - `list` / `list-all` - View managed and system snapshots
  - `delete <timestamp>` - Remove specific snapshots
  - `status` - Show settings and disk usage
  - `auto on|off` - Toggle auto-snapshot before `fc config apply`
  - Auto-integrates with `fc config` and `fc app-settings`

## [1.5.2] - 2026-01-05


### Added

- **v1.5.2: Brewfile Expansion & Role Distribution** - Comprehensive Homebrew package management across all roles:

  **Base Brewfile Additions**:
  - **Casks (11 new)**: gpg-suite, little-snitch, keepassxc, knockknock, yubico-authenticator, google-chrome, raycast, carbon-copy-cloner, dropbox, etrecheckpro, prefs-editor
  - **Formulae (20 new)**: findutils, zsh-completions, bash-completion@2, macos-trash, gh, mackup, bat, eza, fd, ripgrep, jq, fzf, wget, curl, zstd, p7zip
  - **Fonts (4 new)**: font-fira-code, font-jetbrains-mono, font-sf-mono, font-inter
  - **MAS Apps (1 new)**: Bitwarden

  **Developer Brewfile** (`roles/developer/Brewfile`):
  - **Formulae (35 new)**: pyenv, rbenv, rust, redis, sqlite, ccache, pkg-config, make, cmake, git-sizer, git-filter-repo, git-delta, gitui, git-crypt, cloc, colordiff, ctags, tmux, gdb, binwalk, binutils, docker, docker-compose, dive, httpie, grpcurl, glow, pandoc, zoxide, jump, direnv
  - **Casks (10 new)**: dotnet-sdk, rider, warp, docker, parallels, github, ghidra, imazing-profile-editor, launchcontrol, fsmonitor
  - **Fonts (10 new)**: font-fira-code-nerd-font, font-fira-mono, font-fira-mono-nerd-font, font-jetbrains-mono-nerd-font, font-inconsolata-go-nerd-font, font-hack, font-hasklig, font-monoid, font-cascadia-code, font-source-code-pro
  - **MAS Apps (4 new)**: Xcode, Sequel Ace, Apple Configurator, Actions

  **Personal Brewfile** (`roles/personal/Brewfile`):
  - **Formulae (20 new)**: imagemagick, optipng, pngcrush, webp, chafa, catimg, ranger, lf, ncdu, duf, htop, lnav, pstree, pwgen, gnupg, pinentry-mac, lynis, clamav, mtr, iftop, nmap, rsync, rclone
  - **Casks (12 new)**: spotify, vlc, discord, battle-net, brave-browser, cloudflare-warp, protonvpn, proton-drive, rectangle, notion, setapp
  - **Fonts (9 new)**: font-roboto, font-roboto-mono, font-open-sans, font-lato, font-montserrat, font-ubuntu, font-cantarell, font-oxygen, font-oxygen-mono
  - **MAS Apps (3 new)**: Cardhop, Hyperduck, Pages

  **Work Brewfile** (`roles/work/Brewfile`):
  - **Formulae (15 new)**: terraform, ansible, kubernetes-cli, helm, awscli, openssh, openssl, nmap, certbot, logstash, htop, iftop, httpie, oha, dasel, grip, slides
  - **Casks (5 new)**: zoom, notion, docker, github, warp, parallels
  - **Fonts (5 new)**: font-ibm-plex, font-maven-pro, font-open-sans, font-roboto, font-lato
  - **MAS Apps (3 new)**: Slack, Pages, Apple Configurator

### Changed

- **Brewfile Organization**: Reorganized base Brewfile with categorized sections (Shell & Core Utilities, Version Control, Package Management, File & Text Processing, Networking, Compression, Security, Browsers, Productivity, Cloud & Sync, System Utilities, Fonts)
- **Role-specific Distribution**: Moved role-specific apps from base Brewfile to appropriate role Brewfiles
- **MAS over Casks**: Replaced cask versions with MAS versions where available (Slack, Cardhop) for better App Store integration
- **Cask Arguments**: Added comprehensive cask_args for custom installation directories (fonts, plugins, input methods, etc.)

### Notes

- Source files merged from `alt/dotcircus-041425/dot/install/brew/` (Brewfile, casks.zsh, fonts.zsh, formulae.zsh, mas.zsh)
- All 25 fonts from fonts.zsh distributed across role Brewfiles
- Duplicates removed (apps available in both cask and MAS use MAS version)
- Total additions: ~90 formulae, ~40 casks, ~28 fonts, ~11 MAS apps across all Brewfiles

## [1.5.1] - 2026-01-05

### Added

- **v1.5.1: AppleScript Reference Documentation** - Comprehensive practical AppleScript examples in `docs/APPLESCRIPTS.md`:

  **31 Copy-Paste Ready Scripts across 6 categories:**

  **System Control (8 scripts)**:
  - Set volume to percentage / Get current volume / Toggle mute
  - Set display brightness
  - Toggle Do Not Disturb
  - Get battery percentage
  - Switch audio output device
  - Show notification with custom message

  **Window Management (5 scripts)**:
  - Resize window to left/right half of screen
  - Center window on screen
  - Maximize current window
  - Move window to next monitor

  **Finder Automation (6 scripts)**:
  - Open current folder in Terminal/iTerm
  - Copy selected file paths to clipboard
  - Toggle hidden files visibility
  - Create new file in current folder
  - Get file path in various formats (POSIX, HFS, URL)

  **Safari & Browser (4 scripts)**:
  - Copy all open tab URLs to clipboard
  - Export tabs as Markdown list
  - Close duplicate tabs
  - Open URLs from clipboard as new tabs

  **Application Utilities (4 scripts)**:
  - Quit all apps except Finder
  - Get frontmost app name
  - Launch app and bring to front
  - Hide all apps except current

  **Clipboard & Text (6 scripts)**:
  - Convert clipboard to plain text
  - Transform clipboard case (uppercase/lowercase/title case)
  - URL encode/decode clipboard contents

  **Usage Tips section** covering:
  - Running scripts via `osascript` (one-liner and multi-line)
  - Saving as `.scpt` files in Script Editor
  - Integration with Alfred and Raycast
  - Required macOS permissions (Accessibility, Automation, Full Disk Access)
  - Debugging techniques

  **New `fc applescript` Plugin** (`lib/plugins/fc-applescript`):
  - Window management: `left`, `right`, `maximize`, `center`
  - Finder automation: `terminal`, `iterm`, `paths`, `hidden`
  - Safari automation: `tabs`, `markdown`, `duplicates`
  - App utilities: `frontmost`, `quit-all`, `hide-others`
  - Clipboard transformations: `plain`, `upper`, `lower`, `title`
  - Volume control: `get`, `set <0-100>`, `mute`
  - Notifications: `notify "<message>"`

  **Raycast Integration** (13 new scripts in `etc/raycast/scripts/`):
  - Window: left, right, maximize, center
  - Finder: open in Terminal, toggle hidden files
  - Safari: copy tab URLs, export tabs as Markdown
  - Clipboard: convert to plain text, uppercase, lowercase
  - Volume: toggle mute
  - App: hide all others

  **Alfred Integration** (`etc/alfred/workflows/Flying Circus/`):
  - New `applescript` keyword with 16 actions
  - Script filter showing all AppleScript automations
  - Integrated with existing workflow connection pipeline

### Notes

- All scripts tested on macOS and ready for immediate use
- Preserved existing repository reference links
- Scripts provided in both AppleScript and bash `osascript` formats where applicable

## [1.5.0] - 2026-01-04

### Added

- **v1.5.0: Documentation & Polish** - Complete documentation for all defaults scripts and new `fc defaults` command:

  **New `fc defaults` Plugin**:
  - Created `lib/plugins/fc-defaults` with full implementation (~550 lines)
  - 42 curated macOS tweaks across 9 categories: Finder, Dock, Screenshots, System, Safari, Keyboard, Trackpad, Terminal, Text
  - Subcommands: `list`, `status`, `apply`, `reset`, `all`
  - `--dry-run` flag support for previewing changes
  - Bash 3.2+ compatible (works with macOS default shell)
  - Automatic service restarts (Finder, Dock, SystemUIServer) where needed
  - Color-coded status output with check marks

  **New Test Suite**:
  - Created `tests/fc_defaults.bats` with 48 comprehensive tests
  - Coverage: help, list, status, apply, reset, all subcommands
  - Tests for error handling, type flags, dry-run mode
  - Integration tests with fc dispatcher

### Changed

- **Documentation Progress to 100%**:
  - Updated `defaults/README.md` - All 40 scripts now marked ✅ Complete
  - Updated `docs/specs/fc-defaults.md` - Marked as implemented with flags documentation
  - All 10 previously pending scripts now have complete inline documentation

## [1.4.0] - 2026-01-03

### Added

- **v1.4.0: Role-Specific Settings** - Major release with 12 new role-specific configuration files and 8 enhanced existing files:

  **Developer Role - New Files (4)**:
  - `roles/developer/env/docker.env.sh` - Docker/Compose environment
  - `roles/developer/env/database.env.sh` - Database connections (PostgreSQL, MySQL, Redis, MongoDB)
  - `roles/developer/env/testing.env.sh` - Testing frameworks (Jest, pytest, Mocha, Vitest)
  - `roles/developer/defaults/simulator.sh` - iOS Simulator settings
  - `roles/developer/aliases/kubernetes.aliases.sh` - kubectl aliases (25+ aliases)

  **Work Role - New Files (4)**:
  - `roles/work/defaults/calendar.sh` - Work calendar settings
  - `roles/work/defaults/slack.sh` - Work Slack settings
  - `roles/work/defaults/zoom.sh` - Zoom meetings settings
  - `roles/work/env/jira.env.sh` - Atlassian tools configuration

  **Personal Role - New Files (3)**:
  - `roles/personal/env/gaming.env.sh` - Gaming environment (Steam, Wine, emulators)
  - `roles/personal/env/media.env.sh` - Media management (Plex, FFmpeg, yt-dlp)
  - `roles/personal/defaults/relaxed_security.sh` - Relaxed security settings

## [1.3.2] - 2026-01-04

### Added

- **v1.3.2: Major Defaults Expansion** - 50 new settings across 15 scripts:

  **Input Scripts (10 new)**:
  - `input/trackpad_mouse.sh` - Three-finger drag, right-click, haptic feedback, drag lock, swipe gestures
  - `input/keyboard.sh` - Press and hold, auto-correct, smart quotes, auto-capitalization

  **Interface Scripts (14 new)**:
  - `interface/finder.sh` - New window target, path, Quick Look text, spring-load, animations
  - `interface/dock.sh` - Icon size, auto-hide, delay, position, recents, minimize effect
  - `interface/mission_control.sh` - Group by app, separate spaces, switch on activate

  **System Scripts (10 new)**:
  - `system/sound.sh` - Flash screen, stereo balance, interface sounds
  - `system/energy.sh` - Lid wake, reduce brightness on battery (pmset)
  - `system/software_update.sh` - Config data install, check frequency
  - `system/screensaver.sh` - Show clock, module documentation

  **Accessibility Scripts (8 new)**:
  - `accessibility/pointer.sh` - Slow keys, slow key delay, sticky keys, sticky key sound
  - `accessibility/display.sh` - Window title icons, toolbar button shapes
  - `accessibility/zoom.sh` - Hover text font size, flash screen on zoom

  **Application Scripts (8 new)**:
  - `applications/safari.sh` - Tab behavior, page zoom, downloads path
  - `applications/terminal.sh` - UTF-8 encoding, unlimited scrollback, bold fonts
  - `applications/textedit.sh` - Smart links, data detectors

## [1.3.1] - 2026-01-04

### Added

- **v1.3.1: Expanded Defaults Coverage** - 20 new settings to existing scripts:

  **System Scripts (8 new)**:
  - `system/firewall.sh` - Allow signed apps, allow downloaded signed apps
  - `system/privacy.sh` - Advertising ID, app analytics, personalized recommendations
  - `system/bluetooth.sh` - Max bitpool, initial bitpool for A2DP audio quality
  - `system/login.sh` - External accounts control

  **Application Scripts (12 new)**:
  - `applications/zoom_app.sh` - Touch up appearance, original sound, always show controls
  - `applications/calendar.sh` - Week numbers, default event alert time
  - `applications/slack.sh` - Zoom level, spellcheck
  - `applications/music.sh` - Automatic downloads, star ratings
  - `applications/chrome.sh` - Confirm before quitting, external protocol dialog
  - `applications/messages.sh` - Sound effects

## [1.3.0] - 2026-01-03

### Added

- **v1.3.0: macOS Defaults (Applications)** - Major release with 24 new application defaults scripts:

  **User-Requested Apps (5 new)**:
  - `applications/dropbox.sh` - Menu bar, LAN sync, desktop icons
  - `applications/notion.sh` - Documentation for account-based settings
  - `applications/github_desktop.sh` - Usage tracking, config file documentation
  - `applications/setapp.sh` - Auto-updates, launch at login, menu bar
  - `applications/protonmail.sh` - Bridge ports, keychain documentation

  **Apple Apps (10 new)**:
  - `applications/calendar.sh` - Week start, work hours, time zone support
  - `applications/contacts.sh` - Sort order, display format, vCard settings
  - `applications/reminders.sh` - Sidebar visibility, in-app documentation
  - `applications/music.sh` - Crossfade, lossless audio, Dolby Atmos
  - `applications/podcasts.sh` - Skip times, episode limits, sync settings
  - `applications/books.sh` - Night theme, sync settings, audiobook controls
  - `applications/preview.sh` - Sidebar, PDF display, image anti-aliasing
  - `applications/keynote.sh` - Presenter notes, guides, remote control
  - `applications/numbers.sh` - Formula warnings, sheet deletion warnings
  - `applications/pages.sh` - Word count, smart quotes, zoom level

  **Developer Tools (2 new)**:
  - `applications/xcode.sh` - Build times, line numbers, trim whitespace
  - `applications/disk_utility.sh` - Show all devices, debug menu, APFS snapshots

  **Third-Party Apps (6 new)**:
  - `applications/chrome.sh` - Swipe navigation, print dialog, policy docs
  - `applications/firefox.sh` - Swipe navigation, about:config documentation
  - `applications/slack.sh` - Dock bounce, hardware acceleration, auto-launch
  - `applications/zoom_app.sh` - Join muted/video off, HD video, dual monitors
  - `applications/spotify.sh` - Documentation for in-app settings
  - `applications/1password.sh` - Menu bar, security settings documentation

  **Accessibility (1 new)**:
  - `accessibility/audio.sh` - Flash screen, mono audio, audio balance

### Notes

- Total application defaults scripts: 39 (up from 15)
- Total accessibility scripts: 4 (complete)
- All scripts include comprehensive inline documentation with sources
- Scripts follow consistent pattern with `run_defaults()` helper and DRY_RUN_MODE support

## [1.2.0] - 2026-01-02

### Added

- **v1.2.0: macOS Defaults (System)** - Major release with 11 new defaults scripts:

  **System Scripts (8 new)**:
  - `system/spotlight.sh` - Index categories, search suggestions
  - `system/sharing.sh` - SSH, Screen Sharing, File Sharing
  - `system/airdrop.sh` - Discoverability settings
  - `system/network.sh` - Wake-on-LAN, Bonjour, mDNS
  - `system/siri.sh` - Enable/disable, suggestions, voice feedback
  - `system/focus_modes.sh` - Do Not Disturb, display sleep behavior
  - `system/date_time.sh` - Clock format, 24-hour time, NTP
  - `system/filevault.sh` - Disk encryption status and recommendations

  **Interface Scripts (3 new)**:
  - `interface/stage_manager.sh` - Enable, window grouping, strip visibility
  - `interface/window_management.sh` - Double-click, minimize effect, tabs
  - `interface/wallpaper.sh` - Wallpaper setting methods and documentation

### Notes

- Total defaults scripts now: 56
- Privacy profile: 15+ privacy-enhancing settings
- Lockdown profile: 25+ maximum security settings
- All scripts include comprehensive inline documentation

## [1.1.8] - 2026-01-02

### Added

- **Feature #11: Interactive Role Creation** - New guided wizard for creating profiles:
  - `fc profile create` launches interactive 4-step wizard
  - Step 1: Profile name with validation
  - Step 2: Optional description
  - Step 3: Component selection (fzf multi-select: git, ssh, shell, editor)
  - Step 4: Confirmation and preview
  - Generates template files (.gitconfig, .ssh/config, .aliases, VSCode settings)

- **Feature #43: macOS Notification Integration** - New notification helpers:
  - `lib/notify.sh` module with `notify_success`, `notify_error`, `notify_info`
  - Cross-platform: osascript (macOS) or notify-send (Linux)
  - `run_with_notification` wrapper for long-running commands
  - Auto-notification for operations taking 10+ seconds

- **Feature #35: Enhanced fc info** - Completely redesigned system info display:
  - Visual banner with version and ASCII art
  - Circus status (version, profile, plugin count)
  - System info (OS, CPU, memory, hostname)
  - Health indicators with color-coded status (disk, battery, uptime)
  - Tool status checks (Homebrew, Git, fzf, Node, Python)
  - `--short` and `--json` output options

### Changed

- `fc-profile` usage updated to `fc profile` for consistency
- `lib/init.sh` now sources notification helpers

## [1.1.7] - 2026-01-02

### Added

- **Feature #23: Interactive FC Command** - New `-i/--interactive` flag for guided command discovery:
  - `fc -i` launches fzf-powered interactive menu
  - Browse all commands with descriptions
  - Preview command help in side panel
  - Select actions/subcommands interactively
  - Fallback mode when fzf is not installed

### New Files

- `lib/interactive.sh` - Interactive mode helper functions

### Changed

- `bin/fc` - Added `-i/--interactive` flag, improved command parsing

## [1.1.6] - 2026-01-02

### Changed

- **Cross-Platform Phase 4: Package Management** - Final phase of Linux support:
  - `fc clipboard` - Uses `os_clipboard_copy/paste` (xclip/xsel on Linux)
  - `fc apps` - Uses apt/dnf/pacman on Linux, Homebrew on macOS
  - `fc maintenance` - Platform-specific cache cleanup and system maintenance

### Completed

- **Feature #25: Cross-Platform Support** - All phases complete! Core circus functionality now works on Linux:
  - Phases 1-3: Foundation, networking, desktop integration
  - Phase 4: Package management and clipboard

### Documentation

- Updated `docs/CROSS_PLATFORM.md` with complete compatibility matrix

## [1.1.5] - 2026-01-02

### Changed

- **Cross-Platform Phase 3: Desktop Integration** - Desktop plugins now work on Linux:
  - `fc lock` - Uses `os_lock_screen` (loginctl/xdg-screensaver on Linux)
  - `fc caffeine` - Uses systemd-inhibit or caffeine package on Linux
  - macOS-specific subcommands (status, require, timeout) still available on macOS only

### Documentation

- Updated `docs/CROSS_PLATFORM.md` to reflect Phase 3 completion

## [1.1.4] - 2026-01-02

### Changed

- **Cross-Platform Phase 2: Networking** - Refactored networking plugins to use OS abstraction:
  - `fc wifi` - Now uses `os_wifi_on/off/status` (nmcli on Linux)
  - `fc dns` - Now uses `os_set_dns/get_dns/clear_dns` (resolvectl on Linux)
  - `fc firewall` - Now uses `os_firewall_on/off/status` (ufw/firewalld on Linux)

### Documentation

- Updated `docs/CROSS_PLATFORM.md` to reflect Phase 2 completion

## [1.1.3] - 2026-01-02

### Added

- **Cross-Platform Linux Support (Phase 1)**: OS abstraction layer for Linux compatibility:
  - `lib/os/detect.sh` - Platform detection (macOS, Linux, WSL, distros)
  - `lib/os/macos.sh` - macOS implementations (package, clipboard, networking, etc.)
  - `lib/os/linux.sh` - Linux implementations (apt/dnf/pacman, xclip/xsel, nmcli, etc.)
  - Boolean helpers: `is_macos`, `is_linux`, `is_wsl`, `is_debian_based`, etc.
  - Guard functions: `require_macos`, `require_linux`

- **Linux Distro Support**:
  - Ubuntu/Debian (apt)
  - Fedora/RHEL (dnf)
  - Arch Linux (pacman)

### Changed

- `lib/init.sh` loads OS-specific modules automatically
- Tier 3 plugins now gracefully exit on Linux with clear error messages:
  - fc-bluetooth, fc-lock, fc-caffeine, fc-airdrop
  - fc-keychain, fc-alfred, fc-raycast

### Documentation

- New `docs/CROSS_PLATFORM.md` - Platform compatibility matrix and prerequisites
- Updated `ROADMAP.md` to mark feature #25 as in-progress (Phase 1 complete)

## [1.1.2] - 2026-01-02

### Added

- **VM Management**: New `fc vm` command for managing container VMs with:
  - Support for Lima (`limactl`) and Colima providers
  - Provider abstraction in `lib/vm_backends/` for extensibility
  - Subcommands: `list`, `start`, `stop`, `status`, `shell`, `delete`, `create`, `ip`, `provider`
  - Auto-detection of available provider (prefers Colima)
  - Configuration via `~/.config/circus/vm.conf`

### Documentation

- New `docs/VIRTUAL_MACHINES.md` - Complete VM management guide
- Updated `COMMANDS.md` with `fc vm` command documentation
- Updated `ROADMAP.md` to mark feature #45 as complete

## [1.1.1] - 2026-01-02

### Added

- **Raycast Script Commands Integration**: New `fc raycast` command with:
  - `install` subcommand to install Flying Circus script commands to Raycast
  - `uninstall` subcommand to remove the script commands
  - `status` subcommand to check installation status
  - 27 individual script commands for quick-access to fc functionality
  - Script commands source files in `etc/raycast/scripts/`

- **Raycast Commands**: Quick access to fc commands via Raycast:
  - Wi-Fi On/Off/Status - Control Wi-Fi adapter
  - Bluetooth On/Off/Status - Control Bluetooth
  - Lock Screen - Lock screen immediately
  - Caffeine On/Off/30min/1hr/Status - Prevent sleep
  - DNS Status/Cloudflare/Google/Quad9/Clear - Manage DNS servers
  - AirDrop Everyone/Contacts/Off/Status - Control AirDrop visibility
  - System Info - Display system information (full output)
  - System Healthcheck - Run diagnostics (full output)
  - Disk Status/Usage - Disk utilities
  - SSH List/Copy - SSH key management
  - Clipboard Clear - Clear clipboard

### Documentation

- Added `docs/RAYCAST.md` - Complete Raycast integration documentation
- Updated `COMMANDS.md` with `fc raycast` command documentation
- Updated `ROADMAP.md` to mark feature #40 as complete

## [1.1.0] - 2026-01-02

### Added

- **Alfred Workflow Integration**: New `fc alfred` command with:
  - `install` subcommand to install the Flying Circus workflow to Alfred
  - `uninstall` subcommand to remove the workflow
  - `status` subcommand to check installation status
  - Single "Flying Circus" workflow with 12 keyword triggers
  - Script filters returning JSON for dynamic Alfred results
  - Workflow source files in `etc/alfred/workflows/Flying Circus/`

- **Alfred Keywords**: Quick access to fc commands via Alfred:
  - `wifi` - Control Wi-Fi (on/off/status)
  - `bluetooth` - Control Bluetooth (on/off/status)
  - `lock` - Lock screen immediately
  - `caffeine` - Prevent sleep (on/off/for/status)
  - `dns` - Manage DNS servers (Cloudflare, Google, Quad9, clear)
  - `airdrop` - Control AirDrop visibility
  - `fcinfo` - Display system information
  - `healthcheck` - Run system diagnostics
  - `disk` - Disk utilities (status/usage/large/cleanup)
  - `sshkey` - SSH key management (list/copy/generate/add)
  - `keychain` - Keychain access (list/wifi/search)
  - `clip` - Clipboard utilities (show/clear/plain/count)
  - `fc` - Browse all available commands

### Documentation

- Added `docs/ALFRED.md` - Complete Alfred workflow documentation
- Updated `COMMANDS.md` with `fc alfred` command documentation
- Updated `ROADMAP.md` to mark feature #39 as complete

## [1.0.0] - 2026-01-01

### Added

- **Self-Update Mechanism**: Enhanced `fc update` command with:
  - `--check` flag to check for updates without applying them
  - `--version` flag to display the current installed version
  - `--dry-run` flag to preview what an update would do
  - `--skip-migrations` flag to update without running migrations
  - Automatic migration system for version upgrades

- **Migration System**: Framework for running migration scripts during updates
  - Migrations stored in `migrations/` directory
  - Version-based migration selection
  - Documentation for writing migration scripts

- **Version Tracking**: `.version` file for semantic versioning

- **Installer Refactor**: Stage-based modular installer with:
  - 15 independent installation stages
  - 21 preflight system checks
  - Role-based configuration (developer, personal, work)
  - Privacy profiles (standard, privacy, lockdown)
  - Dry-run mode support
  - Comprehensive test coverage

- **Logging System**: 6-level logging with:
  - DEBUG, INFO, SUCCESS, WARN, ERROR, CRITICAL levels
  - File logging with `--log-file` flag
  - Console filtering with `--log-level` flag
  - `--silent` flag for quiet operation
  - Automatic log rotation

- **Plugin System**: Extensible command architecture
  - 22+ plugins in `lib/plugins/`
  - Dynamic plugin discovery
  - Per-plugin help messages

- **Error Handling**: Robust error management with:
  - `die()` function for fatal errors
  - ERR trap for unexpected failures
  - Contextual error messages

### Documentation

- Architecture documentation in `ARCHITECTURE.md`
- Plugin creation guide in `docs/CREATING_PLUGINS.md`
- Troubleshooting guide in `docs/TROUBLESHOOTING.md`
- Update guide in `docs/UPDATING.md`
- Command specifications in `docs/specs/`
