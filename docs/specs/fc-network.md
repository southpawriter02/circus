# Feature Specification: `fc network`

## Overview

**Command:** `fc network`  
**Purpose:** Network diagnostics and monitoring—IP info, connectivity tests, port scanning, and speed tests.

### Use Cases
- Quick check of IP addresses and network interfaces
- Test Internet connectivity and DNS resolution
- Scan for open ports on local or remote hosts
- Run a basic speed test

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show IP addresses, gateway, and DNS servers |
| `interfaces` | List all network interfaces with status |
| `ping [host]` | Ping a host (default: 8.8.8.8) |
| `dns [domain]` | Look up DNS records for a domain |
| `ports [host]` | Scan common ports on a host (default: localhost) |
| `speed` | Run a basic speed test |

---

## Detailed Behaviors

### `fc network status`

Display network overview:

```
$ fc network status

Network Status:
  External IP:    203.0.113.42
  Internal IP:    192.168.1.105
  Gateway:        192.168.1.1
  DNS Servers:    8.8.8.8, 8.8.4.4
  
Interface:      en0 (Wi-Fi)
Status:         Connected ✓
```

**Implementation:**
- Use `ifconfig` for internal IP
- Use `route -n get default | grep gateway` for gateway
- Use `scutil --dns | grep nameserver` for DNS
- Use `curl -s ifconfig.me` for external IP (with timeout)

---

### `fc network interfaces`

List all network interfaces:

```
$ fc network interfaces

Interface    Type        Status      IP Address
en0          Wi-Fi       Active      192.168.1.105
en1          Ethernet    Inactive    --
lo0          Loopback    Active      127.0.0.1
bridge0      Bridge      Inactive    --
```

**Implementation:**
- Parse `ifconfig -a` output
- Show MAC addresses with `--verbose` flag

---

### `fc network ping [host]`

Enhanced ping with summary:

```
$ fc network ping google.com

Pinging google.com (142.250.80.14)...

  Sent: 5  |  Received: 5  |  Lost: 0 (0%)
  Min: 12ms  |  Avg: 15ms  |  Max: 22ms

Status: Excellent ✓
```

**Implementation:**
- Use `ping -c 5` for 5 packets
- Parse statistics and provide assessment
- Default to 8.8.8.8 if no host provided

---

### `fc network dns [domain]`

Look up DNS records:

```
$ fc network dns example.com

DNS Records for example.com:
  A:      93.184.216.34
  AAAA:   2606:2800:220:1:248:1893:25c8:1946
  MX:     mail.example.com (10)
  NS:     a.iana-servers.net
  TXT:    "v=spf1 -all"
```

**Implementation:**
- Use `dig` or `nslookup` for DNS queries
- Query A, AAAA, MX, NS, TXT records
- Accept `--type` flag to query specific record type

---

### `fc network ports [host]`

Scan common ports:

```
$ fc network ports localhost

Port Scan: localhost (127.0.0.1)

  Port      Service         Status
  22        SSH             Open ✓
  80        HTTP            Closed
  443       HTTPS           Closed
  3000      Dev Server      Open ✓
  5432      PostgreSQL      Open ✓
  
Scanned 10 common ports in 2.3s
```

**Implementation:**
- Use `nc -z` (netcat) for port scanning
- Scan common ports: 22, 80, 443, 3000, 3306, 5432, 6379, 8080, 8443, 9000
- Accept `--port` flag for specific port
- Accept `--all` for full 1-1024 range (slow)

---

### `fc network speed`

Run a basic speed test:

```
$ fc network speed

Speed Test (via fast.com or cloudflare):

  Download:  85.4 Mbps
  Upload:    23.1 Mbps
  Latency:   12 ms

Test completed in 15s
```

**Implementation:**
- Use `speedtest-cli` if installed (Homebrew)
- Fall back to `curl` timing to a known endpoint
- Show progress indicator during test

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `ifconfig` | macOS | Yes |
| `ping` | macOS | Yes |
| `dig` | macOS | Yes |
| `nc` (netcat) | macOS | Yes |
| `curl` | macOS | Yes |
| `scutil` | macOS | Yes |
| `route` | macOS | Yes |
| `speedtest-cli` | Homebrew | Optional |

---

## Implementation Notes

### External IP Detection
- Use multiple fallback services: ifconfig.me, ipinfo.io, icanhazip.com
- Set short timeout (3s) to avoid blocking
- Handle "offline" state gracefully

### Port Scanning Ethics
- Default to localhost only
- Add warning when scanning remote hosts
- Keep default port list small (privacy/legal)

### Speed Test Options
- Prefer speedtest-cli for accuracy
- Use curl timing as simple fallback
- Note that results are approximate

---

## Examples

```bash
# Network overview
fc network status

# List all interfaces
fc network interfaces --verbose

# Ping with custom host
fc network ping cloudflare.com

# DNS lookup
fc network dns github.com --type MX

# Scan ports on localhost
fc network ports

# Scan specific port on remote host
fc network ports example.com --port 443

# Run speed test
fc network speed
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc network --help` displays usage
- `fc network status` runs without error
- `fc network ping` works with default host
- Unknown subcommand returns error

### Manual Verification
- Verify IP addresses match System Preferences
- Test DNS lookup with various domains
- Test port scan on known services
- Compare speed test with web-based tests
