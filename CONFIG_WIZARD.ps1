# ============================================
# Windows Backup Configuration Wizard
# Interactive folder and location selection
# ============================================

param(
    [string]$ConfigFile = ""
)

# Display header
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  BACKUP CONFIGURATION WIZARD" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Repo: https://github.com/SibtainOcn/Backup-Automation.git" -ForegroundColor Gray
Write-Host "Dev: SibtainOcn" -ForegroundColor Gray
Write-Host ""

Write-Host "WHAT IS INCLUDED IN THIS BACKUP:" -ForegroundColor Green
Write-Host "  + COMPLETE SOFTWARE LISTS" -ForegroundColor White
Write-Host "    - Installed Softwares (WinGet, Win32, 64-bit, Store Apps)" -ForegroundColor Gray
Write-Host "    - Runtimes & Legacy Components" -ForegroundColor Gray
Write-Host "    - Windows Enabled Features (WSL, Hyper-V, etc.)" -ForegroundColor Gray
Write-Host "  + STARTUP & TASKS" -ForegroundColor White
Write-Host "    - Startup Apps & Folder Shortcuts" -ForegroundColor Gray
Write-Host "    - Scheduled Tasks" -ForegroundColor Gray
Write-Host "  + WINDOWS NATIVE SETTINGS" -ForegroundColor White
Write-Host "    - Wi-Fi Profiles" -ForegroundColor Gray
Write-Host "    - Personalization (Themes, Wallpaper, Colors)" -ForegroundColor Gray
Write-Host "    - System (Display, Sound, Power Plans, Mouse)" -ForegroundColor Gray
Write-Host "    - Explorer View Settings & Taskbar Layout" -ForegroundColor Gray
Write-Host "    - Clipboard Settings" -ForegroundColor Gray
Write-Host "    - Focus Assist" -ForegroundColor Gray
Write-Host "    - Privacy Settings" -ForegroundColor Gray
Write-Host "    - Notifications" -ForegroundColor Gray
Write-Host "    - Typing/Input Settings" -ForegroundColor Gray
Write-Host "    - Network DNS Settings" -ForegroundColor Gray
Write-Host "    - Multitasking Settings" -ForegroundColor Gray
Write-Host "    - Accessibility Options" -ForegroundColor Gray
Write-Host "    - Time Zone & Language" -ForegroundColor Gray
Write-Host "    - Remote Desktop Settings" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "DEFAULT FOLDERS INCLUDED IN BACKUP:" -ForegroundColor Yellow
Write-Host "  - Desktop (excluding backup folders)" -ForegroundColor White
Write-Host "  - Documents" -ForegroundColor White
Write-Host "  - Downloads" -ForegroundColor White
Write-Host "  - Pictures" -ForegroundColor White
Write-Host "  - Music" -ForegroundColor White
Write-Host "  - Videos" -ForegroundColor White
Write-Host "  - Favorites" -ForegroundColor White
Write-Host "  - Links" -ForegroundColor White
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Initialize arrays
$additionalFolders = @()
$addMore = $true

# Ask for additional folders
while ($addMore) {
    Write-Host "Do you want to ADD ANY OTHER FOLDER to include in backup?" -ForegroundColor Yellow
    $response = Read-Host "(Y/N)"
    
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host ""
        Write-Host "[INFO] Opening folder browser..." -ForegroundColor Cyan
        Write-Host "[INFO] Please select the folder you want to backup" -ForegroundColor Cyan
        Write-Host ""
        
        # Load Windows Forms for folder browser
        Add-Type -AssemblyName System.Windows.Forms
        
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select folder to include in backup"
        $folderBrowser.RootFolder = "MyComputer"
        $folderBrowser.ShowNewFolderButton = $false
        
        if ($folderBrowser.ShowDialog() -eq "OK") {
            $selectedFolder = $folderBrowser.SelectedPath
            Write-Host "[ADDED] " -ForegroundColor Green -NoNewline
            Write-Host $selectedFolder
            $additionalFolders += $selectedFolder
            Write-Host ""
        } else {
            Write-Host "[CANCELLED] No folder selected" -ForegroundColor Yellow
            Write-Host ""
        }
    } else {
        $addMore = $false
    }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Ask for custom backup location
Write-Host "BACKUP TARGET LOCATION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Do you want to choose a CUSTOM LOCATION to save backup?" -ForegroundColor Yellow
Write-Host "(Default: Desktop)" -ForegroundColor Gray

$targetResponse = Read-Host "(Y/Skip)"
$targetFolder = ""

if ($targetResponse -eq "Y" -or $targetResponse -eq "y") {
    Write-Host ""
    Write-Host "[INFO] Opening folder browser for backup location..." -ForegroundColor Cyan
    Write-Host "[INFO] Select where to save the backup (USB, External Drive, etc.)" -ForegroundColor Cyan
    Write-Host ""
    
    Add-Type -AssemblyName System.Windows.Forms
    
    $targetBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $targetBrowser.Description = "Select location to save backup"
    $targetBrowser.RootFolder = "MyComputer"
    $targetBrowser.ShowNewFolderButton = $true
    
    if ($targetBrowser.ShowDialog() -eq "OK") {
        $targetFolder = $targetBrowser.SelectedPath
        Write-Host "[SELECTED] " -ForegroundColor Green -NoNewline
        Write-Host $targetFolder
        Write-Host ""
    } else {
        Write-Host "[CANCELLED] Using default location (Desktop)" -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "[SKIP] Using default location (Desktop)" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Display summary
Write-Host "CONFIGURATION SUMMARY:" -ForegroundColor Green
Write-Host ""

if ($additionalFolders.Count -gt 0) {
    Write-Host "Additional folders to backup: $($additionalFolders.Count)" -ForegroundColor Cyan
    foreach ($folder in $additionalFolders) {
        Write-Host "  + $folder" -ForegroundColor White
    }
} else {
    Write-Host "Additional folders: None" -ForegroundColor Gray
}

Write-Host ""

if ($targetFolder -ne "") {
    Write-Host "Backup location: $targetFolder" -ForegroundColor Cyan
} else {
    Write-Host "Backup location: Desktop (Default)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Save configuration to file
Write-Host "[INFO] Saving configuration..." -ForegroundColor Yellow

$config = @{
    AdditionalFolders = $additionalFolders
    TargetFolder = $targetFolder
}

try {
    $config | ConvertTo-Json | Out-File -FilePath $ConfigFile -Encoding UTF8 -Force
    Write-Host "[SUCCESS] Configuration saved!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Could not save configuration: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Starting backup process in 2 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

Write-Host "This window will close automatically." -ForegroundColor Gray
Start-Sleep -Seconds 1

exit 0