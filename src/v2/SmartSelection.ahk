;=====================================================
; Smart Word & Sentence Selector (AutoHotkey v2)
;=====================================================

global toggle := false

; Alt+Z: Bật/Tắt chế độ thông minh
!z:: {
    global toggle
    toggle := !toggle
    ToolTip("Smart Select: " (toggle ? "ON" : "OFF"), , , 1)
    SetTimer(() => ToolTip("", , , 1), -800)
}

#HotIf (toggle)

;----------------------------------------
; Ctrl + Shift + Left/Right → Smart Word
;----------------------------------------
^+Left:: SmartSelectWord("left")
^+Right:: SmartSelectWord("right")

;----------------------------------------
; Up/Down → Smart Sentence
;----------------------------------------
Up:: SmartSelectSentence("up")
Down:: SmartSelectSentence("down")

#HotIf

Esc:: ExitApp()  ; Thoát nhanh

;=====================================================
; Hàm chọn nguyên từ thông minh
;=====================================================
SmartSelectWord(direction) {
    Send("^+{" direction "}")  ; hành vi gốc
    Sleep(20)

    oldClip := ClipboardAll()
    Clipboard := ""
    Send("^c")
    ClipWait(0.1)
    selected := Clipboard
    Clipboard := oldClip

    ; Nếu không có gì được chọn → con trỏ đang giữa từ
    if (selected = "") {
        ; Sao chép dòng hiện tại
        Send("{Home}+{End}")
        Sleep(20)
        oldClip := ClipboardAll()
        Clipboard := ""
        Send("^c")
        ClipWait(0.1)
        line := Clipboard
        Clipboard := oldClip

        if (line = "")
            return

        ; Tìm ký tự gần vị trí con trỏ (lấy 1 ký tự trái)
        Send("{Left}")
        Send("+{Right}")
        Sleep(20)
        oldClip := ClipboardAll()
        Clipboard := ""
        Send("^c")
        ClipWait(0.1)
        caretChar := Clipboard
        Clipboard := oldClip

        if (caretChar = "")
            return

        ; Regex tách từ trong dòng (Unicode-friendly)
        words := []
        pos := 1
        while pos := RegExMatch(line, "O)\b[\pL\d']+\b", &m, pos) {
            words.Push(m[0])
            pos += StrLen(m[0])
        }

        ; Chọn từ chứa ký tự gần caretChar (xấp xỉ)
        found := ""
        for w in words {
            if InStr(w, caretChar) {
                found := w
                break
            }
        }

        if (found != "") {
            selected := found
        }
    }

    if (selected != "") {
        global LastSmartWord := selected
        ToolTip("🧠 Word: " selected, , , 2)
        SetTimer(() => ToolTip("", , , 2), -1000)
    }
}

;=====================================================
; Hàm chọn câu gần nhất (dựa trên .?!)
;=====================================================
SmartSelectSentence(direction) {
    oldClip := ClipboardAll()
    Clipboard := ""
    Send("^a")
    Send("^c")
    ClipWait(0.2)
    text := Clipboard
    Clipboard := oldClip

    if (text = "")
        return

    ; Loại bỏ xuống dòng
    text := RegExReplace(text, "\r?\n", " ")

    ; Tách câu theo dấu kết thúc
    sentences := []
    pos := 1
    while pos := RegExMatch(text, "O)[^.?!]+[.?!]?", &m, pos) {
        s := Trim(m[0])
        if (s != "")
            sentences.Push(s)
        pos += StrLen(m[0])
    }

    if (sentences.Length > 0) {
        chosen := sentences[1]
        global LastSmartSentence := chosen
        ToolTip("🧩 Sentence: " chosen, , , 3)
        SetTimer(() => ToolTip("", , , 3), -1500)
    }
}
