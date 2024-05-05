:: Delete Group Policy
rd /s /q "%windir%\System32\Group Policy"
rd /s /q "%windir%\System32\Group Policy Users"
rd /s /q "%windir%\SysWOW64\Group Policy"
rd /s /q "%windir%\SysWOW64\Group Policy Users"
Reg delete "HKLM\SOFTWARE\Policies" /f
Reg delete "HKCU\Software\Policies" /f
lgpo /s GptTmpl.inf