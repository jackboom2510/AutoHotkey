#Requires AutoHotkey v2.0
#Include <cJSON>
class ChordBinding {
    chordMap := Map()
    currentChord := ""
    chordTimer := 0
    chordTimeout := 1000

    __New(jsonPath := "", keys := []) {
        if jsonPath != ""
            this.LoadChordMap(jsonPath)
        for key in keys
            Hotkey(key, (hk) => this.HandleChord(hk), "On")
    }

    LoadChordMap(jsonPath) {
        try {
            json := FileRead(jsonPath)
            data := cJSON.Parse(json)
            for chord, action in data {
                this.chordMap[chord] := action
            }
        } catch Error as e {
            MsgBox("Lỗi khi đọc JSON: " e.Message)
        }
    }

    HandleChord(thisHotkey) {
        if (this.currentChord = "") {
            this.currentChord := thisHotkey
            SetTimer(() => this.currentChord := "", this.chordTimeout)
        } else {
            fullChord := this.currentChord "," thisHotkey
            this.currentChord := ""
            if this.chordMap.Has(fullChord) {
                this.ExecuteAction(this.chordMap[fullChord])
            }
        }
    }

    ExecuteAction(action) {
        if IsObject(action) {
            if action.type = "run"
                Run(action.value)
            else if action.type = "send"
                Send(action.value)
        } else {
            MsgBox(action)
        }
    }
}