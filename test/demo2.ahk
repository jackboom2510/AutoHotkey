#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <StatusOverlay>
#Include <KeyBinding>
#Include <Log>
; #in
Persistent()

; fn := "ClickTracker.ClickAndSleep"
; fullFn := StrSplit(fn, '.')

; typo(ObjBindMethod(%fullFn[1]%, fullFn[2]))

Send("{RButton}")

FileObj.Close()