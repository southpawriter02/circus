# Feature Specification: `fc bluetooth`

## Overview

**Command:** `fc bluetooth`  
**Purpose:** Manage the system's Bluetooth adapter from the command line.

### Use Cases
- Quickly toggle Bluetooth on/off
- Check current Bluetooth power status
- Scripting and automation
- Troubleshooting Bluetooth connectivity

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `on` | Turn Bluetooth adapter on |
| `off` | Turn Bluetooth adapter off |
| `status` | Show current Bluetooth power state |

---

## Detailed Behaviors

### `fc bluetooth on`

Turn on Bluetooth:

```
$ fc bluetooth on

Turning Bluetooth on...
✓ Bluetooth is now on.
```

**Implementation:**
- Uses `blueutil --power 1`
- Does not reconnect previously paired devices automatically

---

### `fc bluetooth off`

Turn off Bluetooth:

```
$ fc bluetooth off

Turning Bluetooth off...
✓ Bluetooth is now off.
```

**Implementation:**
- Uses `blueutil --power 0`
- Disconnects all connected Bluetooth devices

---

### `fc bluetooth status`

Check current status:

```
$ fc bluetooth status

Checking Bluetooth status...
✓ Bluetooth is currently on.
```

**Implementation:**
- Uses `blueutil --power`
- Returns 1 (on) or 0 (off)

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `blueutil` | Homebrew | Yes |

### Installation

```bash
brew install blueutil
```

---

## Examples

```bash
# Enable Bluetooth
fc bluetooth on

# Disable Bluetooth
fc bluetooth off

# Check current state
fc bluetooth status
```

---

## Implementation Notes

### blueutil Tool

`blueutil` is a third-party command-line tool for Bluetooth control:
- GitHub: https://github.com/toy/blueutil
- Homebrew: `brew install blueutil`

### Additional blueutil Features

The tool supports more features not exposed by this command:
```bash
blueutil --info                    # Show Bluetooth info
blueutil --paired                  # List paired devices
blueutil --connect <address>       # Connect to device
blueutil --disconnect <address>    # Disconnect device
```

### Permissions

No administrator privileges required.

### macOS Features Requiring Bluetooth

- Handoff and Continuity
- AirDrop
- Apple Watch unlock
- Wireless keyboards/mice/trackpads
- AirPods and other Bluetooth audio

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
fc bluetooth --help      # displays usage
fc bluetooth unknown     # returns error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Turn on | `fc bluetooth on` | Bluetooth enabled |
| Turn off | `fc bluetooth off` | Bluetooth disabled |
| Status on | Enable, `fc bluetooth status` | Shows "on" |
| Status off | Disable, `fc bluetooth status` | Shows "off" |
| Dependency | Uninstall blueutil, run command | Clear error message |
