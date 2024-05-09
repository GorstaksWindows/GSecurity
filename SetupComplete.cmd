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
powershell -Command "Checkpoint-Computer -Description 'Pre-script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"

:: Powershell
for %%P in (*.ps1) do (
    echo Running %%P as administrator...
    powershell -Command "Start-Process -WindowStyle Hidden -Verb RunAs powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%%P""'"
)
echo All powershell files have been executed.

:: Batch
for %%B in (*.cmd) do (
    echo Executing: %%B
    call "%%B"
)
echo All batch files have been executed.

:: Registry
setlocal enabledelayedexpansion
set "regFolder=%~dp0"
pushd "%regFolder%"
for %%F in (*.reg) do (
    echo Importing: %%F
    reg.exe import "%%F"
)
echo All registry files have been imported.

endlocal
