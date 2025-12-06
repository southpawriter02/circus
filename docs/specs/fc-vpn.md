# Feature Specification: `fc vpn`

## Overview

**Command:** `fc vpn`  
**Purpose:** Manage VPN connections configured in macOS Network Preferences.

### Use Cases
- Quick connect/disconnect to VPN services
- List available VPN configurations
- Check current VPN connection status
- Toggle VPN without opening System Preferences

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show current VPN connection status |
| `list` | List all configured VPN services |
| `connect [name]` | Connect to a VPN service |
| `disconnect [name]` | Disconnect from a VPN service |
| `toggle [name]` | Toggle VPN connection state |

---

## Detailed Behaviors

### `fc vpn status`

Display VPN connection status:

```
$ fc vpn status

VPN Status:
  Service:    Work VPN
  State:      Connected ✓
  IP:         10.0.1.42
  Duration:   2h 15m

Server: vpn.company.com
```

**Implementation:**
- Use `scutil --nc list` to find active VPN
- Use `scutil --nc status <name>` for details
- Parse connected state and assigned IP

---

### `fc vpn list`

List all configured VPNs:

```
$ fc vpn list

Configured VPNs:
  Name              Type          Status
  Work VPN          IKEv2         Connected ✓
  Home Server       L2TP/IPSec    Disconnected
  Cloud Access      Cisco IPSec   Disconnected
```

**Implementation:**
- Use `scutil --nc list` to enumerate services
- Parse VPN type from configuration
- Show connection state for each

---

### `fc vpn connect [name]`

Connect to VPN:

```
$ fc vpn connect "Work VPN"

Connecting to Work VPN...
Status: Connected ✓

Assigned IP: 10.0.1.42
```

**Implementation:**
- Use `scutil --nc start <name>` to connect
- Wait for connection with timeout
- Display assigned IP on success
- Handle authentication prompts (may trigger Keychain)

---

### `fc vpn disconnect [name]`

Disconnect from VPN:

```
$ fc vpn disconnect "Work VPN"

Disconnecting from Work VPN...
Status: Disconnected

Session duration was 2h 15m
```

**Implementation:**
- Use `scutil --nc stop <name>` to disconnect
- If no name provided, disconnect active VPN
- Show session duration on disconnect

---

### `fc vpn toggle [name]`

Toggle VPN state:

```
$ fc vpn toggle "Work VPN"

Work VPN is currently connected.
Disconnecting...

Status: Disconnected
```

**Implementation:**
- Check current state with `scutil --nc status`
- Connect if disconnected, disconnect if connected
- If no name and only one VPN, use that one

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `scutil` | macOS | Yes |
| `networksetup` | macOS | Yes |

---

## Implementation Notes

### VPN Types Supported
- IKEv2 (native macOS)
- L2TP/IPSec
- Cisco IPSec
- Note: Third-party VPN apps (Tunnelblick, OpenVPN, etc.) not managed by this tool

### Authentication
- Keychain credentials used automatically if saved
- May prompt for password if not saved
- MFA/2FA handled by macOS natively

### Edge Cases
- Handle spaces in VPN names (quote properly)
- Timeout after 30s if connection stalls
- Show "No VPNs configured" if list is empty

### Name Matching
- Support partial name matching: `fc vpn connect work` matches "Work VPN"
- Case-insensitive matching
- Error if multiple matches found

---

## Examples

```bash
# Check VPN status
fc vpn status

# List all VPNs
fc vpn list

# Connect by name
fc vpn connect "Work VPN"

# Partial name matching
fc vpn connect work

# Disconnect active VPN
fc vpn disconnect

# Toggle VPN
fc vpn toggle
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc vpn --help` displays usage
- `fc vpn list` runs without error
- `fc vpn status` runs without error
- Unknown subcommand returns error

### Manual Verification
- Test with actual VPN configuration
- Verify connect/disconnect works
- Test partial name matching
- Check behavior with no VPNs configured
