#Requires AutoHotkey v2+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>

PromtToSaveInSort(filePath := globalLogFile) {
    inp := InputBox(, "Bạn có muốn lưu Macros không?")
    if (inp.Submit() = "Cancel") {
        return
    }
    else {
        inp := InputBox("Hãy nhập vào địa chỉ lưa ", ")
    }
}
