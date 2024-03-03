@echo off
title GSecurity && color 0b

:: Group Policy
rd /s /q "%windir%\System32\Group Policy"
rd /s /q "%windir%\System32\Group Policy Users"
rd /s /q "%windir%\SysWOW64\Group Policy"
rd /s /q "%windir%\SysWOW64\Group Policy Users"
Reg delete "HKLM\SOFTWARE\Policies" /f
Reg delete "HKCU\Software\Policies" /f
Lgpo /s GSecurity.inf

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

:: Disable Netbios
@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"

:: Delete Provisioning Packages
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning

:: Mitigate Spectre Variant 2 and Meltdown in host operating system
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
wmic cpu get name | findstr "Intel" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 0 /f
)
wmic cpu get name | findstr "AMD" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 64 /f
)

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
