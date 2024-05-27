:: Active folder
pushd %~dp0

:Cleaner
devicecleanup * -s -m:7d >nul 2>&1
set /a CPU=%NUMBER_OF_CORES%*%MAX_CLOCK_SPEED%
emptystandbylist.exe workingsets
emptystandbylist.exe modifiedpagelist
timeout /t 10 /nobreak > NUL
goto:Cleaner