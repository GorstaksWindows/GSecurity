:: DHT
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v SavedLegacySettings /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" /v DefaultConnectionSettings /f
Reg DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxySettingsPerUser /f
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\IPSec\Policy\Local" /f
Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\IPSec\Policy\Local" /f
bitsadmin /reset /allusers
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /f /reg:32
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer" /f /reg:64
Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f
Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v DisableConfig /t REG_DWORD /d 0 /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore" /v DisableSR /t REG_DWORD /d 0 /f
Reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
Reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend /f /v Start /t REG_DWORD /d 0x00000002
Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 0x00000000
Reg add "HKLM\SYSTEM\CurrentControlSet\services\MpsSvc" /V Start /T REG_DWORD /D 2 /F
Reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f /v EnableFirewall /t REG_DWORD /d 0x00000001
Reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f /v DoNotAllowExceptions
Reg add "HKLM\SYSTEM\CurrentControlSet\services\wuauserv" /V Start /T REG_DWORD /D 2 /F
Reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v NoWindowsUpdate
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\services\wscsvc" /V Start /T REG_DWORD /D 2 /F
Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v HideSCAHealth /t REG_SZ /d 0
Reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /f /v HideSCAHealth /t REG_SZ /d 0
