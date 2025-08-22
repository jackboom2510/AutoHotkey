#Include <StatusOverlay>
DetectHiddenWindows 1
global currentProjectMode := false
global EN := "0x0409"
global VI := "0x042A"
global soundEnabled := true

windows := WinGetList()
for windowID in windows {
    try PostMessage(0x50, 0, EN, , "ahk_id " windowID)
}
; try PostMessage(0x50, 0, EN, , "A")
CurrentLLayout := EN
global CurrentLLayout := EN
optColor := "bg1{" "ffcd00" "}" " bg2{" "39396a" "}" " tx1{" "da251d" "}" " tx2{" "f7f7f7" "}"
LangOverlay := StatusOverlay("Language Overlay",
    optColor, "p{OnIcon}VI", "p{OffIcon}EN")

LangOverlay.statusTextControl.OnEvent("Click", ̣(*) => ChangeLang())

GetCurrentHKL() {
    return DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinGetID("A"),
    "UIntP", 0))
}

ChangeLang() {
    if (ChangeLangLayout()) {
        HotIf (*) => soundEnabled
        SoundPlay('C:\Users\jackb\Documents\AutoHotkey\sound\success_sfx.wav')
        HotIf
        LangOverlay.ToggleScript()
    }
}

ChangeLangLayout() {
    global CurrentLLayout
    if (CurrentLLayout = VI) {
        windows := WinGetList()
        for windowID in windows
            try PostMessage(0x50, 0, EN, , "ahk_id " windowID)
        ; try PostMessage(0x50, 0, EN, , "A")
        CurrentLLayout := EN
        return true
    } else {
        windows := WinGetList()
        for windowID in windows
            try PostMessage(0x50, 0, VI, , "ahk_id " windowID)
        ; try PostMessage(0x50, 0, VI, , "A")
        CurrentLLayout := VI
        return true
    }
    return false
}

; ChangeLang() {
;     global CurrentLLayout, EN, VI
;     if ChangeLangLayout() {
;         HotIf (*) => soundEnabled
;         SoundPlay("C:\Users\jackb\Documents\AutoHotkey\sound\success_sfx.wav")
;         HotIf
;         LangOverlay.ToggleScript()
;     }
; }

; ChangeLangLayout() {
;     global CurrentLLayout, EN, VI

;     if (CurrentLLayout = EN) {
;         SetDefaultKeyboard(VI)
;         CurrentLLayout := VI
;         return true
;     }
;     else {
;         SetDefaultKeyboard(EN)
;         CurrentLLayout := EN
;         return true
;     }
;     return false
; }

; SetDefaultKeyboard(KLID) {
;     SPI_SETDEFAULTINPUTLANG := 0x005A
;     SPIF_SENDWININICHANGE := 2
;     Lan := DllCall("LoadKeyboardLayout", "Str", KLID, "Int", 1)  ; 1 = KLF_ACTIVATE
;     Buf := Buffer(4)
;     NumPut("UInt", Lan, Buf)
;     DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG
;         , "UInt", 0
;         , "UPtr", Buf.Ptr
;         , "UInt", SPIF_SENDWININICHANGE)

;     windows := WinGetList()
;     for windowID in windows
;         PostMessage(0x50, 0, Lan, , "ahk_id " . windowID)
; }

ToggleProjectMode() {
    global currentProjectMode := !currentProjectMode
    displaySwitchPath := A_WinDir . "\System32\DisplaySwitch.exe"
    if (currentProjectMode = 0) {
        Run displaySwitchPath " /extend"
        TrayTip "Project Mode", "Switched to: Extend (Desktop duplicated and extended to second screen)"
        OutputDebug "Switched to: Extend Mode"
    } else {
        Run displaySwitchPath " /external"
        TrayTip "Project Mode", "Switched to: Second screen only (Only the external display is active)"
        OutputDebug "Switched to: Second Screen Only Mode"
    }
}
