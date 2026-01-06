# Editor Configuration Reference

This directory contains documentation for editor configuration files used across the Dotfiles Flying Circus project.

---

## Overview

Editor configuration files ensure consistent coding styles across different editors and IDEs. These files define formatting rules, key bindings, and editor behavior.

---

## Configuration Files

### 📐 EditorConfig

| Document | Description |
|----------|-------------|
| [.editorconfig](editorconfig.mdx) | Universal formatting rules for multiple editors |

**Supported by:** VS Code, Vim, Sublime Text, JetBrains IDEs, Atom, and [many others](https://editorconfig.org/#pre-installed).

**Controls:**
- Indentation style (tabs vs. spaces)
- Indentation size
- End of line characters
- Charset encoding
- Trailing whitespace
- Final newline

**Example:**

```ini
# Top-most EditorConfig file
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

---

### 🔧 Vim

| Document | Description |
|----------|-------------|
| [.vimrc](vimrc.mdx) | Vim configuration, plugins, and key mappings |

**Controls:**
- Editor appearance (colors, line numbers, status line)
- Key mappings and shortcuts
- Plugin configuration
- Search behavior
- Buffer and window management
- File type settings

**Example:**

```vim
" Enable syntax highlighting
syntax enable

" Show line numbers
set number
set relativenumber

" Use spaces for tabs
set expandtab
set tabstop=4
set shiftwidth=4

" Enable mouse support
set mouse=a
```

---

## Editor Settings Priority

When multiple configuration sources exist, editors typically follow this priority:

1. **Project-specific settings** (e.g., `.vscode/settings.json`)
2. **EditorConfig** (`.editorconfig`)
3. **User settings** (e.g., `~/.vimrc`)
4. **System defaults**

---

## Related Documentation

- [Git Configuration](../git/) — Git settings and aliases
- [Shell Configuration](../shells/) — Shell dotfiles
- [Terminal Configuration](../terminal/) — Readline settings
