# Frequently Asked Questions (FAQ)

Complete guide to common questions about Windows Settings Backup & Restore Tool.

---

## Backup Questions

### Q: How long does a backup take?
**A:** Typically 2-5 minutes for registry settings, plus additional time for user folders depending on their size. A standard backup with 10GB of user files takes about 5-10 minutes.

### Q: How much space does a backup require?
**A:** Registry settings: ~5-10 MB. User folders vary widely. A typical backup ranges from 100 MB to 20 GB depending on your Documents, Pictures, Downloads, etc.

### Q: Can I backup to an external drive or USB?
**A:** Yes! During configuration, select "Custom Location" and choose your external drive or USB.

### Q: Will backing up Desktop cause infinite loops?
**A:** No. The tool has **universal recursion prevention** that automatically excludes its own backup folders from the backup process.

### Q: Can I run multiple backups?
**A:** Yes. Each backup creates a uniquely named folder with timestamp and random suffix, so they won't overwrite each other.

### Q: Does the backup run in the background?
**A:** No. The backup process runs in an interactive window and shows progress. Don't close the window until completion.

### Q: Can I cancel a backup in progress?
**A:** Yes, press `Ctrl+C` in the PowerShell window. However, the backup may be incomplete.

---

## Restore Questions

### Q: How do I restore settings on a new PC?
**A:** 
1. Copy the entire backup folder to your new PC
2. Run `02_RESTORE_LAUNCHER.bat` as Administrator
3. Confirm the restore when prompted
4. Restart your PC when finished

### Q: Can I restore only specific settings?
**A:** Yes! Each setting is saved as a separate `.reg` file. Simply double-click any `.reg` file to restore only that specific setting.

### Q: Do I need to restore everything at once?
**A:** No. You can:
- Run the full restore script for everything
- Double-click individual `.reg` files for selective restore
- Manually copy specific folders from `USER/`

### Q: Will restore overwrite my current settings?
**A:** Yes. That's why the restore script asks for confirmation first. Always backup your current settings before restoring if you're unsure.

### Q: Why do I need to restart after restore?
**A:** Windows caches many settings in memory. A restart ensures all registry changes are loaded and take full effect across all applications.

### Q: Can I restore multiple times?
**A:** Yes. You can restore as many times as needed. Each restore will overwrite current settings with the backed up versions.

---

## Software & Programs

### Q: Will this backup my installed programs?
**A:** No. It creates **comprehensive lists** of installed programs including:
- Program names and versions
- WinGet IDs (when available)
- Installation paths
- Publishers

This allows you to reinstall programs easily without creating massive backups.

### Q: How do I reinstall programs from the backup?
**A:** 
1. Open `SOFTWARES_LIST/Apps_COMPLETE_SOFTWARE_LIST.txt`
2. Look for programs with WinGet source
3. Use WinGet to reinstall:
   ```bash
   winget install 7zip.7zip
   winget install Google.Chrome
   winget install Microsoft.VisualStudioCode
   ```
4. For programs without WinGet IDs, download from official websites

### Q: Can I install all programs at once?
**A:** Not automatically. You need to manually install each program using the lists as reference. WinGet makes this much faster than downloading each installer manually.

### Q: Are Windows Features backed up?
**A:** The tool backs up a **list** of enabled Windows Optional Features (like WSL, Hyper-V, Developer Mode). You'll need to manually re-enable them on a new PC through:
- Settings → Apps → Optional Features → More Windows Features

### Q: What about Microsoft Store apps?
**A:** The tool exports a list of installed Store apps in `Apps_InstalledApps.csv`. You can reinstall them from the Microsoft Store or using:
```bash
winget install <app-name> --source msstore
```

### Q: Are startup programs backed up?
**A:** Yes, the tool backs up lists of:
- Startup applications (`Apps_StartupApps.csv`)
- Scheduled tasks (`Apps_ScheduledTasks.csv`)
- Startup folder items (`Apps_StartupFolder.csv`)

You'll need to manually reconfigure these after restore.

---

## Security & Privacy

### Q: Are my passwords backed up?
**A:** 
- Wi-Fi passwords: Yes (encrypted by Windows)
- Browser passwords: No (use browser sync)
- App passwords: No (for security)
- Windows login password: No

### Q: Is this tool safe to use?
**A:** Yes. The tool is:
- Open-source (review code on GitHub)
- Only reads registry settings and copies files
- No network connections or data transmission
- No modifications to system files

### Q: Why does my antivirus flag this as malware?
**A:** **This is a false positive.** The tool requires:
- Deep registry read access (60+ keys)
- Administrator privileges
- PowerShell script execution

These trigger heuristic detection in some antivirus software.

**Solution**: 
- The launcher automatically adds Windows Defender exclusions
- For third-party antivirus, manually add the folder to exceptions
- Review the open-source code for transparency

### Q: Will this backup expose my personal data?
**A:** The backup contains:
- Your personal files (Documents, Pictures, etc.)
- System settings and preferences
- Wi-Fi passwords (encrypted)
- Software lists

**Store backups securely:**
- Use encrypted external drives
- Password-protect backup archives
- Don't share backups publicly

### Q: Can someone steal my data from the backup?
**A:** The backup contains personal files just like any normal backup. Use standard backup security practices:
- Store on encrypted drives
- Use password-protected archives
- Keep in secure locations

---

## Network & Wi-Fi

### Q: Are Wi-Fi passwords backed up?
**A:** Yes. Wi-Fi profiles are exported with passwords using Windows encryption via `netsh wlan export profile key=clear`.

### Q: Will Wi-Fi profiles work on a new PC?
**A:** Usually yes, but you may need to re-enter passwords for some networks due to:
- Windows security policies
- Different hardware
- Network authentication requirements

### Q: What about Ethernet/wired network settings?
**A:** TCP/IP parameters and DNS settings are backed up. Adapter-specific settings may need reconfiguration.

### Q: Are VPN settings backed up?
**A:** VPN configurations stored in Windows Settings are backed up. Third-party VPN client settings (NordVPN, ExpressVPN, etc.) need manual reconfiguration.

### Q: Can I share Wi-Fi profiles between computers?
**A:** Technically yes, but it's not recommended for security reasons. Each computer should have its own network profiles.

---

## Technical Questions

### Q: What Windows versions are supported?
**A:** 
- Windows 10 (all versions)
- Windows 11 (all versions)
- Windows Server (partial support)

### Q: Does this work on Windows Server?
**A:** Partially. Registry settings work, but some consumer features (like Store apps, Focus Assist) don't apply to Server editions.

### Q: What PowerShell version is required?
**A:** PowerShell 5.1 or later. This is included by default in:
- Windows 10 (all versions)
- Windows 11 (all versions)

### Q: Can I run this without Administrator privileges?
**A:** No. Administrator access is required for:
- Registry exports (HKLM keys require admin)
- System settings access
- Network configuration exports
- Robocopy file operations

### Q: Does this backup the entire Windows Registry?
**A:** No. It backs up **60+ specific registry keys** related to user settings and preferences. A full registry backup would be:
- Massive in size (hundreds of MB)
- Contain system-specific data
- Unnecessary for migration

### Q: What's the difference between this and Windows System Restore?
**A:** 

| Feature | This Tool | System Restore |
|---------|-----------|----------------|
| Size | Small (MBs) | Large (GBs) |
| Settings | 60+ user settings | System files |
| Portability | Cross-PC | Same PC only |
| Selective restore | Yes | No |
| User files | Yes | No |

---

## Troubleshooting

### Q: "Access Denied" errors during backup
**A:** 
- Run as Administrator (right-click → Run as Administrator)
- Disable antivirus temporarily
- Check folder permissions
- Close applications that might lock files

### Q: Some registry keys were skipped
**A:** This is **normal**. Some keys don't exist on all systems:
- Laptop-specific power settings on desktops
- Touch keyboard settings on non-touch devices
- Graphics settings for unavailable hardware

The tool skips non-existent keys automatically and logs them.

### Q: Backup is taking too long
**A:** 
- Large user folders (Downloads, Documents) slow down backup
- Use SSD instead of slow USB 2.0 drives
- Exclude large folders you don't need backed up
- Check if antivirus is scanning files during copy

### Q: Script execution policy error
**A:** The launcher bypasses this automatically. If issues persist:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

### Q: Some settings didn't restore
**A:** 
- Restart your PC (required for most settings)
- Some apps need to be reopened
- Check Windows Update for driver updates
- Certain settings require apps to be installed first

### Q: Can't restore Wi-Fi profiles
**A:** 
- Re-enter passwords manually (most common)
- Check if Wi-Fi adapter drivers are installed
- Some profiles require admin rights to restore
- Network security policies may prevent import

### Q: Restore script doesn't do anything
**A:**
- Ensure you're running as Administrator
- Check if antivirus is blocking the script
- Look for error messages in the PowerShell window
- Try running individual .reg files manually

### Q: "Cannot find PowerShell scripts" error
**A:** Ensure these files are in the same folder:
- `BACKUP_LAUNCHER.bat`
- `CONFIG_AUTOMATE.ps1`
- `CONFIG_WIZARD.ps1`

### Q: Configuration window closes immediately
**A:** Right-click `BACKUP_LAUNCHER.bat` and select "Run as Administrator".

### Q: "Timeout - No configuration input" message
**A:** The configuration wizard waited 5 minutes without input and auto-closed. Run again and complete configuration within 5 minutes.

---

## File & Folder Questions

### Q: Can I select specific folders to backup?
**A:** Yes! During the configuration wizard:
1. Choose "Y" when asked about additional folders
2. Browse and select any folder on your PC
3. Add multiple custom folders as needed

### Q: What are the default folders backed up?
**A:** 
- Desktop
- Documents
- Downloads
- Pictures
- Music
- Videos
- Favorites
- Links

### Q: Can I exclude certain files or folders?
**A:** Not in the GUI version. Advanced users can edit `CONFIG_AUTOMATE.ps1` and add robocopy exclusions:
```powershell
robocopy $source $destination /E /XD "FolderToExclude" /XF "*.tmp"
```

### Q: Are hidden files backed up?
**A:** Yes. All files including hidden and system files are backed up from selected folders.

### Q: What about OneDrive files?
**A:** 
- Synced locally: Backed up
- Cloud-only files: Skipped (don't exist locally)
- Placeholders: May not restore properly

### Q: Are symbolic links backed up?
**A:** No. Robocopy uses `/XJ` flag to skip junctions and symbolic links, preventing errors and infinite loops.

---

## Migration & New PC Setup

### Q: How do I migrate to a new PC?
**A:** 
1. **On old PC**: Create backup using `BACKUP_LAUNCHER.bat`
2. **Transfer**: Copy backup folder to external drive/USB
3. **On new PC**: 
   - Install Windows
   - Copy backup folder to new PC
   - Run `02_RESTORE_LAUNCHER.bat`
   - Restart PC
4. **Reinstall software** using lists in `SOFTWARES_LIST/`
5. **Re-enable Windows Features** manually

### Q: Will this work across different Windows versions?
**A:** Mostly yes:
- Windows 10 → Windows 11: Works well
- Windows 11 → Windows 10: Most settings compatible
- Older versions: May have compatibility issues

### Q: Can I restore from Windows 10 to Windows 11?
**A:** Yes. Most settings are compatible. Some UI-specific settings (like taskbar position on Windows 11) may need manual adjustment.

### Q: What about different PC hardware?
**A:** Settings restore fine. Driver-dependent settings may need reconfiguration:
- Graphics settings (different GPU)
- Power plans (laptop vs desktop)
- Display settings (different monitors)

### Q: Do I need to install Windows Updates first?
**A:** Recommended but not required. Install critical updates and drivers before restoring settings for best results.

---

## Backup Management

### Q: How often should I backup?
**A:** 
- **Before major changes**: Windows updates, major software installations
- **Monthly**: For regular users
- **Weekly**: For developers or power users
- **Before hardware changes**: New components, system upgrades

### Q: Can I automate backups?
**A:** Not built-in currently. The tool requires user interaction for:
- Configuration selection
- Administrator confirmation
- Progress monitoring

Advanced users can schedule the PowerShell script with Task Scheduler (requires configuration file).

### Q: How do I delete old backups?
**A:** Simply delete the `WIN_OS_BACKUP_*` folders. Each backup is completely self-contained and independent.

### Q: Can I compress backups?
**A:** Yes. After backup completes:
- Right-click backup folder → Send to → Compressed (zipped) folder
- Or use 7-Zip/WinRAR for better compression

The tool doesn't auto-compress to allow easy file access.

### Q: Can I backup to cloud storage?
**A:** Yes. Create backup locally, then:
- Copy to OneDrive/Google Drive/Dropbox folder
- Upload to cloud storage manually
- Ensure backup completes before upload starts

---

## Common Error Messages

### Q: "Please run as Administrator"
**A:** Right-click the `.bat` file and select "Run as Administrator". Standard user permissions are insufficient.

### Q: "Cannot find PowerShell scripts"
**A:** Ensure all files are in the same folder:
- `BACKUP_LAUNCHER.bat`
- `CONFIG_AUTOMATE.ps1`
- `CONFIG_WIZARD.ps1`

### Q: "Access is denied" during registry export
**A:** 
- Some registry keys require admin access
- Run as Administrator
- Disable antivirus temporarily

### Q: "The system cannot find the path specified"
**A:**
- Selected folder was deleted or moved
- Network drive disconnected
- USB drive removed during backup

### Q: Backup folder not created
**A:**
- Check disk space (need at least 1GB free)
- Verify write permissions to target location
- Try different backup location

---

## Still Need Help?

If your question isn't answered here:

- Report a Bug: https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=bug
- Request a Feature: https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=enhancement
- Ask a Question: https://github.com/SibtainOcn/Backup-Automation/issues/new?labels=question
- Star this repo if you found it helpful!

---

## Additional Resources

- [Main README](README.md)
- [Complete Backup Details](BACKUP_DETAILS.md)

---

<div align="center">

**Made with ❤️ by [SibtainOcn](https://github.com/SibtainOcn)**

[⬆ Back to Top](#frequently-asked-questions-faq)

</div>
