#!/bin/bash

# Alfred Script Filter for fc disk command
# Returns JSON list of disk actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "disk-status",
      "title": "Disk Status",
      "subtitle": "Show disk usage summary",
      "arg": "disk status",
      "icon": { "path": "icon.png" },
      "match": "status overview summary space",
      "valid": true
    },
    {
      "uid": "disk-usage",
      "title": "Disk Usage",
      "subtitle": "Analyze disk usage in current directory",
      "arg": "disk usage",
      "icon": { "path": "icon.png" },
      "match": "usage analyze what using",
      "valid": true
    },
    {
      "uid": "disk-large",
      "title": "Find Large Files",
      "subtitle": "Find the largest files on disk",
      "arg": "disk large",
      "icon": { "path": "icon.png" },
      "match": "large big files find",
      "valid": true
    },
    {
      "uid": "disk-cleanup",
      "title": "Disk Cleanup",
      "subtitle": "Interactive cleanup wizard (opens Terminal)",
      "arg": "disk cleanup",
      "icon": { "path": "icon.png" },
      "match": "cleanup clean free space",
      "valid": true
    }
  ]
}
EOF
