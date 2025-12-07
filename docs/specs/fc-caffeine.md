# Feature Specification: `fc caffeine`

## Overview

**Command:** `fc caffeine`  
**Purpose:** Prevent the system from sleeping using the built-in `caffeinate` command.

### Use Cases
- Keep Mac awake during long downloads
- Prevent sleep during presentations
- Keep system active for background tasks
- Scripting and automation

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `on` | Prevent sleep indefinitely (background) |
| `off` | Allow system to sleep again |
| `for [min]` | Prevent sleep for specified minutes |
| `status` | Check if caffeine is active |

---

## Detailed Behaviors

### `fc caffeine on`

Prevent sleep indefinitely:

```
$ fc caffeine on

Preventing sleep indefinitely. Run 'fc caffeine off' to restore normal behavior.
✓ Caffeine is now ON.
```

**Implementation:**
- Runs `caffeinate -dis &` in background
- Saves PID to `~/.circus/caffeinate.pid`
- Flags: -d (display), -i (idle), -s (system)

---

### `fc caffeine off`

Allow normal sleep:

```
$ fc caffeine off

Allowing the system to sleep normally again...
✓ Caffeine is now OFF.
```

**Implementation:**
- Reads PID from saved file
- Kills the background caffeinate process
- Cleans up PID file

---

### `fc caffeine for [minutes]`

Prevent sleep for duration:

```
$ fc caffeine for 30

Preventing sleep for 30 minutes...
✓ Caffeine session completed after 30 minutes.
```

**Implementation:**
- Uses `caffeinate -dit <seconds>`
- Runs in foreground
- Exits automatically after timeout

---

### `fc caffeine status`

Check current state:

```
$ fc caffeine status

✓ Caffeine is ON (preventing sleep indefinitely). PID: 12345
```

**Implementation:**
- Checks for PID file existence
- Verifies process is still running
- Cleans up stale PID files

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `caffeinate` | macOS | Yes |

---

## Examples

```bash
# Keep awake until manually stopped
fc caffeine on

# Stop keeping awake
fc caffeine off

# Keep awake for 1 hour
fc caffeine for 60

# Keep awake for 15 minutes
fc caffeine for 15

# Check if active
fc caffeine status
```

---

## Implementation Notes

### caffeinate Flags

| Flag | Description |
|------|-------------|
| `-d` | Prevent display from sleeping |
| `-i` | Prevent system idle sleep |
| `-s` | Prevent system sleep (AC power) |
| `-t <sec>` | Timeout in seconds |

### State Management

State is tracked via a PID file:
- Location: `~/.circus/caffeinate.pid`
- Contains the background process ID
- Automatically cleaned up on `off` or stale detection

### Permissions

No administrator privileges required.

### Related Tools

```bash
# Show power settings
pmset -g

# Show why system is awake
pmset -g assertions

# Native caffeinate usage
caffeinate -t 3600  # Keep awake for 1 hour
```

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
fc caffeine --help      # displays usage
fc caffeine unknown     # returns error
fc caffeine status      # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| On | `fc caffeine on` | System doesn't sleep |
| Off | `fc caffeine off` | Normal sleep restored |
| For | `fc caffeine for 1` | Awake for 1 minute |
| Status on | Enable, check status | Shows ON with PID |
| Status off | Disable, check status | Shows OFF |
| Double on | Run `on` twice | Warning message |
