# Privacy and Security Profiles

This directory contains security and privacy profiles that can be applied during installation. Each profile represents a different balance between convenience and security/privacy, allowing users to choose the appropriate level for their use case.

## Available Profiles

### Standard (`standard`)

The **default** profile that provides a sensible balance between security and convenience. This is suitable for most users and represents the current default behavior of the installer.

**Settings:**
- Firewall enabled with stealth mode
- Screen saver password required (with no grace period)
- Automatic security updates enabled
- Safari privacy defaults (developer mode, full URL shown)
- Location services enabled for timezone
- Quarantine warnings disabled (power-user convenience)

### Privacy (`privacy`)

An **enhanced privacy** profile that disables telemetry, limits data sharing with Apple and third parties, and strengthens tracking protection. Recommended for users who prioritize data privacy.

**Additional Settings (beyond Standard):**
- Siri disabled (no voice data sent to Apple)
- Spotlight Suggestions disabled (no search queries sent to Apple)
- Location Services disabled (except for Find My Mac)
- Safari Intelligent Tracking Prevention at maximum
- Personalized ads disabled
- Analytics and crash reports disabled
- Safari cross-site tracking prevention enabled
- Diagnostic data sharing disabled

### Lockdown (`lockdown`)

A **maximum security** profile designed for high-risk environments or users with strict security requirements. This profile may reduce convenience but provides the strongest protections.

**Additional Settings (beyond Privacy):**
- Block all incoming connections (firewall set to strictest mode)
- Screensaver activates after 2 minutes with immediate password requirement
- Remote Apple Events disabled
- AirDrop disabled
- Bluetooth disabled when not in use (requires manual toggle)
- Content caching disabled
- Safari JavaScript disabled by default (can be enabled per-site)
- Automatic login disabled
- Guest account disabled
- FileVault enforcement (reminder to enable if not already)

## Usage

Profiles are applied during installation using the `--privacy-profile` flag:

```bash
# Apply standard profile (default behavior)
./install.sh

# Apply enhanced privacy profile
./install.sh --privacy-profile privacy

# Apply maximum security profile
./install.sh --privacy-profile lockdown
```

## Profile Stacking

Profiles are cumulative - each higher-security profile includes all settings from lower profiles:

```
standard → privacy → lockdown
```

This means the `lockdown` profile inherently includes all settings from both `standard` and `privacy`.

## Customization

You can create your own custom profile by:

1. Creating a new `.sh` file in this directory (e.g., `custom.sh`)
2. Following the existing script format and documentation style
3. Using the `--privacy-profile custom` flag during installation

## Combining with Roles

Privacy profiles work independently from installation roles. You can combine any privacy profile with any role:

```bash
# Developer setup with enhanced privacy
./install.sh --role developer --privacy-profile privacy

# Work machine with maximum security
./install.sh --role work --privacy-profile lockdown
```

## Reverting to Standard

To revert from a more restrictive profile to standard settings, you can either:

1. Re-run the installer with `--privacy-profile standard`
2. Manually modify specific settings in System Preferences

## Security Considerations

- The `lockdown` profile may interfere with some workflows that require network services
- Some applications may not function correctly with JavaScript disabled
- Consider your threat model before choosing a profile
- Higher security profiles are recommended for:
  - Handling sensitive data
  - Corporate environments
  - Public or shared computers
  - Journalists, activists, or security researchers

## References

- [Apple Platform Security Guide](https://support.apple.com/guide/security/welcome/web)
- [macOS Security Compliance Project](https://github.com/usnistgov/macos_security)
- [CIS Apple macOS Benchmarks](https://www.cisecurity.org/benchmark/apple_os)
- [NSA Cybersecurity Guidance](https://www.nsa.gov/Cybersecurity/)
