@echo off
title scrcpy Wi-Fi connect

REM --- Read phone_ip_address from JSON ---
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command ^
  "(Get-Content 'D:\Documents\AutoHotkey\configs\scrcpy.json' | ConvertFrom-Json).phone_ip_address"`) do (
    set "PHONE_IP=%%i"
)

if "%PHONE_IP%"=="" (
    echo ERROR: Cannot read phone_ip_address from JSON!
    pause
    exit /b
)

echo Connecting to %PHONE_IP% ...
adb connect %PHONE_IP%

echo Starting scrcpy...
scrcpy --keyboard=uhid -s  %PHONE_IP%

pause
