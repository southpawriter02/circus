#!/bin/bash

# Alfred Script Filter for fc clipboard command
# Returns JSON list of clipboard actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "clipboard-show",
      "title": "Clipboard: Show",
      "subtitle": "Display current clipboard contents",
      "arg": "clipboard show",
      "icon": { "path": "icon.png" },
      "match": "show display view contents",
      "valid": true
    },
    {
      "uid": "clipboard-count",
      "title": "Clipboard: Count",
      "subtitle": "Count characters/words in clipboard",
      "arg": "clipboard count",
      "icon": { "path": "icon.png" },
      "match": "count words characters length",
      "valid": true
    },
    {
      "uid": "clipboard-clear",
      "title": "Clipboard: Clear",
      "subtitle": "Clear the clipboard contents",
      "arg": "clipboard clear",
      "icon": { "path": "icon.png" },
      "match": "clear empty erase",
      "valid": true
    },
    {
      "uid": "clipboard-plain",
      "title": "Clipboard: Plain Text",
      "subtitle": "Convert clipboard to plain text (remove formatting)",
      "arg": "clipboard plain",
      "icon": { "path": "icon.png" },
      "match": "plain text strip formatting",
      "valid": true
    }
  ]
}
EOF
