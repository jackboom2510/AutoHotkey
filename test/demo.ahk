#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

obj := {
    KeyModifier: {
        ToggleAndSend: {
            args: [
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
            ],
            description: "Toggle between sending different key combinations based on the assigned arguments.",
            hotkeys: [
                "F20",
                "F22",
                "F23",
                "F24"
            ]
        },
    }
}
MsgBox obj.KeyModifier.ToggleAndSend.hotkeys.length
for idx, hk in obj.KeyModifier.ToggleAndSend.hotkeys {
    if (IsObject(obj.KeyModifier.ToggleAndSend.args[idx])) {
        out := "("
        for idx2, var in obj.KeyModifier.ToggleAndSend.args[idx] {
            out .= var . ', '
        }
        out := out . ")"
        MsgBox out
    }
}
