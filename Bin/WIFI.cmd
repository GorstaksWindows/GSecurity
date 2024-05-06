@echo off
setlocal enabledelayedexpansion

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
