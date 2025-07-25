@echo off
setlocal enabledelayedexpansion

set "BASEDIR=C:\Users\jackb\Documents\AutoHotkey"
set "COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
set "BUILD_DIR=%BASEDIR%\release"
set "DEFAULT_ICON=%BASEDIR%\icon\settings.ico"

for /f %%t in ('powershell -noprofile -command "Get-Date -Format o"') do set "START_TIME=%%t"

set "SRC=%~f1"
if not exist "%SRC%" echo [ERROR] Script not found: %SRC% & exit /b 1
for %%F in ("%SRC%") do set "NAME=%%~nF"

set "ICON="
set "OUT="

shift
:parse
if "%~1"=="" goto :after_parse
if /i "%~1"=="-ico"  if not "%~2"=="" set "ICON=%~2" & shift
if /i "%~1"=="-icon" if not "%~2"=="" set "ICON=%~2" & shift
if /i "%~1"=="-out"  if not "%~2"=="" set "OUT=%~2" & shift
if /i "%~1"=="-o"    if not "%~2"=="" set "OUT=%~2" & shift
shift
goto :parse

:after_parse

if not defined ICON for /f "tokens=1* eol=" %%A in ('findstr /b /c:";@Ahk2Exe-SetMainIcon" "%SRC%"') do set "ICON=%%B"
if not defined OUT  for /f "tokens=1* eol=" %%A in ('findstr /b /c:";@Ahk2Exe-ExeName" "%SRC%"') do set "OUT=%%B"

if not defined ICON set "ICON=%DEFAULT_ICON%"

set "CHECK_ICON=%ICON:~1,1%"
if not "%CHECK_ICON%"==":" set "ICON=%BASEDIR%\icon\%ICON%"

if not exist "%ICON%" echo [ERROR] Icon not found: %ICON% & exit /b 1
if not defined OUT set "OUT=%BUILD_DIR%\%NAME%.exe"
if exist "%OUT%\*" set "OUT=%OUT%\%NAME%.exe"

echo ------------------------------
echo Source : %SRC%
echo Icon   : %ICON%
echo Output : %OUT%
echo ------------------------------

for %%A in ("%OUT%") do set "OUT_FILENAME=%%~nxA"
taskkill /f /im "%OUT_FILENAME%" >nul 2>&1

"%COMPILER%" /in "%SRC%" /out "%OUT%" /icon "%ICON%"
if errorlevel 1 echo [ERROR] Compilation failed. & exit /b 1

echo [OK] Compiled: %OUT%

start "" "%OUT%"

powershell -NoProfile -Command ^
  "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%USERPROFILE%\Desktop\%NAME%.lnk'); $s.TargetPath = '%OUT%'; $s.IconLocation = '%ICON%'; $s.Save()"

echo [OK] Shortcut created.

set "INI_DIR=%BASEDIR%\configs"
set "INI_FILE=%INI_DIR%\sources.ini"

>> "%INI_FILE%" echo [%NAME%]
>> "%INI_FILE%" echo SourcePath=%SRC%

for /f %%t in ('powershell -noprofile -command "Get-Date -Format o"') do set "END_TIME=%%t"

powershell -noprofile -command ^
    "$start = [datetime]::Parse('%START_TIME%');" ^
    "$end = [datetime]::Parse('%END_TIME%');" ^
    "$diff = $end - $start;" ^
    "$hundredths = [math]::Floor($diff.Milliseconds / 10);" ^
    "$duration = '{0:00}:{1:00}:{2:00}.{3:00}' -f $diff.Hours, $diff.Minutes, $diff.Seconds, $hundredths;" ^
    "Write-Host \"Started  : $($start.ToString('HH:mm:ss'))`nFinished : $($end.ToString('HH:mm:ss'))`nDuration : $duration\""

endlocal
