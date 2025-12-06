# Feature Specification: `fc qr`

## Overview

**Command:** `fc qr`  
**Purpose:** Generate QR codes from text, URLs, or WiFi credentials.

### Use Cases
- Create QR code for a URL
- Share WiFi credentials via QR
- Generate QR for text/commands
- Create vCard QR codes

---

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `text [content]` | Generate QR from text |
| `url [url]` | Generate QR from URL |
| `wifi [ssid] [password]` | Generate WiFi sharing QR |
| `file [path]` | Generate QR from file contents |

---

## Detailed Behaviors

### `fc qr text [content]`

Generate QR code:

```
$ fc qr text "Hello World"

Generating QR code...

█████████████████████████
██ ▄▄▄▄▄ █ ▄▄▄█ ▄▄▄▄▄ ██
...

Saved to: ~/Desktop/qr-text-20240115.png
```

**Implementation:**
- Use `qrencode` (Homebrew)
- Output to file and display ASCII preview
- Accept `--output` for custom path

---

### `fc qr wifi [ssid] [password]`

WiFi sharing QR:

```
$ fc qr wifi "Home Network" "MyPassword123"

Generating WiFi QR code...

Scan to connect to: Home Network

Saved to: ~/Desktop/qr-wifi-Home_Network.png
```

**Implementation:**
- Format: `WIFI:T:WPA;S:ssid;P:password;;`
- Support WPA/WPA2 and open networks

---

## Dependencies

| Tool | Source | Required |
|------|--------|----------|
| `qrencode` | Homebrew | Yes |

---

## Examples

```bash
# Text QR
fc qr text "https://example.com"

# URL shorthand
fc qr url https://github.com

# WiFi sharing
fc qr wifi "NetworkName" "password123"
```
