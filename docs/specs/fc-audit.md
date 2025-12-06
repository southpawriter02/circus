# Feature Specification: `fc audit`

## Overview

**Command:** `fc audit`  
**Purpose:** Run a security audit to check system protection settings.

### Use Cases
- Verify security features are enabled
- Check for potential vulnerabilities
- Prepare for security compliance
- Validate system hardening

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `run` | Run full security audit |
| `quick` | Quick check of critical settings |
| `sip` | Check System Integrity Protection |
| `filevault` | Check FileVault encryption status |
| `gatekeeper` | Check Gatekeeper status |
| `firewall` | Check firewall status |

---

## Detailed Behaviors

### `fc audit run`

Run comprehensive audit:

```
$ fc audit run

🔒 macOS Security Audit

System Protection:
  ✓ System Integrity Protection (SIP)     Enabled
  ✓ FileVault Disk Encryption             Enabled
  ✓ Gatekeeper                            Enabled
  ✓ Application Firewall                  Enabled

Authentication:
  ✓ Password Required After Sleep         Yes
  ⚠ Automatic Login                       Enabled (risky)
  ✓ Firmware Password                     Not Set

Network:
  ✓ Firewall Stealth Mode                 Enabled
  ⚠ Remote Login (SSH)                    Enabled
  ⚠ Remote Management                     Enabled

Privacy:
  ✓ Location Services                     Limited
  ⚠ Analytics Sharing                     Enabled

──────────────────────────────────────────
Score: 8/12 checks passed
Recommendations: 4 items need attention
```

**Implementation:**
- Check each security setting
- Categorize findings
- Provide score and recommendations

---

### `fc audit quick`

Quick critical checks:

```
$ fc audit quick

Quick Security Check:
  SIP:        ✓ Enabled
  FileVault:  ✓ Enabled
  Gatekeeper: ✓ Enabled
  Firewall:   ✓ Enabled

All critical protections active ✓
```

---

### `fc audit sip`

Check SIP status:

```
$ fc audit sip

System Integrity Protection: Enabled ✓

SIP protects:
  • /System
  • /usr (except /usr/local)
  • /bin, /sbin
  • Preinstalled apps
```

**Implementation:**
- Use `csrutil status`
- Explain what SIP protects

---

### `fc audit filevault`

Check encryption:

```
$ fc audit filevault

FileVault Status: Enabled ✓

  Encryption:    Fully Encrypted
  Users:         2 enabled users
  Recovery Key:  Escrowed to iCloud
```

**Implementation:**
- Use `fdesetup status`
- Check `fdesetup list` for users

---

## Security Checks Included

| Check | Command | Safe State |
|-------|---------|------------|
| SIP | `csrutil status` | Enabled |
| FileVault | `fdesetup status` | On |
| Gatekeeper | `spctl --status` | assessments enabled |
| Firewall | `socketfilterfw --getglobalstate` | Enabled |
| Stealth Mode | `socketfilterfw --getstealthmode` | Enabled |
| Auto Login | `defaults read .../loginwindow` | Disabled |
| Remote Login | `systemsetup -getremotelogin` | Off |
| Password Hint | `defaults read` | Disabled |

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `csrutil` | macOS | Yes |
| `fdesetup` | macOS | Yes |
| `spctl` | macOS | Yes |
| `systemsetup` | macOS | Yes (sudo) |

---

## Examples

```bash
# Full audit
fc audit run

# Quick check
fc audit quick

# Specific checks
fc audit sip
fc audit filevault
fc audit gatekeeper
```

---

## Testing Strategy

### Automated Tests
- `fc audit --help` displays usage
- `fc audit quick` runs without error

### Manual Verification
- Verify findings match System Settings
- Test on machine with known configuration
