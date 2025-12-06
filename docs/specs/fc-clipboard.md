# Feature Specification: `fc clipboard`

## Overview

**Command:** `fc clipboard`  
**Purpose:** Clipboard utilities—view, clear, history, and transformations.

### Use Cases
- View current clipboard contents
- Clear clipboard for security
- Paste as plain text
- Simple clipboard history

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `show` | Show current clipboard contents |
| `clear` | Clear the clipboard |
| `copy [text]` | Copy text to clipboard |
| `plain` | Convert clipboard to plain text |

---

## Detailed Behaviors

### `fc clipboard show`

Show clipboard:

```
$ fc clipboard show

Clipboard Contents:
---
Hello World, this is some copied text.
---

Type: Plain Text
Size: 42 characters
```

**Implementation:**
- Use `pbpaste`

---

### `fc clipboard clear`

Clear clipboard:

```
$ fc clipboard clear

✓ Clipboard cleared
```

**Implementation:**
- Use `pbcopy < /dev/null`

---

### `fc clipboard copy [text]`

Copy text:

```
$ fc clipboard copy "Hello World"

✓ Copied to clipboard
```

**Implementation:**
- Use `echo "text" | pbcopy`

---

### `fc clipboard plain`

Convert to plain text:

```
$ fc clipboard plain

Converting clipboard to plain text...
✓ Rich text formatting removed
```

**Implementation:**
- Use `pbpaste | pbcopy`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `pbcopy` | macOS | Yes |
| `pbpaste` | macOS | Yes |

---

## Examples

```bash
# View clipboard
fc clipboard show

# Clear it
fc clipboard clear

# Copy from terminal
fc clipboard copy "API_KEY=secret123"

# Remove formatting
fc clipboard plain
```
