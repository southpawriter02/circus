#!/bin/bash

# Alfred Script Filter for fc bluetooth command
# Returns JSON list of bluetooth actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "bluetooth-on",
      "title": "Bluetooth On",
      "subtitle": "Turn on Bluetooth",
      "arg": "bluetooth on",
      "icon": { "path": "icon.png" },
      "match": "on enable turn",
      "valid": true
    },
    {
      "uid": "bluetooth-off",
      "title": "Bluetooth Off",
      "subtitle": "Turn off Bluetooth",
      "arg": "bluetooth off",
      "icon": { "path": "icon.png" },
      "match": "off disable turn",
      "valid": true
    },
    {
      "uid": "bluetooth-status",
      "title": "Bluetooth Status",
      "subtitle": "Check current Bluetooth state",
      "arg": "bluetooth status",
      "icon": { "path": "icon.png" },
      "match": "status check state",
      "valid": true
    }
  ]
}
EOF
