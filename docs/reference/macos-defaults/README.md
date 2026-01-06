# macOS Defaults Reference

This directory contains comprehensive documentation for macOS `defaults` commands — the system preferences that can be configured from the command line.

---

## Overview

The `defaults` command allows you to read, write, and delete macOS user preferences from the terminal. These settings control everything from Finder behavior to keyboard shortcuts to system animations.

### Basic Syntax

```bash
# Read a preference
defaults read <domain> <key>

# Write a preference
defaults write <domain> <key> <value>

# Delete a preference (restore default)
defaults delete <domain> <key>

# List all preferences for a domain
defaults read <domain>
```

### Applying Changes

Most changes require logging out and back in, or restarting the affected application:

```bash
# Restart Finder
killall Finder

# Restart Dock
killall Dock

# Restart SystemUIServer (menu bar)
killall SystemUIServer
```

---

## Settings by Category

### 🦽 Accessibility

Settings for users with disabilities and motion preferences.

| Setting | Description |
|---------|-------------|
| [Reduce Motion](accessibility/) | Minimize interface animations |
| [Color Filters](accessibility/) | Adjust display colors |
| [Zoom](accessibility/) | Screen magnification |

---

### 🎨 Appearance

System-wide visual appearance.

| Setting | Description |
|---------|-------------|
| [Interface Style](appearance/) | Light mode, dark mode, auto |

---

### 💬 Dialogs

System dialog behavior.

| Setting | Description |
|---------|-------------|
| [Save Panel](dialogs/) | Expanded vs. compact save dialogs |

---

### 🚀 Dock

Dock appearance, behavior, and animations.

| Setting | Description |
|---------|-------------|
| [Size & Magnification](dock/) | Icon size and hover effects |
| [Position](dock/) | Left, bottom, or right |
| [Auto-hide](dock/) | Show/hide behavior |
| [Animations](dock/) | Launch and minimize effects |
| [Recent Apps](dock/) | Show recent applications |

---

### 📁 Finder

File browser settings and view options.

| Setting | Description |
|---------|-------------|
| [Show Extensions](finder/) | Always show file extensions |
| [Show Hidden Files](finder/) | Display hidden files and folders |
| [Default View](finder/) | Icon, list, column, or gallery |
| [Path Bar](finder/) | Show full path at bottom |
| [Status Bar](finder/) | Show item count and disk space |
| [New Window Location](finder/) | Default folder for new windows |
| [Search Scope](finder/) | Where to search by default |
| [Desktop Icons](finder/) | Show drives, servers on desktop |
| [Sidebar Items](finder/) | Configure sidebar content |

---

### 🛡️ Firewall

Application firewall configuration.

| Setting | Description |
|---------|-------------|
| [Enable/Disable](firewall/) | Turn firewall on or off |
| [Stealth Mode](firewall/) | Ignore ping requests |

---

### ⌨️ Keyboard

Keyboard behavior and shortcuts.

| Setting | Description |
|---------|-------------|
| [Key Repeat](keyboard/) | Repeat rate and delay |
| [Press and Hold](keyboard/applepressandholdenabled.mdx) | Accent menu vs. key repeat |
| [Function Keys](keyboard/) | Use F1-F12 as standard keys |

---

### 📊 Menu Bar

Top menu bar appearance.

| Setting | Description |
|---------|-------------|
| [Clock Format](menu-bar/) | Digital/analog, seconds, date |
| [Battery Indicator](menu-bar/) | Show percentage |

---

### 🪟 Mission Control

Window management and virtual desktops.

| Setting | Description |
|---------|-------------|
| [Spaces](mission-control/) | Multiple desktop configuration |
| [Hot Corners](mission-control/) | Screen corner actions |
| [Animations](mission-control/) | Transition effects |

---

### 🧭 Safari

Safari browser settings.

| Setting | Description |
|---------|-------------|
| [Developer Tools](safari/) | Enable developer menu |
| [Privacy](safari/) | Tracking and cookie settings |

---

### 🖼️ Screensaver

Screensaver activation and security.

| Setting | Description |
|---------|-------------|
| [Activation Time](screensaver/) | Minutes before screensaver starts |

---

### 🔄 Software Update

System update behavior.

| Setting | Description |
|---------|-------------|
| [Automatic Updates](software-update/) | Download and install automatically |
| [Beta Enrollment](software-update/) | Opt into beta releases |

---

### 🖥️ Terminal

Terminal.app settings.

| Setting | Description |
|---------|-------------|
| [Secure Keyboard](terminal/) | Prevent apps from reading input |
| [Shell Settings](terminal/) | Default shell behavior |

---

### 📝 TextEdit

Text editor defaults.

| Setting | Description |
|---------|-------------|
| [Default Format](textedit/) | Plain text vs. rich text |
| [Smart Features](textedit/) | Quotes, dashes, spelling |

---

### 🖱️ Trackpad

Trackpad gestures and sensitivity.

| Setting | Description |
|---------|-------------|
| [Tap to Click](trackpad/) | Enable single-finger tap |
| [Tracking Speed](trackpad/) | Cursor movement speed |

---

## Finding New Defaults

### List All Domains

```bash
defaults domains | tr ',' '\n'
```

### Watch for Changes

```bash
# Before making a change in System Preferences
defaults read > before.txt

# After making the change
defaults read > after.txt

# See what changed
diff before.txt after.txt
```

### Useful Domains

| Domain | Controls |
|--------|----------|
| `NSGlobalDomain` | System-wide settings |
| `com.apple.finder` | Finder |
| `com.apple.dock` | Dock |
| `com.apple.Safari` | Safari |
| `com.apple.Terminal` | Terminal |

---

## Related Documentation

- [fc defaults](../../specs/fc-defaults.md) — Apply defaults via the `fc` command
- [Privacy Profiles](../../../defaults/profiles/README.md) — Pre-configured security profiles
- [Settings Roadmap](../../SETTINGS_ROADMAP.md) — Planned defaults implementations
