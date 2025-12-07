# Feature Specification: `fc quicklook`

## Overview

**Command:** `fc quicklook`  
**Purpose:** Manage Quick Look previews and plugins.

### Use Cases
- Preview files from terminal
- List installed Quick Look plugins
- Reset Quick Look cache
- Debug Quick Look issues

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `preview [file]` | Quick Look preview a file |
| `plugins` | List installed Quick Look plugins |
| `reset` | Reset Quick Look cache |
| `test [file]` | Test Quick Look for a file type |

---

## Detailed Behaviors

### `fc quicklook preview [file]`

Preview file:

```
$ fc quicklook preview document.pdf

Opening Quick Look preview...
Press Space to close.
```

**Implementation:**
- Use `qlmanage -p <file>`

---

### `fc quicklook plugins`

List plugins:

```
$ fc quicklook plugins

Quick Look Plugins:

  Name                    Bundle ID                    Supports
  QLMarkdown             com.github.qlmarkdown        .md, .markdown
  QLColorCode            com.qlcolorcode              .py, .js, .rb
  QLStephen              com.whomwah.qlstephen        Plain text
```

**Implementation:**
- List from `/Library/QuickLook` and `~/Library/QuickLook`

---

### `fc quicklook reset`

Reset cache:

```
$ fc quicklook reset

Resetting Quick Look cache...
✓ Cache cleared. Restart Finder for full effect.
```

**Implementation:**
- Use `qlmanage -r cache`
- Use `qlmanage -r`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `qlmanage` | macOS | Yes |

---

## Examples

```bash
# Preview a file
fc quicklook preview image.png

# Preview multiple files
fc quicklook preview *.pdf

# List installed plugins
fc quicklook plugins

# Reset Quick Look cache
fc quicklook reset

# Test Quick Look for specific file
fc quicklook test document.md

# Get file metadata
fc quicklook info document.pdf
```

---

## Implementation Notes

### qlmanage Command

`qlmanage` is the Quick Look management tool:

| Command | Description |
|---------|-------------|
| `qlmanage -p <file>` | Preview file in Quick Look window |
| `qlmanage -t <file>` | Generate thumbnail |
| `qlmanage -r` | Reset Quick Look server |
| `qlmanage -r cache` | Reset Quick Look cache |
| `qlmanage -m` | List available generators |

```bash
# Preview file
qlmanage -p document.pdf

# Generate thumbnail (saves to current directory)
qlmanage -t -s 512 image.png -o /tmp/

# Reset Quick Look  
qlmanage -r
qlmanage -r cache
```

### Plugin Locations

Quick Look plugins are stored in two locations:

| Location | Scope |
|----------|-------|
| `/Library/QuickLook/` | System-wide (all users) |
| `~/Library/QuickLook/` | Current user only |

Each plugin is a `.qlgenerator` bundle containing:
- `Info.plist` - Metadata and supported file types
- Binary code for rendering previews

### Listing Plugins

```bash
# List all plugins
ls /Library/QuickLook/ ~/Library/QuickLook/ 2>/dev/null

# Get plugin info
qlmanage -m

# Check which generator handles a file type
qlmanage -m -p document.md
```

### Popular Quick Look Plugins

| Plugin | Install | Supports |
|--------|---------|----------|
| QLMarkdown | `brew install qlmarkdown` | Markdown files |
| QLColorCode | `brew install qlcolorcode` | Source code syntax highlighting |
| QLStephen | `brew install qlstephen` | Plain text files without extension |
| QuickLookJSON | `brew install quicklook-json` | JSON files |
| QLVideo | `brew install qlvideo` | Video thumbnails and previews |
| QLImageSize | `brew install qlimagesize` | Image dimensions in Finder |

### Cache Reset

When Quick Look misbehaves or new plugins aren't recognized:

```bash
# Reset generator list
qlmanage -r

# Clear cache
qlmanage -r cache

# Restart Finder (sometimes needed)
killall Finder
```

### Debugging Quick Look

```bash
# See which generator handles a file
qlmanage -m -p /path/to/file

# Preview with debug output
qlmanage -p -d2 /path/to/file

# Check generator thumbnails
qlmanage -t -d2 /path/to/file
```

### Gatekeeper and Plugins

Third-party plugins may be blocked by Gatekeeper:

```bash
# Check quarantine
xattr -l /Library/QuickLook/QLMarkdown.qlgenerator

# Remove quarantine (if trusted)
xattr -d com.apple.quarantine /Library/QuickLook/QLMarkdown.qlgenerator
```

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc quicklook --help         # displays usage

# Subcommand validation
fc quicklook unknown        # returns error for unknown subcommand

# Non-destructive checks
fc quicklook plugins        # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Preview file | `fc quicklook preview test.pdf` | Quick Look window opens |
| Multiple files | `fc quicklook preview *.png` | Shows files in Quick Look |
| List plugins | `fc quicklook plugins` | Shows installed plugins |
| Reset cache | `fc quicklook reset` | Cache cleared, confirmation shown |
| Test file | `fc quicklook test file.md` | Shows which generator handles file |

### Edge Cases

- File not found
- No generator for file type
- Plugin not loaded (quarantine)
- Very large files
- Corrupted files
