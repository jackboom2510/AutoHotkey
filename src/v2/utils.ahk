#SingleInstance Force
Persistent
#Include <ui\NotificationUI>
#Include <core\cJson>
#Include <other\UIA-v2\Lib\UIA_Browser>
#Include <other\UIA-v2\Lib\UIA>
#Include <core\Log>
GoogleTranslate(isSelected := true, from := "en", to := "vi", notificationFormat := "{}`n-> {}") {
    if (isSelected) {
        oldClipboard := A_Clipboard
        A_Clipboard := ""
        Send "^c"
        ClipWait 1
        if (A_Clipboard != "")
            GoogleTranslate_Internal(A_Clipboard)
        else
            NotificationUI("No text selected to translate.")
    }
    else {
        inputW := 300
        inputH := 100
        if (SysGet(80) > 1) {
            old_CoordMode := A_CoordModeMouse
            CoordMode 'mouse', 'screen'
            MouseGetPos(&mx, &my)
            monitorIdx := (mx >= 0 && mx <= A_ScreenWidth) ? 2 : 1
            MonitorGet(monitorIdx, , , &screenW, &screenH)
            if (A_IsCompiled && monitorIdx = 1) {
                inputW *= 1.5
                inputH *= 1.5
            }
            CoordMode 'mouse', old_CoordMode
        }
        else {
            screenW := A_ScreenWidth
            screenH := A_ScreenHeight
        }
        xPos := screenW - inputW - 10
        yPos := screenH - inputH - 40
        what := InputBox(,
            Format("Google Transplate API ({} -> {})", from, to),
            Format('x{} y{} w{} h{}', xPos, yPos, inputW, inputH)
        )
        if (what.Result = 'Ok' && what.Value != '')
            GoogleTranslate_Internal(what.Value)
    }
    GoogleTranslate_Internal(input) {
        textToTranslate := input
        encodedText := UrlEncode(textToTranslate)
        url := "https://api.mymemory.translated.net/get?q=" encodedText "&langpair=" from "|" to
        response := ""
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", url, false)
            whr.Send()
            response := whr.ResponseText
        }
        catch as e {
            NotificationUI("Error sending HTTP request: " e.Message)
            return
        }
        try {
            json := cJson.Load(response)
            translatedText := json["responseData"]["translatedText"]
            if (translatedText = textToTranslate) {
                NotificationUI(Format('Cannot find the translated word for {}', textToTranslate), 't5')
                Run(Format('https://translate.google.com/?hl=vi&sl=auto&tl=vi&text={}&op=translate', textToTranslate))
                return
            }
            A_Clipboard := translatedText
            if (StrSplit(textToTranslate, ' `t`n').Length <= 5)
                NotificationUI.Prototype.DefineProp("AfterSetup", { Call: AfterSetup })
            NotificationUI(Format(notificationFormat, textToTranslate, translatedText), Format(
                'Google Translate {} -> {}', from, to), 't10 ra w')
        }
        catch as e {
            NotificationUI("Error parsing JSON: " e.Message)
        }
    }
}

AfterSetup(this) {
    content := this.fullPromt
    RegExMatch(content, "(.*)(\s+|\n)?->", &word)
    word := word[1]
    phonetics := []
    words := StrSplit(word, ' ')
    for token in StrSplit(word, ' ')
        phonetics.Push(GetPhonetics(token))
    if (phonetics.Length != 0) {
        fullPhonetics := ""
        for idx, token in phonetics {
            if (token = " " || idx = phonetics.Length || token = "")
                continue
            token := RegExReplace(token, '/', '')
            fullPhonetics .= token
            if (idx != phonetics.Length)
                fullPhonetics .= ' '
        }
        ; if (fullPhonetics != '' && fullPhonetics != ' ') {
            this.gui.AddEdit("r2 +VScroll w" this.guiPos.w - 25, '/' fullPhonetics '/')
            this.guiPos.h += 60
        ; }
    }
    playBtn := this.gui.AddButton("Center h30 w" this.guiPos.w - 25, "🔊 Audio")
    playBtn.OnEvent("Click", (*) => PlayAudio(word))
    this.guiPos.h += 30
}

GetPhonetics(word) {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        url := "https://api.dictionaryapi.dev/api/v2/entries/en/" word
        http.Open("GET", url, false)
        http.Send()
        if (http.Status != 200) {
            return ""
        }
        data := http.ResponseText
        if RegExMatch(data, '"phonetic":\s*"([^"]+)"', &m)
            return m[1]
    } catch {
        return ""
    }
    return ""
}

PlayAudio(word) {
    url := "https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=" UrlEncode(word)
    tmp := A_Temp "\tts.mp3"
    try {
        Download(url, tmp)
        SoundPlay(tmp)
        FileDelete(tmp)
    } catch {
        SoundBeep(100, 300)
    }
}

UrlEncode(str) {
    result := ""
    for char in StrSplit(str) {
        len := StrPut(char, "UTF-8") - 1
        buf := Buffer(len, 0)
        StrPut(char, buf, "UTF-8")
        if (len = 1) {
            byte := NumGet(buf, 0, "UChar")
            if (byte >= 0x30 && byte <= 0x39) ; 0-9
                result .= char
            else if (byte >= 0x41 && byte <= 0x5A) ; A-Z
                result .= char
            else if (byte >= 0x61 && byte <= 0x7A) ; a-z
                result .= char
            else if (InStr("-_.~", char)) ; các ký tự an toàn
                result .= char
            else
                result .= "%" . Format("{:02X}", byte)
        } else {
            loop len {
                b := NumGet(buf, A_Index - 1, "UChar")
                result .= "%" . Format("{:02X}", b)
            }
        }
    }
    return result
}

CopyUrlEncodeToClipboard(from := "en", to := "vi") {
    A_Clipboard := ""
    Send "^c"
    ClipWait 1
    if (A_Clipboard != "") {
        textToEncode := A_Clipboard
        encodedText := UrlEncode(textToEncode)
        A_Clipboard := encodedText
        url := "https://api.mymemory.translated.net/get?q=" encodedText Format("&langpair={}|{}", from, to)
        A_Clipboard := url
        NotificationUI(Format("Original: {} ->`nEncoded: {}`nURL: {}", textToEncode, encodedText, url))
    }
}

PowerToyRun(keyWord := '??', what := '', isSelected := true) {
    if (isSelected) {
        A_Clipboard := ''
        Send '^c'
        ClipWait 1
        if (A_Clipboard != '')
            PowerToyRun_Inernal(A_Clipboard)
        else
            TrayTip('Clipboard is Empty!', , 'Icon!')
    }
    else if (what != '')
        PowerToyRun_Inernal(what)
    PowerToyRun_Inernal(what) {
        Send '!{Space}'
        Sleep 300
        SendText(keyWord ' ' what)
        Sleep 500
        Send '{Enter}'
    }
}

CopyProcessDirectory() {
    hwnd := WinActive("A")
    if !hwnd {
        MsgBox("Không tìm thấy cửa sổ đang hoạt động.", "Lỗi", 48)
        return
    }

    pid := WinGetPID(hwnd)

    try {
        exePath := ProcessGetPath(pid)
        SplitPath exePath, , &dir
        A_Clipboard := dir
        TrayTip("Đã copy: " dir " vào clipboard")
    } catch {
        MsgBox("Không thể lấy đường dẫn tiến trình.", "Lỗi", 48)
    }
}

AddJavaClass(path := 'D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\src') {
    tabTitle := GetBrowserInfo("title", "", 0)
    if RegExMatch(tabTitle, "(?P<id>.*) - (?P<Name>.*)", &m) {
        problem := RemoveDiacritics(m["Name"])
        inp := MsgBox('Tạo file hay folder?`nYes: Folder`nNo: File', , 'YNC')
        if (inp = 'Yes') {
            className := m["id"]
            javaFolder := path "\" m["id"] '_' problem
            DirCreate(javaFolder)
            fileName := className ".java"
            javaPath := javaFolder "\" fileName
        }
        else if (inp = 'No') {
            className := m["id"] '_' problem
            fileName := className '.java'
            javaPath := path "\" fileName
        }
        else
            return
        if (FileExist(javaPath)) {
            NotificationUI("Đã tồn tại file " javaPath, fileName, 't5')
            inp := Msgbox('Bạn có muốn ghi đè file "' javaPath '" không?', fileName, 'YN')
        }
        else
            inp := Msgbox('Bạn có muốn thêm file "' javaPath '" không?`n`nDefaut: Yes(3s)', fileName, 'YN T3')
        if (inp = 'Yes' || inp = 'Timeout') {
            javaFile := FileOpen(javaPath, 'w')
            content :=
                (
                    'public class ' className ' {`n'
                    '    public static void main(String[] args) {`n'
                    '        `n'
                    '    }`n'
                    '}'
                )
            javaFile.Write(content)
            javaFile.Close()
            NotificationUI(content, fileName, 't5')
            inp := Msgbox('Bạn có muốn mở file "' javaPath '" không?`n`nDefaut: Yes(3s)', fileName, 'YN T3')
            if (inp = 'Yes' || inp = 'Timeout')
                Run(javaPath)
            return
        }
        A_Clipboard := tabTitle
        NotificationUI("Đã copy `"" tabTitle "`" vào clipboard!", , 't3')
        return
    }
}

RemoveDiacritics(str) {
    static MAP_COMPOSITE := 0x00000040

    ; cchDest là số ký tự; cấp phát buffer theo byte (UTF-16 = 2 byte/1 ký tự)
    cchDest := StrLen(str) * 4 + 1          ; dư dả để chứa chuỗi đã tách dấu
    buf := Buffer(cchDest * 2, 0)           ; *2 vì byte

    ; cchSrc = -1: xử lý đến ký tự NUL kết thúc
    chars := DllCall("kernel32\FoldStringW"
        , "UInt", MAP_COMPOSITE
        , "Str", str
        , "Int", -1
        , "Ptr", buf
        , "Int", cchDest
        , "Int")

    if (chars = 0) {
        throw OSError("FoldStringW failed", A_LastError)
    }

    s := StrGet(buf, "UTF-16")
    s := StrReplace(s, "đ", "d")
    s := StrReplace(s, "Đ", "D")
    s := RegExReplace(s, "[\x{0300}-\x{036F}\x{1AB0}-\x{1AFF}\x{1DC0}-\x{1DFF}\x{20D0}-\x{20FF}\x{FE20}-\x{FE2F}]")
    s := RegExReplace(s, "\s+", "_")
    return s
}

GetBrowserInfo(specificInfo := '', to := 'A_Clipboard', notificationTimer := 0) {
    browserEx := WinGetProcessName("A")
    cUIA := UIA_Browser("ahk_exe " browserEx)
    url := cUIA.GetCurrentURL()
    if (browserEx = 'chrome.exe') {
        title := cUIA.GetTab().name
        if RegExMatch(title, "(.*) - Memory usage - .*$", &title)
            title := title[1]
    }
    else if (browserEx = 'msedge.exe') {
        title := WinGetTitle("ahk_exe " browserEx)
        if (RegExMatch(title, "(.*)( and \d+ more pages .*)", &title))
            title := title[1]
    }
    if (specificInfo != '') {
        if (to != '') {
            %to% := %specificInfo%
            NotificationUI("Đã copy `"" %to% "`" vào " to "!", , 't' notificationTimer)
        }
        return %specificInfo%
    }
    return {
        url: url, title: title
    }
}
