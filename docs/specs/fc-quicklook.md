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
# Preview file
fc quicklook preview image.png

# List plugins
fc quicklook plugins

# Reset cache
fc quicklook reset
```
