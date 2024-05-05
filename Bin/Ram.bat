:: Active folder
pushd %~dp0

:Cleaner
emptystandbylist.exe workingsets
emptystandbylist.exe modifiedpagelist
for /f "tokens=*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /s /f "ProfileName" /k ^| findstr /i /c:"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"') do (
    reg add "%%A" /v Category /t REG_DWORD /d 1 /f >nul 2>&1
)
timeout /t 10 /nobreak > NUL
goto:Cleaner