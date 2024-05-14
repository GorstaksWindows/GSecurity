@echo off

:: Perms

REM Loop through all drives except the system reserved drive
for %%d in (C: D: E: F: G: H: I: J: K: L: M: N: O: P: Q: R: S: T: U: V: W: X: Y: Z:) do (
    REM Set the owner of the root of the drive to TrustedInstaller
    icacls "%%d\" /setowner "NT SERVICE\TrustedInstaller"
)

echo Ownership set to TrustedInstaller for the root of all local drives.

REM Take ownership of users folder
takeown /f "%USERPROFILE%" /r /d y
icacls "%USERPROFILE%" /inheritance:r
icacls "%USERPROFILE%" /grant:r %username%:(OI)(CI)F /t /l /q /c

echo Ownership of users folder set to %username%

