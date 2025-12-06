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
# Check settings
fc screenshot status

# Change location
fc screenshot location ~/Screenshots

# Use JPG format
fc screenshot format jpg

# Disable shadows
fc screenshot shadow off
```
