@echo off
title GSecurity && color 0b

:: Elevate
>nul 2>&1 fsutil dirty query %systemdrive% || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

:: Active Folder
pushd %~dp0
cd Bin
setlocal enabledelayedexpansion

:: Create a system restore point
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Pre-GSecurity Restore Point", 100, 7

:: Batch
for %%A in (*.cmd) do (
    call "%%A"
)

:: Registry
for %%B in (*.reg) do (
    reg import "%%B"
)

:: Powershell
    for %%C in (*.ps1) do (
        @powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%C" -WindowStyle Hidden
)

:: Msi
for %%D in (*.msi) do (
    start /wait msiexec /i "%%D" /qn
)

:: Script execution
powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

endlocal