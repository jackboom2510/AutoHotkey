#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

args := [
    [
        20,
        "1",
        "2"
    ],
    [
        22,
        "^+2",
        "^+3"
    ],
    [
        23,
        "{Space}",
        "{1}"
    ],
    [
        24,
        "v",
        "h"
    ]
]

MsgBox args[2][1]

; MsgBox obj.KeyModifier.ToggleAndSend.hotkeys.length
; for idx, hk in obj.KeyModifier.ToggleAndSend.hotkeys {
;     if (IsObject(obj.KeyModifier.ToggleAndSend.args[idx])) {
;         out := "("
;         for var in obj.KeyModifier.ToggleAndSend.args[idx] {
;             out .= var . ', '
;         }
;         out := ")"
;         MsgBox out
;     }
; }
