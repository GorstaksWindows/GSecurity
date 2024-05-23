:: variables
for /f "delims=" %%a in ('ver') do ( set "BUILD=%%a" )
setx /m BUILD "%BUILD%"
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%a"
set /a RAM=%TotalVisibleMemorySize%+1024000
setx /m SVCHOSTSPLIT %RAM%
for /f "tokens=2 delims==" %%a in ('wmic systemenclosure get ChassisTypes /format:value ^| findstr "ChassisTypes"') do set "ChassisTypes=%%a"
set ChassisTypes=%ChassisTypes:{=% 
set /a ChassisTypes=%ChassisTypes:}=%
setx /m CHASSISTYPE %ChassisTypes%
for /f "tokens=2 delims==" %%a in ('wmic computersystem get manufacturer /format:value ^| findstr "Manufacturer"') do setx /m MANUFACTURER "%%a"
for /f "tokens=2 delims==" %%a in ('wmic computersystem get model /format:value ^| findstr "Model"') do setx /m MODEL "%%a"
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfCores /format:value ^| findstr "NumberOfCores"') do ( setx /m NUMBER_OF_CORES %%a ) >nul 2>&1
for /f "tokens=2 delims==" %%a in ('wmic cpu get MaxClockSpeed /format:value ^| findstr "MaxClockSpeed"') do ( setx /m MAX_CLOCK_SPEED %%a ) >nul 2>&1

:: powercfg 
powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 5d76a2ca-e8c0-402f-a133-2158492d58ad -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 7b224883-b3cc-4d79-819f-8374152cbe7c -ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 4b92d758-5a24-4851-a470-815d78aee119 -ATTRIB_HIDE
powercfg -attributes 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd +ATTRIB_HIDE
powercfg -attributes 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 +ATTRIB_HIDE
powercfg -attributes 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 +ATTRIB_HIDE
powercfg -attributes 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 +ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f +ATTRIB_HIDE
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 +ATTRIB_HIDE
powercfg -attributes 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 +ATTRIB_HIDE

:: bcdedit
%windir%\system32\bcdedit /deletevalue allowedinmemorysettings
%windir%\system32\bcdedit /deletevalue avoidlowmemory
%windir%\system32\bcdedit /deletevalue bootems
%windir%\system32\bcdedit /deletevalue bootlog
%windir%\system32\bcdedit /deletevalue bootmenupolicy
%windir%\system32\bcdedit /deletevalue bootux
%windir%\system32\bcdedit /deletevalue debug
%windir%\system32\bcdedit /deletevalue disabledynamictick
%windir%\system32\bcdedit /deletevalue disableelamdrivers
%windir%\system32\bcdedit /deletevalue ems
%windir%\system32\bcdedit /deletevalue extendedinput
%windir%\system32\bcdedit /deletevalue firstmegabytepolicy
%windir%\system32\bcdedit /deletevalue forcefipscrypto
%windir%\system32\bcdedit /deletevalue forcelegacyplatform
%windir%\system32\bcdedit /deletevalue halbreakpoint
%windir%\system32\bcdedit /deletevalue highestmode
%windir%\system32\bcdedit /deletevalue hypervisorlaunchtype
%windir%\system32\bcdedit /deletevalue increaseuserva
%windir%\system32\bcdedit /deletevalue integrityservices
%windir%\system32\bcdedit /deletevalue isolatedcontext
%windir%\system32\bcdedit /deletevalue linearaddress57
%windir%\system32\bcdedit /deletevalue nointegritychecks
%windir%\system32\bcdedit /deletevalue nolowmem 
%windir%\system32\bcdedit /deletevalue noumex 
%windir%\system32\bcdedit /deletevalue nx
%windir%\system32\bcdedit /deletevalue onecpu
%windir%\system32\bcdedit /deletevalue pae
%windir%\system32\bcdedit /deletevalue perfmem
%windir%\system32\bcdedit /deletevalue quietboot
%windir%\system32\bcdedit /deletevalue sos
%windir%\system32\bcdedit /deletevalue testsigning
%windir%\system32\bcdedit /deletevalue tpmbootentropy
%windir%\system32\bcdedit /deletevalue tscsyncpolicy
%windir%\system32\bcdedit /deletevalue usefirmwarepcisettings
%windir%\system32\bcdedit /deletevalue usephysicaldestination
%windir%\system32\bcdedit /deletevalue useplatformclock
%windir%\system32\bcdedit /deletevalue useplatformtick
%windir%\system32\bcdedit /deletevalue vm
%windir%\system32\bcdedit /deletevalue vsmlaunchtype
%windir%\system32\bcdedit.exe /set {current} nx AlwaysOn
