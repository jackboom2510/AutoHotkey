@echo off
setlocal enabledelayedexpansion

set "SRC=test.ahk"
set "LOG=log.txt"

echo Testing file: %SRC% > "%LOG%"

type "%SRC%" >> "%LOG%"

echo. >> "%LOG%"

set "ICON="
set "OUT="

if not defined ICON for /f "tokens=1* eol=" %%A in ('findstr /b /c:";@Ahk2Exe-SetMainIcon" "%SRC%"') do set "ICON=%%B"
if not defined OUT  for /f "tokens=1* eol=" %%A in ('findstr /b /c:";@Ahk2Exe-ExeName" "%SRC%"') do set "OUT=%%B"

echo ICON = %ICON% >> "%LOG%"
echo OUT  = %OUT% >> "%LOG%"

type "%LOG%"
endlocal
pause
exit