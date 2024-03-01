@echo off
title GSecurity && color 0b

:: Ram
md "%systemdrive%\Windows\Ram Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Ram Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Ram Cleaner\"
schtasks /create /xml "Ram Cleaner.xml" /tn "Ram Cleaner" /ru ""
for /f "tokens=2 delims==" %%s in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%s"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%

:: System failure watch off
wmic recoveros set WriteToSystemLog = False
wmic recoveros set SendAdminAlert = False
wmic recoveros set AutoReboot = False
wmic recoveros set DebugInfoType = 0

:: wifi
for /f "tokens=*" %%w in ('whoami /user /fo csv ^| find "S-1"') do set CURRENT_SID=%%w
echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!" /v "FeatureStates" /t REG_DWORD /d 0x0000013c /f
echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH" /v "OptInStatus" /t REG_DWORD /d 0x00000000 /f
echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\ABCH-SKYPE" /v "OptInStatus" /t REG_DWORD /d 0x00000000 /f
echo Y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\!CURRENT_SID!\SocialNetworks\FACEBOOK" /v "OptInStatus" /t REG_DWORD /d 0x00000000 /f

:: Script execution
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass}"

:: Disable devices
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Management*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Debug*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*bth*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*AudioEndpoints*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Remote*'} | Disable-PnpDevice"

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

:: Group Policy
rd /s /q "%windir%\System32\Group Policy"
rd /s /q "%windir%\System32\Group Policy Users"
rd /s /q "%windir%\SysWOW64\Group Policy"
rd /s /q "%windir%\SysWOW64\Group Policy Users"
Reg delete "HKLM\SOFTWARE\Policies" /f
Reg delete "HKCU\Software\Policies" /f
lgpo /s GSecurity.inf

:: Disable Netbios
@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"

:: Perms
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    takeown /F %%d:\
    icacls %%d:\ /remove "Administrators"
    icacls %%d:\ /grant "Administrators":RX
    icacls %%d:\ /remove "Authenticated Users"
    icacls %%d:\ /remove "Users"
    icacls %%d:\ /remove "System"
    icacls %%d:\ /grant "*S-1-2-1":M
    icacls %%d:\ /deny "Network":F
)
    icacls C:\ /grant "System":M

:: Take ownership of Desktop
takeown /f "%SystemDrive%\Users\Public\Desktop" /r /d y
icacls "%SystemDrive%\Users\Public\Desktop" /inheritance:r
icacls "%SystemDrive%\Users\Public\Desktop" /grant:r %username%:(OI)(CI)F /t /l /q /c
takeown /f "%USERPROFILE%\Desktop" /r /d y
icacls "%USERPROFILE%\Desktop" /inheritance:r
icacls "%USERPROFILE%\Desktop" /grant:r %username%:(OI)(CI)F /t /l /q /c

:: Delete Provisioning Packages
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning

:: Powershell
    for %%P in (*.ps1) do (
        echo Running %%P as administrator...
        powershell -Command "Start-Process -WindowStyle Hidden -Verb RunAs powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%%P""'"
)
echo All powershell files have been executed.

:: WDAC
rem md %windir%\system32\codeintegrity
rem xcopy codeintegrity %windir%\system32\codeintegrity /Y /C /E /H /R /I

:: Mitigate Spectre Variant 2 and Meltdown in host operating system
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
wmic cpu get name | findstr "Intel" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 0 /f
)
wmic cpu get name | findstr "AMD" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 64 /f
)

:: Drivers
rem %windir%\system32\pnputil /add-driver *.inf /subdirs /install

:: Turn Data Execution Prevention to always On
%windir%\system32\bcdedit.exe /set {current} nx AlwaysOn

:: Registry
setlocal enabledelayedexpansion
set "regFolder=%~dp0"
pushd "%regFolder%"
for %%F in (*.reg) do (
    echo Importing: %%F
    reg.exe import "%%F"
)
echo All registry files have been imported.