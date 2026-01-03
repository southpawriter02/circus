#!/bin/bash

# Alfred Script Filter for fc ssh command
# Returns JSON list of ssh actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "ssh-list",
      "title": "SSH: List Keys",
      "subtitle": "Show available SSH keys",
      "arg": "ssh list",
      "icon": { "path": "icon.png" },
      "match": "list show keys available",
      "valid": true
    },
    {
      "uid": "ssh-copy",
      "title": "SSH: Copy Public Key",
      "subtitle": "Copy default public key to clipboard",
      "arg": "ssh copy",
      "icon": { "path": "icon.png" },
      "match": "copy clipboard public key",
      "valid": true
    },
    {
      "uid": "ssh-generate",
      "title": "SSH: Generate New Key",
      "subtitle": "Generate a new SSH key (opens Terminal)",
      "arg": "ssh generate",
      "icon": { "path": "icon.png" },
      "match": "generate new create key",
      "valid": true
    },
    {
      "uid": "ssh-add",
      "title": "SSH: Add to Agent",
      "subtitle": "Add SSH key to ssh-agent",
      "arg": "ssh add",
      "icon": { "path": "icon.png" },
      "match": "add agent keychain",
      "valid": true
    }
  ]
}
EOF
