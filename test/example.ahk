#Include <Log>
#Include <JSON>
#Requires AutoHotkey v2.0
#SingleInstance Force
; Create some JSON

obj := JSON.LoadFile(jsonPath)

; Convert using default settings
MsgBox (
	"`n"
	"`n"
	"obj[1]: " obj[1] " (expect abc)`n"
	"obj[2]: " obj[2] " (expect 123)`n"
	"`n"
	; "obj[3]: " obj[3] "`n"
	"obj[3]['true']: " obj[3]["false"] " (expect 1)`n"
	"obj[3]['false']: " obj[3]['false'] " (expect 0)`n"
	"obj[3]['null']: " obj[3]['null'] " (expect blank)`n"
	"`n"
	"obj[4][1]: " obj[4][1] " (expect 1)`n"
	"obj[4][2]: " obj[4][2] " (expect 0)`n"
	"obj[4][3]: " obj[4][3] " (expect blank)`n"
)

; Convert Bool and Null values to objects instead of native types
; JSON.BoolsAsInts := false
; JSON.NullsAsStrings := false
; obj := JSON.Load(str)
; MsgBox obj[4][1] == JSON.True ; 1
; MsgBox obj[4][2] == JSON.False ; 1
; MsgBox obj[4][3] == JSON.Null ; 1