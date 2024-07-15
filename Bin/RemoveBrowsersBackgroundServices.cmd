@echo off
TITLE Browsers Background Services remover

fsutil dirty query %systemdrive% >nul 2>&1
if ERRORLEVEL 1 (
 ECHO.
 ECHO.
 ECHO ===================================================================
 ECHO This script needs Administrator permissions!
 ECHO.
 ECHO Please run it as the Administrator or disable User Account Control.
 ECHO ===================================================================
 ECHO.
 PAUSE >NUL
 goto end
)

echo.
echo Removing background tasks and services of the following browsers:
echo.
echo Chrome, Edge, Brave, Vivaldi, Opera, Catsxp, Yandex
echo Firefox, Thunderbird
echo.


net stop edgeupdate /y >nul 2>&1
net stop edgeupdatem /y >nul 2>&1
net stop MicrosoftEdgeElevationService /y >nul 2>&1
sc delete edgeupdate >nul 2>&1
sc delete edgeupdatem >nul 2>&1
sc delete MicrosoftEdgeElevationService >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Services\eventlog\Application\edgeupdate" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet002\Services\eventlog\Application\edgeupdate" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Services\eventlog\Application\edgeupdatem" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet002\Services\eventlog\Application\edgeupdatem" /f >nul 2>&1

net stop gupdate /y >nul 2>&1
net stop gupdatem /y >nul 2>&1
net stop GoogleChromeElevationService /y >nul 2>&1
sc delete gupdate >nul 2>&1
sc delete gupdatem >nul 2>&1
sc delete GoogleChromeElevationService >nul 2>&1

net stop brave /y >nul 2>&1
net stop bravem /y >nul 2>&1
net stop BraveElevationService /y >nul 2>&1
sc delete brave >nul 2>&1
sc delete bravem >nul 2>&1
sc delete BraveElevationService >nul 2>&1

net stop catsxp /y >nul 2>&1
net stop catsxpm /y >nul 2>&1
net stop CatsxpElevationService /y >nul 2>&1
sc delete catsxp >nul 2>&1
sc delete catsxpm >nul 2>&1
sc delete CatsxpElevationService >nul 2>&1

net stop YandexBrowserService /y >nul 2>&1
sc delete YandexBrowserService >nul 2>&1

net stop MozillaMaintenance /y >nul 2>&1
sc delete MozillaMaintenance >nul 2>&1


for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "MicrosoftEdgeUpdate"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "GoogleUpdate"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "BraveSoftwareUpdate"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "CatsxpSoftwareUpdate"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "VivaldiUpdateCheck"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "Opera" ^| find "Autoupdate"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "Yandex" ^| find /i "Update"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)

for /f "tokens=1 delims=," %%t in ('schtasks /query /FO CSV ^| find """\" ^| find "Mozilla"') do (
 schtasks /Delete /TN %%t /F >nul 2>&1
)


REM Remove Mozilla Maintenance Service
if not "%ProgramFiles(x86)%"==""  (
 if exist "%ProgramFiles(x86)%\Mozilla Maintenance Service\uninstall.exe" start /w "" "%ProgramFiles(x86)%\Mozilla Maintenance Service\uninstall.exe" /S /v/qn
)
if exist "%ProgramFiles%\Mozilla Maintenance Service\uninstall.exe" start /w "" "%ProgramFiles%\Mozilla Maintenance Service\uninstall.exe" /S /v/qn


reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f >nul 2>&1
if not "%ProgramFiles(x86)%"=="" (
 reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "1" /f >nul 2>&1
)


set "EdgeSettings=AutoUpdateCheckPeriodMinutes,UpdaterExperimentationAndConfigurationServiceControl"
set "EdgeSettings=%EdgeSettings%,EdgePreview{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062},EdgePreview{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5},EdgePreview{F3C4FE00-EFD5-403B-9569-398A20F1BA4A}"
set "EdgeSettings=%EdgeSettings%,UpdateDefault,Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062},Update{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5},Update{F3C4FE00-EFD5-403B-9569-398A20F1BA4A}"

for %%e in (%EdgeSettings%) do (
 reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "%%e" /t REG_DWORD /d "0" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "%%e" /t REG_DWORD /d "0" /f >nul 2>&1
 if not "%ProgramFiles(x86)%"=="" (
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /v "%%e" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate" /v "%%e" /t REG_DWORD /d "0" /f >nul 2>&1
 )
)


set "EdgeSettings={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062},{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5},{F3C4FE00-EFD5-403B-9569-398A20F1BA4A}"
set "EdgeKeys=on-logon,on-logon-autolaunch,on-logon-startup-boost,on-os-upgrade"

for %%e in (%EdgeSettings%) do (
 for %%k in (%EdgeKeys%) do (
  reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnLogon" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnLogon" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
  if not "%ProgramFiles(x86)%"=="" (
   reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnLogon" /t REG_DWORD /d "0" /f >nul 2>&1
   reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
   reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
   reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnLogon" /t REG_DWORD /d "0" /f >nul 2>&1
   reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "AutoRunOnOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
   reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate\Clients\%%e\Commands\%%k" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
  )
 )
)

set EdgeKeys=

reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "6" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "960" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "6" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "960" /f >nul 2>&1
if not "%ProgramFiles(x86)%"=="" (
 reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "6" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "0" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "960" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "6" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "0" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdate" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "960" /f >nul 2>&1
)

set "EdgeSettings=msedge-stable-win,msedgewebview-stable-win,msedgeupdate-stable-win"

reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev" /v "CanContinueWithMissingUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev" /v "CanContinueWithMissingUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" /v "CanContinueWithMissingUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev" /v "CanContinueWithMissingUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev" /v "AllowUninstall" /t REG_DWORD /d "1" /f >nul 2>&1

for %%e in (%EdgeSettings%) do (
 reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64" /d "%%e-arm64" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86" /d "%%e-arm64" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64" /d "%%e-arm64" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86" /d "%%e-arm64" /f >nul 2>&1
 reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
 if not "%ProgramFiles(x86)%"=="" (
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64" /d "%%e-arm64" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86" /d "%%e-arm64" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64" /d "%%e-arm64" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x64-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86" /d "%%e-arm64" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\EdgeUpdateDev\CdpNames" /v "%%e-x86-zdp" /d "%%e-arm64-zdp" /f >nul 2>&1
 )
)

set EdgeSettings=



Reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdateDefault" /t REG_DWORD /d "0" /f >nul
Reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "0" /f >nul

Reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Update" /v "UpdateDefault" /t REG_DWORD /d "0" /f >nul
Reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "0" /f >nul

Reg add "HKLM\SOFTWARE\Policies\CatsxpSoftware\Update" /v "UpdateDefault" /t REG_DWORD /d "0" /f >nul
Reg add "HKLM\SOFTWARE\Policies\CatsxpSoftware\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "0" /f >nul

Reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "AppAutoUpdate" /t REG_DWORD /d "0" /f >nul
Reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "BackgroundAppUpdate" /t REG_DWORD /d "0" /f >nul

Reg add "HKLM\SOFTWARE\Policies\Mozilla\Thunderbird" /v "AppAutoUpdate" /t REG_DWORD /d "0" /f >nul
Reg add "HKLM\SOFTWARE\Policies\Mozilla\Thunderbird" /v "BackgroundAppUpdate" /t REG_DWORD /d "0" /f >nul


REM Uncomment below if you want completely block updating of these software
rem Reg add "HKLM\SOFTWARE\Policies\Mozilla\Firefox" /v "DisableAppUpdate" /t REG_DWORD /d "1" /f >nul
rem Reg add "HKLM\SOFTWARE\Policies\Mozilla\Thunderbird" /v "DisableAppUpdate" /t REG_DWORD /d "1" /f >nul
rem Reg add "HKLM\SOFTWARE\Policies\YandexBrowser" /v "UpdateAllowed" /t REG_DWORD /d "0" /f >nul


ECHO.
ECHO Done!
ECHO.
TIMEOUT /T 6 >nul

:end
