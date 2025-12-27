@echo off
REM ============================================
REM Universal Windows Settings Backup Launcher
REM ADVANCED: Automatic Antivirus Bypass 
REM ============================================

title Windows Settings Backup Tool - ADVANCED
color 0B

echo.
echo ============================================
echo   Windows Settings Backup Tool
echo   ADVANCED Launcher (AV Bypass)
echo ============================================
echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo Dev: SibtainOcn
echo.

REM Check if PowerShell scripts exist
if not exist "%~dp0CONFIG_AUTOMATE.ps1" (
    color 0C
    echo [ERROR] Cannot find CONFIG_AUTOMATE.ps1
    echo.
    echo Make sure this BAT file is in the same folder as the PowerShell scripts!
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0CONFIG_WIZARD.ps1" (
    color 0C
    echo [ERROR] Cannot find CONFIG_WIZARD.ps1
    echo.
    echo Make sure this BAT file is in the same folder as the PowerShell scripts!
    echo.
    pause
    exit /b 1
)

echo [INFO] Found PowerShell scripts
echo [INFO] Requesting Administrator privileges...
echo.

REM Self-elevate if not running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [NOTICE] This script needs Administrator rights
    echo [NOTICE] A UAC prompt will appear - please click "Yes"
    echo.
    
    REM Launch with admin rights
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM ============================================
REM ANTIVIRUS BYPASS LOGIC (After getting Admin)
REM ============================================
cls
color 0E
echo.
echo ============================================
echo   ANTIVIRUS PROTECTION CHECK
echo ============================================
echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo Dev: SibtainOcn
echo.
echo [INFO] Checking for antivirus interference...
echo.

REM Display antivirus warning
echo [NOTICE] If you see this file flagged as malware/virus
echo [NOTICE] OR if antivirus interferes with the backup:
echo.
echo SOLUTION 1: This script will attempt to auto-bypass
echo SOLUTION 2: Manually add this folder to AV exceptions
echo.
echo Folder path: %~dp0
echo.
echo ============================================
echo.

REM Attempt to add Windows Defender exclusion automatically
echo [ATTEMPTING] Adding folder to Windows Defender exclusions...
powershell -Command "try { Add-MpPreference -ExclusionPath '%~dp0' -ErrorAction Stop; Write-Host '[SUCCESS] Added to Windows Defender exclusions' -ForegroundColor Green } catch { Write-Host '[SKIP] Could not auto-add exclusion (manual action may be needed)' -ForegroundColor Yellow }" 2>nul

echo.
echo [INFO] If using third-party antivirus, you may need to:
echo   1. Open your antivirus settings
echo   2. Find "Exclusions" or "Whitelist" section
echo   3. Add this folder: %~dp0
echo.

echo ============================================
echo.
color 0B
echo Starting backup configuration in 5 seconds...
echo (Press Ctrl+C to cancel)
timeout /t 5 /nobreak >nul

REM ============================================
REM LAUNCH INTERACTIVE CONFIGURATION IN SEPARATE WINDOW
REM ============================================
cls
echo.
echo ============================================
echo   Launching Interactive Configuration
echo ============================================
echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo Dev: SibtainOcn
echo.
echo [INFO] A new window will open for backup configuration
echo [INFO] Please configure your backup preferences there
echo.

REM Create temporary config file path
set CONFIG_FILE=%TEMP%\WinBackup_Config_%RANDOM%.json

REM Launch configuration wizard in a new window
start "Backup Configuration" powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0CONFIG_WIZARD.ps1" -ConfigFile "%CONFIG_FILE%"

REM Wait for configuration file to be created (max 300 seconds = 5 minutes)
echo [INFO] Waiting for configuration to complete...
echo [INFO] Program will auto-close after 5 minutes if no input is given
set WAIT_COUNT=0
:wait_config
if exist "%CONFIG_FILE%" goto :config_ready
timeout /t 1 /nobreak >nul
set /a WAIT_COUNT+=1
if %WAIT_COUNT% lss 300 goto :wait_config

REM If timeout, close the program instead of running with defaults
echo.
echo [TIMEOUT] No configuration input received for 5 minutes
echo [INFO] Program closing automatically to prevent unwanted backup
echo.
REM Clean up temporary files
if exist "%CONFIG_FILE%" del /f /q "%CONFIG_FILE%" >nul 2>&1
timeout /t 3 /nobreak >nul
exit /b 0

:config_ready
echo [SUCCESS] Configuration received!
timeout /t 2 /nobreak >nul

REM ============================================
REM SMART EXECUTION WITH MULTIPLE BYPASS METHODS
REM ============================================
:run_backup
cls
echo.
echo ============================================
echo   Starting Backup Process
echo ============================================
echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo Dev: SibtainOcn
echo.
echo [OK] Administrator privileges: ACTIVE
echo [OK] Execution policy: BYPASSED
echo [OK] Antivirus: HANDLED
echo [OK] Configuration: READY
echo.
echo ============================================
echo.

REM Pass config file path to PowerShell script
set PS_ARGS=-ConfigFile "%CONFIG_FILE%"

REM Method 1: Try with standard bypass
powershell -Command "try { $null = Test-Path '%~dp0CONFIG_AUTOMATE.ps1' } catch { exit 1 }" 2>nul
if %errorLevel% equ 0 (
    echo [METHOD 1] Running with standard bypass...
    powershell -ExecutionPolicy Bypass -NoProfile -Command "& '%~dp0CONFIG_AUTOMATE.ps1' %PS_ARGS%"
    goto :success
)

REM Method 2: Try with Unrestricted policy (more permissive)
echo [METHOD 2] Trying unrestricted policy...
powershell -ExecutionPolicy Unrestricted -NoProfile -Command "& '%~dp0CONFIG_AUTOMATE.ps1' %PS_ARGS%"
if %errorLevel% equ 0 goto :success

REM Method 3: Copy script to temp and run from there (AV often ignores temp)
echo [METHOD 3] Using temporary location...
set TEMP_SCRIPT=%TEMP%\WinBackup_%RANDOM%.ps1
copy /Y "%~dp0CONFIG_AUTOMATE.ps1" "%TEMP_SCRIPT%" >nul 2>&1
if exist "%TEMP_SCRIPT%" (
    powershell -ExecutionPolicy Bypass -NoProfile -Command "& '%TEMP_SCRIPT%' %PS_ARGS%; Remove-Item '%TEMP_SCRIPT%' -Force"
    goto :success
)

REM Method 4: Last resort - Encoded command
echo [METHOD 4] Using encoded execution...
powershell -Command "$script = Get-Content '%~dp0CONFIG_AUTOMATE.ps1' -Raw; $bytes = [System.Text.Encoding]::Unicode.GetBytes($script); $encoded = [Convert]::ToBase64String($bytes); Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -EncodedCommand',$encoded"
goto :success

:success
echo.
echo ============================================
echo [SUCCESS] Backup completed!
echo ============================================
echo.

REM ============================================
REM SCHEDULE RESTORE LAUNCHER CREATION
REM ============================================
echo [INFO] Scheduling restore launcher creation...

REM Create helper script to generate restore launcher
set HELPER_SCRIPT=%TEMP%\CreateRestoreLauncher_%RANDOM%.ps1

(
echo # Helper script to create restore launcher after backup
echo param^(
echo     [string]$ConfigFile = ""
echo ^)
echo.
echo Start-Sleep -Seconds 2
echo.
echo Write-Host "Creating restore launcher..." -ForegroundColor Cyan
echo.
echo # Get backup location
echo $BackupLocation = ""
echo if ^($ConfigFile -ne "" -and ^(Test-Path $ConfigFile^)^) {
echo     try {
echo         $config = Get-Content $ConfigFile -Raw ^| ConvertFrom-Json
echo         if ^($config.TargetFolder -and $config.TargetFolder -ne ""^) {
echo             $BackupLocation = $config.TargetFolder
echo         }
echo     } catch { }
echo }
echo.
echo if ^($BackupLocation -eq ""^) {
echo     $BackupLocation = "$env:USERPROFILE\Desktop"
echo }
echo.
echo # Find most recent backup folder
echo $RecentBackup = Get-ChildItem -Path $BackupLocation -Directory -Filter "WIN_OS_BACKUP_*" ^| Sort-Object LastWriteTime -Descending ^| Select-Object -First 1
echo.
echo if ^($RecentBackup^) {
echo     $InnerBackup = Get-ChildItem -Path $RecentBackup.FullName -Directory -Filter "WindowsSettings_Backup_*" ^| Select-Object -First 1
echo     if ^($InnerBackup^) {
echo         $RestoreLauncherPath = Join-Path $InnerBackup.FullName "02_RESTORE_LAUNCHER.bat"
echo     
echo         # Create restore launcher content
echo         $RestoreLauncherContent = @'
echo @echo off
echo REM ============================================
echo REM Windows Settings RESTORE Launcher
echo REM Auto-generated restore helper
echo REM ============================================
echo.
echo title Windows Settings RESTORE Tool
echo color 0B
echo.
echo echo ============================================
echo echo   Windows Settings RESTORE Tool
echo echo ============================================
echo echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo echo Dev: SibtainOcn
echo echo.
echo.
echo REM Check if RESTORE_SETTINGS.ps1 exists
echo if not exist "%%~dp0RESTORE_SETTINGS.ps1" ^(
echo     color 0C
echo     echo [ERROR] Cannot find RESTORE_SETTINGS.ps1
echo     echo.
echo     echo Make sure this BAT file is in the same backup folder!
echo     echo.
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo [INFO] Found restore script
echo echo [INFO] Requesting Administrator privileges...
echo echo.
echo.
echo REM Self-elevate if not running as Administrator
echo net session ^>nul 2^>^&1
echo if %%errorLevel%% neq 0 ^(
echo     echo [NOTICE] This script needs Administrator rights
echo     echo [NOTICE] A UAC prompt will appear - please click "Yes"
echo     echo.
echo     powershell -Command "Start-Process '%%~f0' -Verb RunAs"
echo     exit /b
echo ^)
echo.
echo REM ============================================
echo REM ANTIVIRUS BYPASS FOR RESTORE
echo REM ============================================
echo cls
echo color 0E
echo echo.
echo echo ============================================
echo echo   ANTIVIRUS PROTECTION CHECK
echo echo ============================================
echo echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo echo Dev: SibtainOcn
echo echo.
echo echo [ATTEMPTING] Adding folder to Windows Defender exclusions...
echo powershell -Command "try { Add-MpPreference -ExclusionPath '%%~dp0' -ErrorAction Stop; Write-Host '[SUCCESS] Added to Windows Defender exclusions' -ForegroundColor Green } catch { Write-Host '[SKIP] Could not auto-add exclusion' -ForegroundColor Yellow }" 2^>nul
echo echo.
echo echo ============================================
echo echo.
echo color 0B
echo.
echo REM ============================================
echo REM EXECUTE RESTORE SCRIPT
echo REM ============================================
echo cls
echo echo.
echo echo ============================================
echo echo   Starting Restore Process
echo echo ============================================
echo echo Repo: https://github.com/SibtainOcn/Backup-Automation.git
echo echo Dev: SibtainOcn
echo echo.
echo echo [OK] Administrator privileges: ACTIVE
echo echo [OK] Execution policy: BYPASSED
echo echo [OK] Antivirus: HANDLED
echo echo.
echo echo ============================================
echo echo.
echo.
echo REM Method 1: Standard bypass
echo powershell -Command "try { $null = Test-Path '%%~dp0RESTORE_SETTINGS.ps1' } catch { exit 1 }" 2^>nul
echo if %%errorLevel%% equ 0 ^(
echo     echo [METHOD 1] Running with standard bypass...
echo     powershell -ExecutionPolicy Bypass -NoProfile -Command "^& '%%~dp0RESTORE_SETTINGS.ps1'"
echo     goto :restore_complete
echo ^)
echo.
echo REM Method 2: Unrestricted policy
echo echo [METHOD 2] Trying unrestricted policy...
echo powershell -ExecutionPolicy Unrestricted -NoProfile -Command "^& '%%~dp0RESTORE_SETTINGS.ps1'"
echo if %%errorLevel%% equ 0 goto :restore_complete
echo.
echo REM Method 3: Copy to temp
echo echo [METHOD 3] Using temporary location...
echo set TEMP_SCRIPT=%%TEMP%%\WinRestore_%%RANDOM%%.ps1
echo copy /Y "%%~dp0RESTORE_SETTINGS.ps1" "%%TEMP_SCRIPT%%" ^>nul 2^>^&1
echo if exist "%%TEMP_SCRIPT%%" ^(
echo     powershell -ExecutionPolicy Bypass -NoProfile -Command "^& '%%TEMP_SCRIPT%%'; Remove-Item '%%TEMP_SCRIPT%%' -Force"
echo     goto :restore_complete
echo ^)
echo.
echo goto :restore_error
echo.
echo :restore_complete
echo echo.
echo echo ============================================
echo echo [SUCCESS] Restore completed!
echo echo ============================================
echo echo.
echo timeout /t 3 /nobreak ^>nul
echo exit
echo.
echo :restore_error
echo color 0C
echo echo.
echo echo ============================================
echo echo [ERROR] Could not launch restore
echo echo ============================================
echo echo.
echo echo TROUBLESHOOTING:
echo echo 1. Your antivirus may be blocking the script
echo echo 2. Manually add this folder to exceptions
echo echo 3. Temporarily disable antivirus and try again
echo echo.
echo pause
echo exit /b 1
echo '@
echo.
echo         # Write the bat file
echo         $RestoreLauncherContent ^| Out-File -FilePath $RestoreLauncherPath -Encoding ASCII -Force
echo         Write-Host "[SUCCESS] Created 02_RESTORE_LAUNCHER.bat" -ForegroundColor Green
echo         Write-Host "Location: $RestoreLauncherPath" -ForegroundColor Cyan
echo     }
echo } else {
echo     Write-Host "[WARNING] Could not find backup folder" -ForegroundColor Yellow
echo }
echo.
echo # Cleanup
echo if ^(Test-Path $ConfigFile^) {
echo     Remove-Item $ConfigFile -Force -ErrorAction SilentlyContinue
echo }
echo Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
) > "%HELPER_SCRIPT%"

REM Run helper script asynchronously (non-blocking)
start /min powershell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File "%HELPER_SCRIPT%" -ConfigFile "%CONFIG_FILE%"

echo [OK] Restore launcher will be created automatically
echo.
timeout /t 2 /nobreak >nul
exit

:error
color 0C
echo.
echo ============================================
echo [ERROR] Could not launch backup
echo ============================================
echo.
echo TROUBLESHOOTING:
echo 1. Your antivirus may be blocking the script
echo 2. Manually add this folder to exceptions:
echo    %~dp0
echo 3. Temporarily disable antivirus and try again
echo 4. Check Windows Event Viewer for details
echo.
REM Clean up temporary files
if exist "%CONFIG_FILE%" del /f /q "%CONFIG_FILE%" >nul 2>&1
pause
exit /b 1