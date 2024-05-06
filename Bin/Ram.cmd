:: Ram
md "%systemdrive%\Windows\Cleaner"
copy /y EmptyStandbyList.exe "%systemdrive%\Windows\Cleaner\"
copy /y Ram.bat "%systemdrive%\Windows\Cleaner\"
schtasks /create /xml "Cleaner.xml" /tn "Cleaner" /ru ""
for /f "tokens=2 delims==" %%s in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%s"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%