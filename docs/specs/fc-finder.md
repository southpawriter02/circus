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
```
