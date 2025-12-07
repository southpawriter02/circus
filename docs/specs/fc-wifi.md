# Feature Specification: `fc wifi`

## Overview

**Command:** `fc wifi`  
**Purpose:** Manage the system's Wi-Fi adapter from the command line.

### Use Cases
- Quickly toggle Wi-Fi on/off
- Check current Wi-Fi power status
- Scripting and automation of network control
- Troubleshooting network connectivity

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `on` | Turn Wi-Fi adapter on |
| `off` | Turn Wi-Fi adapter off |
| `status` | Show current Wi-Fi power state |

---

## Detailed Behaviors

### `fc wifi on`

Turn on Wi-Fi:

```
$ fc wifi on

Turning Wi-Fi on...
✓ Wi-Fi is now on.
```

**Implementation:**
- Uses `networksetup -setairportpower <device> on`
- Automatically detects the Wi-Fi hardware port (en0 or en1)
- Does not connect to a network, only powers on the adapter

---

### `fc wifi off`

Turn off Wi-Fi:

```
$ fc wifi off

Turning Wi-Fi off...
✓ Wi-Fi is now off.
```

**Implementation:**
- Uses `networksetup -setairportpower <device> off`
- Disconnects from any connected wireless network

---

### `fc wifi status`

Check current status:

```
$ fc wifi status

Checking Wi-Fi status...
Wi-Fi Power (en0): On
```

**Implementation:**
- Uses `networksetup -getairportpower <device>`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `networksetup` | macOS | Yes |

---

## Examples

```bash
# Enable Wi-Fi
fc wifi on

# Disable Wi-Fi
fc wifi off

# Check current state
fc wifi status
```

---

## Implementation Notes

### Hardware Port Detection

Wi-Fi interface names vary by Mac model:
- **en0**: Common on older Macs with built-in Wi-Fi
- **en1**: Common on newer Macs or when Ethernet is en0

The plugin dynamically detects the correct interface using:

```bash
networksetup -listallhardwareports | grep -A 1 'Wi-Fi' | awk '/Device:/{print $2}'
```

### Permissions

No administrator privileges required for Wi-Fi power control.

### Related Commands

For connecting to specific networks:
```bash
networksetup -setairportnetwork en0 "NetworkName" "password"
```

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
fc wifi --help         # displays usage
fc wifi unknown        # returns error
fc wifi status         # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Turn on | `fc wifi on` | Wi-Fi enabled |
| Turn off | `fc wifi off` | Wi-Fi disabled, networks disconnected |
| Status on | Enable Wi-Fi, `fc wifi status` | Shows "On" |
| Status off | Disable Wi-Fi, `fc wifi status` | Shows "Off" |
