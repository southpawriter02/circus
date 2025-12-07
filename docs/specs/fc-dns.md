# Feature Specification: `fc dns`

## Overview

**Command:** `fc dns`  
**Purpose:** Manage the system's DNS settings from the command line.

### Use Cases
- Switch between DNS providers (Google, Cloudflare, etc.)
- View current DNS configuration
- Troubleshoot DNS resolution issues
- Revert to DHCP-provided DNS

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `get` | Show current DNS servers |
| `status` | Alias for `get` |
| `set <ip>...` | Set custom DNS servers |
| `clear` | Clear custom DNS, revert to DHCP |

---

## Detailed Behaviors

### `fc dns get`

Show current DNS servers:

```
$ fc dns get

Active network service: Wi-Fi
Current DNS servers:
8.8.8.8
8.8.4.4
```

**Implementation:**
- Uses `networksetup -getdnsservers <service>`
- Automatically detects active network service

---

### `fc dns set <ip>...`

Set custom DNS servers:

```
$ fc dns set 1.1.1.1 1.0.0.1

Active network service: Wi-Fi
Setting DNS servers to: 1.1.1.1 1.0.0.1
✓ DNS servers have been updated.
```

**Implementation:**
- Uses `sudo networksetup -setdnsservers <service> <ip>...`
- Requires administrator password
- Multiple IPs provide redundancy

---

### `fc dns clear`

Revert to DHCP-provided DNS:

```
$ fc dns clear

Active network service: Wi-Fi
Clearing DNS servers...
✓ DNS servers have been cleared.
```

**Implementation:**
- Uses `sudo networksetup -setdnsservers <service> "Empty"`
- The keyword "Empty" clears custom DNS settings

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `networksetup` | macOS | Yes |
| `sudo` | macOS | Yes (for set/clear) |

---

## Examples

```bash
# View current DNS
fc dns get

# Use Google DNS
fc dns set 8.8.8.8 8.8.4.4

# Use Cloudflare DNS
fc dns set 1.1.1.1 1.0.0.1

# Use OpenDNS
fc dns set 208.67.222.222 208.67.220.220

# Use Quad9 (security-focused)
fc dns set 9.9.9.9 149.112.112.112

# Revert to DHCP DNS
fc dns clear
```

---

## Implementation Notes

### Popular DNS Providers

| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| Google | 8.8.8.8 | 8.8.4.4 | Fast, reliable |
| Cloudflare | 1.1.1.1 | 1.0.0.1 | Privacy-focused |
| OpenDNS | 208.67.222.222 | 208.67.220.220 | Family filters available |
| Quad9 | 9.9.9.9 | 149.112.112.112 | Security/malware blocking |

### Network Service Detection

The plugin auto-detects the active network service (Wi-Fi, Ethernet, etc.) to apply settings to the correct interface.

### Permissions

- `get`/`status`: No admin required
- `set`/`clear`: Requires sudo

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
fc dns --help        # displays usage
fc dns unknown       # returns error
fc dns get           # runs without error
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Get DNS | `fc dns get` | Shows DNS servers or "no servers set" |
| Set DNS | `fc dns set 8.8.8.8` | DNS updated (verify with `get`) |
| Multiple | `fc dns set 8.8.8.8 8.8.4.4` | Both servers set |
| Clear | `fc dns clear` | Reverts to DHCP DNS |
