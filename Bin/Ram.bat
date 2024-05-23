:: Active folder
pushd %~dp0

:Cleaner
sc config edgeupdate start=disabled >nul 2>&1
sc config edgeupdatem start=disabled >nul 2>&1
sc config gupdate start=disabled >nul 2>&1
sc config gupdatem start=disabled >nul 2>&1
sc config MozillaMaintenance start=disabled >nul 2>&1
sc stop AppXSvc >nul 2>&1
sc stop BITS >nul 2>&1
sc stop ClipSvc >nul 2>&1
sc stop StorSvc >nul 2>&1
sc stop Wcmsvc >nul 2>&1
devicecleanup * -s -m:7d >nul 2>&1
set /a CPU=%NUMBER_OF_CORES%*%MAX_CLOCK_SPEED%
emptystandbylist.exe workingsets
emptystandbylist.exe modifiedpagelist
for /f "tokens=*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /s /f "ProfileName" /k ^| findstr /i /c:"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"') do (
    reg add "%%A" /v Category /t REG_DWORD /d 1 /f >nul 2>&1
)
timeout /t 10 /nobreak > NUL
goto:Cleaner