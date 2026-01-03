#!/bin/bash

# Alfred Script Filter for main 'fc' keyword
# Returns JSON list of all available command categories

cat << 'EOF'
{
  "items": [
    {
      "uid": "fc-wifi",
      "title": "Wi-Fi",
      "subtitle": "Control Wi-Fi adapter (on/off/status)",
      "arg": "",
      "autocomplete": "wifi ",
      "icon": { "path": "icon.png" },
      "match": "wifi wireless network",
      "valid": false
    },
    {
      "uid": "fc-bluetooth",
      "title": "Bluetooth",
      "subtitle": "Control Bluetooth (on/off/status)",
      "arg": "",
      "autocomplete": "bluetooth ",
      "icon": { "path": "icon.png" },
      "match": "bluetooth bt",
      "valid": false
    },
    {
      "uid": "fc-lock",
      "title": "Lock Screen",
      "subtitle": "Lock the screen immediately",
      "arg": "lock now",
      "icon": { "path": "icon.png" },
      "match": "lock screen security",
      "valid": true
    },
    {
      "uid": "fc-caffeine",
      "title": "Caffeine",
      "subtitle": "Prevent Mac from sleeping",
      "arg": "",
      "autocomplete": "caffeine ",
      "icon": { "path": "icon.png" },
      "match": "caffeine sleep awake caffeinate",
      "valid": false
    },
    {
      "uid": "fc-dns",
      "title": "DNS",
      "subtitle": "Manage DNS servers",
      "arg": "",
      "autocomplete": "dns ",
      "icon": { "path": "icon.png" },
      "match": "dns nameserver",
      "valid": false
    },
    {
      "uid": "fc-airdrop",
      "title": "AirDrop",
      "subtitle": "Control AirDrop visibility",
      "arg": "",
      "autocomplete": "airdrop ",
      "icon": { "path": "icon.png" },
      "match": "airdrop share",
      "valid": false
    },
    {
      "uid": "fc-info",
      "title": "System Info",
      "subtitle": "Display system information",
      "arg": "info",
      "icon": { "path": "icon.png" },
      "match": "info system hardware software",
      "valid": true
    },
    {
      "uid": "fc-healthcheck",
      "title": "Health Check",
      "subtitle": "Run system health diagnostics",
      "arg": "healthcheck",
      "icon": { "path": "icon.png" },
      "match": "health check diagnostic",
      "valid": true
    },
    {
      "uid": "fc-disk",
      "title": "Disk",
      "subtitle": "Disk usage and cleanup utilities",
      "arg": "",
      "autocomplete": "disk ",
      "icon": { "path": "icon.png" },
      "match": "disk storage space",
      "valid": false
    },
    {
      "uid": "fc-ssh",
      "title": "SSH",
      "subtitle": "SSH key management",
      "arg": "",
      "autocomplete": "ssh ",
      "icon": { "path": "icon.png" },
      "match": "ssh key",
      "valid": false
    },
    {
      "uid": "fc-keychain",
      "title": "Keychain",
      "subtitle": "Search and manage Keychain passwords",
      "arg": "",
      "autocomplete": "keychain ",
      "icon": { "path": "icon.png" },
      "match": "keychain password",
      "valid": false
    },
    {
      "uid": "fc-clipboard",
      "title": "Clipboard",
      "subtitle": "Clipboard utilities",
      "arg": "",
      "autocomplete": "clipboard ",
      "icon": { "path": "icon.png" },
      "match": "clipboard paste copy",
      "valid": false
    }
  ]
}
EOF
