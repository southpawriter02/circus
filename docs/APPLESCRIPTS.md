# AppleScripts

Practical AppleScript examples for macOS automation. Copy-paste ready for `osascript -e '...'` or save as `.scpt` files.

## Reference Repositories

* https://github.com/kevin-funderburg/AppleScripts
* https://github.com/unforswearing/applescript
* https://github.com/abbeycode/AppleScripts
* https://github.com/posguy99/AppleScript
* https://github.com/suliveevil/My-AppleScript
* https://github.com/wshanks/applescripts
* https://github.com/dvcrn/applescripts
* https://github.com/DonovanChan/applescripts
* https://github.com/geekcomputers/Applescript
* https://github.com/wafflesnatcha/AppleScripts

---

## System Control

### Set Volume to Percentage

```applescript
-- Set volume to 50%
set volume output volume 50
```

```bash
osascript -e 'set volume output volume 50'
```

### Get Current Volume

```applescript
output volume of (get volume settings)
```

```bash
osascript -e 'output volume of (get volume settings)'
```

### Toggle Mute

```applescript
set currentMute to output muted of (get volume settings)
set volume output muted (not currentMute)
```

```bash
osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
```

### Set Display Brightness

Requires accessibility permissions.

```applescript
tell application "System Events"
    tell process "Control Center"
        -- Brightness slider is in Control Center
        set value of slider 1 of group 1 of window "Control Center" to 0.5
    end tell
end tell
```

Alternative using `brightness` CLI (install via `brew install brightness`):

```bash
brightness 0.5  # Set to 50%
```

### Toggle Do Not Disturb

```applescript
tell application "System Events"
    tell process "Control Center"
        click menu bar item "Control Center" of menu bar 1
        delay 0.3
        click checkbox "Focus" of group 1 of window "Control Center"
        delay 0.1
        key code 53 -- Escape to close
    end tell
end tell
```

### Get Battery Percentage

```applescript
do shell script "pmset -g batt | grep -Eo '\\d+%' | head -1"
```

```bash
osascript -e 'do shell script "pmset -g batt | grep -Eo \"\\d+%\" | head -1"'
```

### Switch Audio Output Device

```applescript
-- Requires SwitchAudioSource: brew install switchaudio-osx
do shell script "/opt/homebrew/bin/SwitchAudioSource -s 'MacBook Pro Speakers'"
```

### Show Notification

```applescript
display notification "Your message here" with title "Title" subtitle "Subtitle" sound name "Glass"
```

```bash
osascript -e 'display notification "Task complete!" with title "Script" sound name "Glass"'
```

---

## Window Management

### Resize Window to Left Half

```applescript
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set bounds of front window to {0, 25, 960, 1080}
end tell
```

### Resize Window to Right Half

```applescript
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set bounds of front window to {960, 25, 1920, 1080}
end tell
```

### Center Window on Screen

```applescript
tell application "Finder"
    set screenBounds to bounds of window of desktop
    set screenWidth to item 3 of screenBounds
    set screenHeight to item 4 of screenBounds
end tell

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set {x, y, w, h} to bounds of front window
    set winWidth to w - x
    set winHeight to h - y
    set newX to (screenWidth - winWidth) / 2
    set newY to (screenHeight - winHeight) / 2
    set bounds of front window to {newX, newY, newX + winWidth, newY + winHeight}
end tell
```

### Maximize Current Window

```applescript
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set bounds of front window to {0, 25, 1920, 1080}
end tell
```

### Move Window to Next Monitor

```applescript
-- Get current window bounds and move to alternate display
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

tell application frontApp
    set {x, y, w, h} to bounds of front window
    set winWidth to w - x
    set winHeight to h - y
    -- Toggle between displays (adjust coordinates for your setup)
    if x < 1920 then
        set bounds of front window to {1920 + 100, 100, 1920 + 100 + winWidth, 100 + winHeight}
    else
        set bounds of front window to {100, 100, 100 + winWidth, 100 + winHeight}
    end if
end tell
```

---

## Finder Automation

### Open Current Folder in Terminal

```applescript
tell application "Finder"
    set currentFolder to (folder of the front window as alias)
    set folderPath to POSIX path of currentFolder
end tell

tell application "Terminal"
    activate
    do script "cd " & quoted form of folderPath
end tell
```

### Open Current Folder in iTerm

```applescript
tell application "Finder"
    set currentFolder to (folder of the front window as alias)
    set folderPath to POSIX path of currentFolder
end tell

tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd " & quoted form of folderPath
        end tell
    end tell
end tell
```

### Copy Selected File Paths to Clipboard

```applescript
tell application "Finder"
    set selectedFiles to selection as alias list
    set pathList to ""
    repeat with f in selectedFiles
        set pathList to pathList & POSIX path of f & linefeed
    end repeat
    set the clipboard to text 1 thru -2 of pathList -- Remove trailing newline
end tell
```

```bash
osascript -e 'tell application "Finder" to set selectedFiles to selection as alias list' -e 'set pathList to ""' -e 'repeat with f in selectedFiles' -e 'set pathList to pathList & POSIX path of f & linefeed' -e 'end repeat' -e 'set the clipboard to pathList'
```

### Toggle Hidden Files Visibility

```applescript
do shell script "current=$(defaults read com.apple.finder AppleShowAllFiles); if [ \"$current\" = \"YES\" ] || [ \"$current\" = \"true\" ]; then defaults write com.apple.finder AppleShowAllFiles -bool false; else defaults write com.apple.finder AppleShowAllFiles -bool true; fi; killall Finder"
```

```bash
osascript -e 'do shell script "defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder"'
```

### Create New File in Current Folder

```applescript
tell application "Finder"
    set currentFolder to (folder of the front window as alias)
    set folderPath to POSIX path of currentFolder
end tell

set fileName to text returned of (display dialog "Enter filename:" default answer "untitled.txt")
do shell script "touch " & quoted form of (folderPath & fileName)

tell application "Finder"
    activate
    reveal POSIX file (folderPath & fileName)
end tell
```

### Get File Path in Various Formats

```applescript
tell application "Finder"
    set theFile to item 1 of (selection as alias list)
    set posixPath to POSIX path of theFile
    set hfsPath to theFile as text
    set urlPath to "file://" & posixPath
end tell

display dialog "POSIX: " & posixPath & return & return & "HFS: " & hfsPath & return & return & "URL: " & urlPath
```

---

## Safari & Browser

### Copy All Open Tab URLs to Clipboard

```applescript
tell application "Safari"
    set urlList to ""
    repeat with t in tabs of front window
        set urlList to urlList & URL of t & linefeed
    end repeat
    set the clipboard to text 1 thru -2 of urlList
end tell
```

```bash
osascript -e 'tell application "Safari" to set urlList to ""' -e 'tell application "Safari" to repeat with t in tabs of front window' -e 'set urlList to urlList & URL of t & linefeed' -e 'end repeat' -e 'set the clipboard to urlList'
```

### Export Tabs as Markdown List

```applescript
tell application "Safari"
    set mdList to ""
    repeat with t in tabs of front window
        set tabTitle to name of t
        set tabURL to URL of t
        set mdList to mdList & "- [" & tabTitle & "](" & tabURL & ")" & linefeed
    end repeat
    set the clipboard to mdList
end tell
```

### Close Duplicate Tabs

```applescript
tell application "Safari"
    set seenURLs to {}
    set tabsToClose to {}
    repeat with t in tabs of front window
        set tabURL to URL of t
        if tabURL is in seenURLs then
            set end of tabsToClose to t
        else
            set end of seenURLs to tabURL
        end if
    end repeat
    repeat with t in tabsToClose
        close t
    end repeat
end tell
```

### Open URLs from Clipboard as Tabs

```applescript
set clipboardContent to the clipboard
set urlList to paragraphs of clipboardContent

tell application "Safari"
    activate
    repeat with urlItem in urlList
        if urlItem starts with "http" then
            tell front window to make new tab with properties {URL:urlItem}
        end if
    end repeat
end tell
```

---

## Application Utilities

### Quit All Apps Except Finder

```applescript
tell application "System Events"
    set appList to name of every application process whose background only is false
end tell

repeat with appName in appList
    if appName is not "Finder" then
        tell application appName to quit
    end if
end repeat
```

### Get Frontmost App Name

```applescript
tell application "System Events"
    name of first application process whose frontmost is true
end tell
```

```bash
osascript -e 'tell application "System Events" to name of first application process whose frontmost is true'
```

### Launch App and Bring to Front

```applescript
tell application "Visual Studio Code"
    activate
    -- Wait for app to launch if not running
    repeat until frontmost
        delay 0.1
    end repeat
end tell
```

```bash
osascript -e 'tell application "Visual Studio Code" to activate'
```

### Hide All Apps Except Current

```applescript
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    set appList to name of every application process whose visible is true
end tell

repeat with appName in appList
    if appName is not frontApp then
        tell application "System Events"
            set visible of process appName to false
        end tell
    end if
end repeat
```

---

## Clipboard & Text

### Convert Clipboard to Plain Text

```applescript
set the clipboard to (the clipboard as text)
```

```bash
osascript -e 'set the clipboard to (the clipboard as text)'
```

### Transform Clipboard to Uppercase

```applescript
set clipText to the clipboard as text
set the clipboard to do shell script "echo " & quoted form of clipText & " | tr '[:lower:]' '[:upper:]'"
```

### Transform Clipboard to Lowercase

```applescript
set clipText to the clipboard as text
set the clipboard to do shell script "echo " & quoted form of clipText & " | tr '[:upper:]' '[:lower:]'"
```

### Transform Clipboard to Title Case

```applescript
set clipText to the clipboard as text
set the clipboard to do shell script "echo " & quoted form of clipText & " | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'"
```

### URL Encode Clipboard

```applescript
set clipText to the clipboard as text
set the clipboard to do shell script "python3 -c \"import urllib.parse; print(urllib.parse.quote('" & clipText & "'))\""
```

### URL Decode Clipboard

```applescript
set clipText to the clipboard as text
set the clipboard to do shell script "python3 -c \"import urllib.parse; print(urllib.parse.unquote('" & clipText & "'))\""
```

---

## Usage Tips

### Running Scripts

**One-liner via Terminal:**
```bash
osascript -e 'display notification "Hello" with title "Test"'
```

**Multi-line script:**
```bash
osascript <<'EOF'
tell application "Finder"
    set currentFolder to (folder of the front window as alias)
    set folderPath to POSIX path of currentFolder
end tell
return folderPath
EOF
```

**From a file:**
```bash
osascript /path/to/script.scpt
osascript /path/to/script.applescript
```

### Saving Scripts

1. Open **Script Editor** (`/Applications/Utilities/Script Editor.app`)
2. Paste your script
3. Save as `.scpt` (compiled) or `.applescript` (text)

### Integration with Launchers

**Alfred:** Create a workflow with "Run Script" action, set language to AppleScript

**Raycast:** Create a script command with `#!/usr/bin/osascript` shebang

**Keyboard Shortcuts:** Use Automator to create a Quick Action, then assign a shortcut in System Settings > Keyboard > Keyboard Shortcuts > Services

### Permissions

Many scripts require permissions in **System Settings > Privacy & Security**:
- **Accessibility** - For window management and UI scripting
- **Automation** - For controlling other applications
- **Full Disk Access** - For accessing protected files

### Debugging

```bash
# Run with verbose output
osascript -ss script.scpt

# Check syntax without running
osacompile -o /dev/null script.applescript
```
