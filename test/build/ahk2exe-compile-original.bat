@echo off
setlocal enabledelayedexpansion
for /f %%t in ('powershell -nologo -noprofile -command "Get-Date -Format o"') do set "START_TIME=%%t"

:: === Default configuration ===
set "BASEDIR=C:\Users\jackb\Documents\AutoHotkey"
set "COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
set "RELEASE_DIR=%BASEDIR%\release"
set "DEFAULT_ICON=%BASEDIR%\icon\settings.ico"
set "ICON_DIR=%BASEDIR%\icon"

:: === Parse the first argument as the script file ===
::if "%~1"=="" (
::    echo [ERROR] Please provide the script file using -in parameter
::    exit /b 1
::)

set "SRC=%~f1"

for %%F in ("%SRC%") do set "NAME=%%~nF"

set "ICON="
set "OUT="

:: === Parse input parameters ===
set "HAS_ICO_PARAM=0"
set "HAS_OUT_PARAM=0"
shift
:parse_params
if "%~1"=="" goto :after_parse_params

if /i "%~1"=="-ico" (
    if "%~2"=="" (
        echo [ERROR] Missing value for -ico
        exit /b 1
    )
    set "HAS_ICO_PARAM=1"
    set "ICON=%~2"
    echo %ICON% | findstr /r "^[A-Za-z]:\\\|^\\\\" >nul
    if errorlevel 1 (
        set "ICON=%ICON_DIR%\%~2"
    )
    if not exist "%ICON%" (
        echo [ERROR] Icon path does not exist: %ICON%
        exit /b 1
    )
    shift
    if "%~1"=="" goto :after_parse_params
)

if /i "%~1"=="-icon" (
    if "%~2"=="" (
        echo [ERROR] Missing value for -icon
        exit /b 1
    )
    set "HAS_ICO_PARAM=1"
    set "ICON=%~2"
    echo %ICON% | findstr /r "^[A-Za-z]:\\\|^\\\\" >nul
    if errorlevel 1 (
        set "ICON=%ICON_DIR%\%~2"
    )
    shift
)

if /i "%~1"=="-out" (
    set "HAS_OUT_PARAM=1"
    set "OUT=%~2"
    shift
)

if /i "%~1"=="-o" (
    set "HAS_OUT_PARAM=1"
    set "OUT=%~2"
    shift
)

shift
goto :parse_params

:after_parse_params
if "%HAS_ICO_PARAM%"=="0" call :check_icon_in_script
if "%HAS_OUT_PARAM%"=="0" call :check_outname_in_script
goto :after_icon_and_outname_detected

:: Check if the script contains specific comments for icon and output name
:check_outname_in_script
for /f "usebackq delims= eol=" %%L in ("%SRC%") do (
    if "%%L" neq "" (
        echo %%L | findstr /b /r ";[ ]*@Ahk2Exe-ExeName " >nul
        if !errorlevel! == 0 (
            set "OUT_NAME_LINE=%%L"
            set "OUT=!OUT_NAME_LINE:;@Ahk2Exe-ExeName =!"
            goto :after_outname_detected
        )
    )
)
:after_outname_detected

:check_icon_in_script
for /f "usebackq delims= eol=" %%L in ("%SRC%") do (
    if "%%L" neq "" (
        echo %%L | findstr /b /r ";[ ]*@Ahk2Exe-SetMainIcon " >nul
        if !errorlevel! == 0 (
            set "ICON=%%L"
            set "ICON=!ICON:;@Ahk2Exe-SetMainIcon =!"
            goto :after_icon_detected
        )
    )
)
:after_icon_detected

:after_icon_and_outname_detected

::: Ensure the output directory exists
::if exist "%OUT%\*" (
::    set "OUT=%OUT%\%NAME%.exe"
::) else (
::    if "%OUT:~-1%"=="\" (
::        md "%OUT%" 2>nul
::        set "OUT=%OUT%%NAME%.exe"
::    )
::)

rem Kiểm tra nếu OUT kết thúc bằng .exe hay không
echo %OUT% | findstr /i "\.exe$" >nul
if errorlevel 1 (
    rem OUT không kết thúc bằng .exe → xử lý là thư mục
    if not exist "%OUT%" md "%OUT%" 2>nul
    set "OUT=%OUT%\%NAME%.exe"
)

:: Ensure the icon is set to a default if not specified
if not defined ICON (
    set "ICON=%DEFAULT_ICON%"
)

:: Ensure the output file path is set
if not defined OUT (
    set "OUT=%RELEASE_DIR%\%NAME%.exe"
)

for %%A in ("%OUT%") do set "OUT_FILENAME=%%~nxA"

echo [INFO] Killing existing process named: %OUT_FILENAME%
tasklist | findstr /i "%OUT_FILENAME%" >nul
if not errorlevel 1 (
    taskkill /f /im "%OUT_FILENAME%" >nul
    if errorlevel 1 (
        echo [WARNING] Failed to terminate %OUT_FILENAME%.
    ) else (
        echo [OK] %OUT_FILENAME% terminated successfully.
    )
)

:: === Check if script and icon exist ===
if not exist "%SRC%" (
    echo [ERROR] Script not found: %SRC%
    exit /b 1
)

if not exist "%ICON%" (
    echo [ERROR] Icon not found: %ICON%
    exit /b 1
)

echo ------------------------------
echo Compiling script...
echo Source   : %SRC%
echo Icon     : %ICON%
echo Output   : %OUT%
echo ------------------------------

"%COMPILER%" /in "%SRC%" /out "%OUT%" /icon "%ICON%"

if errorlevel 1 (
    echo [ERROR] Compilation failed.
    exit /b 1
)

echo [OK] Compilation complete: %OUT%
echo.

echo Launching compiled application...
start "" "%OUT%"
timeout /t 1 >nul

set "SHORTCUT_NAME=%NAME%.lnk"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%"

powershell -NoProfile -Command ^
  "& { $s = (New-Object -ComObject WScript.Shell).CreateShortcut(\"%SHORTCUT_PATH%\"); $s.TargetPath = \"%OUT%\"; $s.IconLocation = \"%ICON%\"; $s.Save() }"

echo [OK] Shortcut created or updated on Desktop: %SHORTCUT_PATH%

for /f %%t in ('powershell -nologo -noprofile -command "Get-Date -Format o"') do set "END_TIME=%%t"

echo.
echo Started  : %START_TIME%
echo Finished : %END_TIME%
echo Duration :
powershell -nologo -noprofile -command ^
    "$start = [datetime]::Parse('%START_TIME%'); $end = [datetime]::Parse('%END_TIME%'); $diff = $end - $start; Write-Host ('Total time: ' + $diff.ToString())"

endlocal
