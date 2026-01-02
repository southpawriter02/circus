# Dotfile Profiles

This document explains the profile system in Dotfiles Flying Circus, which allows you to maintain different configurations for different environments (e.g., work vs personal).

## Overview

Profiles provide a way to layer environment-specific configurations on top of your base dotfiles. This is useful when you need different settings for:

- **Work vs Personal**: Different git emails, signing keys, or aliases
- **Different Machines**: Machine-specific paths or configurations
- **Project-Specific**: Different tool configurations for different projects

## Directory Structure

```
profiles/
  base/           # Common dotfiles (always applied)
    bash/
    git/
    jetbrains/
    sh/
    zsh/
  work/           # Work-specific overrides
    .gitconfig    # Work email, signing key, etc.
  personal/       # Personal overrides
    .gitconfig    # Personal email
```

### Base Profile

The `profiles/base/` directory contains your default dotfiles that are shared across all environments. This is where most of your configuration lives.

### Named Profiles

Additional directories in `profiles/` (e.g., `work/`, `personal/`) contain override files. When you switch to a profile, files from that profile's directory replace the corresponding base files.

## Commands

### List Available Profiles

```bash
fc fc-profile list
```

Shows all available profiles and indicates which one is currently active.

### View Current Profile

```bash
fc fc-profile current
```

Shows which profile is currently active and what files it overrides.

### Switch Profiles

```bash
fc fc-profile switch work
fc fc-profile switch personal
```

Switches to the specified profile by:
1. Applying all dotfiles from `profiles/base/`
2. Overlaying files from the specified profile
3. Saving the current profile to `~/.config/circus/current_profile`

After switching, restart your shell or run `source ~/.zshrc` to apply changes.

## Creating a New Profile

1. Create a directory in `profiles/` with your profile name:

   ```bash
   mkdir -p profiles/myprofile
   ```

2. Add any override files. Only include files you want to differ from base:

   ```bash
   # Create a custom .gitconfig for this profile
   cat > profiles/myprofile/.gitconfig << 'EOF'
   [user]
       name = Your Name
       email = specific@email.com
   EOF
   ```

3. Switch to your new profile:

   ```bash
   fc fc-profile switch myprofile
   ```

## How Layering Works

When you switch profiles, the system creates symlinks in your home directory:

1. **Base files first**: Each dotfile in `profiles/base/` gets symlinked to `~`
2. **Profile overrides**: Files in your active profile directory replace base symlinks

For example, with the `work` profile:

```
~/.gitconfig  ->  profiles/work/.gitconfig     (override)
~/.zshrc      ->  profiles/base/zsh/zshrc.symlink  (base)
~/.bashrc     ->  profiles/base/bash/.bashrc   (base)
```

## Example Profile Configurations

### Work Profile

```gitconfig
# profiles/work/.gitconfig
[user]
    name = Your Name
    email = your.name@company.com
[commit]
    gpgsign = true
[user]
    signingkey = WORK_GPG_KEY_ID
```

### Personal Profile

```gitconfig
# profiles/personal/.gitconfig
[user]
    name = Your Name
    email = personal@example.com
```

## State File

The current active profile is stored in:

```
~/.config/circus/current_profile
```

This file is created when you first switch profiles and contains the profile name.

## Tips

1. **Keep overrides minimal**: Only include files that actually differ between environments
2. **Use includes**: Git supports `[include]` directives - you can include a base config and override specific values
3. **Test before switching**: Preview what files a profile contains with `ls profiles/<name>/`
4. **Backup first**: The switch command backs up existing files before replacing them

## Troubleshooting

### "Profile not found"

The specified profile directory doesn't exist. Create it first or check spelling.

### Changes not taking effect

Run `source ~/.zshrc` or start a new terminal session after switching profiles.

### Need to revert to base only

There's currently no "no profile" mode. To use only base dotfiles, create an empty profile:

```bash
mkdir -p profiles/base-only
fc fc-profile switch base-only
```
