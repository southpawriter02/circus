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

# Remove app
fc dock remove "App Store"

# List apps
fc dock list

# Move to left
fc dock position left

# Auto-hide
fc dock autohide on

# Reset
fc dock reset
```
