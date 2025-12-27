# 📚 Complete Backup Details

This document provides a comprehensive list of all settings and data backed up by the Windows Settings Backup & Restore Tool.

---

## 📋 Registry Files Backed Up (60+ Settings)

### 🎨 Personalization (7 categories)

| File Name | Description |
|-----------|-------------|
| `Personalization_Themes.reg` | Theme configurations and customizations |
| `Personalization_Accent.reg` | Accent colors and color preferences |
| `Personalization_Desktop.reg` | Desktop background and related settings |
| `Personalization_Colors.reg` | System-wide color schemes |
| `Personalization_Settings.reg` | General personalization preferences |
| `Personalization_DWM.reg` | Desktop Window Manager settings |
| `Personalization_History.reg` | Theme history and previous configurations |

### ⚙️ System Settings (7 categories)

| File Name | Description |
|-----------|-------------|
| `System_ExplorerAdvanced.reg` | File Explorer advanced options |
| `System_Notifications.reg` | Notification center preferences |
| `System_ControlPanel.reg` | Control Panel configurations |
| `System_Power.reg` | System power management settings |
| `System_PowerCfg.reg` | Power configuration options |
| `System_StorageSense.reg` | Storage Sense automation settings |
| `System_Clipboard.reg` | Clipboard history and sync preferences |

### 🖥️ Display Settings (4 categories)

| File Name | Description |
|-----------|-------------|
| `Display_WindowMetrics.reg` | Window sizing, borders, and metrics |
| `Display_DWM.reg` | Desktop Window Manager display settings |
| `Display_GraphicsDrivers.reg` | Graphics driver configurations |
| `Display_Desktop.reg` | Desktop display preferences |

### 🔊 Sound Settings (2 categories)

| File Name | Description |
|-----------|-------------|
| `Sound_Audio.reg` | Audio device settings and volumes |
| `Sound_Schemes.reg` | System sound schemes and event sounds |

### 🌐 Network & Internet (8 categories)

| File Name | Description |
|-----------|-------------|
| `Network_TcpipParameters.reg` | TCP/IP network parameters |
| `Network_NetBTParameters.reg` | NetBIOS over TCP/IP settings |
| `Network_InternetSettings.reg` | Internet Explorer and proxy settings |
| `Network_WiFiProfiles.xml` | Wi-Fi profiles with encrypted passwords |
| `Network_DNS.xml` | DNS server configurations |

### 🔐 Privacy & Security (6 categories)

| File Name | Description |
|-----------|-------------|
| `Privacy_CapabilityAccess.reg` | App capability access permissions |
| `Privacy_DeviceAccess.reg` | Device access controls (camera, mic, etc.) |
| `Privacy_Personalization.reg` | Personalization privacy settings |
| `Privacy_Settings.reg` | General privacy preferences |
| `Privacy_BackgroundApps.reg` | Background app access permissions |
| `Privacy_Search.reg` | Search and Cortana privacy settings |

### 📊 Taskbar & Start Menu (5 categories)

| File Name | Description |
|-----------|-------------|
| `Taskbar_StuckRects.reg` | Taskbar position, size, and location |
| `Taskbar_Taskband.reg` | Taskbar band and button settings |
| `Taskbar_Search.reg` | Taskbar search box configuration |
| `StartMenu_Start.reg` | Start menu layout and preferences |
| `StartMenu_StartPage.reg` | Start page and recently used items |

### 📁 File Explorer (3 categories)

| File Name | Description |
|-----------|-------------|
| `Explorer_Main.reg` | Main File Explorer settings |
| `Explorer_Advanced.reg` | Advanced options (hidden files, extensions, etc.) |
| `Explorer_CabinetState.reg` | Folder view states and preferences |

### 🎯 Additional Settings (12 categories)

| File Name | Description |
|-----------|-------------|
| `Additional_Mouse.reg` | Mouse sensitivity, speed, and buttons |
| `Additional_Cursors.reg` | Cursor schemes and pointer settings |
| `Additional_Keyboard.reg` | Keyboard repeat rate and delay |
| `Additional_KeyboardLayout.reg` | Keyboard layouts and input languages |
| `Additional_Accessibility.reg` | Accessibility and ease of access options |
| `Additional_RemoteDesktop.reg` | Remote Desktop connection settings |
| `TimeLanguage_International.reg` | Regional and language settings |
| `TimeLanguage_W32Time.reg` | Windows Time service configuration |
| `Typing_TabletTip.reg` | Touch keyboard settings |
| `Typing_Input.reg` | Input method editor settings |
| `FocusAssist_QuietMoments.reg` | Focus Assist (Quiet Hours) configuration |
| `Multitasking_View.reg` | Snap windows and virtual desktop settings |

### 🔑 Additional XML Exports

| File Name | Description |
|-----------|-------------|
| `Personalization_Wallpaper.xml` | Wallpaper path and settings |
| `System_Clipboard_Settings.xml` | Detailed clipboard preferences |
| `Display_Monitor_Info.xml` | Monitor specifications and capabilities |
| `Activation_Info.xml` | Windows activation status (for reference) |
| `TimeLanguage_TimeZone.xml` | Time zone configuration |
| `TimeLanguage_Languages.xml` | Installed language packs |
| `Explorer_ViewSettings.xml` | File Explorer view preferences |
| `Additional_DefaultApps.xml` | Default application associations |

### 📄 Additional Text Files

| File Name | Description |
|-----------|-------------|
| `Power_ActivePlan.txt` | Currently active power plan |
| `Power_AllPlans.txt` | List of all power plans |

---

## 📦 Software & Features Lists

### Complete Software Inventory

All files are saved in the `SOFTWARES_LIST/` folder:

| File Name | Description |
|-----------|-------------|
| `Apps_COMPLETE_SOFTWARE_LIST.txt` | Complete software list from WinGet (all sources) |
| `Apps_Win32Programs.csv` | Traditional desktop programs (32-bit registry) |
| `Apps_Win32Programs_64bit.csv` | Traditional desktop programs (64-bit registry) |
| `Apps_InstalledApps.csv` | Microsoft Store and UWP applications |
| `Apps_StartupApps.csv` | Programs that run at Windows startup |
| `Apps_ScheduledTasks.csv` | All scheduled tasks (Ready state) |
| `Apps_StartupFolder.csv` | Shortcuts in Startup folder |

### Windows Optional Features

| File Name | Description |
|-----------|-------------|
| `WindowsFeatures_Enabled.txt` | Human-readable list of enabled features |
| `WindowsFeatures_Enabled.csv` | Spreadsheet format (importable) |
| `WindowsFeatures_Enabled.xml` | Machine-readable format for scripts |

**Common features tracked:**
- Windows Subsystem for Linux (WSL)
- Hyper-V
- Developer Mode
- .NET Framework versions
- Windows Sandbox
- Virtual Machine Platform
- Legacy components
- Media features
- Print and Document Services

---

## 👤 User Profile Backup

All files are saved in the `USER/` folder:

### Default Folders Backed Up

| Folder Name | Location | Description |
|-------------|----------|-------------|
| `Desktop/` | `%USERPROFILE%\Desktop` | Desktop files and shortcuts |
| `Documents/` | `%USERPROFILE%\Documents` | User documents |
| `Downloads/` | `%USERPROFILE%\Downloads` | Downloaded files |
| `Pictures/` | `%USERPROFILE%\Pictures` | Photos and images |
| `Music/` | `%USERPROFILE%\Music` | Audio files and music library |
| `Videos/` | `%USERPROFILE%\Videos` | Video files |
| `Favorites/` | `%USERPROFILE%\Favorites` | Browser favorites |
| `Links/` | `%USERPROFILE%\Links` | Quick access links |

### Custom Folders

If you selected additional folders during backup configuration:
- `CustomFolder_1/` - Your first custom selection
- `CustomFolder_2/` - Your second custom selection
- *And so on...*

### Backup Summary

| File Name | Description |
|-----------|-------------|
| `BACKUP_SUMMARY.txt` | Detailed summary of backed up folders with file counts and sizes |

---

## 🔧 Special Features

### Recursion Prevention
The tool automatically excludes:
- `WIN_OS_BACKUP_*` folders (outer layer)
- `WindowsSettings_Backup_*` folders (inner layer)

This prevents infinite loops when backing up Desktop or Documents folders.

### Smart Exclusions
The backup process uses `robocopy` with junction exclusions (`/XJ`) to avoid:
- OneDrive placeholder files
- System junctions
- Symbolic links that could cause issues

---

## 📊 Backup Statistics

After backup completion, the tool provides:
- Total registry files exported
- Total registry keys skipped (if unavailable)
- User folders successfully backed up
- Custom folders included
- Total files created
- Estimated backup size

---

## 🔄 What's NOT Backed Up

For security and practicality reasons, the following are **NOT** backed up:

### ❌ Not Included
- Installed program files (only lists are created)
- Application passwords and credentials
- Browser saved passwords (use browser sync)
- Windows product key (activation info only)
- System drivers
- Windows Update history
- Temporary files and caches

### ✅ Why Not?
- **Programs**: Would create massive backups (GBs). Instead, comprehensive lists are provided for easy reinstallation.
- **Passwords**: Security risk. Use built-in browser sync or password managers.
- **Drivers**: Hardware-specific and better managed by Windows Update.

---

## 📝 Notes

- All registry files are exported in Windows Registry format (`.reg`)
- All lists are in CSV or TXT format for easy reading
- XML files are PowerShell CliXML format
- Backup is portable across different Windows PCs
- No compression applied (for easy access and selective restore)

---

[⬆ Back to Main README](README.md)
