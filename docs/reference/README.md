# Reference Documentation

This directory contains **technical reference documentation** for configuration files, system settings, and developer tools used by the Dotfiles Flying Circus project.

---

## Overview

Reference documentation provides in-depth technical details about:

- **Configuration file syntax** — What each option does and how to use it
- **System defaults** — macOS `defaults` commands and their effects
- **Best practices** — Recommended settings and patterns
- **Load order** — When and how configuration files are processed

Unlike guides (which teach concepts) or specifications (which define commands), reference docs are meant to be consulted when you need specific details about a setting or option.

---

## Documentation Categories

### 🖥️ Shells

Shell configuration files for Bash and Zsh.

| Document | Description |
|----------|-------------|
| [Shell Overview](shells/index.mdx) | Comparison of Bash vs Zsh startup files and load order |

#### Zsh Configuration

| File | Description |
|------|-------------|
| [.zshenv](shells/zsh/zshenv.mdx) | Environment variables for all shells |
| [.zprofile](shells/zsh/zprofile.mdx) | Login shell setup (early) |
| [.zshrc](shells/zsh/zshrc.mdx) | Interactive shell configuration |
| [.zlogin](shells/zsh/zlogin.mdx) | Login shell setup (late) |
| [.zlogout](shells/zsh/zlogout.mdx) | Login shell cleanup |

#### Bash Configuration

| File | Description |
|------|-------------|
| [.bash_profile](shells/bash/bash_profile.mdx) | Login shell initialization |
| [.bashrc](shells/bash/bashrc.mdx) | Interactive shell configuration |
| [.bash_login](shells/bash/bash_login.mdx) | Alternative login setup |
| [.bash_logout](shells/bash/bash_logout.mdx) | Login shell cleanup |
| [.profile](shells/bash/profile.mdx) | POSIX-compatible fallback |

---

### ✏️ Editors

Editor configuration files.

| Document | Description |
|----------|-------------|
| [.editorconfig](editors/editorconfig.mdx) | Cross-editor formatting rules |
| [.vimrc](editors/vimrc.mdx) | Vim configuration and key bindings |

---

### 🔀 Git

Git configuration and ignore patterns.

| Document | Description |
|----------|-------------|
| [.gitconfig](git/gitconfig.mdx) | Git settings, aliases, and behaviors |
| [.gitignore_global](git/gitignore_global.mdx) | Global ignore patterns |

---

### ⌨️ Terminal

Terminal input and behavior configuration.

| Document | Description |
|----------|-------------|
| [.inputrc](terminal/inputrc.mdx) | Readline library configuration for command-line input |

---

### 🍎 macOS Defaults

Comprehensive reference for macOS `defaults` commands organized by system area.

| Category | Settings |
|----------|----------|
| [Accessibility](macos-defaults/accessibility/) | Reduce motion, color filters, zoom |
| [Appearance](macos-defaults/appearance/) | Interface style, accent colors |
| [Dialogs](macos-defaults/dialogs/) | Save/print panel behaviors |
| [Dock](macos-defaults/dock/) | Size, position, auto-hide, animations |
| [Finder](macos-defaults/finder/) | View options, extensions, hidden files |
| [Firewall](macos-defaults/firewall/) | Application firewall settings |
| [Keyboard](macos-defaults/keyboard/) | Key repeat, function keys, shortcuts |
| [Menu Bar](macos-defaults/menu-bar/) | Clock format, battery indicator |
| [Mission Control](macos-defaults/mission-control/) | Spaces, Hot Corners, animations |
| [Safari](macos-defaults/safari/) | Developer tools, privacy settings |
| [Screensaver](macos-defaults/screensaver/) | Activation time, password requirement |
| [Software Update](macos-defaults/software-update/) | Automatic updates, beta enrollment |
| [Terminal](macos-defaults/terminal/) | Secure keyboard entry, shell settings |
| [TextEdit](macos-defaults/textedit/) | Default format, smart features |
| [Trackpad](macos-defaults/trackpad/) | Gestures, tap-to-click, tracking speed |

---

## Document Format

Reference documentation in this directory uses the `.mdx` format (Markdown with JSX) to support:

- **Interactive examples** — Copy-to-clipboard buttons
- **Tabbed content** — Multiple options in one view
- **Diagrams** — Mermaid flowcharts for load order visualization
- **Callouts** — Tips, warnings, and notes

### Standard Sections

Each reference document typically includes:

1. **Overview** — What the file/setting does
2. **Location** — Where the file lives or command syntax
3. **Options Reference** — Detailed table of all options
4. **Examples** — Common configurations
5. **Related** — Links to related documentation

---

## Quick Links by Topic

### For New Users

- [Shell Overview](shells/index.mdx) — Understand how shell configs work
- [.zshrc](shells/zsh/zshrc.mdx) — Most commonly edited shell file
- [.gitconfig](git/gitconfig.mdx) — Essential Git configuration

### For Power Users

- [macOS Defaults](macos-defaults/) — Customize every aspect of macOS
- [.vimrc](editors/vimrc.mdx) — Advanced Vim configuration
- [.inputrc](terminal/inputrc.mdx) — Fine-tune command-line input

### For Contributors

- [.editorconfig](editors/editorconfig.mdx) — Ensure consistent formatting
- [.gitignore_global](git/gitignore_global.mdx) — Ignore generated files

---

## Contributing

To add new reference documentation:

1. Choose the appropriate category directory (or create a new one)
2. Use the `.mdx` format for rich content support
3. Follow the standard sections format
4. Include practical examples
5. Link to related documentation

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for general guidelines.
