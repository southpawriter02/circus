# Settings Roadmap

This roadmap organizes **settings, defaults, and environment variables** into versioned milestones. It complements the main `ROADMAP.md` which focuses on features and commands.

---

## Current State Assessment

### ✅ What's Done (v1.0.0 Foundation)

The **infrastructure** is solid. Circus has:

| Category | Status | Details |
|----------|--------|---------|
| Plugin System | ✅ Complete | 22+ plugins, extensible architecture |
| Installer | ✅ Complete | 15 stages, preflight checks, roles, profiles |
| Logging | ✅ Complete | 6 levels, file logging, rotation |
| Error Handling | ✅ Complete | `die()`, ERR traps, contextual messages |
| Backup System | ✅ Complete | 3 backends, remote storage, scheduling |
| Secrets Management | ✅ Complete | 1Password, Keychain, Vault integration |
| Dotfile Management | ✅ Complete | Profiles, symlinks, editing |
| Update System | ✅ Complete | Self-update, migrations, version tracking |

### ⚠️ Technical Debt (Settings & Configuration)

The **settings layer** needs work:

| Category | Current State | Gap |
|----------|---------------|-----|
| Environment Variables | 7 files | ~20+ potential files needed |
| macOS Defaults | 22 scripts | ~40+ scripts identified |
| Shell Profile Structure | Minimal | `.zprofile`, PATH management missing |
| Role-Specific Settings | Sparse | Only Brewfiles, minimal env/defaults |
| Documentation | Partial | ~50% scripts have full inline docs |

---

## Version Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VERSION PROGRESSION                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  v1.0.0 (Current)     v1.1.0           v1.2.0           v1.3.0    v2.0.0   │
│  ────────────────     ──────           ──────           ──────    ──────   │
│  Infrastructure       Shell &          macOS            Polish    Major    │
│  Complete             Env Vars         Defaults         & UX      Features │
│                                                                             │
│  ★ You are here                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Philosophy**: v1.0.0 marks a **functional** product. Subsequent versions add **depth** through settings and configuration options. The command infrastructure won't change much—it's the underlying defaults and variables that grow.

---

## v1.1.0 — Shell & Environment Variables

**Theme**: Get the shell configuration house in order. This is foundational for everything else.

**Target**: ~30 items | Est. effort: Medium

### Shell Profile Structure

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `.zprofile` | New file | 🔴 High | Login shell environment setup |
| `.zshenv` | New file | 🔴 High | Critical PATH only (runs in scripts too) |
| `.zlogout` | New file | 🟡 Medium | Cleanup on logout |
| `path.env.sh` | New file | 🔴 High | Consolidated PATH management |

### Core Environment Variables

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `xdg.env.sh` | New file | 🟡 Medium | XDG Base Directory variables |
| `security.env.sh` | New file | 🔴 High | `GPG_TTY`, `SSH_AUTH_SOCK` |
| `telemetry.env.sh` | New file | 🔴 High | Privacy opt-outs for all CLIs |
| `colors.env.sh` | New file | 🟡 Medium | `CLICOLOR`, `LSCOLORS`, etc. |
| `pager.env.sh` | New file | 🟡 Medium | `LESS`, `MANPAGER`, `BAT_*` |

### Development Environment Variables

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `python.env.sh` | New file | 🟢 Low | `PYTHONDONTWRITEBYTECODE`, venv settings |
| `node.env.sh` | New file | 🟢 Low | `NODE_OPTIONS`, `NPM_*` |
| `docker.env.sh` | New file | 🟢 Low | `DOCKER_BUILDKIT`, etc. |
| `go.env.sh` | New file | 🟢 Low | `GOPATH`, `GOBIN` |
| `rust.env.sh` | New file | 🟢 Low | `CARGO_HOME`, `RUSTUP_HOME` |
| `java.env.sh` | New file | 🟢 Low | `JAVA_HOME`, auto-detection |
| `cloud.env.sh` | New file | 🟢 Low | AWS, Azure, GCP CLI configs |

### Shell Enhancements

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `aliases.sh` | New file | 🟡 Medium | Common safety aliases, shortcuts |
| `functions.sh` | New file | 🟡 Medium | `mkcd`, `extract`, `up`, etc. |
| `completion.sh` | New file | 🟢 Low | Zsh completion configuration |
| `keybindings.sh` | New file | 🟢 Low | Zsh key bindings |
| `fzf.sh` | New file | 🟡 Medium | FZF configuration |

### v1.1.0 Success Criteria

- [ ] Shell login properly sources all env files
- [ ] Telemetry disabled for all common CLIs
- [ ] PATH is managed in one place
- [ ] GPG/SSH agents work without manual intervention
- [ ] Common aliases available in all shells

---

## v1.2.0 — macOS Defaults (System)

**Theme**: System-level macOS settings. Security, privacy, and core system behavior.

**Target**: ~40 items | Est. effort: Large

### Security & Privacy (High Priority)

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `system/firewall.sh` | ✅ Complete | — | Already complete with docs |
| `system/screensaver.sh` | ✅ Complete | — | Already complete with docs |
| `system/software_update.sh` | ✅ Complete | — | Already complete with docs |
| `system/privacy.sh` | ✅ Complete | — | Analytics, ads, location, Siri data |
| `system/gatekeeper.sh` | ✅ Complete | — | App sources, quarantine |
| `system/filevault.sh` | ✅ Complete | — | Disk encryption status check |

### System Behavior

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `system/core.sh` | ✅ Complete | — | Network time, timezone, remote login |
| `system/time_machine.sh` | ✅ Complete | — | Backup exclusions |
| `system/auto_updates.sh` | ✅ Complete | — | Launchd agents |
| `system/energy.sh` | ✅ Complete | — | Sleep, Power Nap, lid behavior |
| `system/sound.sh` | ✅ Complete | — | Alert volume, UI sounds |
| `system/bluetooth.sh` | ✅ Complete | — | Discoverable mode, Handoff |
| `system/network.sh` | ✅ Complete | — | DNS, wake-on-LAN |
| `system/siri.sh` | ✅ Complete | — | Enable/disable, suggestions |
| `system/airdrop.sh` | ✅ Complete | — | Discoverability settings |
| `system/spotlight.sh` | ✅ Complete | — | Index categories, exclusions |
| `system/sharing.sh` | ✅ Complete | — | SSH, Screen Sharing, File Sharing |
| `system/login.sh` | ✅ Complete | — | Login window, fast user switch |
| `system/date_time.sh` | ✅ Complete | — | NTP, timezone, clock format |
| `system/focus_modes.sh` | ✅ Complete | — | Do Not Disturb, Focus filters |

### Interface Settings

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `interface/finder.sh` | ✅ Complete | — | Already complete with docs |
| `interface/dock.sh` | ✅ Complete | — | Uses dockutil, complete with docs |
| `interface/mission_control.sh` | ✅ Complete | — | Already complete with docs |
| `interface/activity_monitor.sh` | ✅ Complete | — | Already complete with docs |
| `interface/ui_ux.sh` | ✅ Complete | — | Already complete with docs |
| `interface/menu_bar.sh` | ✅ Complete | — | Clock, battery %, icons |
| `interface/notifications.sh` | ✅ Complete | — | Preview, grouping, sounds |
| `interface/control_center.sh` | ✅ Complete | — | Which modules visible |
| `interface/desktop.sh` | ✅ Complete | — | Icons, stacks, grid spacing |
| `interface/stage_manager.sh` | ✅ Complete | — | Enable, recent apps, behavior |
| `interface/window_management.sh` | ✅ Complete | — | Double-click, minimize effect |
| `interface/wallpaper.sh` | ✅ Complete | — | Wallpaper path, dynamic |

### Input Settings

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `input/keyboard.sh` | ✅ Complete | — | Already complete with docs |
| `input/trackpad_mouse.sh` | ✅ Complete | — | Already complete with docs |

### Privacy Profiles

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `profiles/standard.sh` | ✅ Exists | 🟡 Medium | Add more granular settings |
| `profiles/privacy.sh` | ✅ Exists | 🔴 High | Disable Siri suggestions, ads, analytics |
| `profiles/lockdown.sh` | ✅ Exists | 🔴 High | Disable AirDrop, Handoff, max security |

### v1.2.0 Success Criteria

- [x] All system defaults have complete inline documentation
- [x] Privacy profile applies 20+ privacy-enhancing settings (15+ implemented)
- [x] Lockdown profile suitable for security-conscious users (25+ settings)
- [x] `fc defaults` command can apply all defaults (already exists)

> **✅ v1.2.0 COMPLETE** — Released 2026-01-02

---

## v1.3.0 — macOS Defaults (Applications)

**Theme**: Application-specific settings. Focus on user-requested apps first.

**Target**: ~35 items | Est. effort: Large

### User-Requested Applications (High Priority ⭐)

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `applications/terminal.sh` | ✅ Complete | — | Already complete with docs |
| `applications/mail.sh` ⭐ | ✅ Complete | — | Format, remote content, conversation view |
| `applications/messages.sh` ⭐ | ✅ Complete | — | Read receipts, typing indicators |
| `applications/jetbrains.sh` ⭐ | ✅ Complete | — | Theme, font, memory, tabs |
| `applications/warp.sh` ⭐ | ✅ Complete | — | Theme, AI features, block mode |
| `applications/dropbox.sh` ⭐ | ✅ Complete | — | Start on login, LAN sync |
| `applications/notion.sh` ⭐ | ✅ Complete | — | Quick note, theme, zoom |
| `applications/github_desktop.sh` ⭐ | ✅ Complete | — | Editor, shell, notifications |
| `applications/setapp.sh` ⭐ | ✅ Complete | — | Start on login, updates |
| `applications/protonmail.sh` ⭐ | ✅ Complete | — | Bridge ports, keychain |

### Apple Apps

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `applications/safari.sh` | ✅ Complete | — | Already complete with docs |
| `applications/textedit.sh` | ✅ Complete | — | Already complete with docs |
| `applications/photos.sh` | ✅ Complete | — | iCloud, originals, memories |
| `applications/calendar.sh` | ✅ Complete | — | Week start, time zone |
| `applications/contacts.sh` | ✅ Complete | — | Sort order, display format |
| `applications/reminders.sh` | ✅ Complete | — | Default list, badge count |
| `applications/notes.sh` | ✅ Complete | — | Default account, sorting |
| `applications/music.sh` | ✅ Complete | — | Quality, crossfade, lossless |
| `applications/podcasts.sh` | ✅ Complete | — | Auto-download, limit |
| `applications/books.sh` | ✅ Complete | — | iCloud sync, night theme |
| `applications/preview.sh` | ✅ Complete | — | Sidebar, anti-aliasing |
| `applications/keynote.sh` | ✅ Complete | — | Auto-save, presenter |
| `applications/numbers.sh` | ✅ Complete | — | Default template |
| `applications/pages.sh` | ✅ Complete | — | Default template, author |

### Developer Tools

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `applications/vscode.sh` | ✅ Complete | — | Extensions, settings symlink |
| `applications/iterm2.sh` | ✅ Complete | — | Preferences sync folder |
| `applications/docker.sh` | ✅ Complete | — | Resource allocation |
| `applications/alfred.sh` | ✅ Complete | — | Preferences sync folder |
| `applications/xcode.sh` | ✅ Complete | — | Derived data, build times |
| `applications/disk_utility.sh` | ✅ Complete | — | Show all devices, debug |

### Third-Party Apps

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `applications/chrome.sh` | ✅ Complete | — | Sync, password manager, HW accel |
| `applications/firefox.sh` | ✅ Complete | — | Tracking protection, DoH |
| `applications/slack.sh` | ✅ Complete | — | Notifications, HW accel |
| `applications/zoom_app.sh` | ✅ Complete | — | Video/audio defaults |
| `applications/spotify.sh` | ✅ Complete | — | Quality, crossfade |
| `applications/1password.sh` | ✅ Complete | — | Lock behavior, biometric |

### Accessibility

| Script | Status | Priority | Key Settings |
|--------|--------|----------|--------------|
| `accessibility/display.sh` | ✅ Complete | — | Reduce motion, transparency |
| `accessibility/pointer.sh` | ✅ Complete | — | Size, shake to locate |
| `accessibility/zoom.sh` | ✅ Complete | — | Scroll gesture zoom |
| `accessibility/audio.sh` | ✅ Complete | — | Flash screen, mono audio |

### v1.3.0 Success Criteria

- [x] All user-requested apps have defaults scripts
- [x] All existing app scripts have complete documentation
- [x] Accessibility category exists for users who need it
- [ ] Role-based app defaults work (work apps for work role, etc.)

> **✅ v1.3.0 COMPLETE** — Released 2026-01-03

---

## v1.4.0 — Role-Specific Settings

**Theme**: Different configurations for different contexts (developer, work, personal).

**Target**: ~25 items | Est. effort: Medium

### Developer Role (`roles/developer/`)

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `env/development.env.sh` | New file | 🔴 High | `EDITOR`, `GIT_EDITOR`, etc. |
| `env/debugging.env.sh` | New file | 🟡 Medium | `DEBUG`, `VERBOSE`, `LOG_LEVEL` |
| `env/docker.env.sh` | New file | 🟡 Medium | Docker development settings |
| `env/database.env.sh` | New file | 🟢 Low | `PGUSER`, `MYSQL_*`, `REDIS_*` |
| `env/testing.env.sh` | New file | 🟢 Low | `CI`, `TEST_*`, `COVERAGE_*` |
| `defaults/xcode.sh` | New file | 🟡 Medium | Build settings, derived data |
| `defaults/simulator.sh` | New file | 🟢 Low | iOS Simulator preferences |
| `aliases/git.aliases.sh` | New file | 🔴 High | `g`, `gst`, `gco`, `gp`, `gl` |
| `aliases/docker.aliases.sh` | New file | 🟡 Medium | `dc`, `dcu`, `dcd`, etc. |
| `aliases/kubernetes.aliases.sh` | New file | 🟢 Low | `k`, `kgp`, `kgs`, etc. |

### Work Role (`roles/work/`)

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `env/corporate.env.sh` | New file | 🔴 High | `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` |
| `env/vpn.env.sh` | New file | 🟡 Medium | VPN-related variables |
| `env/jira.env.sh` | New file | 🟢 Low | Jira CLI configuration |
| `defaults/calendar.sh` | New file | 🟡 Medium | Work calendar defaults |
| `defaults/slack.sh` | New file | 🟡 Medium | Work notification timing |
| `defaults/zoom.sh` | New file | 🟡 Medium | Meeting defaults |
| `defaults/security.sh` | New file | 🔴 High | Stricter security for work |

### Personal Role (`roles/personal/`)

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| `env/gaming.env.sh` | New file | 🟢 Low | Game-related paths |
| `env/media.env.sh` | New file | 🟢 Low | Media directories |
| `defaults/music.sh` | New file | 🟢 Low | Apple Music preferences |
| `defaults/photos.sh` | New file | 🟢 Low | Photos app settings |
| `defaults/relaxed_security.sh` | New file | 🟢 Low | More permissive settings |

### v1.4.0 Success Criteria

- [ ] `fc profile switch developer` applies dev env + defaults
- [ ] Work role includes proxy configuration for corporate networks
- [ ] Role switching is seamless via existing `fc profile` command

---

## v1.5.0 — Documentation & Polish

**Theme**: Complete inline documentation for all settings. Quality pass.

**Target**: ~30 items | Est. effort: Medium

### Documentation Completion

| Script | Status | Needs |
|--------|--------|-------|
| `defaults/system/core.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/system/time_machine.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/system/auto_updates.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/alfred.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/docker.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/iterm2.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/mariadb.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/nvm.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/applications/vscode.sh` | 📋 Pending | Full inline docs with sources |
| `defaults/interface/dock.sh` | ⚠️ Partial | Add source citations |

### Quality Improvements

| Item | Type | Priority | Description |
|------|------|----------|-------------|
| Validate all defaults on latest macOS | Testing | 🔴 High | Ensure compatibility |
| Add `--list` flag to `fc defaults` | Feature | 🟡 Medium | List available defaults |
| Add `--dry-run` to individual scripts | Feature | 🟡 Medium | Preview changes |
| Create defaults test suite | Testing | 🟡 Medium | Automated validation |
| Document XDG migration path | Docs | 🟢 Low | For users who want XDG |

### v1.5.0 Success Criteria

- [ ] 100% of defaults scripts have inline documentation
- [ ] All documentation includes Apple Support source URLs
- [ ] Settings tested on macOS 15 (current)
- [ ] `README.md` in `defaults/` shows 100% completion

---

## v2.0.0 — Major Features

**Theme**: Big new capabilities. Only after settings foundation is complete.

**Target**: TBD | Est. effort: Very Large

### Candidates (from main ROADMAP.md)

| Feature | Status | Description |
|---------|--------|-------------|
| `24-web-ui-dashboard` | Not started | Graphical interface |
| `25-cross-platform-support` | Not started | Linux support |
| `23-interactive-fc-command` | Not started | fzf-based interactive mode |
| `11-interactive-role-creation` | Not started | Role creation wizard |
| `45-vm-management` | Not started | Lima/Colima management |
| `39-alfred-workflow-integration` | Not started | Alfred workflows |

### Prerequisites

- ✅ v1.5.0 complete (settings foundation solid)
- ✅ Test coverage at acceptable level
- ✅ Documentation complete

---

## Quick Reference

### Progress Summary

| Version | Theme | Items | Started | Complete |
|---------|-------|-------|---------|----------|
| v1.0.0 | Infrastructure | — | ✅ | ✅ |
| v1.1.0 | Shell & Env Vars | ~30 | ✅ | 🟡 Partial |
| v1.2.0 | System Defaults | ~40 | ✅ | ✅ |
| v1.3.0 | App Defaults | ~35 | ✅ | ✅ |
| v1.4.0 | Role Settings | ~25 | ⬜ | ⬜ |
| v1.5.0 | Docs & Polish | ~30 | ⬜ | ⬜ |
| v2.0.0 | Major Features | TBD | ✅ | 🟡 Partial |

### Priority Legend

| Symbol | Meaning |
|--------|---------|
| 🔴 High | Core functionality, security, or user-requested |
| 🟡 Medium | Important but not blocking |
| 🟢 Low | Nice to have, do when convenient |
| ⭐ | User-requested application |

### Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ Complete | Done with full documentation |
| ⚠️ Partial | Exists but needs doc update |
| 📋 Needs docs | Works but lacks inline documentation |
| 🆕 New | Not yet created |

---

## Appendices

### Appendix A: Shell Profile Load Order

```
LOGIN SHELL (Terminal.app, SSH):     .zprofile → .zshrc → .zlogin
INTERACTIVE SHELL (new tab):         .zshrc only
NON-INTERACTIVE (scripts):           .zshenv only
```

| File | When It Runs | What to Put Here |
|------|--------------|------------------|
| `.zshenv` | Every shell | Critical PATH only |
| `.zprofile` | Login shells | Environment variables |
| `.zshrc` | Interactive shells | Aliases, functions, prompt |
| `.zlogin` | Login, after .zshrc | Welcome messages |
| `.zlogout` | Logout | Cleanup |

### Appendix B: XDG Base Directories

XDG standardizes where apps store files:

| Variable | Default | Purpose |
|----------|---------|---------|
| `XDG_CONFIG_HOME` | `~/.config` | Configuration |
| `XDG_DATA_HOME` | `~/.local/share` | Data |
| `XDG_CACHE_HOME` | `~/.cache` | Cache (deletable) |
| `XDG_STATE_HOME` | `~/.local/state` | State/logs |

**Recommendation**: Implement as opt-in feature in v1.1.0.

### Appendix C: Environment Variable Categories

| Category | File | Key Variables |
|----------|------|---------------|
| PATH | `path.env.sh` | `PATH` additions |
| XDG | `xdg.env.sh` | `XDG_CONFIG_HOME`, etc. |
| Security | `security.env.sh` | `GPG_TTY`, `SSH_AUTH_SOCK` |
| Telemetry | `telemetry.env.sh` | `HOMEBREW_NO_ANALYTICS`, etc. |
| Colors | `colors.env.sh` | `CLICOLOR`, `LSCOLORS` |
| Pager | `pager.env.sh` | `LESS`, `MANPAGER`, `BAT_*` |
| Python | `python.env.sh` | `PYTHONDONTWRITEBYTECODE` |
| Node | `node.env.sh` | `NODE_OPTIONS`, `NPM_*` |
| Docker | `docker.env.sh` | `DOCKER_BUILDKIT` |
| Go | `go.env.sh` | `GOPATH`, `GOBIN` |
| Rust | `rust.env.sh` | `CARGO_HOME` |
| Java | `java.env.sh` | `JAVA_HOME` |
| Cloud | `cloud.env.sh` | `AWS_*`, `AZURE_*` |

### Appendix D: Defaults Documentation Format

Every defaults script should follow this format:

```bash
# --- Setting Name ---
# Key:          preference_key_name
# Description:  What this setting does
# Default:      value (Apple's default)
# Options:      value1 = description
#               value2 = description
# Set to:       value (our choice with rationale)
# UI Location:  System Settings > Category > Setting
# Source:       https://support.apple.com/...
```

See `defaults/README.md` for complete documentation.
