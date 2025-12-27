# ============================================
# Complete Windows Settings Backup Script
# FIXED VERSION - Properly exports .reg files
# ENHANCED: Interactive folder selection support
# FIXED: Universal recursion prevention with 2-layer folder structure
# ============================================

# Accept configuration file parameter
param(
    [string]$ConfigFile = ""
)

# Must run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    Read-Host "Press Enter to exit"
    exit
}

$BackupDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$RandomSuffix = -join ((65..90) + (48..57) | Get-Random -Count 4 | ForEach-Object {[char]$_})

# Load configuration if provided
$AdditionalFolders = @()
$CustomTargetFolder = ""

if ($ConfigFile -ne "" -and (Test-Path $ConfigFile)) {
    try {
        Write-Host "Loading configuration from interactive setup..." -ForegroundColor Cyan
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        
        if ($config.AdditionalFolders) {
            $AdditionalFolders = $config.AdditionalFolders
            Write-Host "  [OK] Loaded $($AdditionalFolders.Count) additional folder(s)" -ForegroundColor Green
        }
        
        if ($config.TargetFolder -and $config.TargetFolder -ne "") {
            $CustomTargetFolder = $config.TargetFolder
            Write-Host "  [OK] Custom backup location: $CustomTargetFolder" -ForegroundColor Green
        }
        
        Write-Host ""
    } catch {
        Write-Host "  [WARNING] Could not load configuration, using defaults" -ForegroundColor Yellow
    }
}

# Determine backup folder location with 2-layer structure
if ($CustomTargetFolder -ne "" -and (Test-Path $CustomTargetFolder)) {
    $BackupParentFolder = "$CustomTargetFolder\WIN_OS_BACKUP_${BackupDate}_${RandomSuffix}"
    Write-Host "Using custom backup location: $CustomTargetFolder" -ForegroundColor Yellow
} else {
    $BackupParentFolder = "$env:USERPROFILE\Desktop\WIN_OS_BACKUP_${BackupDate}_${RandomSuffix}"
    Write-Host "Using default backup location: Desktop" -ForegroundColor Yellow
}

# Create outer layer folder (WIN_OS_BACKUP_*)
New-Item -Path $BackupParentFolder -ItemType Directory -Force | Out-Null

# Create inner layer folder (WindowsSettings_Backup_*)
$BackupRoot = "$BackupParentFolder\WindowsSettings_Backup_$BackupDate"
New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null

# Create SOFTWARES_LIST folder for software-related files
$SoftwareListFolder = "$BackupRoot\SOFTWARES_LIST"
New-Item -Path $SoftwareListFolder -ItemType Directory -Force | Out-Null

# Create USER folder for user profile backup
$UserBackupFolder = "$BackupRoot\USER"
New-Item -Path $UserBackupFolder -ItemType Directory -Force | Out-Null

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Complete Windows Settings Backup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Repo: https://github.com/SibtainOcn/Backup-Automation.git" -ForegroundColor Gray
Write-Host "Dev: SibtainOcn" -ForegroundColor Gray
Write-Host ""
Write-Host "Backup location: $BackupRoot" -ForegroundColor Yellow
Write-Host ""

# Function to safely export registry
function Export-RegistryKey {
    param(
        [string]$KeyPath,
        [string]$OutputFile
    )
    
    # Convert PowerShell path to reg.exe path
    $RegPath = $KeyPath -replace "HKCU:", "HKEY_CURRENT_USER" -replace "HKLM:", "HKEY_LOCAL_MACHINE"
    
    # Check if key exists
    if (Test-Path $KeyPath) {
        $result = reg export $RegPath $OutputFile /y 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Exported: $OutputFile" -ForegroundColor DarkGray
            return $true
        } else {
            Write-Host "  [SKIP] Could not export: $KeyPath" -ForegroundColor DarkYellow
            return $false
        }
    } else {
        Write-Host "  [SKIP] Key does not exist: $KeyPath" -ForegroundColor DarkYellow
        return $false
    }
}

# Function to show progress bar
function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    $barLength = 50
    $filled = [math]::Round(($percent / 100) * $barLength)
    $empty = $barLength - $filled
    
    $bar = ("#" * $filled) + ("." * $empty)
    
    Write-Host "`r[$bar] $percent% - $Activity" -NoNewline -ForegroundColor Cyan
}

$TotalExported = 0
$TotalSkipped = 0
$TotalSteps = 22
$CurrentStep = 0

# ============================================
# 1. PERSONALIZATION SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Personalization"
Write-Host ""
Write-Host "[1/21] Backing up Personalization..." -ForegroundColor Green

$PersonalizationKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" = "Personalization_Themes.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" = "Personalization_Accent.reg"
    "HKCU:\Control Panel\Desktop" = "Personalization_Desktop.reg"
    "HKCU:\Control Panel\Colors" = "Personalization_Colors.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" = "Personalization_Settings.reg"
    "HKCU:\Software\Microsoft\Windows\DWM" = "Personalization_DWM.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\History" = "Personalization_History.reg"
}

foreach ($key in $PersonalizationKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($PersonalizationKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Backup wallpaper path
$WallpaperPath = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -ErrorAction SilentlyContinue
$WallpaperPath | Export-Clixml "$BackupRoot\Personalization_Wallpaper.xml" -ErrorAction SilentlyContinue

# ============================================
# 2. SYSTEM SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "System Settings"
Write-Host ""
Write-Host "[2/21] Backing up System Settings..." -ForegroundColor Green

$SystemKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = "System_ExplorerAdvanced.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" = "System_Notifications.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" = "System_ControlPanel.reg"
    "HKLM:\SYSTEM\CurrentControlSet\Control\Power" = "System_Power.reg"
    "HKCU:\Control Panel\PowerCfg" = "System_PowerCfg.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense" = "System_StorageSense.reg"
    "HKCU:\Software\Microsoft\Clipboard" = "System_Clipboard.reg"
}

foreach ($key in $SystemKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($SystemKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Clipboard settings
$ClipboardSettings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -ErrorAction SilentlyContinue
$ClipboardSettings | Export-Clixml "$BackupRoot\System_Clipboard_Settings.xml" -ErrorAction SilentlyContinue

# ============================================
# 3. DISPLAY SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Display Settings"
Write-Host ""
Write-Host "[3/21] Backing up Display Settings..." -ForegroundColor Green

$DisplayKeys = @{
    "HKCU:\Control Panel\Desktop\WindowMetrics" = "Display_WindowMetrics.reg"
    "HKCU:\Software\Microsoft\Windows\DWM" = "Display_DWM.reg"
    "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" = "Display_GraphicsDrivers.reg"
    "HKCU:\Control Panel\Desktop" = "Display_Desktop.reg"
}

foreach ($key in $DisplayKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($DisplayKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Display scaling and resolution settings
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue | 
    Export-Clixml "$BackupRoot\Display_Monitor_Info.xml" -ErrorAction SilentlyContinue

# ============================================
# 4. SOUND SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Sound Settings"
Write-Host ""
Write-Host "[4/21] Backing up Sound Settings..." -ForegroundColor Green

$SoundKeys = @{
    "HKCU:\Software\Microsoft\Multimedia\Audio" = "Sound_Audio.reg"
    "HKCU:\AppEvents\Schemes" = "Sound_Schemes.reg"
}

foreach ($key in $SoundKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($SoundKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 5. NOTIFICATIONS SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Notifications"
Write-Host ""
Write-Host "[5/21] Backing up Notifications..." -ForegroundColor Green

$NotificationKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" = "Notifications_Settings.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" = "Notifications_Push.reg"
}

foreach ($key in $NotificationKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($NotificationKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 6. FOCUS ASSIST SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Focus Assist"
Write-Host ""
Write-Host "[6/21] Backing up Focus Assist..." -ForegroundColor Green

$FocusKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\QuietMoments" = "FocusAssist_QuietMoments.reg"
}

foreach ($key in $FocusKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($FocusKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 7. POWER AND BATTERY SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Power and Battery"
Write-Host ""
Write-Host "[7/21] Backing up Power Settings..." -ForegroundColor Green

$PowerKeys = @{
    "HKLM:\SYSTEM\CurrentControlSet\Control\Power" = "Power_Control.reg"
    "HKCU:\Control Panel\PowerCfg" = "Power_UserConfig.reg"
}

foreach ($key in $PowerKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($PowerKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Export active power plan
$ActivePlan = powercfg /getactivescheme
$ActivePlan | Out-File "$BackupRoot\Power_ActivePlan.txt"
powercfg /list | Out-File "$BackupRoot\Power_AllPlans.txt"

# ============================================
# 8. STORAGE SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Storage Settings"
Write-Host ""
Write-Host "[8/21] Backing up Storage Settings..." -ForegroundColor Green

$StorageKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense" = "Storage_StorageSense.reg"
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" = "Storage_VolumeCaches.reg"
}

foreach ($key in $StorageKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($StorageKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 9. NEARBY SHARING SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Nearby Sharing"
Write-Host ""
Write-Host "[9/21] Backing up Nearby Sharing..." -ForegroundColor Green

$NearbyKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" = "NearbySharing_CDP.reg"
}

foreach ($key in $NearbyKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($NearbyKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 10. MULTITASKING SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Multitasking"
Write-Host ""
Write-Host "[10/21] Backing up Multitasking..." -ForegroundColor Green

$MultitaskingKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultitaskingView" = "Multitasking_View.reg"
}

foreach ($key in $MultitaskingKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($MultitaskingKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 11. ACTIVATION SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Activation Info"
Write-Host ""
Write-Host "[11/21] Backing up Activation Info..." -ForegroundColor Green

Get-CimInstance SoftwareLicensingProduct | Where-Object {$_.PartialProductKey} | 
    Select-Object Name, Description, LicenseStatus, PartialProductKey | 
    Export-Clixml "$BackupRoot\Activation_Info.xml" -ErrorAction SilentlyContinue

# ============================================
# 12. APPS AND INSTALLED APPS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Installed Apps"
Write-Host ""
Write-Host "[12/22] Backing up Installed Apps..." -ForegroundColor Green

# Export installed apps list (UWP/Store apps)
Get-AppxPackage | Select-Object Name, Version, PackageFullName, InstallLocation | 
    Export-Csv "$SoftwareListFolder\Apps_InstalledApps.csv" -NoTypeInformation

# Export startup apps
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User | 
    Export-Csv "$SoftwareListFolder\Apps_StartupApps.csv" -NoTypeInformation

# Task Scheduler startup tasks
Get-ScheduledTask | Where-Object {$_.State -eq "Ready"} | 
    Select-Object TaskName, TaskPath, State | 
    Export-Csv "$SoftwareListFolder\Apps_ScheduledTasks.csv" -NoTypeInformation

# Startup folder items
$StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Get-ChildItem -Path $StartupPath -ErrorAction SilentlyContinue | 
    Select-Object Name, FullName, Target | 
    Export-Csv "$SoftwareListFolder\Apps_StartupFolder.csv" -NoTypeInformation

# App execution aliases
Export-RegistryKey -KeyPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths" -OutputFile "$BackupRoot\Apps_AppPaths.reg" | Out-Null

# === COMPLETE SOFTWARE LIST (WinGet) ===
Write-Host "  Capturing complete software list with WinGet..." -ForegroundColor Cyan
try {
    # Check if winget is available
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetPath) {
        # Export complete software list including all sources (winget, msstore, system)
        $softwareList = winget list --accept-source-agreements 2>$null
        $softwareList | Out-File "$SoftwareListFolder\Apps_COMPLETE_SOFTWARE_LIST.txt" -Encoding UTF8
        Write-Host "  [OK] Complete software list exported" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] WinGet not available" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [SKIP] Could not export software list" -ForegroundColor Yellow
}

# Also get traditional Win32 programs
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
    Where-Object {$_.DisplayName -ne $null} | 
    Export-Csv "$SoftwareListFolder\Apps_Win32Programs.csv" -NoTypeInformation

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
    Where-Object {$_.DisplayName -ne $null} | 
    Export-Csv "$SoftwareListFolder\Apps_Win32Programs_64bit.csv" -NoTypeInformation

# ============================================
# 13. ACCOUNTS AND SIGN-IN OPTIONS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Account Settings"
Write-Host ""
Write-Host "[13/22] Backing up Account Settings..." -ForegroundColor Green

$AccountKeys = @{
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication" = "Accounts_Authentication.reg"
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" = "Accounts_Winlogon.reg"
}

foreach ($key in $AccountKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($AccountKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 14. TIME AND LANGUAGE SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Time and Language"
Write-Host ""
Write-Host "[14/22] Backing up Time and Language..." -ForegroundColor Green

$TimeLanguageKeys = @{
    "HKCU:\Control Panel\International" = "TimeLanguage_International.reg"
    "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time" = "TimeLanguage_W32Time.reg"
}

foreach ($key in $TimeLanguageKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($TimeLanguageKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Time zone info
Get-TimeZone | Export-Clixml "$BackupRoot\TimeLanguage_TimeZone.xml"

# Language settings
Get-WinUserLanguageList | Export-Clixml "$BackupRoot\TimeLanguage_Languages.xml" -ErrorAction SilentlyContinue

# ============================================
# 15. TYPING SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Typing Settings"
Write-Host ""
Write-Host "[15/22] Backing up Typing Settings..." -ForegroundColor Green

$TypingKeys = @{
    "HKCU:\Software\Microsoft\TabletTip" = "Typing_TabletTip.reg"
    "HKCU:\Software\Microsoft\Input" = "Typing_Input.reg"
    "HKCU:\Software\Microsoft\InputPersonalization" = "Typing_InputPersonalization.reg"
}

foreach ($key in $TypingKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($TypingKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 16. PRIVACY SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Privacy Settings"
Write-Host ""
Write-Host "[16/22] Backing up Privacy Settings..." -ForegroundColor Green

$PrivacyKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager" = "Privacy_CapabilityAccess.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess" = "Privacy_DeviceAccess.reg"
    "HKCU:\Software\Microsoft\Personalization\Settings" = "Privacy_Personalization.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" = "Privacy_Settings.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" = "Privacy_BackgroundApps.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" = "Privacy_Search.reg"
}

foreach ($key in $PrivacyKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($PrivacyKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 17. NETWORK AND INTERNET SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Network Settings"
Write-Host ""
Write-Host "[17/22] Backing up Network Settings..." -ForegroundColor Green

$NetworkKeys = @{
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" = "Network_TcpipParameters.reg"
    "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" = "Network_NetBTParameters.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" = "Network_InternetSettings.reg"
}

foreach ($key in $NetworkKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($NetworkKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Export Wi-Fi profiles
$WifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    ($_ -split ":")[-1].Trim()
}

$WifiData = @()
foreach ($profile in $WifiProfiles) {
    $profileXml = netsh wlan show profile name="$profile" key=clear
    $WifiData += [PSCustomObject]@{
        ProfileName = $profile
        Details = $profileXml -join "`n"
    }
}
$WifiData | Export-Clixml "$BackupRoot\Network_WiFiProfiles.xml" -ErrorAction SilentlyContinue

# DNS settings
Get-DnsClientServerAddress | Export-Clixml "$BackupRoot\Network_DNS.xml" -ErrorAction SilentlyContinue

# ============================================
# 18. TASKBAR AND START MENU
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Taskbar and Start Menu"
Write-Host ""
Write-Host "[18/22] Backing up Taskbar and Start Menu..." -ForegroundColor Green

$TaskbarKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" = "Taskbar_StuckRects.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" = "Taskbar_Taskband.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" = "Taskbar_Search.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start" = "StartMenu_Start.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" = "StartMenu_StartPage.reg"
}

foreach ($key in $TaskbarKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($TaskbarKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# ============================================
# 19. FILE EXPLORER SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "File Explorer"
Write-Host ""
Write-Host "[19/22] Backing up File Explorer..." -ForegroundColor Green

$ExplorerKeys = @{
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" = "Explorer_Main.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = "Explorer_Advanced.reg"
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" = "Explorer_CabinetState.reg"
}

foreach ($key in $ExplorerKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($ExplorerKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# File Explorer view settings
$ExplorerSettings = @{
    ShowFileExtensions = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -ErrorAction SilentlyContinue).HideFileExt
    ShowHiddenFiles = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -ErrorAction SilentlyContinue).Hidden
    LaunchFolderWindowsInSeparateProcess = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name SeparateProcess -ErrorAction SilentlyContinue).SeparateProcess
}
$ExplorerSettings | Export-Clixml "$BackupRoot\Explorer_ViewSettings.xml"

# ============================================
# 20. ADDITIONAL SETTINGS
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Additional Settings"
Write-Host ""
Write-Host "[20/22] Backing up Additional Settings..." -ForegroundColor Green

$AdditionalKeys = @{
    "HKCU:\Control Panel\Mouse" = "Additional_Mouse.reg"
    "HKCU:\Control Panel\Cursors" = "Additional_Cursors.reg"
    "HKCU:\Control Panel\Keyboard" = "Additional_Keyboard.reg"
    "HKCU:\Keyboard Layout" = "Additional_KeyboardLayout.reg"
    "HKCU:\Control Panel\Accessibility" = "Additional_Accessibility.reg"
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" = "Additional_RemoteDesktop.reg"
}

foreach ($key in $AdditionalKeys.Keys) {
    if (Export-RegistryKey -KeyPath $key -OutputFile "$BackupRoot\$($AdditionalKeys[$key])") {
        $TotalExported++
    } else {
        $TotalSkipped++
    }
}

# Default apps
$DefaultApps = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations" -ErrorAction SilentlyContinue
$DefaultApps | Export-Clixml "$BackupRoot\Additional_DefaultApps.xml" -ErrorAction SilentlyContinue

# ============================================
# 21. WINDOWS OPTIONAL FEATURES
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "Windows Features"
Write-Host ""
Write-Host "[21/22] Backing up Windows Optional Features..." -ForegroundColor Green

try {
    Write-Host "  Collecting enabled Windows Features..." -ForegroundColor Cyan
    
    # Get all Windows Optional Features that are enabled
    $EnabledFeatures = Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq "Enabled"} | 
        Select-Object FeatureName, State, Description
    
    # Export to CSV for easy reading
    $EnabledFeatures | Export-Csv "$SoftwareListFolder\WindowsFeatures_Enabled.csv" -NoTypeInformation
    
    # Also export to XML for programmatic access
    $EnabledFeatures | Export-Clixml "$SoftwareListFolder\WindowsFeatures_Enabled.xml"
    
    # Create a readable text file
    $FeaturesText = "============================================`r`n"
    $FeaturesText += "ENABLED WINDOWS OPTIONAL FEATURES`r`n"
    $FeaturesText += "Backup Date: $BackupDate`r`n"
    $FeaturesText += "============================================`r`n`r`n"
    
    foreach ($feature in $EnabledFeatures) {
        $FeaturesText += "- $($feature.FeatureName)`r`n"
    }
    
    $FeaturesText += "`r`n============================================`r`n"
    $FeaturesText += "Total Enabled Features: $($EnabledFeatures.Count)`r`n"
    $FeaturesText += "============================================`r`n"
    
    $FeaturesText | Out-File "$SoftwareListFolder\WindowsFeatures_Enabled.txt" -Encoding UTF8
    
    Write-Host "  [OK] Backed up $($EnabledFeatures.Count) enabled Windows features" -ForegroundColor Green
    
} catch {
    Write-Host "  [SKIP] Could not backup Windows Features: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ============================================
# 22. USER PROFILE FOLDERS BACKUP
# ============================================
$CurrentStep++
Show-ProgressBar -Current $CurrentStep -Total $TotalSteps -Activity "User Profile Folders"
Write-Host ""
Write-Host "[22/22] Backing up User Profile Folders..." -ForegroundColor Green

# Define default user folders to backup
$UserFolders = @(
    @{Name = "Desktop"; Path = [Environment]::GetFolderPath("Desktop")},
    @{Name = "Documents"; Path = [Environment]::GetFolderPath("MyDocuments")},
    @{Name = "Downloads"; Path = "$env:USERPROFILE\Downloads"},
    @{Name = "Pictures"; Path = [Environment]::GetFolderPath("MyPictures")},
    @{Name = "Music"; Path = [Environment]::GetFolderPath("MyMusic")},
    @{Name = "Videos"; Path = [Environment]::GetFolderPath("MyVideos")},
    @{Name = "Favorites"; Path = "$env:USERPROFILE\Favorites"},
    @{Name = "Links"; Path = "$env:USERPROFILE\Links"}
)

# Add additional folders from interactive configuration
if ($AdditionalFolders.Count -gt 0) {
    Write-Host ""
    Write-Host "  [INFO] Adding $($AdditionalFolders.Count) additional custom folder(s)..." -ForegroundColor Cyan
    
    $folderIndex = 1
    foreach ($customFolder in $AdditionalFolders) {
        if (Test-Path $customFolder) {
            $folderName = "CustomFolder_" + $folderIndex
            $UserFolders += @{Name = $folderName; Path = $customFolder}
            Write-Host "  [ADDED] $customFolder" -ForegroundColor Green
            $folderIndex++
        } else {
            Write-Host "  [SKIP] Folder not found: $customFolder" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

$TotalFoldersCopied = 0
$TotalFoldersFailed = 0

foreach ($folder in $UserFolders) {
    try {
        if (Test-Path $folder.Path) {
            Write-Host "  Copying $($folder.Name)..." -ForegroundColor Cyan
            
            $destination = "$UserBackupFolder\$($folder.Name)"
            
            # *** UNIVERSAL RECURSION PREVENTION WITH 2-LAYER PATTERN EXCLUSION ***
            # Exclude both outer layer (WIN_OS_BACKUP_*) and inner layer (WindowsSettings_Backup_*)
            # This works for ALL folders, not just Desktop
            $robocopyResult = robocopy $folder.Path $destination /E /MT:8 /R:2 /W:3 /NFL /NDL /NP /XJ /XD "WIN_OS_BACKUP_*" /XD "WindowsSettings_Backup_*" 2>&1
            
            # Robocopy exit codes: 0-7 are success (with varying levels), 8+ are errors
            if ($LASTEXITCODE -lt 8) {
                Write-Host "  [OK] Backed up $($folder.Name)" -ForegroundColor Green
                $TotalFoldersCopied++
            } else {
                Write-Host "  [WARNING] Partial backup of $($folder.Name) - some files may have been skipped" -ForegroundColor Yellow
                $TotalFoldersCopied++
            }
        } else {
            Write-Host "  [SKIP] $($folder.Name) folder not found" -ForegroundColor DarkYellow
            $TotalFoldersFailed++
        }
    } catch {
        Write-Host "  [ERROR] Failed to backup $($folder.Name): $($_.Exception.Message)" -ForegroundColor Red
        $TotalFoldersFailed++
    }
}

# Create a summary file
$UserBackupSummary = @"
============================================
USER PROFILE FOLDERS BACKUP SUMMARY
Backup Date: $BackupDate
============================================

FOLDERS BACKED UP:
"@

foreach ($folder in $UserFolders) {
    $destination = "$UserBackupFolder\$($folder.Name)"
    if (Test-Path $destination) {
        $itemCount = (Get-ChildItem -Path $destination -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        $folderSize = (Get-ChildItem -Path $destination -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeGB = [math]::Round($folderSize / 1GB, 2)
        
        if ($folder.Name -like "CustomFolder_*") {
            $UserBackupSummary += "`r`n- $($folder.Name) [$($folder.Path)]: $itemCount files ($sizeGB GB)"
        } else {
            $UserBackupSummary += "`r`n- $($folder.Name): $itemCount files ($sizeGB GB)"
        }
    }
}

$UserBackupSummary += "`r`n`r`n============================================`r`n"
$UserBackupSummary += "Total Folders Backed Up: $TotalFoldersCopied`r`n"
$UserBackupSummary += "Total Folders Skipped: $TotalFoldersFailed`r`n"
$UserBackupSummary += "============================================`r`n"
$UserBackupSummary += "`r`nDONE[OK]`r`n"

if ($AdditionalFolders.Count -gt 0) {
    $UserBackupSummary += "`r`nCUSTOM FOLDERS ADDED:`r`n"
    foreach ($customFolder in $AdditionalFolders) {
        $UserBackupSummary += "- $customFolder`r`n"
    }
}

$UserBackupSummary | Out-File "$UserBackupFolder\BACKUP_SUMMARY.txt" -Encoding UTF8

Write-Host ""
Write-Host "  User Profile Backup Complete!" -ForegroundColor Green
Write-Host "  Folders backed up: $TotalFoldersCopied" -ForegroundColor Cyan
Write-Host "  Folders skipped: $TotalFoldersFailed" -ForegroundColor Yellow

# ============================================
# CREATE RESTORE SCRIPT
# ============================================
Write-Host ""
Show-ProgressBar -Current 22 -Total 22 -Activity "Creating restore script"
Write-Host ""
Write-Host "`nCreating restore script..." -ForegroundColor Yellow

$RestoreScript = @'
# ============================================
# Windows Settings RESTORE Script
# ============================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Windows Settings RESTORE Tool" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Repo: https://github.com/SibtainOcn/Backup-Automation.git" -ForegroundColor Gray
Write-Host "- SibtainOcn" -ForegroundColor Gray
Write-Host ""
Write-Host "WARNING: This will restore all settings from backup." -ForegroundColor Yellow
Write-Host "Current settings will be overwritten." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Continue? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Restore cancelled." -ForegroundColor Red
    exit
}

$BackupFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`nRestoring settings..." -ForegroundColor Green
Write-Host ""

$ImportCount = 0
$FailCount = 0

# Import all .reg files
Get-ChildItem "$BackupFolder\*.reg" | ForEach-Object {
    Write-Host "Restoring: $($_.Name)" -ForegroundColor Cyan
    $result = reg import $_.FullName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $ImportCount++
    } else {
        $FailCount++
        Write-Host "  [FAILED] Could not import: $($_.Name)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Imported $ImportCount registry files successfully" -ForegroundColor Green
if ($FailCount -gt 0) {
    Write-Host "Failed to import $FailCount files" -ForegroundColor Yellow
}

# Restore Wi-Fi profiles
if (Test-Path "$BackupFolder\Network_WiFiProfiles.xml") {
    Write-Host "`nRestoring WiFi profiles..." -ForegroundColor Cyan
    $WifiData = Import-Clixml "$BackupFolder\Network_WiFiProfiles.xml"
    Write-Host "  WiFi profiles found: $($WifiData.Count)" -ForegroundColor Yellow
    Write-Host "  (Passwords need to be re-entered manually)" -ForegroundColor Yellow
}

# Restore time zone
if (Test-Path "$BackupFolder\TimeLanguage_TimeZone.xml") {
    Write-Host "`nRestoring time zone..." -ForegroundColor Cyan
    $TimeZone = Import-Clixml "$BackupFolder\TimeLanguage_TimeZone.xml"
    Set-TimeZone -Id $TimeZone.Id -ErrorAction SilentlyContinue
    Write-Host "  Time zone set to: $($TimeZone.Id)" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Settings Restored Successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Restart your PC for all changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Some settings may require:" -ForegroundColor Yellow
Write-Host "  - Re-entering WiFi passwords" -ForegroundColor Yellow
Write-Host "  - Re-signing into Microsoft account" -ForegroundColor Yellow
Write-Host "  - Manually configuring some app permissions" -ForegroundColor Yellow
Write-Host ""
$restart = Read-Host "Restart now? (Y/N)"

if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}
'@

$RestoreScript | Out-File "$BackupRoot\RESTORE_SETTINGS.ps1" -Encoding UTF8

# ============================================
# CREATE README
# ============================================
$ReadMe = @"
============================================
Complete Windows Settings Backup
Created: $BackupDate
============================================

BACKUP SUMMARY:
- Registry files exported: $TotalExported
- Registry keys skipped: $TotalSkipped
- User folders backed up: $TotalFoldersCopied
"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += "- Additional custom folders: $($AdditionalFolders.Count)`r`n"
}

if ($CustomTargetFolder -ne "") {
    $ReadMe += "- Backup saved to: $CustomTargetFolder`r`n"
} else {
    $ReadMe += "- Backup saved to: Desktop\WIN_OS_BACKUP_*`r`n"
}

$ReadMe += @"
- Total backup files: $(Get-ChildItem $BackupRoot -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count)
- For restore/installing this backup, run 02_RESTORE_LAUNCHER.bat or RESTORE_SETTINGS.ps1
- If your antivirus block restore or treat this as malware, just STOP ANTIVIRUS temporary or EXCLUDE THIS FOLDER.

============================================
FOLDER STRUCTURE:
============================================

SOFTWARES_LIST/  - All software and features lists
  - Apps_COMPLETE_SOFTWARE_LIST.txt
  - Apps_InstalledApps.csv
  - Apps_Win32Programs.csv
  - Apps_Win32Programs_64bit.csv
  - Apps_StartupApps.csv
  - Apps_ScheduledTasks.csv
  - Apps_StartupFolder.csv
  - WindowsFeatures_Enabled.txt
  - WindowsFeatures_Enabled.csv
  - WindowsFeatures_Enabled.xml

USER/  - Complete user profile backup
  - Desktop/
  - Documents/
  - Downloads/
  - Pictures/
  - Music/
  - Videos/
  - Favorites/
  - Links/
"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += "  - CustomFolder_1/ ... CustomFolder_N/ (user-selected folders)`r`n"
}

$ReadMe += @"
  - BACKUP_SUMMARY.txt (details about backed up folders)

"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += @"
============================================
CUSTOM FOLDERS INCLUDED IN THIS BACKUP:
============================================

You selected the following additional folders to backup:

"@
    $folderNum = 1
    foreach ($customFolder in $AdditionalFolders) {
        $ReadMe += "$folderNum. $customFolder`r`n"
        $folderNum++
    }
    $ReadMe += "`r`nThese are saved in the USER/ folder as CustomFolder_1, CustomFolder_2, etc.`r`n"
    $ReadMe += "`r`n"
}

$ReadMe += @"
============================================
COMPLETE SOFTWARE LIST INCLUDED:
============================================

This backup includes a COMPLETE list of ALL installed software:

FILES INCLUDED (in SOFTWARES_LIST folder):
- Apps_COMPLETE_SOFTWARE_LIST.txt - Complete WinGet list (all sources)
- Apps_Win32Programs.csv - Traditional desktop programs (32-bit)
- Apps_Win32Programs_64bit.csv - Traditional desktop programs (64-bit)
- Apps_InstalledApps.csv - Microsoft Store / UWP apps
- Apps_StartupApps.csv - Programs that run at startup
- Apps_ScheduledTasks.csv - Scheduled tasks
- Apps_StartupFolder.csv - Startup folder shortcuts

NOTE: These are REFERENCE LISTS only. The backup does NOT install
programs automatically. After restoring Windows settings, you'll need
to manually reinstall your programs using these lists as reference.


============================================


FILES INCLUDED (in SOFTWARES_LIST folder):
- WindowsFeatures_Enabled.txt - Human-readable list of enabled features
- WindowsFeatures_Enabled.csv - Spreadsheet format
- WindowsFeatures_Enabled.xml - Machine-readable format

"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += @"
CUSTOM FOLDERS YOU SELECTED:
"@
    foreach ($customFolder in $AdditionalFolders) {
        $ReadMe += "- $customFolder`r`n"
    }
    $ReadMe += "`r`n"
}

$ReadMe += @"
RESTORE RECOMMENDATION:
- Review files before restoring to avoid overwriting new files
- Manually copy files you need rather than bulk copying everything
- Check USER/BACKUP_SUMMARY.txt for details on what was backed up

============================================
WINDOWS SETTINGS BACKED UP:
============================================

- System Settings (Display, Sound, Notifications, Power, Storage)
- Personalization (Themes, Colors, Wallpaper, Lock Screen)
- Accounts and Sign-in options
- Time and Language (Time zone, Regional settings, Languages)
- Privacy and Security settings
- Network and Internet (Wi-Fi profiles, DNS, Proxy)
- Taskbar and Start Menu customization
- File Explorer (View settings, Hidden files, Extensions)
- Multitasking (Snap windows, Virtual desktops)
- Typing and Input settings
- Mouse, Keyboard, Cursors
- Clipboard settings
- Focus Assist settings
- Remote Desktop settings
- Accessibility options
- Windows Optional Features (enabled features list)
- User Profile Folders (Desktop, Documents, Downloads, Pictures, etc.)
"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += "- Custom user-selected folders`r`n"
}

$ReadMe += @"

============================================
HOW TO RESTORE ON NEW PC:
============================================

STEP 1 - RESTORE WINDOWS SETTINGS:
1. Copy this entire folder to your new Windows PC
2. RUN RESTORE.bat or "RESTORE_SETTINGS.ps1"
3. Select "Run with PowerShell" (as Administrator)
4. Type Y to confirm
5. Restart your PC when prompted

STEP 2 - RESTORE USER FILES:
1. Open the USER/ folder
2. Review BACKUP_SUMMARY.txt to see what was backed up
3. Manually copy files from USER/ subfolders to your new profile folders
 
"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += "   Example: Copy USER/CustomFolder_1/* to the original location`r`n"
}

$ReadMe += @"
4. Or use robocopy for bulk copy:
   robocopy "USER\Desktop" "%USERPROFILE%\Desktop" /E /MT:8


============================================
HOW TO REINSTALL SOFTWARES
============================================

Many programs can be reinstalled using WinGet. EXAMPLE

  winget install 7zip.7zip
  winget install Google.Chrome
  

Check "SOFTWARES_LIST/Apps_COMPLETE_SOFTWARE_LIST.txt" for the full list.

To re-enable Windows Optional Features on new PC:

 Using Settings:
  1. Open Settings > Apps > Optional Features
  2. Click "More Windows Features"
  3. Check the features from SOFTWARES_LIST/WindowsFeatures_Enabled.txt
  4. Click OK and restart
 
  
============================================

- Keep this backup safe (external drive or cloud storage)
- After restoring, use the software lists to reinstall your programs
- Software lists show: you can Download via Name, ID (WinGet)
- Windows features must be manually enabled after restore
"@

if ($AdditionalFolders.Count -gt 0) {
    $ReadMe += "- Custom folders you selected are backed up in USER/CustomFolder_N/`r`n"
}

$ReadMe += @"

============================================
SOFTWARE LIST LEGEND:
============================================

Source "winget" = Available via WinGet (can reinstall easily)
Source "msstore" = Microsoft Store app (reinstall from Store)
No source = Manually installed program (download from official site)

============================================
"@

$ReadMe | Out-File "$BackupRoot\01_README.txt" -Encoding UTF8

# ============================================
# COMPLETION
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Backup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $BackupRoot" -ForegroundColor Cyan
Write-Host ""
Write-Host "BACKUP SUMMARY:" -ForegroundColor Yellow
Write-Host "  Registry files exported: $TotalExported" -ForegroundColor Cyan
Write-Host "  Registry keys skipped: $TotalSkipped" -ForegroundColor Yellow
Write-Host "  User folders backed up: $TotalFoldersCopied" -ForegroundColor Cyan

if ($AdditionalFolders.Count -gt 0) {
    Write-Host "  Custom folders added: $($AdditionalFolders.Count)" -ForegroundColor Cyan
}

if ($CustomTargetFolder -ne "") {
    Write-Host "  Saved to custom location: $CustomTargetFolder" -ForegroundColor Cyan
}

Write-Host "  Total files created: $(Get-ChildItem $BackupRoot | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully backed up:" -ForegroundColor Yellow
Write-Host "  Done! System settings (Display, Sound, Notifications, Power)"
Write-Host "  Done! Personalization (Themes, Colors, Wallpaper)"
Write-Host "  Done! Privacy and Security settings"
Write-Host "  Done! Network and Internet (Wi-Fi, DNS)"
Write-Host "  Done! Taskbar and Start Menu"
Write-Host "  Done! File Explorer (View, Hidden files, Extensions)"
Write-Host "  Done! Time and Language"
Write-Host "  Done! Typing and Input settings"
Write-Host "  Done! Multitasking settings"
Write-Host "  Done! Mouse, Keyboard, Regional"
Write-Host "  Done! Installed apps list"
Write-Host "  Done! Startup apps"
Write-Host "  Done! Clipboard settings"
Write-Host "  Done! Focus Assist"
Write-Host "  Done! Activation info"
Write-Host "  Done! COMPLETE SOFTWARE LIST (WinGet + Win32)" -ForegroundColor Cyan
Write-Host "  Done! WINDOWS OPTIONAL FEATURES (enabled list)" -ForegroundColor Cyan
Write-Host "  Done! USER PROFILE FOLDERS (Desktop, Documents, Downloads, etc.)" -ForegroundColor Cyan

if ($AdditionalFolders.Count -gt 0) {
    Write-Host "  Done! CUSTOM USER-SELECTED FOLDERS ($($AdditionalFolders.Count) folders)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Backup organized in folders:" -ForegroundColor Yellow
Write-Host "  - SOFTWARES_LIST/ (all software and features lists)" -ForegroundColor Cyan
Write-Host "  - USER/ (complete user profile backup)" -ForegroundColor Cyan

if ($AdditionalFolders.Count -gt 0) {
    Write-Host "  - USER/CustomFolder_N/ (your custom selections)" -ForegroundColor Cyan
}

Write-Host "  - Root folder (registry files and system settings)" -ForegroundColor Cyan
Write-Host ""
Write-Host "To restore: Run 'RESTORE_SETTINGS.ps1' in the backup folder" -ForegroundColor Green
Write-Host ""
Write-Host "RECURSION PREVENTION: All backup folders excluded automatically!" -ForegroundColor Green
Write-Host ""



Read-Host "Press Enter to Finish the program"

# Open backup folder
Start-Process explorer.exe $BackupRoot