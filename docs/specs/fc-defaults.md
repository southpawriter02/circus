# Feature Specification: `fc defaults`

## Overview

**Command:** `fc defaults`  
**Purpose:** Apply curated macOS defaults tweaks—show hidden files, speed up animations, etc.

### Use Cases
- Apply popular macOS customizations
- Show/hide hidden files in Finder
- Speed up or disable animations
- Configure Dock behavior
- Safari developer settings
- Reset to macOS defaults

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all available tweaks |
| `apply [name]` | Apply a specific tweak |
| `reset [name]` | Reset a tweak to macOS default |
| `status` | Show current status of all tweaks |
| `all` | Apply all recommended tweaks |

---

## Available Tweaks

### Finder

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `finder.hidden-files` | Show hidden files | No | Yes |
| `finder.path-bar` | Show path bar | No | Yes |
| `finder.status-bar` | Show status bar | No | Yes |
| `finder.extensions` | Show file extensions | No | Yes |
| `finder.quit` | Allow quitting Finder | No | No |
| `finder.default-view` | Default view style | Icons | List |

### Dock

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `dock.autohide` | Auto-hide Dock | No | Optional |
| `dock.autohide-delay` | Delay before showing | 0.5s | 0s |
| `dock.minimize-effect` | Minimize animation | Genie | Scale |
| `dock.static-only` | Only show running apps | No | Optional |
| `dock.mru-spaces` | Reorder spaces by use | Yes | No |

### Screenshots

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `screenshot.location` | Save location | Desktop | custom |
| `screenshot.format` | File format | PNG | PNG |
| `screenshot.shadow` | Include shadow | Yes | No |
| `screenshot.preview` | Show preview | Yes | Optional |

### System

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `system.animations` | Speed up/disable animations | Normal | Fast |
| `system.crash-reporter` | Disable crash dialogs | No | Yes |
| `system.disk-warning` | Low disk space warning | Yes | Yes |
| `system.quarantine` | App quarantine dialogs | Yes | Optional |

### Safari

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `safari.develop-menu` | Show Develop menu | No | Yes |
| `safari.full-url` | Show full URLs | No | Yes |
| `safari.autofill` | Form autofill | Yes | Optional |

### Terminal

| Tweak | Description | Default | Recommended |
|-------|-------------|---------|-------------|
| `terminal.secure-keyboard` | Secure keyboard entry (anti-keylogging) | No | Yes |
| `terminal.focus-follows-mouse` | Auto-focus window under cursor | No | No |
| `terminal.new-window-dir` | Working directory for new windows | Home | Home |
| `terminal.new-tab-dir` | Working directory for new tabs | Home | Same |
| `terminal.resize-speed` | Window resize animation speed | Normal | Fast |
| `terminal.show-marks` | Show command line marks | Yes | Yes |
| `terminal.shell-exit` | Close window on shell exit | Clean | Clean |

---

## Detailed Behaviors

### `fc defaults list`

List available tweaks:

```
$ fc defaults list

Available macOS Defaults Tweaks:

Category: Finder
  finder.hidden-files    Show hidden files in Finder
  finder.path-bar        Show path bar at bottom
  finder.extensions      Always show file extensions
  ...

Category: Dock
  dock.autohide          Auto-hide the Dock
  dock.autohide-delay    Remove Dock auto-hide delay
  ...
```

**Implementation:**
- Display all tweaks by category
- Show brief description

---

### `fc defaults apply [name]`

Apply a specific tweak:

```
$ fc defaults apply finder.hidden-files

Applying: Show hidden files in Finder

Running: defaults write com.apple.finder AppleShowAllFiles -bool true

✓ Applied! Restarting Finder...
```

**Implementation:**
- Run the appropriate `defaults write` command
- Restart affected app if needed (Finder, Dock, etc.)
- Show what command was executed

---

### `fc defaults reset [name]`

Reset to default:

```
$ fc defaults reset finder.hidden-files

Resetting to macOS default: Hide hidden files in Finder

Running: defaults write com.apple.finder AppleShowAllFiles -bool false

✓ Reset! Restarting Finder...
```

**Implementation:**
- Use `defaults delete` or set to default value
- Restart affected app if needed

---

### `fc defaults status`

Show current state:

```
$ fc defaults status

Current Defaults Status:

  Tweak                    Current    Recommended    
  finder.hidden-files      ✓ On       On
  finder.path-bar          ✓ On       On
  dock.autohide            ✗ Off      Optional
  dock.autohide-delay      ✗ 0.5s     0s
  safari.develop-menu      ✓ On       On
  ...
```

**Implementation:**
- Read each setting with `defaults read`
- Compare to recommended values

---

### `fc defaults all`

Apply all recommended tweaks:

```
$ fc defaults all

Applying all recommended tweaks...

  ✓ finder.hidden-files
  ✓ finder.path-bar
  ✓ finder.extensions
  ✓ dock.autohide-delay
  ✓ safari.develop-menu
  ...

Applied 12 tweaks. Run 'fc defaults status' to verify.
```

**Implementation:**
- Apply all tweaks marked "Recommended: Yes"
- Skip optional tweaks
- Show summary

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `defaults` | macOS | Yes |
| `killall` | macOS | Yes |

---

## Implementation Notes

### Restart Requirements
- Finder: `killall Finder`
- Dock: `killall Dock`
- SystemUIServer: `killall SystemUIServer`
- Safari: Restart manually (warn user)

### Common Domains
- `com.apple.finder` - Finder settings
- `com.apple.dock` - Dock settings
- `com.apple.Safari` - Safari settings
- `com.apple.screencapture` - Screenshots
- `NSGlobalDomain` - System-wide settings

### Safety
- Never run with sudo (user defaults only)
- Show exact command being run
- Warn before opening Safari settings (requires closing Safari)

---

## Examples

```bash
# List all tweaks
fc defaults list

# Check current settings
fc defaults status

# Apply single tweak
fc defaults apply finder.hidden-files

# Reset single tweak
fc defaults reset finder.hidden-files

# Apply all recommended
fc defaults all

# Category-specific
fc defaults apply dock.autohide
fc defaults apply dock.autohide-delay
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc defaults --help` displays usage
- `fc defaults list` runs without error
- `fc defaults status` runs without error
- Unknown subcommand returns error

### Manual Verification
- Test each tweak individually
- Verify setting persists after restart
- Check app restarts properly
- Test reset returns to original
