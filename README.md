# 🔄 Windows Settings Backup & Restore Tool

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](https://github.com/SibtainOcn/Backup-Automation/blob/main/LICENSE)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Backup--Automation-blue?logo=github)](https://github.com/SibtainOcn/Backup-Automation)

>  **A lightweight, granular Windows backup solution for developers and power users**

Effortlessly backup and restore your complete Windows environment without massive system images. Perfect for migrating to a new PC, system recovery, or preserving your workflow configuration.

---

## ✨ Features


- <span style="color:red">+</span> Themes, wallpapers, and accent colors
- <span style="color:red">+</span> Desktop background and lock screen
- <span style="color:red">+</span> DWM (Desktop Window Manager) settings
- <span style="color:red">+</span> Color schemes and visual preferences
- <span style="color:red">+</span> Display and monitor configurations
- <span style="color:red">+</span> Sound schemes and audio settings
- <span style="color:red">+</span> Power plans and battery settings
- <span style="color:red">+</span> Storage sense and cleanup preferences
- <span style="color:red">+</span> Clipboard and notification settings
- <span style="color:red">+</span> Wi-Fi profiles and passwords
- <span style="color:red">+</span> DNS configurations
- <span style="color:red">+</span> Network adapter settings
- <span style="color:red">+</span> Internet preferences
- <span style="color:red">+</span> View settings (hidden files, extensions)
- <span style="color:red">+</span> Folder options and layouts
- <span style="color:red">+</span> Quick access preferences
- <span style="color:red">+</span> Navigation pane configuration
- <span style="color:red">+</span> Taskbar position and layout
- <span style="color:red">+</span> Pinned applications
- <span style="color:red">+</span> Start menu customization
- <span style="color:red">+</span> Search settings
- <span style="color:red">+</span> App permissions and capabilities
- <span style="color:red">+</span> Background app access
- <span style="color:red">+</span> Device access settings
 <span style="color:red">+</span> Personalization privacy options
- <span style="color:red">+</span> Complete installed software list (WinGet-ready)
- <span style="color:red">+</span> Win32 programs (32-bit & 64-bit)
- <span style="color:red">+</span> Microsoft Store apps
- <span style="color:red">+</span> Startup applications
- <span style="color:red">+</span> Scheduled tasks
- <span style="color:red">+</span> **Windows Optional Features** (WSL, Hyper-V, Developer Mode, etc.)
- <span style="color:red">+</span> Desktop, Documents, Downloads
- <span style="color:red">+</span> Pictures, Music, Videos
- <span style="color:red">+</span> Favorites and Links
- <span style="color:red">+</span> Custom folder selection support

---

##  Comparison: Why Choose This Tool?

| Feature | This Tool | Commercial Tools<br>(Acronis, Macrium) |
|---------|-----------|----------------------------------------|
| Windows Settings Backup | <span style="color:red">+</span> Complete (60+ registry keys) |  Limited or none |
| Taskbar / Start customization | <span style="color:red">+</span> Yes |  No |
| File Explorer preferences | <span style="color:red">+</span> Yes |  No |
| Privacy settings | <span style="color:red">+</span> Yes |  No |
| Network configs (WiFi) | <span style="color:red">+</span> Yes | ⚠️ Partial |
| Complete software list | <span style="color:red">+</span> Yes (WinGet-ready) | ⚠️ Basic list only |
| Windows Features list | <span style="color:red">+</span> Yes |  No |
| User folders backup | <span style="color:red">+</span> Yes (smart exclusion) | <span style="color:red">+</span> Yes |
| Selective restore | <span style="color:red">+</span> Yes (.reg files) |  Full image only |
| Cross-PC portability | <span style="color:red">+</span> Perfect | ⚠️ Driver issues |
| File size | <span style="color:red">+</span> Small (MBs) |  Huge (GBs) |

---

##  Quick Start

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrator privileges

### Installation

```bash
# Clone the repository
git clone https://github.com/SibtainOcn/Backup-Automation.git

# Navigate to directory
cd Backup-Automation
```

###  Creating a Backup

1. **Run the backup launcher** (Right-click → Run as Administrator)
   ```batch
   BACKUP_LAUNCHER.bat
   ```

2. **Configure your backup**
   - Select additional folders to backup (optional)
   - Choose custom backup location (optional, default: Desktop)

3. **Wait for completion**
   - Backup will be created in `WIN_OS_BACKUP_[date]_[id]` folder

###  Restoring Settings

1. **Copy the backup folder to your new/restored PC**

2. **Run the restore launcher** (Right-click → Run as Administrator)
   ```batch
   02_RESTORE_LAUNCHER.bat
   ```

3. **Restart your PC** for all changes to take effect

---

##  Backup Structure

```
WIN_OS_BACKUP_XX-XX-XX_xxxx/
│
├── WindowsSettings_Backup_2024-12-27/
│   │
│   ├── 01_README.txt                    # Detailed backup information
│   ├── 02_RESTORE_LAUNCHER.bat          # Quick restore launcher
│   ├── RESTORE_SETTINGS.ps1             # Main restore script
│   │
│   ├── SOFTWARES_LIST/                  # 📦 Software inventory
│   │   ├── Apps_COMPLETE_SOFTWARE_LIST.txt
│   │   ├── Apps_InstalledApps.csv
│   │   ├── Apps_Win32Programs.csv
│   │   ├── Apps_StartupApps.csv
│   │   ├── WindowsFeatures_Enabled.txt
│   │   └── ...
│   │
│   ├── USER/                            # 👤 User profile backup
│   │   ├── Desktop/
│   │   ├── Documents/
│   │   ├── Downloads/
│   │   ├── Pictures/
│   │   ├── CustomFolder_1/              # Your custom selections
│   │   └── BACKUP_SUMMARY.txt
│   │
│   └── *.reg files                      #  Registry backups (60+)
│       ├── Personalization_*.reg
│       ├── System_*.reg
│       ├── Privacy_*.reg
│       ├── Network_*.reg
│       └── ...
```

---

##  Use Cases

### [YES] **New PC Setup**
Migrate your entire workflow to a new machine in minutes instead of hours.

### [YES] **System Recovery**
Quickly restore your settings after a fresh Windows installation.

### [YES] **Developer Environments**
Track and restore development tools, WSL, Hyper-V, and other features.

### [YES] **Corporate Deployments**
Standardize settings across multiple machines.

### [YES] **Testing & Experimentation**
Create snapshots before testing new configurations.

---

## 🛡️ Antivirus Notice

> ⚠️ **False Positive Warning**: Some antivirus software may flag this tool as suspicious due to deep registry access.

**This is a FALSE POSITIVE.** The tool requires extensive registry read access to backup your settings.

**Solutions:**
1. <span style="color:red">+</span> The launcher automatically adds exclusions to Windows Defender
2. <span style="color:red">+</span> For third-party antivirus: manually add the folder to exclusions
3. <span style="color:red">+</span> Review the open-source code for transparency

---

## What Gets Backed Up?

<details>
<summary><b>[INCLUDED] Personalization (7 categories)</b></summary>

- Themes and color schemes
- Wallpaper and lock screen
- Desktop Window Manager (DWM) settings
- Accent colors
- Theme history
</details>

<details>
<summary><b>[INCLUDED] System Settings (7 categories)</b></summary>

- Explorer advanced settings
- Notifications preferences
- Control Panel configurations
- Power management
- Storage sense
- Clipboard settings
</details>

<details>
<summary><b>[INCLUDED] Display & Sound (6 categories)</b></summary>

- Window metrics and scaling
- Graphics driver settings
- Monitor configurations
- Audio device settings
- Sound schemes
</details>

<details>
<summary><b>[INCLUDED] Network & Internet (8 categories)</b></summary>

- Wi-Fi profiles (with passwords)
- TCP/IP parameters
- DNS settings
- Internet settings
- Network adapter configs
</details>

<details>
<summary><b>[INCLUDED] Software & Features</b></summary>

- Complete WinGet software list
- Win32 programs (32 & 64-bit)
- Microsoft Store apps
- Startup applications
- Scheduled tasks
- **Windows Optional Features** (WSL, Hyper-V, etc.)
</details>

<details>
<summary><b>[INCLUDED] Privacy & Security (6 categories)</b></summary>

- App permissions
- Capability access manager
- Device access controls
- Background apps
- Search settings
- Personalization privacy
</details>

<details>
<summary><b>[INCLUDED] User Profile</b></summary>

- All standard user folders
- Custom folder selections
- Folder shortcuts
- Quick access items
</details>

➡️ **[See complete list of 60+ backed up settings →](BACKUP_DETAILS.md)**

---

[![Advanced](https://img.shields.io/badge/LEVEL-ADVANCED-blue.svg)](#advanced-features)


###  **Granular Control**
Unlike commercial tools that create monolithic system images, this tool exports individual `.reg` files for each setting category. This allows you to:
- Restore only specific settings
- Review changes before applying
- Manually edit configurations

###  **Smart Recursion Prevention**
The tool automatically excludes its own backup folders during user profile backup, preventing infinite loops even when backing up Desktop or Documents.

###  **WinGet-Ready Software Lists**
Software inventory includes WinGet package IDs, making bulk reinstallation simple:
```bash
# Reinstall all WinGet packages from the list
winget install 7zip.7zip
winget install Google.Chrome
```

###  **Windows Features Tracking**
Keeps a comprehensive list of enabled Windows Optional Features:
- WSL (Windows Subsystem for Linux)
- Hyper-V
- Developer Mode
- .NET Framework versions
- Legacy components
- And more...

---

##Frequently Asked Questions

**Quick answers to common questions:**

<details>
<summary><b>How do I restore settings on a new PC?</b></summary>

1. Copy the entire backup folder to your new PC
2. Run `02_RESTORE_LAUNCHER.bat` or you can also use RESTORE_LAUNCHER.ps1 as Administrator
3. Restart your PC after restoration completes
</details>

<details>
<summary><b>Will this backup my installed programs?</b></summary>

No, it backs up a **list** of installed programs (with WinGet IDs when available). You'll need to reinstall programs manually using the generated lists as reference.
</details>

<details>
<summary><b>Can I restore only specific settings?</b></summary>

Yes! Each setting category is exported as a separate `.reg` file. You can double-click individual `.reg` files to restore only those specific settings.
</details>

<details>
<summary><b>Why does antivirus flag this as malware?</b></summary>

**This is a false positive.** The tool requires deep registry access which triggers some antivirus software. The launcher automatically adds exclusions to Windows Defender. For third-party antivirus, manually add the folder to exclusions.
</details>

<details>
<summary><b>Are passwords backed up?</b></summary>

-  **Wi-Fi passwords**: Yes (encrypted by Windows)
-  **Application passwords**: No (for security)
-  **Browser passwords**: No (use browser sync instead)
</details>

➡️ **[See all FAQs and detailed answers →](FAQ.md)**

---

##  Troubleshooting

### Antivirus blocks the script
**Solution**: Add the folder to your antivirus exclusions. The tool requires deep registry access which triggers false positives.

### "Access Denied" errors
**Solution**: Ensure you're running as Administrator (right-click → Run as Administrator).

### Some settings didn't restore
**Solution**: Some settings require a restart to take effect. Reboot your PC after restoration.

### Wi-Fi profiles won't connect
**Solution**: Wi-Fi profiles are restored but you may need to re-enter passwords for security reasons.

### Script execution policy error
**Solution**: The launcher automatically bypasses execution policy. If issues persist, run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

---

##  Additional Resources

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/SibtainOcn/Backup-Automation/blob/main/LICENSE) file for details.

---

## Acknowledgments

- Built with ❤️ for the Windows power user community
- Inspired by the need for lightweight, portable backup solutions
- Thanks to all users providing feedback and suggestions

---

##  Support

-  [Report a Bug](https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=bug&template=bug_report.md)
-  [Request a Feature](https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=enhancement&template=feature_request.md)
-  [Ask a Question](https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=question)
- ⭐ Star this repo if you find it useful!

---



<div align="center">

**Made with ❤️ by [SibtainOcn](https://github.com/SibtainOcn)**

If this tool saved you time, consider giving it a ⭐!

[⬆ Back to Top](#-windows-settings-backup--restore-tool)

</div>
