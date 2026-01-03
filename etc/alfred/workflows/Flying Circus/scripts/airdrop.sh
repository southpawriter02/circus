#!/bin/bash

# Alfred Script Filter for fc airdrop command
# Returns JSON list of airdrop actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "airdrop-on",
      "title": "AirDrop: Everyone",
      "subtitle": "Allow AirDrop from everyone",
      "arg": "airdrop on",
      "icon": { "path": "icon.png" },
      "match": "on everyone all enable",
      "valid": true
    },
    {
      "uid": "airdrop-contacts",
      "title": "AirDrop: Contacts Only",
      "subtitle": "Allow AirDrop from contacts only",
      "arg": "airdrop contacts",
      "icon": { "path": "icon.png" },
      "match": "contacts only friends",
      "valid": true
    },
    {
      "uid": "airdrop-off",
      "title": "AirDrop: Off",
      "subtitle": "Disable AirDrop receiving",
      "arg": "airdrop off",
      "icon": { "path": "icon.png" },
      "match": "off disable nobody none",
      "valid": true
    },
    {
      "uid": "airdrop-status",
      "title": "AirDrop Status",
      "subtitle": "Check current AirDrop setting",
      "arg": "airdrop status",
      "icon": { "path": "icon.png" },
      "match": "status check state",
      "valid": true
    }
  ]
}
EOF
