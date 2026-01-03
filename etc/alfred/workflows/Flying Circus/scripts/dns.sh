#!/bin/bash

# Alfred Script Filter for fc dns command
# Returns JSON list of dns actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "dns-status",
      "title": "DNS Status",
      "subtitle": "Show current DNS servers",
      "arg": "dns status",
      "icon": { "path": "icon.png" },
      "match": "status check current show",
      "valid": true
    },
    {
      "uid": "dns-cloudflare",
      "title": "DNS: Cloudflare",
      "subtitle": "Set DNS to 1.1.1.1 (Cloudflare)",
      "arg": "dns set 1.1.1.1 1.0.0.1",
      "icon": { "path": "icon.png" },
      "match": "cloudflare 1.1.1.1 fast privacy",
      "valid": true
    },
    {
      "uid": "dns-google",
      "title": "DNS: Google",
      "subtitle": "Set DNS to 8.8.8.8 (Google)",
      "arg": "dns set 8.8.8.8 8.8.4.4",
      "icon": { "path": "icon.png" },
      "match": "google 8.8.8.8",
      "valid": true
    },
    {
      "uid": "dns-quad9",
      "title": "DNS: Quad9",
      "subtitle": "Set DNS to 9.9.9.9 (Quad9 - Security focused)",
      "arg": "dns set 9.9.9.9 149.112.112.112",
      "icon": { "path": "icon.png" },
      "match": "quad9 9.9.9.9 security malware",
      "valid": true
    },
    {
      "uid": "dns-clear",
      "title": "DNS: Clear (DHCP)",
      "subtitle": "Clear custom DNS, use DHCP defaults",
      "arg": "dns clear",
      "icon": { "path": "icon.png" },
      "match": "clear reset dhcp default automatic",
      "valid": true
    }
  ]
}
EOF
