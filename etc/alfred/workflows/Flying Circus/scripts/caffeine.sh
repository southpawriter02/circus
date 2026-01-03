#!/bin/bash

# Alfred Script Filter for fc caffeine command
# Returns JSON list of caffeine actions

cat << 'EOF'
{
  "items": [
    {
      "uid": "caffeine-on",
      "title": "Caffeine On",
      "subtitle": "Prevent sleep indefinitely",
      "arg": "caffeine on",
      "icon": { "path": "icon.png" },
      "match": "on enable awake prevent sleep",
      "valid": true
    },
    {
      "uid": "caffeine-off",
      "title": "Caffeine Off",
      "subtitle": "Allow sleep again",
      "arg": "caffeine off",
      "icon": { "path": "icon.png" },
      "match": "off disable allow sleep",
      "valid": true
    },
    {
      "uid": "caffeine-for-30",
      "title": "Caffeine for 30 minutes",
      "subtitle": "Prevent sleep for 30 minutes",
      "arg": "caffeine for 30",
      "icon": { "path": "icon.png" },
      "match": "30 minutes half hour",
      "valid": true
    },
    {
      "uid": "caffeine-for-60",
      "title": "Caffeine for 1 hour",
      "subtitle": "Prevent sleep for 60 minutes",
      "arg": "caffeine for 60",
      "icon": { "path": "icon.png" },
      "match": "60 minutes 1 hour one",
      "valid": true
    },
    {
      "uid": "caffeine-for-120",
      "title": "Caffeine for 2 hours",
      "subtitle": "Prevent sleep for 120 minutes",
      "arg": "caffeine for 120",
      "icon": { "path": "icon.png" },
      "match": "120 minutes 2 hours two",
      "valid": true
    },
    {
      "uid": "caffeine-status",
      "title": "Caffeine Status",
      "subtitle": "Check if caffeinate is running",
      "arg": "caffeine status",
      "icon": { "path": "icon.png" },
      "match": "status check state",
      "valid": true
    }
  ]
}
EOF
