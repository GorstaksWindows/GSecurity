takeown /f "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester"
icacls "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester" /inheritance:r
icacls "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester" /grant:r %username%:(OI)(CI)F /t /l /q /c
rd /s /q "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester"
takeown /f "C:\Program Files\WindowsPowerShell\Modules\Pester"
icacls "C:\Program Files\WindowsPowerShell\Modules\Pester" /inheritance:r
icacls "C:\Program Files\WindowsPowerShell\Modules\Pester" /grant:r %username%:(OI)(CI)F /t /l /q /c
rd /s /q "C:\Program Files\WindowsPowerShell\Modules\Pester"
takeown /f %CommonFilesFolder%
icacls %CommonFilesFolder% /inheritance:r
icacls %CommonFilesFolder% /grant:r %username%:(OI)(CI)F /t /l /q /c
rd /s /q %CommonFilesFolder%
takeown /f %CommonFiles64Folder%
icacls %CommonFiles64Folder% /inheritance:r
icacls %CommonFiles64Folder% /grant:r %username%:(OI)(CI)F /t /l /q /c
rd /s /q %CommonFiles64Folder%
