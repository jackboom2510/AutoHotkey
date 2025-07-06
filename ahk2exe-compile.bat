@echo off
setlocal enabledelayedexpansion

:: === Default configuration ===
set "BASEDIR=C:\Users\jackb\Documents\AutoHotkey"
set "COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

:: === Check input ===
if "%~1"=="" (
    echo [ERROR] Please provide a relative path to the .ahk file
    echo.
    echo Usage:
    echo    ahk2exe-compile.bat v2\Script.ahk [icon\IconName.ico]
    exit /b 1
)

set "SRC=%BASEDIR%\%~1"

:: Get base file name (without extension)
for %%F in ("%SRC%") do (
    set "NAME=%%~nF"
)

:: Handle optional icon argument
if not "%~2"=="" (
    set "ICON=%BASEDIR%\%~2"
) else (
    set "ICON=%BASEDIR%\icon\%NAME%.ico"
)

:: Output .exe file path
set "OUT=%BASEDIR%\%NAME%.exe"

:: === Check file existence ===
if not exist "%SRC%" (
    echo [ERROR] Script not found: %SRC%
    exit /b 1
)

if not exist "%ICON%" (
    echo [ERROR] Icon not found: %ICON%
    exit /b 1
)

:: === Compile ===
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

:: === Create or update shortcut on Desktop ===
set "SHORTCUT_NAME=%NAME%.lnk"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%"

powershell -NoProfile -Command ^
  "& { $s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = '%OUT%'; $s.IconLocation = '%ICON%'; $s.Save() }"

echo [OK] Shortcut created or updated on Desktop: %SHORTCUT_PATH%


endlocal
pause