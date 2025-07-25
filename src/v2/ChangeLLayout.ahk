#SingleInstance Force
#Include <StatusOverlay>
global EN := "0x4090409"
global VI := "0x000042A"
; Setting To English to Default
PostMessage(0x50, 0x0001, EN, WinGetID("A"))
global CurrentLLayout := EN
; 
optColor := "bg1{" "ffcd00" "}" " bg2{" "39396a" "}" " tx1{" "da251d" "}" " tx2{" "f7f7f7" "}"
; optColor := "bg1{" "39396a" "}" " bg2{" "ffcd00" "}" " tx1{" "f7f7f7" "}" " tx2{" "da251d" "}"
LangOverlay := StatusOverlay("Language Overlay",
"y{863} w{18} h{24} " optColor, "p{OnIcon}VI", "p{OffIcon}EN")
; OnMessage(0x0050, UpdateLangOverlay)
; UpdateLangOverlay(wParam, lParam, msg, hwnd) {
;     LangOverlay.ToggleScript()
;     global EN, VI, CurrentLLayout, LangOverlay
;     CurrentLLayout := lParam &0xFFFF ; Update the global variable to match the system's current layout

;     if (CurrentLLayout = VI) {
;         LangOverlay.ToggleScript(true) ; Set to VI (OnIcon)
;     } else {
;         LangOverlay.ToggleScript(false) ; Set to EN (OffIcon)
;     }
;     return
; }
LangOverlay.statusTextControl.OnEvent("Click", (this := &CurrentLLayout, *) => (
    LangOverlay.ToggleScript()
    Send("#{Space}"),
    Sleep(100),
    (LangOverlay.isScriptEnabled = false ? Send("#{Space}") : 0),
    this := (this = EN) ? VI : EN,
    true
))

;----------------------------------------------------------
;----------------------MAIN_FUNCTION-----------------------
;----------------------------------------------------------
GetCurrentHKL() {
    return DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", WinGetID("A"),
    "UIntP", 0))
}

ChangeLang(WindowID := "A") {
    LangOverlay.ToggleScript()
    ChangeLangLayout(WindowID)
}

; ChangeLangLayout() {
;     global CurrentLLayout
;     if (CurrentLLayout = VI) {
;         ; SendMessage(0x50, 0x0001, EN, WinGetID("A"))
;         PostMessage(0x50, 0, EN, ,"A")
;         CurrentLLayout := EN
;     } else {
;         ; SendMessage(0x50, 0x0001, VI, WinGetID("A"))
;         PostMessage(0x50, 0, VI, ,"A")
;         CurrentLLayout := VI

;     }
;     return
; }

ChangeLangLayout(WindowID := "A") {
    global CurrentLLayout
    if (CurrentLLayout = VI) {
        SendMessage(0x50, 0x0001, EN, WinGetID(WindowID))
        ; Send "#{Space}"
        ; PostMessage(0x50, 0, EN, ,"A")
        CurrentLLayout := EN
    } else {
        SendMessage(0x50, 0x0001, VI, WinGetID(WindowID))
        ; Send "#{Space}"
        ; Sleep(100)
        ; Send "#{Space}"
        CurrentLLayout := VI

    }
    return
}