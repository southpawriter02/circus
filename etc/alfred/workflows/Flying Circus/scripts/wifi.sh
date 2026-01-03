#!/bin/bash

# Alfred Script Filter for fc wifi command
# Returns JSON list of wifi actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "wifi-on",
      "title": "Wi-Fi On",
      "subtitle": "Turn on the Wi-Fi adapter",
      "arg": "wifi on",
      "icon": { "path": "icon.png" },
      "match": "on enable turn",
      "valid": true
    },
    {
      "uid": "wifi-off",
      "title": "Wi-Fi Off",
      "subtitle": "Turn off the Wi-Fi adapter",
      "arg": "wifi off",
      "icon": { "path": "icon.png" },
      "match": "off disable turn",
      "valid": true
    },
    {
      "uid": "wifi-status",
      "title": "Wi-Fi Status",
      "subtitle": "Check current Wi-Fi power state",
      "arg": "wifi status",
      "icon": { "path": "icon.png" },
      "match": "status check state",
      "valid": true
    }
  ]
}
EOF
