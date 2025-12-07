# Customization Guide

This guide explains how to adapt the Dotfiles Flying Circus to your own needs, whether you're adding new commands, modifying defaults, or creating your own configuration profiles.

---

## Quick Start

1. **Fork the repository** to your own GitHub account
2. **Clone your fork** and make changes
3. **Run the installer** to test your customizations

---

## Customizing System Defaults

### Location
System defaults are stored in the `defaults/` directory, organized by application:

```
defaults/
├── README.md           # Overview of defaults system
├── dock.sh             # Dock settings
├── finder.sh           # Finder settings
├── keyboard.sh         # Keyboard settings
├── terminal.sh         # Terminal settings
└── profiles/           # Privacy/security profiles
```

### How to Modify

1. Open the relevant file in `defaults/`
2. Modify or add `defaults write` commands
3. Run the installer to apply changes

### Example: Adding a Dock Setting

```bash
# In defaults/dock.sh, add:

# Enable magnification
defaults write com.apple.dock magnification -bool true

# Set magnification size
defaults write com.apple.dock largesize -int 80
```

### Finding Default Keys

```bash
# Read current settings for an app
defaults read com.apple.dock

# Watch for changes (run in one terminal, change settings in GUI)
defaults read com.apple.dock > before.txt
# Make change in System Settings
defaults read com.apple.dock > after.txt
diff before.txt after.txt
```

---

## Creating New `fc` Commands

### Step 1: Copy the Template

```bash
cp lib/plugins/fc-template lib/plugins/fc-mycommand
```

### Step 2: Edit Your Command

Open `lib/plugins/fc-mycommand` and customize:

1. Update the header comments
2. Modify the `usage()` function
3. Implement your actions in the `case` statement

### Step 3: Make It Executable

```bash
chmod +x lib/plugins/fc-mycommand
```

### Step 4: Test

```bash
fc mycommand --help
fc mycommand status
```

### Gold Standard Template

See [fc-disk](lib/plugins/fc-disk) for a comprehensive example with:
- Detailed header (REQUIRES, DEPENDENCIES, REFERENCES, ACTIONS, EXAMPLES, NOTES)
- Per-action comments explaining what each command does
- Helper functions for reusable logic
- Proper error handling

---

## Creating Roles

Roles allow different configurations for different machines (e.g., work laptop vs. personal desktop).

### Location

```
roles/
├── developer.sh    # Development-focused role
├── personal.sh     # Personal machine role
└── work.sh         # Work machine role
```

### Creating a New Role

1. Create a new file: `roles/myrole.sh`
2. Define applications and settings:

```bash
#!/usr/bin/env bash

# Applications to install via Homebrew
HOMEBREW_PACKAGES=(
    "git"
    "neovim"
    "ripgrep"
)

HOMEBREW_CASKS=(
    "visual-studio-code"
    "firefox"
)

# Custom settings
export MY_CUSTOM_VAR="value"
```

3. Run installer with your role:
```bash
./install.sh --role myrole
```

---

## Customizing Privacy Profiles

Privacy profiles control security and privacy settings.

### Available Profiles

| Profile | Description |
|---------|-------------|
| `standard` | Balanced defaults |
| `privacy` | Enhanced privacy settings |
| `lockdown` | Maximum security |

### Location

```
defaults/profiles/
├── README.md
├── standard.sh
├── privacy.sh
└── lockdown.sh
```

### Creating a Custom Profile

1. Copy an existing profile: `cp defaults/profiles/privacy.sh defaults/profiles/myprofile.sh`
2. Modify settings as needed
3. Apply with: `./install.sh --privacy-profile myprofile`

---

## Adding to the Brewfile

The `Brewfile` contains packages installed via Homebrew.

```ruby
# Formulae (CLI tools)
brew "git"
brew "neovim"

# Casks (GUI applications)
cask "visual-studio-code"
cask "firefox"

# Mac App Store apps (requires mas)
mas "Xcode", id: 497799835
```

---

## Shell Customization

### Custom Plugin Location

Shell customizations are in the `circus` Oh My Zsh plugin:

```
profiles/.oh-my-zsh/custom/plugins/circus/
├── circus.plugin.zsh    # Main plugin file
├── aliases.zsh          # Custom aliases
├── functions.zsh        # Custom functions
└── exports.zsh          # Environment variables
```

### Adding Aliases

Edit `profiles/.oh-my-zsh/custom/plugins/circus/aliases.zsh`:

```bash
# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Quick edits
alias zshrc='$EDITOR ~/.zshrc'

# Project shortcuts
alias projects='cd ~/Projects'
```

### Adding Functions

Edit `profiles/.oh-my-zsh/custom/plugins/circus/functions.zsh`:

```bash
# Create and enter directory
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick git status
function gs() {
    git status -sb
}
```

---

## Testing Your Changes

### Run the Test Suite

```bash
./run-tests.sh
```

### Run Specific Tests

```bash
bats tests/fc-mycommand.bats
```

### Manual Testing

Always test on a VM or spare machine first before applying to your main system.

---

## Best Practices

1. **Document your changes** - Add comments explaining what custom settings do
2. **Test incrementally** - Apply one change at a time
3. **Use version control** - Commit working states before experimentation
4. **Keep original comments** - They help future you remember why settings exist
5. **Follow naming conventions** - Use lowercase with hyphens for command names
