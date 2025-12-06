# Feature Specification: `fc notify`

## Overview

**Command:** `fc notify`  
**Purpose:** Send macOS notifications from the terminal.

### Use Cases
- Notify when long-running command completes
- Schedule reminders
- Script-based alerts
- System monitoring notifications

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `send [message]` | Send a notification |
| `done [command]` | Run command and notify when complete |

---

## Detailed Behaviors

### `fc notify send [message]`

Send notification:

```
$ fc notify send "Build complete!" --title "Xcode"

✓ Notification sent
```

**Implementation:**
- Use `osascript -e 'display notification "msg" with title "title"'`
- Accept `--title`, `--subtitle`, `--sound`

---

### `fc notify done [command]`

Run command then notify:

```
$ fc notify done "npm run build"

Running: npm run build
[command output]

✓ Build finished (exit: 0)
Notification sent!
```

**Implementation:**
- Run command, capture exit code
- Send notification with success/failure status

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `osascript` | macOS | Yes |

---

## Examples

```bash
# Simple notification
fc notify send "Hello!"

# With title
fc notify send "Build complete" --title "Build"

# Notify when command finishes
fc notify done "make test"
```
