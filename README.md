<div align="center">

# 🎪 Dotfiles Flying Circus

### *Your Mac, Automated.*

**Transform a fresh Mac into a fully configured powerhouse with one command.**

[![Version](https://img.shields.io/badge/Version-1.6.0-blue)](CHANGELOG.md)
[![macOS](https://img.shields.io/badge/macOS-Sequoia%20%7C%20Sonoma%20%7C%20Ventura-blue?logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Fedora%20%7C%20Arch-FCC624?logo=linux&logoColor=black)](docs/CROSS_PLATFORM.md)
[![Shell](https://img.shields.io/badge/Shell-Zsh%20%2B%20Oh%20My%20Zsh-4EAA25?logo=gnu-bash&logoColor=white)](https://ohmyz.sh/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

[**Features**](#-features) •
[**Quick Start**](#-quick-start) •
[**Commands**](#-the-fc-command) •
[**Security**](#-security-hardening) •
[**Documentation**](#-documentation) •
[**Contributing**](#-contributing)

</div>

---

## 🚀 What Is This?

The **Dotfiles Flying Circus** is a comprehensive macOS (and Linux!) automation framework that:

- 🔧 **Configures everything** — 55+ defaults scripts covering system, interface, accessibility, and apps
- 🛡️ **Security controls** — hardening against privilege escalation, command injection and untrusted code, with each control's status stated plainly ([see the table](#-security-hardening))
- 🔐 **Hardens your Mac** — Firewall, FileVault, privacy permissions, APFS snapshots, and security audits
- 📦 **Installs your tools** — Homebrew packages, casks, and App Store apps with verified taps
- 🎯 **Role-based setup** — Different configs for `developer`, `personal`, or `work` machines
- 💾 **Encrypted backups** — Multiple backends: GPG, Restic, Borg with remote sync via rclone
- 🔑 **Secrets management** — 1Password, macOS Keychain, and HashiCorp Vault integration
- 🐧 **Cross-platform** — Full Linux support (Ubuntu, Fedora, Arch) with OS abstraction layer

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   $ ./install.sh --role developer --privacy-profile lockdown            │
│                                                                         │
│   ✓ Homebrew installed                                                  │
│   ✓ 47 packages installed                                               │
│   ✓ System preferences configured                                       │
│   ✓ Security hardening complete                                         │
│   ✓ Shell environment ready                                             │
│                                                                         │
│   🎉 Your Mac is ready!                                                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🆕 What's New in v1.6 — *The Security & Architecture Release*

<details open>
<summary><strong>🛡️ Complete Security Framework (30 Features)</strong></summary>

This release introduces a security hardening library (`lib/security.sh`) covering 6 categories. Some controls are wired in by default and some are available but not yet called — the [Security Hardening](#-security-hardening) table gives the status of each:

| Category | Features | Highlights |
|----------|----------|------------|
| **Input Validation** | S01-S05 | Path traversal guard, YAML injection prevention, command injection filter, URL validation, package name allowlist |
| **Privilege Protection** | S06-S10 | Sudo audit logging, confirmation prompts, privilege drop, sudoers integrity check, root execution block |
| **File System Security** | S11-S15 | Secure temp files (0600), symlink attack prevention, config permission checks, backup encryption, secure delete |
| **Integrity & Authenticity** | S16-S20 | Config file signing (GPG), script integrity hashes, Homebrew tap verification, self-update signature check, rollback verification |
| **Monitoring & Detection** | S21-S25 | Security event logging, config change detection, failed operation alerting, startup security checks, periodic health reports |
| **Network Security** | S26-S30 | Remote URL allowlist, TLS certificate pinning, network request logging, firewall rule auditor, DNS leak detection |

</details>

<details>
<summary><strong>🔧 7 New FC Commands</strong></summary>

| Command | Description |
|---------|-------------|
| `fc uninstall` | Complete app removal (bundle, preferences, caches, containers) |
| `fc theme` | Shell theme management with dark/light themes |
| `fc network` | Network diagnostics (status, diag, latency, DNS, port check) |
| `fc docker` | Docker cleanup utility with resource management |
| `fc desktop` | Desktop organizer (archive, organize by type, undo) |
| `fc history` | Enhanced shell history search with fzf integration |
| `fc scaffold` | Project scaffolding with template variable substitution |

**Plus enhanced commands:**
- `fc firewall` — Granular per-app rules, stealth mode, block-all mode
- `fc focus` — Distraction-free work sessions with website blocking
- `fc snapshot` — APFS snapshot management for safe rollbacks
- `fc config-audit` — Configuration drift detection

</details>

<details>
<summary><strong>⚡ Infrastructure Improvements</strong></summary>

- **Declarative YAML Configuration** — `fc config` with `apply`, `validate`, `show` commands
- **APFS Snapshot Integration** — Automatic snapshots before major changes
- **Cross-Platform Linux Support** — Ubuntu, Fedora, Arch with OS abstraction layer
- **40+ FC Commands** — Comprehensive system control suite
- **55+ macOS Defaults Scripts** — Complete system customization

</details>

<details>
<summary><strong>📦 Previous Releases (v1.0-v1.5)</strong></summary>

### v1.5: Documentation & Defaults
- New `fc defaults` plugin with 42 curated macOS tweaks
- Complete documentation for all 40+ defaults scripts
- AppleScript reference with 31 copy-paste ready scripts

### v1.4: Role-Specific Settings
- 12 new role-specific configuration files
- Developer: Docker, databases, testing, Kubernetes aliases
- Work: Calendar, Slack, Zoom, Atlassian tools
- Personal: Gaming, media, relaxed security

### v1.3: macOS Defaults Expansion
- 24 new application defaults scripts
- 50+ new settings across 15 scripts
- Privacy and lockdown profile enhancements

### v1.2: System Defaults
- 11 new system and interface defaults scripts
- Spotlight, Sharing, AirDrop, Network, Siri, Focus Modes

### v1.1: Alfred & Raycast Integration
- `fc alfred` with 12 keyword triggers
- `fc raycast` with 27 script commands
- VM management with Lima/Colima support

### v1.0: Initial Release
- 30+ fc commands with plugin architecture
- Role-based installation (developer, personal, work)
- Multiple backup backends (GPG, Restic, Borg)
- Secrets management (1Password, Keychain, Vault)

</details>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🛠️ System Configuration (55+ Scripts)
- **System**: Privacy, energy, sound, Bluetooth, login
- **Interface**: Dock, Finder, menu bar, Control Center
- **Input**: Keyboard, trackpad, gestures
- **Accessibility**: Display, pointer, zoom
- **Apps**: Safari, Mail, Chrome, Slack, Xcode, and 30+ more

</td>
<td width="50%">

### 🛡️ Enterprise Security (30 Features)
- Input validation & command injection protection
- Privilege escalation prevention
- Secure temp files & symlink attack guards
- Config signing & script integrity verification
- Security event logging & anomaly detection
- TLS certificate pinning & DNS leak checks

</td>
</tr>
<tr>
<td width="50%">

### 📦 Package Management
- Homebrew formulae & casks with verified taps
- Mac App Store apps (via `mas`)
- Role-specific Brewfiles (140+ packages)
- Automatic dependency updates
- Orphaned package cleanup

</td>
<td width="50%">

### 🐚 Shell Environment (21 env files)
- Oh My Zsh with custom `circus` plugin
- Language configs: Python, Node, Go, Rust, Java
- DevOps: Docker, Kubernetes, AWS/GCP/Azure
- XDG directory compliance
- 100+ role-based aliases

</td>
</tr>
<tr>
<td width="50%">

### 💾 Backup & Sync
- **3 backends**: GPG, Restic, Borg
- Remote sync via rclone (40+ providers)
- APFS snapshots for instant rollback
- VS Code settings sync
- Encrypted backups with secure delete

</td>
<td width="50%">

### 🎯 Role-Based Setup
- **Developer**: Git aliases, debugging, Xcode, Docker
- **Personal**: Media tools, gaming, relaxed security
- **Work**: Corporate proxy/VPN, Slack, Zoom, Jira
- **Secrets**: 1Password, Keychain, Vault

</td>
</tr>
</table>

---

## 🏃 Quick Start

### One-Line Install

```bash
git clone https://github.com/southpawriter02/circus.git && cd circus && ./install.sh
```

### With Options

```bash
# Developer setup with enhanced privacy
./install.sh --role developer --privacy-profile privacy

# Personal machine with maximum security
./install.sh --role personal --privacy-profile lockdown

# Work machine with standard settings
./install.sh --role work
```

---

## 🎮 The `fc` Command

The heart of the project is the `fc` (Flying Circus) command-line utility — **40+ commands** to control every aspect of your Mac:

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  fc <command> [action]                                                         │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                │
│  NETWORK          SECURITY          SYSTEM           PRODUCTIVITY             │
│  ───────          ────────          ──────           ────────────              │
│  wifi             audit             disk             caffeine                  │
│  bluetooth        firewall          info             clipboard                 │
│  dns              lock              update           backup                    │
│  airdrop          encrypt           maintenance      sync                      │
│  network          keychain          healthcheck      schedule                  │
│                   privacy           snapshot         vscode-sync               │
│                   focus             timemachine      desktop                   │
│                                                                                │
│  CONFIGURATION    HARDWARE          DEVELOPMENT      MANAGEMENT               │
│  ─────────────    ────────          ───────────      ──────────                │
│  config           power             gpg-setup        dotfiles                  │
│  config-audit     audio             ssh              apps                      │
│  defaults         display           docker           profile                   │
│  app-settings     vm                scaffold         uninstall                 │
│                                     history          theme                     │
│                                                                                │
│  INTEGRATIONS     BOOTSTRAP                                                    │
│  ────────────     ─────────                                                    │
│  alfred           bootstrap                                                    │
│  raycast          secrets                                                      │
│  applescript      clean                                                        │
│  notify                                                                        │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Command Highlights

```bash
# 🔒 Run a security audit
fc audit run
# Output: Checks SIP, FileVault, Gatekeeper, Firewall... gives you a score!

# 📊 Analyze disk usage
fc disk usage ~/Downloads
fc disk cleanup  # Interactive cleanup wizard

# 🔑 Generate SSH key (auto-adds to keychain, copies to clipboard)
fc ssh generate

# ☕ Keep Mac awake
fc caffeine on           # Indefinitely
fc caffeine for 60       # For 60 minutes

# 🌐 Switch DNS servers
fc dns set 1.1.1.1 1.0.0.1  # Cloudflare
fc dns set 8.8.8.8 8.8.4.4  # Google

# 💾 Encrypted backup with multiple backends
fc sync backup              # GPG-encrypted backup (default)
fc sync backup --backend restic  # Deduplicating backup
fc sync push                # Push to remote (S3, Dropbox, etc.)

# 🚀 Bootstrap a new machine
fc bootstrap                # Interactive setup wizard
fc bootstrap --phases all   # Full automated setup

# 🔑 Secrets management
fc secrets sync             # Sync secrets from 1Password/Keychain
fc secrets get op://vault/item/password  # Get specific secret

# 📸 APFS Snapshots for safe rollbacks (NEW in v1.6!)
fc snapshot create "before-update"  # Create snapshot
fc snapshot list                    # View all snapshots

# ⚙️ Declarative configuration (NEW in v1.6!)
fc config apply roles/developer/config.yaml  # Apply YAML config
fc config-audit                              # Detect configuration drift

# 🎯 Focus mode for productivity (NEW in v1.6!)
fc focus start 2h          # Start 2-hour focus session
fc focus status            # Check remaining time

# 🔌 Hardware control (NEW in v1.6!)
fc power switch battery-saver   # Switch power profile
fc audio volume 50              # Set volume to 50%
fc display save-layout work     # Save monitor arrangement
```

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph "Installation"
        A[install.sh] --> B[Role Selection]
        B --> C[Homebrew Setup]
        C --> D[System Defaults]
        D --> E[Security Hardening]
        E --> F[Shell Configuration]
    end

    subgraph "Daily Usage"
        G[fc command] --> H[40+ Plugins]
        H --> I[System Control]
        H --> J[Security Management]
        H --> K[Backup & Sync]
        H --> L[Secrets Management]
    end

    subgraph "Shell Environment"
        M[Oh My Zsh] --> N[circus plugin]
        N --> O[21 env files]
        N --> P[Role-based config]
    end

    subgraph "macOS Defaults"
        Q[55+ scripts] --> R[System]
        Q --> S[Interface]
        Q --> T[Apps]
        Q --> U[Accessibility]
    end

    subgraph "Security Layer"
        V[lib/security.sh] --> W[Input Validation]
        V --> X[Privilege Protection]
        V --> Y[Integrity Checking]
        V --> Z[Audit Logging]
    end
```

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| [📖 Commands Reference](COMMANDS.md) | Complete `fc` command documentation (40+ commands) |
| [🏛️ Architecture](ARCHITECTURE.md) | System design and philosophy |
| [👥 Roles Guide](ROLES.md) | Role-based installation explained |
| [🛡️ Security Hardening](ROADMAP.md#-security-hardening-priority-0---critical) | Security controls S01-S30, with per-control status |
| [🔐 Privacy Profiles](defaults/profiles/README.md) | Security profile options |
| [🔧 macOS Defaults](defaults/README.md) | 55+ defaults scripts documented |
| [💾 Backup Backends](docs/BACKUP_BACKENDS.md) | GPG, Restic, and Borg options |
| [🔑 Secrets Management](docs/SECRETS.md) | 1Password, Keychain, Vault integration |
| [🚀 Bootstrap Guide](docs/BOOTSTRAP.md) | New machine setup automation |
| [🌐 Cross-Platform](docs/CROSS_PLATFORM.md) | Linux support (Ubuntu, Fedora, Arch) |
| [🎩 Alfred Workflow](docs/ALFRED.md) | Alfred integration for quick access |
| [🔌 Creating Plugins](docs/CREATING_PLUGINS.md) | Extend `fc` with your own commands |
| [🎵 AppleScripts](docs/APPLESCRIPTS.md) | 31 ready-to-use automation scripts |
| [📝 YAML Configuration](docs/YAML_CONFIGURATION.md) | Declarative config system |
| [📋 All Documentation](docs/README.md) | Full documentation index |

---

## 🔒 Privacy Profiles

Choose your security level:

| Profile | Firewall | FileVault | Analytics | Siri | Location |
|---------|----------|-----------|-----------|------|----------|
| **Standard** | ✅ On | ✅ Enabled | ⚡ Limited | ✅ On | ⚡ Apps |
| **Privacy** | ✅ Stealth | ✅ Enabled | ❌ Off | ❌ Off | ⚡ System Only |
| **Lockdown** | ✅ Block All | ✅ Required | ❌ Off | ❌ Off | ❌ Off |

---

## 🛡️ Security Hardening

`lib/security.sh` implements a set of hardening controls. **Not all of them are
active**, and the table below says which is which — a control that looks enabled
but isn't is worse than one you know you have to turn on.

| Status | Meaning |
|--------|---------|
| ✅ **Active** | Wired into the code paths that need it. You get this by default. |
| 🔌 **Available** | Implemented and tested, but not called from anywhere yet. Opt in by calling it, or wire it into your own scripts. |
| ⚠️ **Limited** | Present, but does not deliver what its name suggests. Read the note before relying on it. |

<details>
<summary><strong>Input Validation & Sanitization (S01-S05)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Path Traversal Guard** | ✅ Active | Resolves paths physically (so intermediate symlinks cannot escape), rejects control characters, and enforces an allowlist on component boundaries. Used by `fc config` and `fc config-audit`. |
| **YAML Injection Prevention** | ✅ Active | Generated shell (`~/.aliases.local`, `~/.zshenv.local`) is emitted with `printf %q` and identifier-checked names, so a YAML value cannot become code. |
| **Command Injection Filter** | ⚠️ Limited | `sanitize_string` is a denylist and is bypassable (removed tokens can be reassembled). Do not rely on it as a boundary — quote with `printf %q` instead. |
| **URL Validation** | 🔌 Available | `validate_url` enforces an `https://` scheme and a well-formed host. |
| **Package Name Allowlist** | ✅ Active | brew/cask/mas names from YAML are validated before use. |

</details>

<details>
<summary><strong>Privilege Escalation Protection (S06-S10)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Sudo Audit Logging** | ⚠️ Limited | `sudo_audit` logs the commands it wraps, but only a handful of the framework's `sudo` calls go through it. Most do not appear in the audit log. |
| **Sudo Prompt Confirmation** | 🔌 Available | `sudo_confirm` prompts for destructive commands. Its pattern list is a denylist — it catches `rm -rf` but not `rm -fr`. |
| **Privilege Drop After Use** | 🔌 Available | `sudo_drop` invalidates the cached credential. Note `sudo -k` affects the whole terminal session, not just the script. |
| **sudoers Integrity Check** | 🔌 Available | Hashes `/etc/sudoers` and `/etc/sudoers.d/*` and compares against a saved baseline. Requires a sudo credential and **fails closed** without one. |
| **Root Execution Block** | ✅ Active | `fc` refuses to run as root. |

</details>

<details>
<summary><strong>File System Security (S11-S15)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Secure Temp Files** | 🔌 Available | `secure_mktemp` creates 0600 files. Call it via `with_secure_temp`; the tracking array is not populated when it is used in a `$( )` subshell. |
| **Symlink Attack Prevention** | 🔌 Available | `safe_write_check` inspects the destination's parent before writing. |
| **Config File Permissions** | 🔌 Available | Warns when config files are group- or world-accessible. |
| **Backup Encryption** | ✅ Active | GPG, restic and borg backends all encrypt, and each **fails closed** on a missing key or passphrase rather than writing plaintext. |
| **Secure Delete for Secrets** | ⚠️ Limited | Overwrite-then-delete does **not** reliably destroy data on APFS: it is copy-on-write, so overwrites land on new blocks and the originals survive — and snapshots pin them. Treat this as `rm`, not as erasure. Use FileVault and destroy the key. |

</details>

<details>
<summary><strong>Integrity & Authenticity (S16-S20)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Config File Signing** | 🔌 Available (opt-in pinning) | `verify_config_signature` checks the signature via gpg's machine-readable status output. A bare `gpg --verify` succeeds for **any** key in your keyring, so set `CIRCUS_TRUSTED_SIGNING_FPR` to require *your* fingerprint; unset, this proves a file was signed, not who signed it. |
| **Script Integrity Hashes** | 🔌 Available | SHA-256 manifest over tracked scripts. Detects modification of known files; will not notice a newly added one. |
| **Homebrew Tap Verification** | ✅ Active | Brewfiles are scanned before `brew bundle` runs. Taps under the `homebrew/` org are trusted; anything else prompts. Tapping runs third-party formula code, so this is a real execution boundary. |
| **Self-Update Signature Check** | ✅ Active (opt-in) | `fc self-update` verifies the incoming commit with git's own `%G?`/`%GF`. Set `CIRCUS_TRUSTED_SIGNING_FPR` to a fingerprint to **enforce** it; unset, it warns that commits are unverified. |
| **Rollback Verification** | 🔌 Available | Confirms a snapshot exists before restoring. |

</details>

<details>
<summary><strong>Monitoring & Detection (S21-S25)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Security Event Logging** | ✅ Active | Structured logging to `~/.circus/`. Log files are created `0600` inside a `0700` directory, so they are not readable by other local users. |
| **Config Change Detection** | 🔌 Available | Compares tracked config files against a saved baseline. |
| **Failed Operation Alerting** | 🔌 Available | Counts failures in a category within a time window (default 10 minutes) and alerts past a threshold. |
| **Startup Security Checks** | 🔌 Available | Runs the audit set on demand; not invoked automatically at startup. |
| **Periodic Health Reports** | 🔌 Available | Generates a report when called; nothing schedules it. |

</details>

<details>
<summary><strong>Network Security (S26-S30)</strong></summary>

| Feature | Status | Description |
|---------|--------|-------------|
| **Remote URL Allowlist** | 🔌 Available | Host allowlist for downloads. Note it follows redirects without re-checking the final host. |
| **TLS Certificate Pinning** | ⚠️ Limited | Probes the certificate on a *separate* connection from the one that transfers data, and continues when OpenSSL is unavailable. It does not bind the transfer. Prefer `curl --pinnedpubkey`. |
| **Network Request Logging** | 🔌 Available | Logs requests made through `logged_curl`. URLs are recorded verbatim, so credentials in a URL would be written to disk. |
| **Firewall Rule Auditor** | 🔌 Available | Baselines and diffs firewall rules. |
| **DNS Leak Detection** | ⚠️ Limited | Compares the *configured* resolvers against a baseline. It cannot detect an actual leak (queries escaping a VPN, DoH inside a browser), and is macOS-only. |

</details>

**Installer transport.** Bootstrap installers (Homebrew, Oh My Zsh) are downloaded
to disk over pinned-HTTPS (`--proto '=https' --proto-redir '=https'`) and run from
a file rather than piped into a shell. Set `CIRCUS_HOMEBREW_INSTALLER_SHA256` or
`CIRCUS_OHMYZSH_INSTALLER_SHA256` to a digest to enforce a checksum — unset, the
observed digest is printed and the script runs unverified.

---

## 🔄 Machine Migration

Moving to a new Mac? Use the bootstrap command for a complete setup:

```bash
# On your OLD Mac
fc sync backup
fc sync push  # Push to cloud storage (optional)

# On your NEW Mac - Full automated setup
git clone https://github.com/southpawriter02/circus.git && cd circus
fc bootstrap  # Interactive wizard guides you through everything!

# Or step-by-step:
./install.sh --role developer
fc sync restore
# 🎉 You're back in business!
```

---

## 🤝 Contributing

Contributions are welcome! This project uses automated quality checks:

```bash
# Set up development environment
bin/setup-dev

# Pre-commit hooks run automatically:
# ✓ shellcheck - Lint shell scripts
# ✓ shfmt - Format shell scripts  
# ✓ bats - Run test suite
```

See the [Contributing Guide](CONTRIBUTING.md) for details.

---

## 🙏 Inspiration

Standing on the shoulders of giants:

- [Oh My Zsh](https://ohmyz.sh/) — Shell framework
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) — macOS defaults
- [Zach Holman's dotfiles](https://github.com/holman/dotfiles) — Modular approach
- [pre-commit](https://pre-commit.com/) — Git hooks framework

---

<div align="center">

**🎪 The Dotfiles Flying Circus**

*Because setting up a Mac should be fun, not work.*

Made with ☕ and 🎲 by [@southpawriter02](https://github.com/southpawriter02)

</div>
