# YAML Configuration Guide

This guide explains how to use the declarative YAML configuration system for managing your dotfiles and system settings.

## Overview

The YAML configuration system allows you to define your entire machine setup in a single, readable file. Instead of writing shell scripts that imperatively execute commands, you declare what you want your system to look like, and the framework applies it.

**Benefits:**
- **Readable**: YAML is clean and easy to understand
- **Safe**: No arbitrary code execution; only data
- **Portable**: Easy to share and version control
- **Declarative**: Describe the end state, not the steps

## Prerequisites

Install the YAML processor:

```bash
brew install yq
```

## Quick Start

```bash
# View available configurations
fc config list

# Validate a configuration
fc config validate roles/personal/config.yaml

# Preview changes (dry run)
fc config apply roles/personal/config.yaml --dry-run

# Apply configuration
fc config apply roles/personal/config.yaml
```

## Configuration Schema

### Metadata

```yaml
metadata:
  name: my-role
  description: Description of this configuration
  author: Your Name
  version: "1.0.0"
```

### Packages

```yaml
packages:
  # Homebrew formulae (CLI tools)
  brew:
    - git
    - wget
    - htop

  # Homebrew casks (GUI applications)
  cask:
    - visual-studio-code
    - firefox
    - slack

  # Mac App Store apps
  mas:
    - name: Xcode
      id: 497799835
    - name: Pages
      id: 409201541
```

### macOS Defaults

```yaml
defaults:
  - domain: com.apple.finder
    key: AppleShowAllFiles
    type: bool
    value: true
    description: Show hidden files in Finder

  - domain: com.apple.dock
    key: autohide
    type: bool
    value: true
    description: Auto-hide the Dock

  - domain: com.apple.dock
    key: autohide-delay
    type: float
    value: 0.1
    description: Speed up Dock auto-hide
```

**Supported types:** `bool`, `int`, `float`, `string`, `array`, `dict`

### Environment Variables

```yaml
environment:
  - name: EDITOR
    value: vim

  - name: HOMEBREW_NO_ANALYTICS
    value: "1"
```

### Shell Aliases

```yaml
aliases:
  - name: ll
    command: ls -lah
    description: Long list with hidden files

  - name: update
    command: fc update --all
    description: Update system and packages
```

## Converting Existing Roles

To convert a shell-based role to YAML:

```bash
fc config convert personal
```

This shows a step-by-step guide for your specific role.

### Manual Conversion Steps

1. **Create the YAML file:**
   ```bash
   touch roles/<role>/config.yaml
   ```

2. **Convert Brewfile:**
   
   From:
   ```ruby
   brew "git"
   brew "wget"
   cask "firefox"
   mas "Pages", id: 409201541
   ```
   
   To:
   ```yaml
   packages:
     brew:
       - git
       - wget
     cask:
       - firefox
     mas:
       - name: Pages
         id: 409201541
   ```

3. **Convert defaults scripts:**
   
   From:
   ```bash
   defaults write com.apple.finder AppleShowAllFiles -bool true
   ```
   
   To:
   ```yaml
   defaults:
     - domain: com.apple.finder
       key: AppleShowAllFiles
       type: bool
       value: true
   ```

4. **Convert environment exports:**
   
   From:
   ```bash
   export EDITOR=vim
   ```
   
   To:
   ```yaml
   environment:
     - name: EDITOR
       value: vim
   ```

## Best Practices

### 1. Use Descriptive Names

```yaml
metadata:
  name: developer-workstation
  description: Full development environment with Docker and cloud tools
```

### 2. Group Related Settings

Organize your defaults by application:

```yaml
defaults:
  # === Finder ===
  - domain: com.apple.finder
    key: AppleShowAllFiles
    # ...

  # === Dock ===
  - domain: com.apple.dock
    key: autohide
    # ...
```

### 3. Document Everything

Add descriptions to help future-you understand:

```yaml
defaults:
  - domain: com.apple.screensaver
    key: askForPassword
    type: bool
    value: true
    description: Require password after sleep/screensaver (security)
```

### 4. Validate Before Applying

Always validate first:

```bash
fc config validate config.yaml
fc config show config.yaml
fc config apply config.yaml --dry-run
```

## File Locations

| Path | Purpose |
|------|---------|
| `roles/<role>/config.yaml` | Role-specific configuration |
| `lib/yaml_config.sh` | Configuration engine |
| `~/.zshenv.local` | Generated environment variables |
| `~/.aliases.local` | Generated shell aliases |

## Troubleshooting

### "yq is required but not installed"

```bash
brew install yq
```

### "Invalid YAML syntax"

Validate with:
```bash
yq eval '.' config.yaml
```

Common issues:
- Indentation must be consistent (use 2 spaces)
- Strings with special characters need quotes
- Boolean values: `true`/`false` (lowercase)

### Defaults not taking effect

Some defaults require:
```bash
killall Finder  # For Finder settings
killall Dock    # For Dock settings
```

Or log out and back in.

## Available Configurations

The YAML configuration system includes the following ready-to-use configurations:

### Role Configurations

| Role | Description | Path |
|------|-------------|------|
| personal | Productivity and entertainment | `roles/personal/config.yaml` |
| developer | Full-stack development environment | `roles/developer/config.yaml` |
| work | DevOps and cloud engineering | `roles/work/config.yaml` |

### Specialized Configurations

| Config | Description | Path |
|--------|-------------|------|
| privacy-hardening | Minimize tracking and telemetry | `configs/privacy-hardening.yaml` |
| security-hardening | Strengthen system security | `configs/security-hardening.yaml` |

### Usage

```bash
# Apply a role configuration
fc config apply roles/developer/config.yaml

# Apply a specialized configuration
fc config apply configs/security-hardening.yaml

# Preview before applying
fc config apply configs/privacy-hardening.yaml --dry-run
```

## API Reference

### Library Functions

```bash
source "$DOTFILES_ROOT/lib/yaml_config.sh"

# Apply full configuration
apply_role_config "path/to/config.yaml"

# Validate configuration
validate_config "path/to/config.yaml"

# Read YAML values
yaml_get "config.yaml" ".metadata.name"
yaml_array_length "config.yaml" ".packages.brew"
```

### CLI Commands

```bash
fc config apply <file>      # Apply configuration
fc config validate <file>   # Validate YAML
fc config show <file>       # Display summary
fc config list              # List configs
fc config convert <role>    # Conversion guide
```
