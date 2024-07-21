@echo off
title GSecurity && color 0b

:: Elevate privileges if not already running as admin
>nul 2>&1 fsutil dirty query %systemdrive% || (
    echo Requesting elevated privileges...
    echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs"
    "%temp%\uac.vbs"
    exit /b
)
DEL /F /Q "%temp%\uac.vbs"

:: Navigate to the script directory and then into the Bin folder
echo Navigating to the script directory...
pushd %~dp0
echo Current directory: %cd%
cd Bin || (echo Failed to navigate to Bin directory & pause & exit /b)
echo Current directory after navigating to Bin: %cd%
setlocal enabledelayedexpansion

:: Create a system restore point
echo Creating system restore point...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Pre-GSecurity Restore Point", 100, 7
if %errorlevel% neq 0 (
    echo Failed to create system restore point & pause & exit /b
)
echo System restore point created successfully.

:: Execute batch files
echo Executing batch files...
for %%A in (*.cmd) do (
    echo Running %%A...
    call "%%A"
)
echo Batch files executed successfully.

:: Execute PowerShell scripts
echo Executing PowerShell scripts...
for %%B in (*.ps1) do (
    echo Running %%B...
    @powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%B" -WindowStyle Hidden
)
echo PowerShell scripts executed successfully.

:: Import registry files
echo Importing registry files...
for %%C in (*.reg) do (
    echo Importing %%C...
    reg import "%%C"
)
echo Registry files imported successfully.

:: Install MSI packages
echo Installing MSI packages...
for %%D in (*.msi) do (
    echo Installing %%D...
    start /wait msiexec /i "%%D" /qn
)
echo MSI packages installed successfully.

:: Set execution policy for PowerShell
echo Setting PowerShell execution policy...
powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
echo PowerShell execution policy set successfully.

endlocal
popd

echo All tasks completed successfully.