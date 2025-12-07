# Feature Specification: `fc dock`

## Overview

**Command:** `fc dock`  
**Purpose:** Customize the macOS Dock from the command line.

### Use Cases
- Add/remove apps from Dock
- Change Dock position and size
- Toggle auto-hide
- Reset Dock to defaults

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `add [app]` | Add an app to the Dock |
| `remove [app]` | Remove an app from the Dock |
| `list` | List apps in the Dock |
| `position [left/bottom/right]` | Set Dock position |
| `size [small/medium/large]` | Set Dock icon size |
| `autohide [on/off]` | Toggle auto-hide |
| `reset` | Reset Dock to defaults |

---

## Detailed Behaviors

### `fc dock add [app]`

Add app to Dock:

```
$ fc dock add "Visual Studio Code"

Adding Visual Studio Code to Dock...
✓ App added. Restarting Dock...
```

**Implementation:**
- Use `defaults write com.apple.dock persistent-apps`
- Restart Dock with `killall Dock`

---

### `fc dock position [position]`

Set position:

```
$ fc dock position left

Moving Dock to left side...
✓ Dock is now on the left
```

**Implementation:**
- Use `defaults write com.apple.dock orientation left`

---

### `fc dock autohide [on/off]`

Toggle auto-hide:

```
$ fc dock autohide on

Enabling Dock auto-hide...
✓ Dock will now hide automatically
```

**Implementation:**
- Use `defaults write com.apple.dock autohide -bool true`

---

### `fc dock reset`

Reset to defaults:

```
$ fc dock reset

⚠️  This will reset your Dock to macOS defaults.
    All custom apps will be removed.

Continue? [y/N] y

✓ Dock has been reset
```

**Implementation:**
- Use `defaults delete com.apple.dock`
- Restart Dock

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `defaults` | macOS | Yes |
| `killall` | macOS | Yes |
| `dockutil` | Homebrew | Optional (easier management) |

---

## Examples

```bash
# Add app
fc dock add Safari

# Add app by path
fc dock add "/Applications/Visual Studio Code.app"

# Remove app
fc dock remove "App Store"

# List apps
fc dock list

# Move to left
fc dock position left

# Set icon size
fc dock size large

# Auto-hide with no delay
fc dock autohide on --no-delay

# Reset
fc dock reset
```

---

## Implementation Notes

### Dock Domain

All Dock preferences use the `com.apple.dock` domain:

```bash
# Read current settings
defaults read com.apple.dock

# Write setting
defaults write com.apple.dock autohide -bool true

# Restart Dock (required for changes)
killall Dock
```

### Dock Position

| Value | Description |
|-------|-------------|
| `left` | Dock on left side of screen |
| `bottom` | Dock at bottom (default) |
| `right` | Dock on right side of screen |

```bash
defaults write com.apple.dock orientation -string "left"
```

### Icon Size

The `tilesize` preference controls icon size in pixels:

| Size | Pixels |
|------|--------|
| Small | 36 |
| Medium | 48 (default) |
| Large | 64 |
| Custom | 16-128 |

```bash
defaults write com.apple.dock tilesize -int 48
```

### Auto-hide Settings

| Preference | Description |
|------------|-------------|
| `autohide` | Enable/disable auto-hide |
| `autohide-delay` | Delay before showing (default: 0.5) |
| `autohide-time-modifier` | Animation speed (default: 0.5) |

```bash
# Enable auto-hide
defaults write com.apple.dock autohide -bool true

# Remove show delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up animation
defaults write com.apple.dock autohide-time-modifier -float 0.25
```

### Adding/Removing Apps

The Dock stores apps in a `persistent-apps` array. Managing this directly is complex. Consider using `dockutil`:

```bash
# Install dockutil
brew install dockutil

# Add app
dockutil --add "/Applications/Safari.app"

# Remove app
dockutil --remove "Safari"

# List apps
dockutil --list
```

### Native defaults Approach

For adding apps without dockutil:

```bash
# Read current apps
defaults read com.apple.dock persistent-apps

# Add app (complex - requires proper plist structure)
# Format: tile-data with file-data containing _CFURLString
```

> **Recommendation:** Use `dockutil` for reliable app management.

### Restart Requirements

All Dock changes require a restart:

```bash
killall Dock
```

The Dock will automatically relaunch after killall.

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc dock --help              # displays usage

# Subcommand validation
fc dock unknown             # returns error for unknown subcommand
fc dock position invalid    # returns error for invalid position

# Non-destructive checks
fc dock list                # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| List apps | `fc dock list` | Shows apps in Dock |
| Add app | `fc dock add Safari` | Safari added to Dock |
| Remove app | `fc dock remove Safari` | Safari removed from Dock |
| Position left | `fc dock position left` | Dock moves to left |
| Position bottom | `fc dock position bottom` | Dock moves to bottom |
| Size change | `fc dock size large` | Icons become larger |
| Auto-hide on | `fc dock autohide on` | Dock auto-hides |
| Reset | `fc dock reset` | Dock returns to default state |

### Edge Cases

- App not found for add/remove
- Invalid position values
- Reset confirmation bypass with `--yes`
- App already in Dock (duplicate prevention)
- Special characters in app names
