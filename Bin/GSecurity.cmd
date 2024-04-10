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

:: Take ownership of Desktop
takeown /f "%SystemDrive%\Users\Public\Desktop" /r /d y
icacls "%SystemDrive%\Users\Public\Desktop" /inheritance:r
icacls "%SystemDrive%\Users\Public\Desktop" /grant:r %username%:(OI)(CI)F /t /l /q /c
takeown /f "%USERPROFILE%\Desktop" /r /d y
icacls "%USERPROFILE%\Desktop" /inheritance:r
icacls "%USERPROFILE%\Desktop" /grant:r %username%:(OI)(CI)F /t /l /q /c

:: Remove remote desktop
net user administrator /active:yes
sc delete SessionEnv
sc stop SessionEnv
sc delete TermService
sc stop TermService
sc delete UmRdpService
sc stop UmRdpService
sc delete RemoteRegistry
sc stop RemoteRegistry
sc delete Rasman
sc stop Rasman
sc delete RasAuto
sc delete RmSvc
takeown /f C:\Windows\System32\termsrv.dll
cacls termsrv.dll /E /P %username%:F
del C:\Windows\System32\termsrv.dll
takeown /f C:\Windows\System32\termmgr.dll
cacls termmgr.dll /E /P %username%:F
del C:\Windows\System32\termmgr.dll
sc delete CDPSvc
sc stop CDPSvc
sc delete CDPUserSvc
sc stop CDPUsersvc
sc delete DiagTrack
sc stop DiagTrack
sc delete PimIndexMaintenanceSvc
sc stop PimIndexMaintenanceSvc
sc config DPS start= disabled
sc stop DPS
sc config WdiServiceHost start= disabled
sc stop WdiServiceHost
sc config WdiSystemHost start= disabled
sc stop WdiSystemHost
sc config NlaSvc start= disabled
sc config netprofm start= disabled
sc config AppVClient start= disabled
sc config Wecsvc start= disabled
sc config WerSvc start= disabled
sc config EventLog start= disabled
sc delete RdpVideoMiniport
sc delete tsusbflt
sc delete tsusbhub 
sc delete TsUsbGD
sc delete RDPDR
sc delete rdpbus
sc start rdpbus
sc stop rdpbus
sc delete RasPppoe
sc delete NdisWan
sc delete NdisTapi
sc delete ndiswanlegacy
sc delete wanarpv6
sc delete wanarp
sc delete RasAcd
takeown /f C:\Windows\System32\drivers\rdpbus.sys
cacls C:\Windows\System32\drivers\rdpbus.sys /E /P %username%:F
del C:\Windows\System32\drivers\rdpbus.sys

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
