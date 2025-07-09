#Requires AutoHotkey v2.0
#Include <JSON>  ; Thư viện JSON xử lý AHK v2 (có thể dùng zLib hoặc chuẩn riêng)

JsonToIni(jsonFile, iniFile) {
    if !FileExist(jsonFile) {
        MsgBox "❌ File JSON không tồn tại: " jsonFile
        return
    }

    jsonText := FileRead(jsonFile, "UTF-8")
    try {
        data := JSON.Parse(jsonText)  ; Phải có thư viện JSON v2 tương thích
    } catch as e {
        MsgBox "❌ Không thể parse JSON: " e.Message
        return
    }

    ; Ghi từng section vào INI
    for section, kv in data {
        for key, value in kv {
            IniWrite value, iniFile, section, key
        }
    }

    MsgBox "✅ Đã chuyển đổi xong: " iniFile
}

; Gọi thử
JsonToIni("example.json", "output.ini")
