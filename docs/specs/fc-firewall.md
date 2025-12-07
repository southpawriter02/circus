# Feature Specification: `fc firewall`

## Overview

**Command:** `fc firewall`  
**Purpose:** Manage the macOS application firewall from the command line.

### Use Cases
- Enable/disable the application firewall
- Check current firewall status
- Security management scripts
- Troubleshooting network connectivity

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `on` | Turn the application firewall on |
| `off` | Turn the application firewall off |
| `status` | Show current firewall state |

---

## Detailed Behaviors

### `fc firewall on`

Enable the firewall:

```
$ fc firewall on

Turning the firewall on...
Firewall is enabled. (State = 1)
✓ Firewall is now on.
```

**Implementation:**
- Uses `sudo socketfilterfw --setglobalstate on`
- Requires administrator privileges

---

### `fc firewall off`

Disable the firewall:

```
$ fc firewall off

Turning the firewall off...
Firewall is disabled. (State = 0)
✓ Firewall is now off.
```

**Implementation:**
- Uses `sudo socketfilterfw --setglobalstate off`
- Allows all incoming connections to applications

---

### `fc firewall status`

Check current status:

```
$ fc firewall status

Checking firewall status...
Firewall is enabled. (State = 1)
```

**Implementation:**
- Uses `sudo socketfilterfw --getglobalstate`

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `socketfilterfw` | macOS | Yes |
| `sudo` | macOS | Yes |

---

## Examples

```bash
# Enable firewall
fc firewall on

# Disable firewall
fc firewall off

# Check status
fc firewall status
```

---

## Implementation Notes

### macOS Application Firewall

The macOS firewall is an **application-level** firewall:
- Controls incoming connections to applications
- Does NOT filter outgoing connections
- Per-application rules can be configured

### Firewall Utility Location

```
/usr/libexec/ApplicationFirewall/socketfilterfw
```

### Additional socketfilterfw Options

```bash
# Block all incoming connections
sudo socketfilterfw --setblockall on

# Enable stealth mode (don't respond to pings)
sudo socketfilterfw --setstealthmode on

# Auto-allow signed apps
sudo socketfilterfw --setallowsigned on

# Add app to allowed list
sudo socketfilterfw --add /Applications/MyApp.app

# Remove app from allowed list
sudo socketfilterfw --remove /Applications/MyApp.app

# List apps in firewall settings
sudo socketfilterfw --listapps
```

### GUI Location

System Settings → Network → Firewall

### Permissions

All operations require administrator (sudo) privileges.

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
fc firewall --help       # displays usage
fc firewall unknown      # returns error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Enable | `fc firewall on` | Firewall enabled (State = 1) |
| Disable | `fc firewall off` | Firewall disabled (State = 0) |
| Status | `fc firewall status` | Shows current state |
| GUI verify | Check System Settings | Matches command output |
