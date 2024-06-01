:: Install Credential and VBS Guard
Dism /Online /Enable-Feature /FeatureName:"HypervisorPlatform" /NoRestart

:: Install Edge Chromium Sandbox
Dism /Online /Enable-Feature /FeatureName:"Windows-Defender-ApplicationGuard" /NoRestart

:: Disable point of entry for Spectre and Meltdown
dism /online /Disable-Feature /FeatureName:"SMB1Protocol" /NoRestart
dism /Online /Disable-Feature /FeatureName:"SMB1Protocol-Client" /NoRestart
dism /Online /Disable-Feature /FeatureName:"SMB1Protocol-Server" /NoRestart

:: Enable security against PowerShell 2.0 downgrade attacks-
dism /online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellV2Root" /NoRestart
dism /online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellV2" /NoRestart

:: Mitigate Spectre Variant 2 and Meltdown in host operating system
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
wmic cpu get name | findstr "Intel" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 0 /f
)
wmic cpu get name | findstr "AMD" >nul && (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 64 /f
)

:: WDAC
rem md %windir%\system32\codeintegrity
rem xcopy codeintegrity %windir%\system32\codeintegrity /Y /C /E /H /R /I

:: Drivers
rem %windir%\system32\pnputil /add-driver *.inf /subdirs /install