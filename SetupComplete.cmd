@echo off

:: Elevate
>nul 2>&1 fsutil dirty query %systemdrive% || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

:: Active Folder
pushd %~dp0
cd Bin
setlocal enabledelayedexpansion

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
endlocal