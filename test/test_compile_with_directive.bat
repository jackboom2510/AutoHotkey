@echo off
setlocal enabledelayedexpansion

REM === Config ===
set "COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
set "TEST_SCRIPT=%~dp0test_directive.ahk"
set "TEMP_OUTPUT=%~dp0build_temp.exe"

REM === Kiểm tra file test_directive.ahk tồn tại ===
if not exist "%TEST_SCRIPT%" (
    echo [ERROR] Không tìm thấy file test_directive.ahk tại: %TEST_SCRIPT%
    exit /b 1
)

REM === Biên dịch với chỉ tham số /in, không truyền icon hay output ===
"%COMPILER%" /in "%TEST_SCRIPT%"

REM === Thông báo kết quả ===
if errorlevel 1 (
    echo [ERROR] Biên dịch thất bại!
) else (
    echo [OK] Biên dịch hoàn tất! Kiểm tra file exe và icon/output name.
)

pause
endlocal