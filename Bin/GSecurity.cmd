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

:: Disable devices
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Management*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Debug*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*bth*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Remote*'} | Disable-PnpDevice"

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

:: Registry
setlocal enabledelayedexpansion
set "regFolder=%~dp0"
pushd "%regFolder%"
for %%F in (*.reg) do (
    echo Importing: %%F
    reg.exe import "%%F"
)
echo All registry files have been imported.

:: Group Policy
rd /s /q "%windir%\System32\Group Policy"
rd /s /q "%windir%\System32\Group Policy Users"
rd /s /q "%windir%\SysWOW64\Group Policy"
rd /s /q "%windir%\SysWOW64\Group Policy Users"
lgpo /g .\