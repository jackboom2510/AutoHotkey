@echo off
title Connect scrcpy with phone

echo Checking device connection...
adb devices

echo Starting scrcpy...
@REM scrcpy --keyboard=uhid -d --select-usb

scrcpy --video-codec=h265 -m1920 --max-fps=60 --no-audio -K --select-usb