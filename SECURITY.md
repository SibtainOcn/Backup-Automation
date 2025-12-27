# Security Policy



*The Windows Settings Backup & Restore Tool is designed with security and user privacy as top priorities. This document outlines our security practices, what data is collected, and how to report security vulnerabilities.*


## 🛡️ Security Commitments

### What This Tool Does
- \+ **Read-only registry access** - Only exports registry keys, never modifies system files during backup
- \+ **Local-only operations** - No network connections, no data transmission to external servers
- \+ **Transparent code** - Fully open-source, auditable PowerShell and batch scripts
- \+ **Administrator privileges explained** - Required only for legitimate registry exports and file operations
- \+ **User consent** - Interactive prompts before any major operation

### What This Tool Does NOT Do
- ✖ **No telemetry** - No usage tracking or analytics
- ✖ **No external connections** - No internet communication whatsoever
- ✖ **No code obfuscation** - All scripts are human-readable
- ✖ **No credential harvesting** - Browser passwords and app credentials are NOT backed up
- ✖ **No unauthorized modifications** - Only writes to user-selected backup locations

---

## Data Privacy & What Gets Backed Up

### Sensitive Data Included in Backups

The backup **DOES** include:
- \+ **Wi-Fi passwords** (encrypted by Windows, exported via `netsh wlan`)
- \+ **Registry settings** (personalization, system preferences, privacy settings)
- \+ **User files** (Desktop, Documents, Downloads, Pictures, etc.)
- \+ **Network configurations** (DNS settings, TCP/IP parameters)
- \+ **Software lists** (installed programs, startup apps, scheduled tasks)

### Sensitive Data NOT Included

The backup **does NOT** include:
- ✖ **Browser passwords** (use browser sync instead)
- ✖ **Application credentials** (app logins, API keys)
- ✖ **Windows login password** (only system settings)
- ✖ **Encryption keys** (BitLocker, EFS keys not included)
- ✖ **Windows product key** (only activation status for reference)

### Storage Recommendations

**⚠️ Important:** Backups contain personal data and should be stored securely:

1. **Use encrypted external drives** for backup storage
2. **Password-protect backup archives** (ZIP with password, 7-Zip AES-256)
3. **Avoid cloud storage** unless using end-to-end encryption
4. **Never share backups publicly** or on unsecured networks
5. **Delete old backups** you no longer need

---

##  Antivirus False Positives

### Why Antivirus Software May Flag This Tool

This tool requires deep system access which triggers heuristic detection:

**Legitimate reasons for high permissions:**
- Reads 60+ registry keys across HKCU and HKLM
- Exports system configurations via `reg.exe`
- Executes PowerShell scripts with `-ExecutionPolicy Bypass`
- Uses `robocopy` for file operations
- Requests Administrator elevation

**This is NOT malware.** The tool:
- Has no network capabilities
- Doesn't inject code into other processes
- Doesn't encrypt or lock files (ransomware behavior)
- Doesn't hide its operations

### Mitigation Strategies

**Automatic Windows Defender Exclusion:**
The launcher (`BACKUP_LAUNCHER.bat`) automatically attempts to add itself to Windows Defender exclusions:

```batch
powershell -Command "Add-MpPreference -ExclusionPath '%~dp0'"
```

**Manual Third-Party Antivirus:**
1. Open your antivirus settings
2. Find "Exclusions" or "Whitelist" section
3. Add the tool's folder path
4. Re-run the backup

**Verification:**
- Review the open-source code on GitHub
- Scan with multiple antivirus engines (VirusTotal)
- Check digital signatures (if available)

---

## Code Transparency

### Script Execution Flow

**Backup Process:**
1. `BACKUP_LAUNCHER.bat` - Entry point, requests admin, adds AV exclusions
2. `CONFIG_WIZARD.ps1` - Interactive GUI for folder selection
3. `CONFIG_AUTOMATE.ps1` - Main backup engine (exports registry, copies files)
4. Creates `RESTORE_SETTINGS.ps1` for later restoration

**Restore Process:**
1. `02_RESTORE_LAUNCHER.bat` - Restore entry point with AV exclusions
2. `RESTORE_SETTINGS.ps1` - Imports .reg files, restores settings

### No Hidden Operations

- All scripts are plain-text PowerShell (.ps1) and Batch (.bat)
- No compiled executables (.exe)
- No encoded or obfuscated commands (except standard `-EncodedCommand` fallback)
- All registry operations use standard Windows `reg.exe`

### Audit the Code

Before running, you can inspect:
- `BACKUP_LAUNCHER.bat` - 370 lines
- `CONFIG_WIZARD.ps1` - 170 lines
- `CONFIG_AUTOMATE.ps1` - 850+ lines
- All code available at: https://github.com/SibtainOcn/Backup-Automation

---

## 🛠️ Administrator Privileges Explained

### Why Administrator Access is Required

**Registry Exports (HKLM keys):**
```powershell
HKLM:\SYSTEM\CurrentControlSet\Control\Power
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication
```
These system-wide keys require admin to read.

**Network Configuration Exports:**
```powershell
netsh wlan export profile key=clear
```
Exporting Wi-Fi profiles with passwords requires elevated privileges.

**Robocopy File Operations:**
```powershell
robocopy $source $destination /E /MT:8 /XJ
```
Accessing all user files (including hidden/system files) requires admin.

### What We Do With Admin Access

- \+ Export registry keys to .reg files
- \+ Copy user profile folders
- \+ Read system configurations
- \+ Add Windows Defender exclusions (with user consent)

### What We DON'T Do

- ✖ Modify system files
- ✖ Install drivers or services
- ✖ Create scheduled tasks (except optionally by user)
- ✖ Disable security features
- ✖ Download or execute remote code

---

## 🐛 Reporting Security Vulnerabilities

### Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| Latest  | \+ Yes             |
| Older   |    No (upgrade)    |

### How to Report

**For security vulnerabilities, please:**

1. **DO NOT** open a public GitHub issue
2. **Email:** [Your Email or GitHub Security Advisory]
3. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

**Response Timeline:**
- Initial response: Within 48 hours
- Vulnerability assessment: 7 days
- Fix deployment: 14-30 days (depending on severity)

### Vulnerability Disclosure Policy

- We follow responsible disclosure practices
- Security fixes are prioritized over feature development
- Credit will be given to reporters (unless anonymity is requested)

---

## Best Practices for Users

### Before Running the Backup

1. \+ **Review the code** on GitHub
2. \+ **Scan with antivirus** (expect false positives)
3. \+ **Run from a trusted location** (not from Downloads, email attachments)
4. \+ **Verify digital signatures** (if available)

### During Backup Creation

1. \+ **Choose secure storage** (encrypted USB, external drive)
2. \+ **Don't interrupt** the backup process
3. \+ **Review backup contents** after creation

### Storing Backups

1. \+ **Encrypt the backup folder** (7-Zip AES-256, VeraCrypt)
2. \+ **Store offline** when not in use
3. \+ **Keep multiple versions** (3-2-1 backup rule)
4. \+ **Test restores periodically**

### Before Restoring

1. \+ **Verify backup integrity** (not corrupted)
2. \+ **Backup current settings first** (just in case)
3. \+ **Review restore script** before running
4. \+ **Close all applications** before restore

### After Restore

1. \+ **Restart your PC** (required for settings to apply)
2. \+ **Re-enter Wi-Fi passwords** (may be needed)
3. \+ **Check privacy settings** (ensure nothing unexpected changed)
4. \+ **Verify no unauthorized changes**

---

## ⚠️ Known Limitations & Security Notes

### Recursion Prevention

The tool **automatically excludes** its own backup folders:
```powershell
/XD "WIN_OS_BACKUP_*" /XD "WindowsSettings_Backup_*"
```


### Symbolic Link Handling

Uses `/XJ` flag to skip junctions and symbolic links:
```powershell
robocopy $source $destination /E /XJ
```
This prevents:
- OneDrive cloud-only file issues
- Infinite loops through system junctions
- Access denied errors

### Credential Security

**Wi-Fi Passwords:**
- Exported using Windows encryption via `netsh wlan export profile key=clear`
- Passwords are in plain text in XML files
- **Recommendation:** Encrypt the entire backup folder

**No Browser Passwords:**
- Browser credentials are NOT backed up
- Use browser built-in sync instead
- More secure than storing in plain text

---

##  Security Changelog

### Current Version
- \+ Automatic Windows Defender exclusion
- \+ Universal recursion prevention (2-layer folder structure)
- \+ Multiple execution policy bypass methods
- \+ Symbolic link and junction exclusion
- \+ User consent for all major operations
- \+ No network connections
- \+ Transparent, auditable code

### Future Security Enhancements

Planned improvements:
- 🔄 Optional backup encryption (AES-256)
- 🔄 Checksum verification (SHA-256)
- 🔄 Digital signature for releases
- 🔄 Tamper detection for restore scripts






**General & Support:**
- GitHub Issues: https://github.com/SibtainOcn/Backup-Automation/issues
- Discussions: https://github.com/SibtainOcn/Backup-Automation/discussions

**Verify Authenticity:**
- Official Repository: https://github.com/SibtainOcn/Backup-Automation
- Developer: [@SibtainOcn](https://github.com/SibtainOcn)

---

## 📄 License & Legal

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

**Disclaimer:** This tool is provided "AS IS" without warranty of any kind. Users are responsible for:
- Securing their backups
- Verifying backup integrity
- Testing restores before relying on them
- Compliance with their organization's security policies

---

<div align="center">

** Security is a shared responsibility**

Report issues responsibly | Keep backups secure | Stay informed

**Made with ❤️ by [SibtainOcn](https://github.com/SibtainOcn)**

[⬆️ Back to Top](#security-policy)

</div>

