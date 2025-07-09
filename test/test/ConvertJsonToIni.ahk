#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <JSON>  ; Đường dẫn đến thư viện

JsonToIni(jsonPath, iniPath) {
    if !FileExist(jsonPath) {
        MsgBox "❌ Không tìm thấy file JSON: " jsonPath
        return
    }

    jsonText := JSON.LoadFile(jsonPath, "UTF-8")

    try {
        root := JSON.Parse(jsonText)  ; class JSON từ cJson.ahk
    }
    ; Duyệt qua từng section (nếu root là Object)
    for sectionName, sectionValue in root {
        if Type(sectionValue) = "Object" {
            ; Mỗi cặp con trong section
            for key, val in sectionValue {
                IniWrite val, iniPath, sectionName, key
            }
        } else {
            ; Nếu section không phải Object → ghi vào section "General"
            IniWrite sectionValue, iniPath, "General", sectionName
        }
    }

    MsgBox "✅ Đã chuyển JSON thành INI: " iniPath
}

; ======= Gọi thử =======
JsonToIni("example.json", "output.ini")