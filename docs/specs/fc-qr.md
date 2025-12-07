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
fc qr text "Hello World"

# URL QR
fc qr url https://github.com

# WiFi sharing
fc qr wifi "NetworkName" "password123"

# WiFi with encryption type
fc qr wifi "NetworkName" "password123" --type WPA

# Open network (no password)
fc qr wifi "PublicNetwork" --open

# Custom output path
fc qr text "Message" --output ~/qrcodes/my-code.png

# vCard contact
fc qr vcard "John Doe" --phone "+1234567890" --email "john@example.com"
```

---

## Implementation Notes

### qrencode Installation

```bash
# Install via Homebrew
brew install qrencode
```

### qrencode Options

| Option | Description |
|--------|-------------|
| `-o` | Output file path |
| `-t` | Output type (PNG, SVG, UTF8, ANSI) |
| `-s` | Module size in pixels (default: 3) |
| `-m` | Margin size in modules (default: 4) |
| `-l` | Error correction level (L, M, Q, H) |

```bash
# Generate PNG file
qrencode -o output.png "content"

# Generate ASCII preview in terminal
qrencode -t ANSI "content"

# High error correction for reliability
qrencode -l H -o output.png "content"
```

### WiFi QR Format

WiFi credentials use a specific format:

```
WIFI:T:<type>;S:<ssid>;P:<password>;H:<hidden>;;
```

| Field | Description | Values |
|-------|-------------|--------|
| `T` | Security type | `WPA`, `WEP`, `nopass` |
| `S` | Network SSID | Network name |
| `P` | Password | Plain text password |
| `H` | Hidden network | `true` or `false` |

**Examples:**

```bash
# WPA/WPA2 network
"WIFI:T:WPA;S:MyNetwork;P:MyPassword;;"

# Open network
"WIFI:T:nopass;S:PublicWiFi;;"

# Hidden network
"WIFI:T:WPA;S:HiddenNet;P:Secret;H:true;;"
```

### vCard QR Format

vCard v3.0 format for contact sharing:

```
BEGIN:VCARD
VERSION:3.0
N:Doe;John
FN:John Doe
TEL:+1234567890
EMAIL:john@example.com
END:VCARD
```

### Output Handling

Default behavior:
1. Generate PNG file to `~/Desktop/qr-<type>-<timestamp>.png`
2. Display ASCII preview in terminal
3. Print save location

Custom output:
- Use `--output` to specify path
- Supports PNG and SVG formats
- Create parent directories if needed

### Error Correction Levels

| Level | Recovery | Best For |
|-------|----------|----------|
| L | 7% | Normal use |
| M | 15% | Moderate damage |
| Q | 25% | Heavy use |
| H | 30% | Maximum reliability |

---

## Testing Strategy

### Automated Tests (`bats`)

```bash
# Basic command availability
fc qr --help              # displays usage

# Subcommand validation
fc qr unknown             # returns error for unknown subcommand

# Dependency check
fc qr text "test" 2>&1    # fails gracefully if qrencode not installed
```

### Manual Verification

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Text QR | `fc qr text "Hello"` | PNG created, ASCII preview shown |
| URL QR | `fc qr url https://example.com` | Valid URL QR code |
| WiFi QR | `fc qr wifi "SSID" "pass"` | Scan connects to network |
| Custom output | `fc qr text "test" --output ~/test.png` | File saved to specified path |
| vCard | `fc qr vcard "Name" --phone "123"` | Contact imports on scan |

### Scan Testing

Use phone camera or QR scanner app to verify:
- Text content decodes correctly
- URLs open in browser
- WiFi credentials connect successfully
- vCards import to contacts app

### Edge Cases

- Very long text (QR size limits)
- Special characters in SSID/password
- Unicode text content
- Missing qrencode dependency
- File path with spaces
