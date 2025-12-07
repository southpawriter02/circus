# Feature Specification: `fc finder`

## Overview

**Command:** `fc finder`  
**Purpose:** Control Finder behavior and settings from the command line.

### Use Cases
- Show/hide hidden files quickly
- Restart Finder after configuration changes
- Open specific paths in Finder
- Reset Finder to defaults

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `hidden [on/off]` | Show/hide hidden files |
| `restart` | Restart Finder |
| `open [path]` | Open path in Finder |
| `path` | Show current Finder path |
| `desktop [on/off]` | Show/hide desktop icons |
| `reset` | Reset Finder preferences |

---

## Detailed Behaviors

### `fc finder hidden [on/off]`

Toggle hidden files:

```
$ fc finder hidden on

Showing hidden files in Finder...
Restarting Finder...

✓ Hidden files are now visible
```

**Implementation:**
- Use `defaults write com.apple.finder AppleShowAllFiles -bool true`
- Auto-restart Finder

---

### `fc finder restart`

Restart Finder:

```
$ fc finder restart

Restarting Finder...
✓ Finder restarted
```

**Implementation:**
- Use `killall Finder`

---

### `fc finder open [path]`

Open in Finder:

```
$ fc finder open ~/Documents

Opening /Users/turtle1/Documents in Finder...
```

**Implementation:**
- Use `open -R <path>` to reveal in Finder

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `defaults` | macOS | Yes |
| `killall` | macOS | Yes |
| `open` | macOS | Yes |

---

## Examples

```bash
# Show hidden files
fc finder hidden on

# Hide them again
fc finder hidden off

# Restart Finder
fc finder restart

# Open current directory
fc finder open .

# Show desktop icons
fc finder desktop on

# Get current Finder window path
fc finder path
```

---

## Implementation Notes

### Finder Domain

All Finder preferences use the `com.apple.finder` domain:

```bash
# Read current setting
defaults read com.apple.finder AppleShowAllFiles

# Write setting
defaults write com.apple.finder AppleShowAllFiles -bool true
```

### Restart Requirements

Finder must be restarted for most preference changes to take effect:

- **Hidden files**: Requires restart
- **Desktop icons**: Requires restart  
- **Path bar/status bar**: Requires restart

Use `killall Finder` to restart. Finder will automatically relaunch.

### Desktop Icons

Desktop icons are controlled by the `CreateDesktop` preference:

```bash
# Hide desktop icons
defaults write com.apple.finder CreateDesktop -bool false

# Show desktop icons (default)
defaults write com.apple.finder CreateDesktop -bool true
```

### Path Detection

The current Finder window path can be retrieved via AppleScript:

```bash
osascript -e 'tell application "Finder" to get POSIX path of (target of front window as text)'
```

### Safety Considerations

- Never run with `sudo` (user preferences only)
- Always verify Finder relaunches after `killall`
- The `reset` subcommand should warn before clearing all preferences

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc finder --help           # displays usage
fc finder hidden --help    # displays subcommand help

# Subcommand validation  
fc finder unknown          # returns error for unknown subcommand
fc finder hidden invalid   # returns error for invalid argument

# Non-destructive checks
fc finder path             # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Show hidden files | Run `fc finder hidden on`, check ~/Library visibility | Hidden files visible in Finder |
| Hide hidden files | Run `fc finder hidden off`, check ~/Library visibility | Hidden files hidden |
| Restart Finder | Run `fc finder restart` | Finder closes and relaunches |
| Open path | Run `fc finder open ~/Documents` | Documents folder opens in Finder |
| Desktop toggle | Run `fc finder desktop off` | Desktop icons disappear |
| Path display | Open Finder window, run `fc finder path` | Correct path printed |
