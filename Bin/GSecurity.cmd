@echo off
title GSecurity && color 0b

:: Group Policy
rd /s /q "%windir%\System32\GroupPolicy"
rd /s /q "%windir%\System32\GroupPolicyUsers"
rd /s /q "%windir%\SysWOW64\GroupPolicy"
rd /s /q "%windir%\SysWOW64\GroupPolicyUsers"
Reg delete "HKLM\SOFTWARE\Policies" /f
Reg delete "HKCU\Software\Policies" /f
Lgpo /g .\

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
assoc .ps1=Microsoft.PowerShellScript
ftype Microsoft.PowerShellScript=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -File "%1" %*

:: Disable Netbios
@powershell.exe -ExecutionPolicy Bypass -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { $_.SetTcpipNetbios(2) }"

:: Delete Provisioning Packages
@powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Uninstall-ProvisioningPackage -AllInstalledPackages"
rd /s /q %ProgramData%\Microsoft\Provisioning

:: Powershell
    for %%P in (*.ps1) do (
        echo Running %%P as administrator...
        powershell -Command "Start-Process -WindowStyle Hidden -Verb RunAs powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%%P""'"
)
echo All powershell files have been executed.

:: Turn Data Execution Prevention to always On
%windir%\system32\bcdedit.exe /set {current} nx AlwaysOn

:: Perms
setlocal enabledelayedexpansion

rem Iterate through drive letters
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    rem Check if the drive exists
    if exist %%d:\ (
        rem Assign TrustedInstaller as owner for the root directory of the drive
        takeown /F %%d:\ /A /R /D Y > nul 2>&1
        icacls %%d:\ /setowner "NT SERVICE\TrustedInstaller" > nul 2>&1
        echo Assigned TrustedInstaller as owner for %%d:\
    ) else (
        echo Drive %%d: does not exist.
    )
)

echo All available drives have been processed.

:: Registry
setlocal enabledelayedexpansion
set "regFolder=%~dp0"
pushd "%regFolder%"
for %%F in (*.reg) do (
    echo Importing: %%F
    reg.exe import "%%F"
)
echo All registry files have been imported.
