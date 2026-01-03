# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
