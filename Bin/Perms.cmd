@echo off

REM Loop through all drives except the system reserved drive
for %%d in (A: B: C: D: E: F: G: H: I: J: K: L: M: N: O: P: Q: R: S: T: U: V: W: X: Y: Z:) do (
    REM Remove all existing permissions on the drive
    icacls "%%d\" /inheritance:r
    icacls "%%d\" /remove "System"
    icacls "%%d\" /remove "Administrators"
    icacls "%%d\" /remove "Users"
    icacls "%%d\" /remove "Authenticated Users"

    REM Set permissions for Administrators group and Console Logon Users on the drive
    icacls "%%d\" /grant Administrators:(OI)(CI)(RX) /grant *S-1-2-1:(OI)(CI)(M) /T /C
)

    REM Grant full permissions to the System account only on the C: drive
    icacls C:\ /grant System:(OI)(CI)(F) /T /C

REM Set the folder path dynamically using %username%
set "folderPath=C:\Users\%username%"

REM Take ownership of the folder
takeown /F "%folderPath%" /R /D Y

REM Remove all existing permissions
icacls "%folderPath%" /inheritance:r
icacls "%folderPath%" /remove "*S-1-5-32-544" /T /C 2>nul
icacls "%folderPath%" /remove "*S-1-1-0" /T /C 2>nul
icacls "%folderPath%" /remove "*S-1-5-18" /T /C 2>nul

REM Set permissions for the folder
icacls "%folderPath%" /grant %username%:(F) /T /C

echo Permissions modified successfully.
