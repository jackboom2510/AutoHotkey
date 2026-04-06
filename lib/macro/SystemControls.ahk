#Include <ui\StatusOverlay>
#Include <core\Core>
global currentProjectMode := false
global EN := "0x0409"
global VI := "0x042A"
global CurrentLLayout := unset

ChangeHKL()

LangOverlay := StatusOverlay(
    "Language Overlay",
    Format(
        "bg1{} bg2{} tx1{} tx2{}",
        "ffcd00", "39396a",
        "da251d", "f7f7f7"
    ),
    "p{OnIcon}VI", "p{OffIcon}EN"
)
LangOverlay.statusTextControl.OnEvent("Click", ̣(*) => ChangeLangLayout(true, EN, VI))

GetCurrentHKL() {
    return DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinGetID("A"),
    "UIntP", 0))
}

ChangeHKL(what := EN) {
    DetectHiddenWindows 1
    windows := WinGetList()
    for windowID in windows {
        try PostMessage(0x50, 0, what, , "ahk_id " windowID)
    }
    global CurrentLLayout := what
    DetectHiddenWindows 0
    return what
}

ChangeLangLayout(soundEnabled := true, lang1 := EN, lang2 := VI) {
    ChangeHKL((CurrentLLayout = lang1) ? lang2 : lang1)
    HotIf (*) => soundEnabled
    SoundPlay('D:\Documents\AutoHotkey\assets\sound\success_sfx.wav')
    HotIf
    LangOverlay.ToggleScript()
}

ToggleProjectMode() {
    global currentProjectMode := !currentProjectMode
    displaySwitchPath := A_WinDir . "\System32\DisplaySwitch.exe"
    if (currentProjectMode = 0) {
        Run displaySwitchPath " /extend"
        Notify "Switched to: Extend (Desktop duplicated and extended to second screen)", "Project Mode"
        OutputDebug "Switched to: Extend Mode"
    }
    else {
        Run displaySwitchPath " /external"
        Notify "Switched to: Second screen only (Only the external display is active)", "Project Mode"
        OutputDebug "Switched to: Second Screen Only Mode"
    }
}

SetDPI(scale) {
    dpiValue := 96 * (scale / 100)
    RegWrite("REG_DWORD", dpiValue, "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics", "AppliedDPI")

    DllCall("SendMessageTimeout"
        , "Ptr", 0xFFFF    ; HWND_BROADCAST
        , "UInt", 0x1A     ; WM_SETTINGCHANGE
        , "Ptr", 0
        , "Str", "WindowMetrics"
        , "UInt", 2        ; SMTO_ABORTIFHUNG
        , "UInt", 5000
        , "Ptr*", 0)
}
