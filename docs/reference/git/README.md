# Git Configuration Reference

This directory contains documentation for Git configuration files.

---

## Overview

Git configuration files control version control behavior, from commit authorship to diff display to merge strategies. Understanding these files helps you customize Git for your workflow.

---

## Configuration Files

### ⚙️ Git Configuration

| Document | Description |
|----------|-------------|
| [.gitconfig](gitconfig.mdx) | User-level Git settings, aliases, and behaviors |

**Location:** `~/.gitconfig` (user) or `.git/config` (repository)

**Controls:**
- User identity (name, email)
- Default branch name
- Diff and merge tools
- Aliases for common commands
- Push/pull behavior
- Color output
- Credential helpers

**Example:**

```ini
[user]
    name = Your Name
    email = your.email@example.com
    signingkey = ABCD1234

[core]
    editor = vim
    autocrlf = input
    excludesfile = ~/.gitignore_global

[init]
    defaultBranch = main

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --decorate

[push]
    default = current
    autoSetupRemote = true

[pull]
    rebase = true
```

---

### 🚫 Global Ignore Patterns

| Document | Description |
|----------|-------------|
| [.gitignore_global](gitignore_global.mdx) | Patterns to ignore across all repositories |

**Location:** `~/.gitignore_global` (referenced in `.gitconfig`)

**Controls:**
- OS-generated files (`.DS_Store`, `Thumbs.db`)
- Editor/IDE files (`.idea/`, `.vscode/`)
- Build artifacts (`*.o`, `*.pyc`)
- Dependency directories (`node_modules/`)
- Environment files (`.env.local`)

**Example:**

```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Editors
*.swp
*.swo
*~
.idea/
.vscode/
*.sublime-*

# Build
*.o
*.pyc
__pycache__/
dist/
build/

# Dependencies
node_modules/
vendor/

# Secrets (never commit these!)
.env.local
*.pem
*.key
```

---

## Configuration Hierarchy

Git reads configuration from multiple sources, with later sources overriding earlier ones:

1. **System** (`/etc/gitconfig`) — All users on the machine
2. **Global** (`~/.gitconfig`) — Current user
3. **Local** (`.git/config`) — Current repository
4. **Worktree** (`.git/config.worktree`) — Current worktree

Check where a setting comes from:

```bash
git config --list --show-origin
```

---

## Related Documentation

- [Editor Configuration](../editors/) — EditorConfig and Vim settings
- [Shell Configuration](../shells/) — Aliases and environment variables
- [fc-gpg-setup](../../specs/fc-gpg-setup.md) — GPG key setup for signed commits
