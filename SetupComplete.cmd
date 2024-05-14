@echo off
title GSecurity && color 0b

:: Elevate
>nul 2>&1 fsutil dirty query %systemdrive% || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

:: Active Folder
pushd %~dp0
cd Bin
setlocal enabledelayedexpansion

:: Script execution
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass}"

:: Create a system restore point
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Pre-GSecurity Restore Point", 100, 7

:: Powershell
    for %%A in (*.ps1) do (
        @powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%A" -WindowStyle Hidden
)

:: Batch
for %%B in (*.cmd) do (
    call "%%B"
)

:: Registry
for %%C in (*.reg) do (
    reg import "%%C"
)

:: Msi
for %%D in (*.msi) do (
    start /wait msiexec /i "%%D" /qn
)

endlocal