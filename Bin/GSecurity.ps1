# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "You need to run this script as an administrator."
    exit
}

:: Autopilot
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverInstall\Restrictions" /v "AllowUserDeviceClasses" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "2" /f

:: Default user
net user defaultuser1 /delete
net user defaultuser100000 /delete

:: Netbios
@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

:: Adapters
wmic path win32_networkadapter where index=3 call disable
wmic path win32_networkadapter where index=4 call disable
wmic path win32_networkadapter where index=5 call disable
wmic path win32_networkadapter where index=6 call disable
wmic path win32_networkadapter where index=7 call disable
wmic path win32_networkadapter where index=8 call disable
wmic path win32_networkadapter where index=9 call disable

:: Install Credential and VBS Guard
Dism /Online /Enable-Feature /FeatureName:"HypervisorPlatform" /NoRestart

:: Install Edge Chromium Sandbox
Dism /Online /Enable-Feature /FeatureName:"Windows-Defender-ApplicationGuard" /NoRestart

:: Disable point of entry for Spectre and Meltdown
dism /online /Disable-Feature /FeatureName:"SMB1Protocol" /NoRestart
dism /Online /Disable-Feature /FeatureName:"SMB1Protocol-Client" /NoRestart
dism /Online /Disable-Feature /FeatureName:"SMB1Protocol-Server" /NoRestart

:: Enable security against PowerShell 2.0 downgrade attacks-
dism /online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellV2Root" /NoRestart
dism /online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellV2" /NoRestart

:: Mitigate Spectre Variant 2 and Meltdown in host operating system
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
wmic cpu get name | findstr "Intel" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 0 /f
)
wmic cpu get name | findstr "AMD" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 64 /f
)

:: WDAC
rem md %windir%\system32\codeintegrity
rem xcopy codeintegrity %windir%\system32\codeintegrity /Y /C /E /H /R /I

:: Drivers
rem %windir%\system32\pnputil /add-driver *.inf /subdirs /install

:: Group Policy
lgpo /g ./

:: variables
for /f "delims=" %%a in ('ver') do ( set "BUILD=%%a" )
setx /m BUILD "%BUILD%"
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%a"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%
for /f "tokens=2 delims==" %%a in ('wmic systemenclosure get ChassisTypes /format:value ^| findstr "ChassisTypes"') do set "ChassisTypes=%%a"
set ChassisTypes=%ChassisTypes:{=% 
set /a ChassisTypes=%ChassisTypes:}=%
setx /m CHASSISTYPE %ChassisTypes%
for /f "tokens=2 delims==" %%a in ('wmic computersystem get manufacturer /format:value ^| findstr "Manufacturer"') do setx /m MANUFACTURER "%%a"
for /f "tokens=2 delims==" %%a in ('wmic computersystem get model /format:value ^| findstr "Model"') do setx /m MODEL "%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfCores /format:value ^| findstr "NumberOfCores"') do ( setx /m NUMBER_OF_CORES %%a ) >nul 2>&1
for /f "tokens=2 delims==" %%a in ('wmic cpu get MaxClockSpeed /format:value ^| findstr "MaxClockSpeed"') do ( setx /m MAX_CLOCK_SPEED %%a ) >nul 2>&1

:: powercfg 
powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 5d76a2ca-e8c0-402f-a133-2158492d58ad -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 7b224883-b3cc-4d79-819f-8374152cbe7c -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 4b92d758-5a24-4851-a470-815d78aee119 -ATTRIB_HIDE
powercfg -attributes 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd +ATTRIB_HIDE
powercfg -attributes 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 +ATTRIB_HIDE
powercfg -attributes 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 +ATTRIB_HIDE
powercfg -attributes 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 +ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f +ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 +ATTRIB_HIDE

:: bcdedit
%windir%\system32\bcdedit /deletevalue allowedinmemorysettings
%windir%\system32\bcdedit /deletevalue avoidlowmemory
%windir%\system32\bcdedit /deletevalue bootems
%windir%\system32\bcdedit /deletevalue bootlog
%windir%\system32\bcdedit /deletevalue bootmenupolicy
%windir%\system32\bcdedit /deletevalue bootux
%windir%\system32\bcdedit /deletevalue debug
%windir%\system32\bcdedit /deletevalue disabledynamictick
%windir%\system32\bcdedit /deletevalue disableelamdrivers
%windir%\system32\bcdedit /deletevalue ems
%windir%\system32\bcdedit /deletevalue extendedinput
%windir%\system32\bcdedit /deletevalue firstmegabytepolicy
%windir%\system32\bcdedit /deletevalue forcefipscrypto
%windir%\system32\bcdedit /deletevalue forcelegacyplatform
%windir%\system32\bcdedit /deletevalue halbreakpoint
%windir%\system32\bcdedit /deletevalue highestmode
%windir%\system32\bcdedit /deletevalue hypervisorlaunchtype
%windir%\system32\bcdedit /deletevalue increaseuserva
%windir%\system32\bcdedit /deletevalue integrityservices
%windir%\system32\bcdedit /deletevalue isolatedcontext
%windir%\system32\bcdedit /deletevalue linearaddress57
%windir%\system32\bcdedit /deletevalue nointegritychecks
%windir%\system32\bcdedit /deletevalue nolowmem 
%windir%\system32\bcdedit /deletevalue noumex 
%windir%\system32\bcdedit /deletevalue nx
%windir%\system32\bcdedit /deletevalue onecpu
%windir%\system32\bcdedit /deletevalue pae
%windir%\system32\bcdedit /deletevalue perfmem
%windir%\system32\bcdedit /deletevalue quietboot
%windir%\system32\bcdedit /deletevalue sos
%windir%\system32\bcdedit /deletevalue testsigning
%windir%\system32\bcdedit /deletevalue tpmbootentropy
%windir%\system32\bcdedit /deletevalue tscsyncpolicy
%windir%\system32\bcdedit /deletevalue usefirmwarepcisettings
%windir%\system32\bcdedit /deletevalue usephysicaldestination
%windir%\system32\bcdedit /deletevalue useplatformclock
%windir%\system32\bcdedit /deletevalue useplatformtick
%windir%\system32\bcdedit /deletevalue vm
%windir%\system32\bcdedit /deletevalue vsmlaunchtype
%windir%\system32\bcdedit.exe /set {current} nx AlwaysOn

:: Delete Provisioning Packages
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning

:: Ram
md "%systemdrive%\Windows\Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Cleaner\"
copy /y devicecleanup.exe "%systemdrive%\Windows\Cleaner\"
schtasks /create /xml "Cleaner.xml" /tn "Cleaner" /ru ""
for /f "tokens=2 delims==" %%s in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%s"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%

:: Riddance
:: Get the currently logged-on username and SID
for /f "tokens=1,2*" %%s in ('whoami /user /fo list ^| findstr /i "name sid"') do (
    set "USERNAME=%%t"
    set "USERSID=%%u"
)

:: Get the RID from the SID
for /f "tokens=5 delims=-" %%r in ("!USERSID!") do set "RID=%%r"

:: List all user accounts and filter by RID
for /f "tokens=*" %%v in ('net user ^| findstr /i /c:"User" ^| find /v "command completed successfully"') do (
    set "USERLINE=%%v"
    set "USERRID=!USERLINE:~-4!"
    if !USERRID! neq !RID! (
        echo Removing user: !USERLINE!
        net user !USERLINE! /delete
    )
)

:: Configure UAC for elevation
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f

:: Display a message
echo Only user %USERNAME% (%USERSID%) has administrative privileges.
echo UAC has been configured for elevation.

:: Tweaks
%windir%\system32\bcdedit /set disabledynamictick yes >nul 2>&1
%windir%\system32\bcdedit /set useplatformtick yes >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "EnabledState" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "EnabledStateOptions" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "Variant" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "VariantPayload" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "VariantPayloadKind" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "EnabledState" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "EnabledStateOptions" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "Variant" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "VariantPayload" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "VariantPayloadKind" /t REG_DWORD /d "0" /f >nul 2>&1
devcon disable "=CDROM" >nul 2>&1
devcon disable "=Printer" >nul 2>&1
devcon disable "=PrintQueue" >nul 2>&1
devcon disable ACPI\HP* >nul 2>&1
devcon disable ACPI\MSFT01* >nul 2>&1
lodctr /r >nul 2>&1
lodctr /r >nul 2>&1

:: Services
sc config Netlogon start= disabled
sc config FastUserSwitchingCompatibility start= disabled
sc config seclogon start= disabled
sc config LanmanServer start= disabled
sc config LanmanWorkstation start= disabled

:: System failure watch off
wmic recoveros set WriteToSystemLog = False
wmic recoveros set SendAdminAlert = False
wmic recoveros set AutoReboot = False
wmic recoveros set DebugInfoType = 0

:: Wifi
REM Get current user SID
for /f "tokens=*" %%a in ('whoami /user /fo csv ^| find "S-1"') do set CURRENT_SID=%%a

REM Check if SID retrieval was successful
if not defined CURRENT_SID (
    echo Error: Unable to retrieve current user SID.
    exit /b 1
)

REM Set the registry values with the current user SID
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!" /v "FeatureStates" /t REG_DWORD /d 0000013c /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH-SKYPE" /v "OptInStatus" /t REG_DWORD /d 00000000 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\FACEBOOK" /v "OptInStatus" /t REG_DWORD /d 00000000 /f

echo Registry values updated successfully for SID: !CURRENT_SID!

:: Deletion
# Define the paths
$paths = @(
    "C:\Program Files (x86)\WindowsPowerShell\Modules\PSReadLine",
    "C:\Program Files\WindowsPowerShell\Modules\PSReadLine",
    "C:\Program Files (x86)\WindowsPowerShell\Modules\PowerShellGet",
    "C:\Program Files\WindowsPowerShell\Modules\PowerShellGet",
    "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester",
    "C:\Program Files\WindowsPowerShell\Modules\Pester",
    [System.Environment]::GetFolderPath("CommonProgramFiles"),
    [System.Environment]::GetFolderPath("CommonProgramW6432")
)

function Get-ProcessesUsingFiles($path) {
    $openFiles = @()
    $processes = Get-Process
    foreach ($process in $processes) {
        try {
            $handleCount = ($process.Modules | Where-Object { $_.FileName -like "$path\*" }).Count
            if ($handleCount -gt 0) {
                $openFiles += $process
            }
        } catch {
            # Ignore errors for processes where we don't have access to the modules
        }
    }
    return $openFiles
}

# Process each path
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Processing path: $path"

        # Get processes using files in this path
        $processes = Get-ProcessesUsingFiles -path $path
        if ($processes) {
            Write-Host "Stopping processes using files in $path..."
            foreach ($process in $processes) {
                Write-Host "Stopping process: $($process.Name) (PID: $($process.Id))"
                Stop-Process -Id $process.Id -Force
            }
        }

        # Get the current ACL
        $acl = Get-Acl $path

        # Clear existing permissions
        $acl.Access | ForEach-Object {
            $acl.RemoveAccessRule($_)
        }

        # Allow current user full control
        $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($username, "FullControl", "Allow")
        $acl.SetAccessRule($permission)

        # Apply the new ACL
        Set-Acl -Path $path -AclObject $acl
        Write-Host "File permissions set for $path"

        # Remove the directory
        Remove-Item -Path $path -Recurse -Force
        Write-Host "$path directory removed"
    } else {
        Write-Host "$path does not exist"
    }
}

:: Devices
Disable-MMAgent -PageCombining
Disable-MMAgent -MemoryCompression

Get-PnpDevice -FriendlyName 'AMD PSP' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'AMD SMBus' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Base System Device' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Composite Bus Enumerator' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'High precision event timer' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Intel SMBus' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Legacy device' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Microsoft GS Wavetable Synth' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Microsoft Kernel Debug Network Adapter' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Microsoft Virtual Drive Enumerator' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'NDIS Virtual Network Adapter Enumerator' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Numeric data processor' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'PCI Data Acquisition and Signal Processing Controller' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'PCI Encryption/Decryption Controller' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'PCI Memory Controller' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'PCI Simple Communications Controller' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Realtek USB 2.0 Card Reader' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'SM Bus Controller' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'System Speaker' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'System Timer' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'UMBus Root Bus Enumerator' | Disable-PnpDevice -confirm:$false

Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force

:: Hosts
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest "https://scripttiger.github.io/alts/compressed/blacklist-fg.txt" -OutFile "C:\Windows\System32\drivers\etc\hosts"
ipconfig /flushdns
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t "REG_DWORD" /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t "REG_DWORD" /d "1" /f

:: Drivers
$UpdateSvc = New-Object -ComObject Microsoft.Update.ServiceManager
$UpdateSvc.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher() 

$Searcher.ServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
$Searcher.SearchScope =  1 # MachineOnly
$Searcher.ServerSelection = 3 # Third Party
          
$Criteria = "IsInstalled=0 and Type='Driver'"
Write-Host('Searching Driver-Updates...') -Fore Green     
$SearchResult = $Searcher.Search($Criteria)          
$Updates = $SearchResult.Updates
if([string]::IsNullOrEmpty($Updates)){
  Write-Host "No pending driver updates."
}
else{
  #Show available Drivers...
  $Updates | select Title, DriverModel, DriverVerDate, Driverclass, DriverManufacturer | fl
  $UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
  $updates | % { $UpdatesToDownload.Add($_) | out-null }
  Write-Host('Downloading Drivers...')  -Fore Green
  $UpdateSession = New-Object -Com Microsoft.Update.Session
  $Downloader = $UpdateSession.CreateUpdateDownloader()
  $Downloader.Updates = $UpdatesToDownload
  $Downloader.Download()
  $UpdatesToInstall = New-Object -Com Microsoft.Update.UpdateColl
  $updates | % { if($_.IsDownloaded) { $UpdatesToInstall.Add($_) | out-null } }

  Write-Host('Installing Drivers...')  -Fore Green
  $Installer = $UpdateSession.CreateUpdateInstaller()
  $Installer.Updates = $UpdatesToInstall
  $InstallationResult = $Installer.Install()
  if($InstallationResult.RebootRequired) { 
  Write-Host('Reboot required! Please reboot now.') -Fore Red
  } else { Write-Host('Done.') -Fore Green }
  $updateSvc.Services | ? { $_.IsDefaultAUService -eq $false -and $_.ServiceID -eq "7971f918-a847-4430-9279-4a52d1efe18d" } | % { $UpdateSvc.RemoveService($_.ServiceID) }
}

:: Network
# Define function to check if a program is installed
function Test-ProgramInstalled {
    param (
        [string]$programName
    )
    
    $programKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $programs = Get-ChildItem $programKey | Get-ItemProperty
    
    foreach ($program in $programs) {
        if ($program.DisplayName -eq $programName) {
            return $true
        }
    }
    
    return $false
}

# Define function to modify Chromium browser preferences
function Modify-ChromiumPreferences {
    param (
        [string]$InstallLocation
    )

    $prefsPath = Join-Path $InstallLocation 'User Data\Default\Preferences'

    if (Test-Path $prefsPath) {
        $prefs = Get-Content $prefsPath | ConvertFrom-Json

        # Modify preferences to block WebRTC and Chrome Remote Desktop
        $prefs.webrtc.ip_handling_policy = "disable_non_proxied_udp"
        $prefs.RemoteAccessHost.client = $false

        # Save modified preferences
        $prefs | ConvertTo-Json | Set-Content $prefsPath
    }
}

# Define list of common browser executables
$browsers = @(
    "chrome.exe",
    "firefox.exe",
    "iexplore.exe",
    "brave.exe",
    "edge.exe",
    "msedge.exe"
    # Add more browsers as needed
)

# Loop through browsers to block internet access
foreach ($browser in $browsers) {
    if (Test-ProgramInstalled $browser) {
        $browserPath = "C:\Program Files\Internet Browsers\$browser"
        Write-Host "Blocking internet access for $browser"
        New-NetFirewallRule -DisplayName "Block $browser internet access" -Direction Outbound -Program $browserPath -Action Block
    }
}

# Get all fixed drives and deny network access
$drives = Get-Volume

foreach ($drive in $drives) {
    $drivePath = $drive.Path
    try {
        # Get current ACL
        $acl = Get-Acl -Path $drivePath

        # Create NETWORK SID and DENY rule
        $networkSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::NetworkSid, $null)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($networkSid, "FullControl", "ContainerInherit, ObjectInherit", "None", "Deny")

        # Add DENY rule to the current ACL
        $acl.AddAccessRule($accessRule)

        # Apply the new ACL
        Set-Acl -Path $drivePath -AclObject $acl

        Write-Host "Successfully denied NETWORK access to $drivePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to deny NETWORK access on $drivePath. Error: $_" -ForegroundColor Red
    }
}

# Get list of installed programs and filter Chromium browsers
$chromiumBrowsers = Get-WmiObject -Query "SELECT * FROM Win32_Product" | Where-Object { $_.Name -like "*Chromium*" }

# Loop through Chromium browsers to modify preferences
foreach ($browser in $chromiumBrowsers) {
    Write-Output "Found Chromium browser: $($browser.Name)"
    Modify-ChromiumPreferences -InstallLocation $browser.InstallLocation
}

:: Perms
# Get TrustedInstaller SID
$trustedInstallerSID = "NT SERVICE\TrustedInstaller"

# Get current user's SID and name
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$currentUserSID = $currentUser.User
$currentUserName = $currentUser.Name

# Set TrustedInstaller as owner of root of all local drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" }
foreach ($drive in $drives) {
    $rootPath = $drive.Root
    Write-Host "Setting TrustedInstaller as owner of $rootPath"
    $acl = Get-Acl $rootPath
    $acl.SetOwner([System.Security.Principal.NTAccount] $trustedInstallerSID)
    Set-Acl -Path $rootPath -AclObject $acl
    Write-Host "TrustedInstaller is now owner of $rootPath"
}

# Set current user as sole owner of %USERPROFILE%
$userProfilePath = [System.Environment]::GetFolderPath("UserProfile")
Write-Host "Setting $currentUserName as sole owner of $userProfilePath"

# Remove all existing access rules
$acl = Get-Acl $userProfilePath
$acl.Access | ForEach-Object {
    $acl.RemoveAccessRule($_)
}

# Set the current user as the sole owner
$acl.SetOwner([System.Security.Principal.NTAccount] $currentUserName)
Set-Acl -Path $userProfilePath -AclObject $acl
Write-Host "$currentUserName is now sole owner of $userProfilePath"


# Take ownership and set permissions on specific files and directories
$files = @("logonui.exe", "winlogon.exe")
foreach ($file in $files) {
    takeown /f "$env:windir\System32\$file"
    icacls "$env:windir\System32\$file" /reset
    icacls "$env:windir\System32\$file" /inheritance:r
    icacls "$env:windir\System32\$file" /deny "NETWORK:F"
    icacls "$env:windir\System32\$file" /grant "SYSTEM:RX"
    icacls "$env:windir\System32\$file" /grant "Administrator:RX"
    icacls "$env:windir\System32\$file" /deny "Users:F"
}
