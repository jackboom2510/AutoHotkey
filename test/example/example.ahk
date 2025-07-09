#Include <JSON>

; Create some JSON
str := '["abc", 123, {"true": 1, "false": 0, "null": ""}, [true, false, null]]'
obj := JSON.Load(str)

; Convert using default settings
MsgBox (
	str "`n"
	"`n"
	"obj[1]: " obj[1] " (expect abc)`n"
	"obj[2]: " obj[2] " (expect 123)`n"
	"`n"
	"obj[3]['true']: " obj[3]['true'] " (expect 1)`n"
	"obj[3]['false']: " obj[3]['false'] " (expect 0)`n"
	"obj[3]['null']: " obj[3]['null'] " (expect blank)`n"
	"`n"
	"obj[4][1]: " obj[4][1] " (expect 1)`n"
	"obj[4][2]: " obj[4][2] " (expect 0)`n"
	"obj[4][3]: " obj[4][3] " (expect blank)`n"
)

; Convert Bool and Null values to objects instead of native types
JSON.BoolsAsInts := false
JSON.NullsAsStrings := false
obj := JSON.Load(str)
MsgBox obj[4][1] == JSON.True ; 1
MsgBox obj[4][2] == JSON.False ; 1
MsgBox obj[4][3] == JSON.Null ; 1