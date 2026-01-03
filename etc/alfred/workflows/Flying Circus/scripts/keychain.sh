#!/bin/bash

# Alfred Script Filter for fc keychain command
# Returns JSON list of keychain actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "keychain-list",
      "title": "Keychain: List Passwords",
      "subtitle": "List saved passwords in Keychain",
      "arg": "keychain list",
      "icon": { "path": "icon.png" },
      "match": "list show all passwords",
      "valid": true
    },
    {
      "uid": "keychain-wifi",
      "title": "Keychain: Wi-Fi Passwords",
      "subtitle": "List saved Wi-Fi network passwords",
      "arg": "keychain wifi",
      "icon": { "path": "icon.png" },
      "match": "wifi wireless network password",
      "valid": true
    },
    {
      "uid": "keychain-search",
      "title": "Keychain: Search",
      "subtitle": "Search for a password by name",
      "arg": "keychain search",
      "icon": { "path": "icon.png" },
      "match": "search find password",
      "valid": true
    }
  ]
}
EOF
