# Feature Specification: `fc screenshot`

## Overview

**Command:** `fc screenshot`  
**Purpose:** Configure macOS screenshot settings.

### Use Cases
- Change screenshot save location
- Change screenshot format (PNG, JPG, etc.)
- Disable screenshot shadows
- Disable floating thumbnail preview

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show current screenshot settings |
| `location [path]` | Set save location |
| `format [type]` | Set file format (png, jpg, gif, pdf) |
| `shadow [on/off]` | Enable/disable window shadows |
| `preview [on/off]` | Enable/disable floating preview |

---

## Detailed Behaviors

### `fc screenshot status`

Show settings:

```
$ fc screenshot status

Screenshot Settings:
  Location:   ~/Desktop
  Format:     PNG
  Shadow:     Enabled
  Preview:    Enabled
```

---

### `fc screenshot location [path]`

Set save location:

```
$ fc screenshot location ~/Screenshots

Setting screenshot location to ~/Screenshots...

✓ Screenshots will now save to ~/Screenshots
```

**Implementation:**
- Use `defaults write com.apple.screencapture location <path>`
- Create directory if needed

---

### `fc screenshot format [type]`

Set format:

```
$ fc screenshot format jpg

Setting screenshot format to JPG...

✓ Screenshots will now save as JPG files
```

**Implementation:**
- Use `defaults write com.apple.screencapture type <format>`
- Valid types: png, jpg, gif, pdf, tiff

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `defaults` | macOS | Yes |
| `killall` | macOS | Yes (SystemUIServer restart) |

---

## Examples

```bash
# Check current settings
fc screenshot status

# Change save location
fc screenshot location ~/Screenshots

# Use JPG format
fc screenshot format jpg

# Disable shadows on window captures
fc screenshot shadow off

# Disable floating preview thumbnail
fc screenshot preview off

# Set a custom filename prefix
fc screenshot prefix "Screen Capture"

# Reset to defaults
fc screenshot reset
```

---

## Implementation Notes

### Screenshot Domain

Screenshot preferences use the `com.apple.screencapture` domain:

```bash
# Read all settings
defaults read com.apple.screencapture

# Restart SystemUIServer (sometimes required)
killall SystemUIServer
```

### Save Location

```bash
# Set save location
defaults write com.apple.screencapture location -string "/path/to/folder"

# Reset to default (Desktop)
defaults delete com.apple.screencapture location
```

> **Note:** The directory must exist. Create it before setting the location.

### File Format

| Format | Description |
|--------|-------------|
| `png` | Default, lossless with transparency |
| `jpg` | Smaller file size, no transparency |
| `gif` | Limited colors, supports transparency |
| `pdf` | Vector-based, scalable |
| `tiff` | High quality, large files |
| `bmp` | Uncompressed bitmap |

```bash
defaults write com.apple.screencapture type -string "png"
```

### Window Shadows

When capturing a window (⌘⇧4 then Space), macOS adds a shadow:

```bash
# Disable shadow
defaults write com.apple.screencapture disable-shadow -bool true

# Enable shadow (default)
defaults delete com.apple.screencapture disable-shadow
```

### Floating Preview

The thumbnail preview appears briefly after taking a screenshot:

```bash
# Disable preview thumbnail
defaults write com.apple.screencapture show-thumbnail -bool false

# Enable preview (default)
defaults delete com.apple.screencapture show-thumbnail
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧3` | Capture entire screen |
| `⌘⇧4` | Capture selection |
| `⌘⇧4` then `Space` | Capture window |
| `⌘⇧5` | Open Screenshot app with options |
| `⌘⇧6` | Capture Touch Bar (if available) |

Add `Control` to any shortcut to copy to clipboard instead of saving.

### Command-Line Capture

The `screencapture` command provides programmatic access:

```bash
# Capture entire screen
screencapture ~/Desktop/screen.png

# Capture selection
screencapture -i ~/Desktop/selection.png

# Capture window
screencapture -W ~/Desktop/window.png

# Capture to clipboard
screencapture -c

# Delayed capture (5 seconds)
screencapture -T 5 ~/Desktop/delayed.png

# Capture without shadow
screencapture -o -W ~/Desktop/window-no-shadow.png
```

### Restart Requirements

Most settings take effect immediately, but some may require:

```bash
killall SystemUIServer
```

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc screenshot --help          # displays usage

# Subcommand validation
fc screenshot unknown         # returns error for unknown subcommand
fc screenshot format invalid  # returns error for invalid format

# Non-destructive checks
fc screenshot status          # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Check status | `fc screenshot status` | Shows current settings |
| Change location | `fc screenshot location ~/Screenshots` | Location setting updated |
| Change format | `fc screenshot format jpg` | Take screenshot, verify JPG format |
| Disable shadow | `fc screenshot shadow off` | Window capture has no shadow |
| Disable preview | `fc screenshot preview off` | No thumbnail appears after capture |
| Reset | `fc screenshot reset` | Settings return to defaults |

### Verification Commands

```bash
# Read current location
defaults read com.apple.screencapture location

# Read current format
defaults read com.apple.screencapture type

# Check shadow setting
defaults read com.apple.screencapture disable-shadow
```

### Edge Cases

- Location path with spaces
- Non-existent directory for location
- Invalid format type
- Permission issues for save location
