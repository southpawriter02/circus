# Feature Specification: `fc kill`

## Overview

**Command:** `fc kill`  
**Purpose:** Force quit unresponsive applications or terminate processes.

### Use Cases
- Force quit frozen applications
- Kill processes by name or PID
- Find and kill processes using a specific port
- List processes for a given user

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `app [name]` | Force quit an application by name |
| `pid [pid]` | Kill a process by PID |
| `port [port]` | Kill process using a specific port |
| `name [process]` | Kill all processes matching a name |
| `list [query]` | List running processes matching query |

---

## Detailed Behaviors

### `fc kill app [name]`

Force quit a macOS application:

```
$ fc kill app "Google Chrome"

Force quitting Google Chrome...
✓ Google Chrome has been terminated
```

**Implementation:**
- Use `osascript -e 'tell application "AppName" to quit'` first (graceful)
- Fall back to `killall "AppName"` if needed
- Accept `--force` to skip graceful quit

---

### `fc kill pid [pid]`

Kill by process ID:

```
$ fc kill pid 1234

Killing process 1234 (node)...
✓ Process 1234 has been terminated
```

**Implementation:**
- Use `kill <pid>` (SIGTERM)
- Accept `--force`/`-9` for SIGKILL
- Verify PID exists before attempting

---

### `fc kill port [port]`

Kill process using a port:

```
$ fc kill port 3000

Finding process on port 3000...
  PID 5678: node (npm start)

Kill this process? [y/N] y

✓ Process 5678 has been terminated
Port 3000 is now free
```

**Implementation:**
- Use `lsof -ti:PORT` to find PID
- Show process info before killing
- Require confirmation (bypass with `--yes`)

---

### `fc kill name [process]`

Kill all matching processes:

```
$ fc kill name node

Found 3 processes matching "node":
  PID 1234: node /app/server.js
  PID 5678: node /app/worker.js
  PID 9012: node /scripts/build.js

Kill all 3 processes? [y/N] y

✓ Killed 3 processes
```

**Implementation:**
- Use `pgrep -l pattern` to find matches
- Require confirmation for multiple kills
- Use `pkill pattern` to kill all

---

### `fc kill list [query]`

List running processes:

```
$ fc kill list chrome

Running processes matching "chrome":

  PID     CPU%    MEM     Command
  1234    15.2%   1.2GB   Google Chrome
  2345    8.1%    450MB   Google Chrome Helper
  3456    2.3%    120MB   Google Chrome Helper (GPU)
```

**Implementation:**
- Use `ps aux | grep pattern`
- Format nicely with CPU/memory usage
- Show parent process info with `--tree`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `kill` | macOS | Yes |
| `killall` | macOS | Yes |
| `pkill` | macOS | Yes |
| `pgrep` | macOS | Yes |
| `lsof` | macOS | Yes |
| `osascript` | macOS | Yes |

---

## Implementation Notes

### Signal Levels
- Default: SIGTERM (15) - graceful termination
- `--force`: SIGKILL (9) - immediate termination
- Apps should be given chance to save work

### Safety Features
- Require confirmation for multiple process kills
- Show process details before killing
- Prevent killing critical system processes
- Cannot kill processes owned by root without sudo

### Protected Processes
- Warn if trying to kill: Finder, loginwindow, kernel_task
- These may require reboot to restart

---

## Examples

```bash
# Force quit frozen app
fc kill app Safari

# Kill by PID
fc kill pid 1234

# Force kill (SIGKILL)
fc kill pid 1234 --force

# Free up a port
fc kill port 8080

# Kill all node processes
fc kill name node --yes

# List processes
fc kill list python
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc kill --help` displays usage
- `fc kill list` runs without error
- `fc kill port` handles unused ports gracefully
- Unknown subcommand returns error

### Manual Verification
- Test force quit on actual frozen app
- Test port killing with dev server
- Verify confirmation prompts work
- Test protected process warnings
