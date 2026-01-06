# Terminal Configuration Reference

This directory contains documentation for terminal and command-line input configuration.

---

## Overview

Terminal configuration files control how your shell handles input, including command-line editing, history navigation, and key bindings. These settings affect the user experience when typing commands.

---

## Configuration Files

### ⌨️ Readline Configuration

| Document | Description |
|----------|-------------|
| [.inputrc](inputrc.mdx) | GNU Readline library configuration |

**Location:** `~/.inputrc`

**Affects:** Bash, Python REPL, MySQL client, and any program using GNU Readline.

> **Note:** Zsh uses its own line editor (ZLE) and does not read `.inputrc`. For Zsh, configure key bindings in `.zshrc`.

**Controls:**
- Key bindings for editing commands
- History search behavior
- Completion settings
- Bell behavior
- Input mode (Emacs vs Vi)

**Example:**

```bash
# Use Vi editing mode
set editing-mode vi

# Make Tab autocomplete regardless of filename case
set completion-ignore-case on

# Show all completions at once
set show-all-if-ambiguous on

# Append slash to completed directories
set mark-directories on

# Color files by type during completion
set colored-stats on

# Up/Down arrows search through history
"\e[A": history-search-backward
"\e[B": history-search-forward

# Ctrl+Left/Right to move by word
"\e[1;5C": forward-word
"\e[1;5D": backward-word
```

---

## Readline vs ZLE

| Feature | Readline (Bash) | ZLE (Zsh) |
|---------|-----------------|-----------|
| Config file | `~/.inputrc` | `~/.zshrc` |
| Default mode | Emacs | Emacs |
| Vi mode | `set editing-mode vi` | `bindkey -v` |
| Custom bindings | `.inputrc` syntax | `bindkey` command |
| Completion | Built-in | More powerful |

---

## Common Key Bindings

These work in most Readline-enabled applications:

| Key | Action |
|-----|--------|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+R` | Reverse history search |
| `Ctrl+L` | Clear screen |
| `Tab` | Autocomplete |

---

## Related Documentation

- [Shell Configuration](../shells/) — Bash and Zsh dotfiles
- [Editor Configuration](../editors/) — Vim key bindings
- [.bashrc](../shells/bash/bashrc.mdx) — Bash-specific settings
- [.zshrc](../shells/zsh/zshrc.mdx) — Zsh-specific settings
