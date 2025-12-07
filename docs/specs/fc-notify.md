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

# With title and subtitle
fc notify send "Task finished" --title "Automation" --subtitle "Background Job"

# With sound
fc notify send "Alert!" --sound "Glass"

# Notify when command finishes
fc notify done "make test"

# Notify on long-running command
fc notify done "npm install"
```

---

## Implementation Notes

### osascript Notification

The native macOS notification is sent via AppleScript:

```bash
osascript -e 'display notification "message" with title "title"'
```

Full syntax with all options:

```bash
osascript -e 'display notification "message" with title "title" subtitle "subtitle" sound name "sound"'
```

### Available Options

| Option | Description | Default |
|--------|-------------|---------|
| `--title` | Notification title (bold text) | "fc notify" |
| `--subtitle` | Subtitle (smaller text below title) | None |
| `--sound` | System sound to play | None |

### System Sounds

Available system sounds (case-sensitive):

| Sound Name | Description |
|------------|-------------|
| `Basso` | Low-pitched error sound |
| `Blow` | Short horn |
| `Bottle` | Pop/cork sound |
| `Frog` | Ribbit sound |
| `Funk` | Quirky alert |
| `Glass` | Gentle chime |
| `Hero` | Triumphant fanfare |
| `Morse` | Morse code beep |
| `Ping` | Simple ping |
| `Pop` | Short pop |
| `Purr` | Soft purr |
| `Sosumi` | Classic Mac sound |
| `Submarine` | Sonar ping |
| `Tink` | Light tap |

> **Tip:** List all sounds: `ls /System/Library/Sounds/`

### Alternative: terminal-notifier

For more advanced notifications, `terminal-notifier` (Homebrew) provides:

- Clickable notifications
- Custom icons
- URL opening on click
- Bundle ID spoofing

```bash
# Install
brew install terminal-notifier

# Usage
terminal-notifier -message "Hello" -title "Title" -open "https://example.com"
```

### Notification Limits

- Notifications appear in Notification Center
- Too many rapid notifications may be throttled by macOS
- Do Not Disturb mode suppresses notifications

### Exit Code Handling (done subcommand)

The `done` subcommand should:

1. Run the specified command
2. Capture stdout, stderr, and exit code
3. Send notification with success/failure status
4. Include exit code in notification message

```bash
# Success notification
"✓ Command completed (exit: 0)"

# Failure notification  
"✗ Command failed (exit: 1)"
```

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc notify --help            # displays usage

# Subcommand validation
fc notify unknown           # returns error for unknown subcommand

# Note: Testing actual notifications is difficult in CI
# Focus on argument parsing and error handling
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Simple notification | `fc notify send "Test"` | Notification appears in corner |
| With title | `fc notify send "Msg" --title "Test"` | Title shows in notification |
| With sound | `fc notify send "Alert" --sound "Glass"` | Sound plays with notification |
| Done success | `fc notify done "echo hello"` | Success notification after command |
| Done failure | `fc notify done "exit 1"` | Failure notification with exit code |
| Invalid sound | `fc notify send "Test" --sound "Invalid"` | Warning about invalid sound name |

### Edge Cases

- Empty message
- Very long message text
- Special characters in message
- Command with quotes in `done` subcommand
- Do Not Disturb mode active
