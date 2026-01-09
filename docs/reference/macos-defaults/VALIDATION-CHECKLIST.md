# macOS Defaults Documentation Validation Checklist

This document provides criteria and checklists for validating the accuracy and correctness of macOS defaults documentation.

---

## Quick Validation Summary

For each documented setting, verify:

- [ ] **Domain exists** - `defaults read <domain>` doesn't error
- [ ] **Key exists** - Setting appears in domain's preferences
- [ ] **Type is correct** - Boolean, integer, string, float, etc.
- [ ] **Default value is accurate** - Matches fresh macOS install
- [ ] **Values produce described behavior** - Real-world testing confirms
- [ ] **UI location is correct** - Setting found where documented
- [ ] **Source file reference is valid** - Code exists at specified location

---

## Detailed Validation Checklists

### 1. Technical Accuracy

#### Domain Verification
- [ ] Domain can be read without errors: `defaults read <domain>`
- [ ] Domain matches Apple's naming conventions (com.apple.*)
- [ ] For third-party apps, domain matches bundle identifier
- [ ] Domain is consistent between Overview table and Code Examples

#### Key Verification
- [ ] Key exists in the domain: `defaults read <domain> <key>`
- [ ] Key name spelling is exact (case-sensitive)
- [ ] Key matches what's shown in source shell script
- [ ] Special characters in key names are properly escaped in examples

#### Type Verification
- [ ] Documented type matches actual preference type
- [ ] Type in Overview table matches `-type` flag in code examples
- [ ] For ambiguous types, verify with: `defaults read-type <domain> <key>`

| Documented Type | defaults Flag | Verification Command |
|----------------|---------------|---------------------|
| Boolean | `-bool` | Should show `0` or `1` |
| Integer | `-int` | Should show whole number |
| Float | `-float` | Should show decimal number |
| String | `-string` | Should show text value |
| Array | `-array` | Should show list in parens |
| Dictionary | `-dict` | Should show key-value pairs |

#### Value Verification
- [ ] Default value matches fresh macOS installation
- [ ] All documented values are valid for this setting
- [ ] Value ranges are accurate (min/max for integers)
- [ ] Enum values cover all valid options

### 2. Source Cross-Reference

#### Primary Sources (Highest Authority)
- [ ] **Apple Developer Documentation** - Check developer.apple.com
- [ ] **Apple Support Articles** - Check support.apple.com
- [ ] **Apple Man Pages** - `man defaults`, app-specific man pages
- [ ] **System Preferences/Settings UI** - Verify UI labels match

#### Secondary Sources (Corroboration)
- [ ] **defaults-write.com** - Community database of defaults
- [ ] **macos-defaults.com** - Curated defaults collection
- [ ] **GitHub dotfiles repos** - Real-world usage patterns
- [ ] **Stack Overflow/Ask Different** - Community verification
- [ ] **macOS release notes** - Version-specific changes

#### Source Agreement Criteria
| Confidence Level | Criteria |
|-----------------|----------|
| **High** | Apple docs + 2 independent sources agree |
| **Medium** | 2-3 independent sources agree, no Apple docs |
| **Low** | Single source or conflicting information |
| **Unverified** | No external sources found |

### 3. Behavioral Verification

#### Real-World Testing Protocol
```bash
# 1. Record current value
defaults read <domain> <key>

# 2. Set to documented value
defaults write <domain> <key> -<type> <value>

# 3. Verify setting was written
defaults read <domain> <key>

# 4. Test behavior (app restart if needed)
# - Observe UI change
# - Verify functionality
# - Check for side effects

# 5. Reset to original
defaults write <domain> <key> -<type> <original_value>
# OR
defaults delete <domain> <key>
```

#### Behavior Checklist
- [ ] Setting change produces documented effect
- [ ] Documented restart/logout requirements are accurate
- [ ] No undocumented side effects observed
- [ ] Setting persists across app restarts
- [ ] Setting persists across system restarts
- [ ] UI reflects the changed setting (if applicable)

### 4. UI Location Verification

#### Finding Settings in UI
- [ ] Navigate to documented path in System Settings/Preferences
- [ ] UI toggle/control exists at specified location
- [ ] UI label matches or closely matches documented description
- [ ] Changing UI updates the preference value
- [ ] Changing preference value updates UI

#### UI Location Accuracy
| Status | Criteria |
|--------|----------|
| **Exact** | Path and control name match documentation |
| **Approximate** | Path correct, control name slightly different |
| **Moved** | Setting exists but in different location (note macOS version) |
| **Hidden** | No UI exists; command-line only |
| **Removed** | UI removed in recent macOS version |

### 5. Version Compatibility

#### macOS Version Testing
- [ ] Verify setting exists on documented minimum macOS version
- [ ] Note if setting was added in specific macOS version
- [ ] Note if setting was removed or deprecated
- [ ] Note if behavior changed between versions
- [ ] Document version-specific UI location changes

#### Compatibility Matrix Template
| macOS Version | Setting Exists | Behavior Verified | UI Location |
|--------------|----------------|-------------------|-------------|
| Sequoia (15) | ✓/✗ | ✓/✗ | Path or N/A |
| Sonoma (14) | ✓/✗ | ✓/✗ | Path or N/A |
| Ventura (13) | ✓/✗ | ✓/✗ | Path or N/A |
| Monterey (12) | ✓/✗ | ✓/✗ | Path or N/A |

### 6. Documentation Quality

#### Content Completeness
- [ ] Overview table has all required fields
- [ ] Description explains what the setting does
- [ ] Values section lists all valid options
- [ ] Visual demonstration aids understanding
- [ ] Code examples are copy-paste ready
- [ ] Related settings are relevant and accurate
- [ ] Troubleshooting covers common issues
- [ ] References link to valid, authoritative sources

#### Code Example Verification
- [ ] Read command syntax is correct
- [ ] Write command syntax is correct
- [ ] Delete/reset command syntax is correct
- [ ] Commands execute without errors
- [ ] Example values are valid for this setting

#### Link Verification
- [ ] All reference URLs are accessible (not 404)
- [ ] Apple Support links go to relevant articles
- [ ] Source file path is correct relative to repo root
- [ ] Internal cross-references resolve correctly

### 7. Security & Privacy Review

#### Security-Sensitive Settings
- [ ] Security implications are documented
- [ ] Recommended secure values are noted
- [ ] Risks of insecure configurations explained
- [ ] Complies with security best practices

#### Privacy-Sensitive Settings
- [ ] Privacy implications are documented
- [ ] Data collection/sharing behavior explained
- [ ] Privacy-preserving recommendations included
- [ ] GDPR/privacy regulation considerations noted

---

## Validation Workflow

### Per-Document Validation Process

1. **Initial Review**
   - Read entire document for coherence
   - Check for obvious errors or inconsistencies
   - Verify document follows template structure

2. **Technical Verification**
   - Run all code examples on test system
   - Verify domain, key, type, and default value
   - Test each documented value option

3. **Source Cross-Reference**
   - Search Apple documentation for setting
   - Find 2+ independent sources confirming behavior
   - Note any conflicting information

4. **UI Verification**
   - Locate setting in System Settings
   - Verify UI path matches documentation
   - Confirm UI and preference stay in sync

5. **Version Check**
   - Test on current macOS if possible
   - Note any version-specific behavior
   - Update compatibility section if needed

6. **Final Review**
   - All links are valid
   - All code examples work
   - Content is accurate and complete

### Batch Validation for New Documentation

```bash
# Quick validation script for new .mdx files

# 1. Extract domains and keys from documentation
grep -E "^\| \*\*Domain\*\*" *.mdx
grep -E "^\| \*\*Key\*\*" *.mdx

# 2. Test each setting exists
defaults read <domain> <key> 2>/dev/null && echo "EXISTS" || echo "NOT FOUND"

# 3. Verify type
defaults read-type <domain> <key>

# 4. Check default value on fresh system or VM
```

---

## Validation Record Template

Use this template to record validation results for each document:

```markdown
## Validation Record: [setting-name.mdx]

**Validated By:** [Name]
**Validation Date:** [YYYY-MM-DD]
**macOS Version Tested:** [Version]

### Technical Accuracy
- Domain verified: ✓/✗
- Key verified: ✓/✗
- Type verified: ✓/✗
- Default value verified: ✓/✗
- Values produce expected behavior: ✓/✗

### Source Cross-Reference
- Apple documentation: [Found/Not Found] [URL if found]
- Secondary sources: [List sources]
- Source agreement: [High/Medium/Low/Unverified]

### UI Verification
- UI location correct: ✓/✗/N/A
- UI path: [Actual path found]

### Issues Found
- [List any discrepancies or errors]

### Corrections Made
- [List any corrections applied]

### Validation Status: [PASSED/FAILED/NEEDS REVIEW]
```

---

## Common Validation Issues

### Frequent Problems to Check

| Issue | How to Detect | How to Fix |
|-------|--------------|------------|
| Wrong default value | Compare to fresh macOS install | Update Overview table |
| Incorrect type | `defaults read-type` shows different | Update type in docs |
| Key name typo | `defaults read` fails | Check source file for exact name |
| Outdated UI path | Can't find setting in UI | Update for current macOS version |
| Missing restart requirement | Setting doesn't take effect | Add restart instructions |
| Broken reference links | 404 on click | Update or remove link |
| Deprecated setting | Setting has no effect | Add deprecation notice |

### Red Flags Requiring Investigation

- Setting not found in any Apple documentation
- Conflicting information between sources
- Setting exists but produces no observable effect
- Very unusual domain or key naming
- Claims of undocumented or hidden features
- Security-related settings with unusual recommendations

---

## Tools for Validation

### Command-Line Tools
```bash
# Read all preferences for a domain
defaults read <domain>

# Read specific key
defaults read <domain> <key>

# Get type of a preference
defaults read-type <domain> <key>

# Find all domains containing a key
defaults domains | tr ',' '\n' | while read d; do
  defaults read "$d" <key> 2>/dev/null && echo "Found in: $d"
done

# Export domain to XML for inspection
defaults export <domain> - | xmllint --format -

# Watch for preference changes in real-time
fswatch ~/Library/Preferences/<domain>.plist
```

### GUI Tools
- **Prefs Editor** - GUI for viewing/editing preferences
- **PlistEdit Pro** - Professional plist editor
- **Xcode** - Built-in plist viewing

### Online Resources
- [defaults-write.com](https://www.defaults-write.com/)
- [macos-defaults.com](https://macos-defaults.com/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Apple Support](https://support.apple.com/)

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-09 | 1.0 | Initial validation checklist created |

---

## Notes

- Validation should be performed on the oldest supported macOS version when possible
- Some settings may only exist after certain apps are launched
- Third-party app preferences may change with app updates
- Always test on a non-production system when possible
- Some preferences require SIP disabled or root access to modify
