#!/bin/bash

# AppleScript actions for Alfred
# Returns JSON list of available AppleScript actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "as-window-left",
      "title": "Window: Left Half",
      "subtitle": "Move current window to left half of screen",
      "arg": "applescript window left",
      "match": "window left half tile",
      "icon": {"path": "icons/window.png"},
      "valid": true
    },
    {
      "uid": "as-window-right",
      "title": "Window: Right Half",
      "subtitle": "Move current window to right half of screen",
      "arg": "applescript window right",
      "match": "window right half tile",
      "valid": true
    },
    {
      "uid": "as-window-maximize",
      "title": "Window: Maximize",
      "subtitle": "Maximize current window to fill screen",
      "arg": "applescript window maximize",
      "match": "window maximize full screen",
      "valid": true
    },
    {
      "uid": "as-window-center",
      "title": "Window: Center",
      "subtitle": "Center current window on screen",
      "arg": "applescript window center",
      "match": "window center middle",
      "valid": true
    },
    {
      "uid": "as-finder-terminal",
      "title": "Finder: Open in Terminal",
      "subtitle": "Open current Finder folder in Terminal",
      "arg": "applescript finder terminal",
      "match": "finder terminal open folder cd",
      "valid": true
    },
    {
      "uid": "as-finder-hidden",
      "title": "Finder: Toggle Hidden Files",
      "subtitle": "Toggle visibility of hidden files in Finder",
      "arg": "applescript finder hidden",
      "match": "finder hidden files show hide toggle dotfiles",
      "valid": true
    },
    {
      "uid": "as-safari-tabs",
      "title": "Safari: Copy Tab URLs",
      "subtitle": "Copy all open Safari tab URLs to clipboard",
      "arg": "applescript safari tabs",
      "match": "safari tabs urls copy clipboard",
      "valid": true
    },
    {
      "uid": "as-safari-markdown",
      "title": "Safari: Export as Markdown",
      "subtitle": "Export Safari tabs as Markdown list to clipboard",
      "arg": "applescript safari markdown",
      "match": "safari tabs markdown export links",
      "valid": true
    },
    {
      "uid": "as-safari-duplicates",
      "title": "Safari: Close Duplicates",
      "subtitle": "Close duplicate tabs in Safari",
      "arg": "applescript safari duplicates",
      "match": "safari tabs duplicate close remove",
      "valid": true
    },
    {
      "uid": "as-clip-plain",
      "title": "Clipboard: Plain Text",
      "subtitle": "Convert clipboard to plain text (strip formatting)",
      "arg": "applescript clip plain",
      "match": "clipboard plain text strip formatting paste",
      "valid": true
    },
    {
      "uid": "as-clip-upper",
      "title": "Clipboard: UPPERCASE",
      "subtitle": "Convert clipboard text to UPPERCASE",
      "arg": "applescript clip upper",
      "match": "clipboard uppercase caps transform",
      "valid": true
    },
    {
      "uid": "as-clip-lower",
      "title": "Clipboard: lowercase",
      "subtitle": "Convert clipboard text to lowercase",
      "arg": "applescript clip lower",
      "match": "clipboard lowercase transform",
      "valid": true
    },
    {
      "uid": "as-clip-title",
      "title": "Clipboard: Title Case",
      "subtitle": "Convert clipboard text to Title Case",
      "arg": "applescript clip title",
      "match": "clipboard title case transform capitalize",
      "valid": true
    },
    {
      "uid": "as-volume-mute",
      "title": "Volume: Toggle Mute",
      "subtitle": "Toggle audio mute on/off",
      "arg": "applescript volume mute",
      "match": "volume mute unmute audio sound toggle",
      "valid": true
    },
    {
      "uid": "as-app-hide-others",
      "title": "App: Hide Others",
      "subtitle": "Hide all apps except the current one",
      "arg": "applescript app hide-others",
      "match": "app hide others focus clean desktop",
      "valid": true
    },
    {
      "uid": "as-app-quit-all",
      "title": "App: Quit All",
      "subtitle": "Quit all apps except Finder",
      "arg": "applescript app quit-all",
      "match": "app quit all close applications",
      "valid": true
    }
  ]
}
EOF
