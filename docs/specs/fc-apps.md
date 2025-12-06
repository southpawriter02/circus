# Feature Specification: `fc apps`

## Overview

**Command:** `fc apps`  
**Purpose:** List, search, and manage installed applications.

### Use Cases
- List all installed applications with version info
- Search for installed apps by name
- Open applications from terminal
- Check for updates (App Store apps)
- Remove applications and their associated files

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all installed applications |
| `search [query]` | Search for installed applications |
| `open [name]` | Open an application by name |
| `quit [name]` | Quit a running application |
| `info [name]` | Show detailed info about an app |
| `locate [name]` | Find where an app is installed |

---

## Detailed Behaviors

### `fc apps list`

List all installed applications:

```
$ fc apps list

Installed Applications (sorted alphabetically):

  Name                    Version     Source
  1Password               8.10.24     App Store
  Cursor                  0.45.2      Manual
  Docker Desktop          4.25.0      Homebrew Cask
  Firefox                 120.0       Homebrew Cask
  Xcode                   15.1        App Store
  ...

Total: 87 applications
```

**Implementation:**
- Use `mdfind "kMDItemKind == 'Application'"` for all apps
- Use `mdls` to get version and source info
- Accept `--json` flag for machine-readable output

---

### `fc apps search [query]`

Search installed applications:

```
$ fc apps search chrome

Search results for "chrome":

  Name                    Path
  Google Chrome           /Applications/Google Chrome.app
  Chrome Canary           /Applications/Google Chrome Canary.app
```

**Implementation:**
- Use `mdfind "kMDItemKind == 'Application' && kMDItemDisplayName == '*query*'c"`
- Case-insensitive search
- Support glob patterns

---

### `fc apps open [name]`

Open an application:

```
$ fc apps open Finder

Opening Finder...
✓ Finder is now running
```

**Implementation:**
- Use `open -a "AppName"` to launch
- Support partial matching
- Error if app not found

---

### `fc apps quit [name]`

Quit a running application:

```
$ fc apps quit "Google Chrome"

Quitting Google Chrome...
✓ Google Chrome has been closed
```

**Implementation:**
- Use `osascript -e 'quit app "AppName"'`
- Graceful quit (allows app to save)
- Accept `--force` for force quit (`killall`)

---

### `fc apps info [name]`

Show application details:

```
$ fc apps info "Visual Studio Code"

Application Info: Visual Studio Code
  
  Version:        1.85.0
  Bundle ID:      com.microsoft.VSCode
  Path:           /Applications/Visual Studio Code.app
  Size:           480 MB
  Signed:         Yes (Apple Distribution)
  Architecture:   Universal (arm64, x86_64)
  Min macOS:      10.15
```

**Implementation:**
- Use `mdls` for metadata
- Use `codesign -dv` for signature info
- Use `lipo -info` for architecture

---

### `fc apps locate [name]`

Find application location:

```
$ fc apps locate zoom

Searching for "zoom"...

  /Applications/zoom.us.app
  ~/Applications/Zoom.app
```

**Implementation:**
- Use `mdfind` to search
- Show all matching locations
- Handle apps in ~/Applications too

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `mdfind` | macOS | Yes |
| `mdls` | macOS | Yes |
| `open` | macOS | Yes |
| `osascript` | macOS | Yes |
| `codesign` | macOS | Yes |

---

## Implementation Notes

### App Locations
- /Applications (system-wide)
- ~/Applications (user-only)
- /System/Applications (system apps)
- Homebrew: /opt/homebrew/Caskroom

### Name Matching
- Support partial, case-insensitive matching
- Error if multiple matches for open/quit
- Show all matches for search/locate

### Architecture Detection
- Universal: supports both Intel and Apple Silicon
- arm64: Apple Silicon only
- x86_64: Intel only (runs via Rosetta on AS)

---

## Examples

```bash
# List all apps
fc apps list

# Search for apps
fc apps search slack

# Open app
fc apps open "Visual Studio Code"

# Quit app gracefully
fc apps quit Safari

# Force quit
fc apps quit Safari --force

# Get app info
fc apps info Xcode
```

---

## Testing Strategy

### Automated Tests (`bats`)
- `fc apps --help` displays usage
- `fc apps list` runs without error
- `fc apps search` finds known apps
- Unknown subcommand returns error

### Manual Verification
- Verify list includes all visible apps
- Test open/quit with actual applications
- Check info accuracy against Finder Get Info
