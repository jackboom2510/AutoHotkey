#Include <core\Core>
#Include <core\cJson>
#Include <other\UIA-v2\Lib\UIA_Browser>
#Include <other\UIA-v2\Lib\UIA>
GoogleTranslate(isSelected := 1, from := "en", to := "vi", notificationFormat := "{}`n-> {}") {
  if (isSelected = 1) {
    ; global startTranslateTime := A_TickCount
    oldClipboard := A_Clipboard
    A_Clipboard := ""
    Send "^c"
    ClipWait 1
    if (A_Clipboard != "")
      GoogleTranslate_Internal(A_Clipboard)
    else
      Notify("No text selected to translate.")
  }
  else if (isSelected = 0) {
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
    what := InputBox(, Format("Google Transplate API ({} -> {})", from, to), Format('x{} y{} w{} h{}', xPos, yPos,
      inputW, inputH))
    if (what.Result = 'Ok' && what.Value != '')
      GoogleTranslate_Internal(what.Value)
  }
  else {
    if (A_Clipboard != "")
      GoogleTranslate_Internal(A_Clipboard)
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
      Notify("Error sending HTTP request: " e.Message)
      return
    }
    try {
      json := cJson.Load(response)
      translatedText := json["responseData"]["translatedText"]
      if (translatedText = textToTranslate) {
        Notify(Format('Cannot find the translated word for {}', textToTranslate), '+ t5')
        Run(Format('https://translate.google.com/?hl=vi&sl=auto&tl=vi&text={}&op=translate', textToTranslate))
        return
      }
      A_Clipboard := translatedText
      if (StrSplit(textToTranslate, [
        ' ',
        '`t`n'
      ]).Length <= 5) {
        Notify.Prototype.DefineProp("AfterSetup", { Call: AfterSetup })
      }
      Notify(Format(notificationFormat, textToTranslate, translatedText), Format('Google Translate {} -> {}',
        from, to), '+ t10 ra c5db899')
    }
    catch as e {
      Notify("Error parsing JSON: " e.Message)
    }
  }
}

AfterSetup(this) {
  if (RegExMatch(this.fullPromt, "(.*)(\s+|\n)?->", &word)) {
    word := word[1]
    words := StrSplit(word, ' ')
    phonetics := []
    for token in StrSplit(word, ' ')
      phonetics.Push(GetPhonetics(token))
    if (phonetics.Length != 0) {
      fullPhonetics := ""
      for idx, token in phonetics {
        token := RegExReplace(token, '/', '')
        fullPhonetics .= token
      }
      fullPhonetics := RTrim(fullPhonetics)
      if (fullPhonetics != '' && fullPhonetics != ' ') {
        this.gui.AddEdit("r2 +VScroll w" this.guiPos.w - 25, '/' fullPhonetics '/')
        this.guiPos.h += 60
      }
    }
    playBtn := this.gui.AddButton("Center h30 w" this.guiPos.w - 25, "🔊 Audio")
    playBtn.OnEvent("Click", (*) => PlayAudio(word))
    this.guiPos.h += 30
    PlayAudio(word)
    ; global startTranslateTime
    ; this.StatusBar := this.gui.AddStatusBar()
    ; this.StatusBar.SetText("Running time: " A_TickCount - startTranslateTime)
    ; this.guiPos.h += 30
  }
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
  }
  catch {
    return ""
  }
  return ""
}

PlayAudio(word) {
  url := "https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=" UrlEncode(word)
  tmp := "D:\Documents\AutoHotkey\temp\tts.mp3"
  try {
    Download(url, tmp)
    SoundPlay(tmp)
    FileDelete(tmp)
  }
  catch {
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
    }
    else {
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
    Notify(Format("Original: {} ->`nEncoded: {}`nURL: {}", textToEncode, encodedText, url))
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

CopyProcessDirectory_origin() {
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
  }
  catch {
    MsgBox("Không thể lấy đường dẫn tiến trình.", "Lỗi", 48)
  }
}

CopyProcessDirectory() {
  hwnd := WinActive("A")
  if !hwnd {
    Notify("Không tìm thấy cửa sổ đang hoạt động.", "Lỗi", "+ x16 w250 t15 ra ci")
    return
  }

  try {
    pid := WinGetPID(hwnd)
    exePath := ProcessGetPath(pid)
    SplitPath exePath, , &dir
  }
  catch {
    Notify("Không thể lấy đường dẫn tiến trình.", "Lỗi", "+ x16 w250 t15 ra ci")
    return
  }

  ; --- Lấy thông tin cửa sổ ---
  winTitle := WinGetTitle(hwnd)
  winClass := WinGetClass(hwnd)
  WinGetPos(&x, &y, , , hwnd)
  winExe := exePath
  winPid := pid
  winPos := "(" x ", " y ")"

  ; --- Mặc định copy path ---
  A_Clipboard := dir

  ; --- Thiết lập giao diện Notify ---
  Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (
    ; --- Hàm tạo nút (tự động nhận “xm” hoặc “x+”)
    makeBtn := (x, y, w, label, val, priority := 0, isFirst := false) => (pos := isFirst ? Format("xm w{1}", w)           ; nút đầu tiên
      : Format("x+{1} yp w{2}", x, w), ; các nút tiếp theo
    ; --- smartTrim mới: priority=0 mặc định giữa-cân ---
    btnText := smartTrim(val, w, priority, 1), btn := this.gui.AddButton(pos, btnText), btn.Tooltip := label ": " val,
    btn.OnEvent("Click", (*) => (A_Clipboard := val,                          ; copy vào clipboard
      ; --- Wrap lại giá trị mới ---
      wrappedVal := this.WordWrap("Đã copy: " val " vào clipboard", this.charLimit), this.content.Value :=
      wrappedVal,             ; cập nhật vùng hiển thị
      ; --- Cập nhật chiều cao GUI dựa vào số dòng mới ---
      lines := StrSplit(wrappedVal, "`n"), lineCount := lines.Length, autoHeight := lineCount * 20,                 ; 20 px mỗi dòng, có thể điều chỉnh
      this.guiPos.h := autoHeight, ToolTip(label " copied!"),                   ; hiển thị thông báo
      SetTimer(() => ToolTip(), -1000)             ; tắt tooltip sau 1 giây
    )), btn),
    ; --- Tạo các nút với width chuẩn ---
    w := 150, btn1 := makeBtn(0, 0, w, "Path", dir, 0, true),      ; priority=0, mặc định giữa-cân
    btn2 := makeBtn(10, 0, w, "Title", winTitle, 0), btn3 := makeBtn(10, 0, w, "ahk_exe", winExe, 0), btn4 :=
    makeBtn(0, 40, w, "Position", winPos, 0, true), btn5 := makeBtn(10, 0, w, "ahk_class", winClass, 0), btn6 :=
    makeBtn(10, 0, w, "ahk_pid", winPid, 0),
    ; --- Cập nhật chiều cao GUI ---
    this.guiPos.h += ((SysGet(80) >= 2) ? 40 : 10) * 2) })
  Notify("Đã copy: " dir " vào clipboard", "CopyProcessDirectory", "+ w500 t0.15 ra")
}

; 🔧 Đo chiều rộng chuỗi (theo font GUI thực tế)
measureTextWidth(txt, guiObj) {
  hDC := DllCall("GetDC", "ptr", guiObj.hwnd, "ptr")
  hFont := SendMessage(0x31, 0, 0, guiObj.Hwnd)  ; WM_GETFONT
  oldFont := DllCall("SelectObject", "ptr", hDC, "ptr", hFont, "ptr")
  sz := Buffer(8, 0)
  DllCall("GetTextExtentPoint32W", "ptr", hDC, "wstr", txt, "int", StrLen(txt), "ptr", sz)
  DllCall("SelectObject", "ptr", hDC, "ptr", oldFont)
  DllCall("ReleaseDC", "ptr", guiObj.hwnd, "ptr", hDC)
  return NumGet(sz, 0, "int")
}

smartTrim(txt, w, priority := 0, scale := A_ScreenDPI / 96) {
  pxWidth := w * 0.63643 * scale
  padding := 25 * scale
  maxWidth := pxWidth - padding
  ; --- Đo chiều rộng thực của chuỗi ---
  hDC := DllCall("GetDC", "ptr", 0, "ptr")
  hFont := DllCall("GetStockObject", "int", 17, "ptr")
  oldFont := DllCall("SelectObject", "ptr", hDC, "ptr", hFont, "ptr")
  size := Buffer(8, 0)
  DllCall("GetTextExtentPoint32W", "ptr", hDC, "wstr", txt, "int", StrLen(txt), "ptr", size)
  width := NumGet(size, 0, "int")
  DllCall("SelectObject", "ptr", hDC, "ptr", oldFont)
  DllCall("ReleaseDC", "ptr", 0, "ptr", hDC)
  if (width <= maxWidth)
    return txt
  cut := Ceil(StrLen(txt) * maxWidth / width)
  if (cut < 5)
    cut := 5
  ; --- Trường hợp mặc định (priority = 0) ---
  if (priority = 0)
    return SubStr(txt, 1, Floor(cut / 2) - 2) "..." SubStr(txt, -Floor(cut / 2))
  ; --- Trường hợp priority 1-6: các hướng cắt trước đó ---
  if (priority >= 1 && priority <= 6) {
    switch priority {
      case 1: return SubStr(txt, 1, cut - 3) "..."               ; trái
      case 2: return SubStr(txt, 1, Floor(cut / 2) - 2) "..." SubStr(txt, -Floor(cut / 2)) ; giữa cân
      case 3: return "..." SubStr(txt, -cut + 3)               ; phải
      case 4: return SubStr(txt, 1, Floor(cut * 0.7)) "..." SubStr(txt, -Floor(cut * 0.3)) ; lệch trái
      case 5: return SubStr(txt, 1, Floor(cut * 0.3)) "..." SubStr(txt, -Floor(cut * 0.7)) ; lệch phải
      case 6: return "..." SubStr(txt, Floor(StrLen(txt) / 2 - cut / 2), cut) "..." ; trung tâm tuyệt đối
    }
  }
  ; --- Trường hợp priority là string: xem như focusWord / regex ---
  m := RegExMatch(txt, priority, &found)
  if (m) {
    start := Max(1, m - Floor(cut / 2))
    trimmed := SubStr(txt, start, cut)
    if (start > 1)
      trimmed := "..." trimmed
    if ((start + cut) < StrLen(txt))
      trimmed .= "..."
    return trimmed
  }
  ; fallback: kiểu mặc định giữa-cân
  return SubStr(txt, 1, Floor(cut / 2) - 2) "..." SubStr(txt, -Floor(cut / 2))
}

GetRelativePath(path, subDrive := 1) {
  ; path := StrReplace(path, "/", "\")
  parts := StrSplit(path, "\")

  ; Bỏ ổ đĩa (D:, C:...) nếu có
  if (InStr(parts[1], ":"))
    parts.RemoveAt(1)

  total := parts.Length

  ; Lấy subDrive cấp cuối
  tail := []
  loop subDrive
    tail.Push(parts[total - subDrive + A_Index])

  ; Ghép "..\" với phần đuôi
  return "..\" . StrJoin("\", tail*)
}

GetBrowserInfo(specificInfo := '', to := '', notificationTimer := 0) {
  browserEx := WinGetProcessName("A")
  cUIA := UIA_Browser("ahk_exe " browserEx)
  url := cUIA.GetCurrentURL()
  if (browserEx = 'chrome.exe') {
    title := cUIA.GetTab()
    .name
    if RegExMatch(title, "(.*) - Memory usage - .*$", &title)
      title := title[1]
  }
  else if (browserEx = 'msedge.exe') {
    fullTitle := WinGetTitle("ahk_exe " browserEx)
    title := fullTitle
    if RegExMatch(title, "(.*?)( and \d+? more pages?)? - Personal - Microsoft​ Edge", &title) {
      ; Notify(toString(title))
      title := title[1]
    }
  }
  else if (browserEx = 'brave.exe') {
    fullTitle := WinGetTitle("ahk_exe " browserEx)
    title := fullTitle
    if RegExMatch(title, "(.*?) - Brave", &title) {
      title := title[1]
    }
  }
  if (specificInfo != '') {
    if (to != '') {
      %to% := %specificInfo%
      Notify("Đã copy `"" %to% "`" vào " to "!", , '+ t' notificationTimer)
    }
    return %specificInfo%
  }
  return { url: url, title: title, fullTitle: fullTitle }
}

; ============================================================
; 📦 AddCodeFile - thông báo lựa chọn tạo file/folder (Không đổi)
; ============================================================
CopyProblemID(isAuto := true, ext := "java") {
  tabTitle := ""
  try {
    browserInfo := GetBrowserInfo()
    tabTitle := browserInfo.title
    if !RegExMatch(tabTitle, "(?P<id>.*?) - (?P<Name>.*)", &m) || Trim(tabTitle) == ""
      return Notify("❌ Không thể lấy ID/Name từ tiêu đề:`n" browserInfo.fullTitle, "Extract Error",
        "+ t0 ce ra rb")
    ; Notify(tabTitle)
    ; Notify("Extract Failed:`n" browserInfo.fullTitle, "Extract Error", "+ t0 ce ra rb")
    ; if (InStr(tabTitle, "(Microsoft​ Edge)|(and \d+? more page(s)?)"))
    ;     return Notify("Extract Failed:`n" browserInfo.fullTitle, "Extract Error", "+ t0 ce ra rb")
    id := m["id"], problem := RemoveDiacritics(RegExReplace(m["Name"], "[-\(\)]"))

    ; Define path based on isAuto
    if (isAuto) {
      switch true {
        case RegExMatch(id, "i)^(J)"):
          ext := "java"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
        case RegExMatch(id, "i)^(ICPC|PY)"):
          ext := "py"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\1. Python\code\Python-PTIT"
        case RegExMatch(id, "i)^(SQL|DB|Q)"):
          ext := "sql"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\3. Database\code"
        default:
          ext := "java"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
      }
    }
    else {
      ; Existing path handling if isAuto is false
      switch ext {
        case "java":
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
        case "py":
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\1. Python\code\Python-PTIT"
        case "sql":
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\3. Database\code"
        default:
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
      }
    }
    filePath := path "\" id "_" problem "." ext
    ; targetFolderPath := path "\" id "_" problem
    ; targetFilePath := path "\" id "_" problem "." ext
    A_Clipboard := id

    try {
      switch ext {
        case "java":
          if FileExist(filePath) {
            Run(filePath)
            Notify(id "_" problem ".java", tabTitle, "+ s t3 ci")
          }
          else {
            Notify(id "_" problem ".java don't exist!`nPath: " filePath, "File Path Error", "+ ce t5")
            return
          }
        case "py":
          if FileExist(path "\" tabTitle ".py") {
            Run(path "\" tabTitle ".py")
            Notify(tabTitle, tabTitle, "+ s t3 ci")
          }
          else {
            Notify(tabTitle ".py don't exist!`nPath: " path "\" tabTitle ".py", "File Path Error",
              "+ ce t5")
            return
          }
        default:
          Notify("Unsupported file type!", "File Type Error", "+ ce t5")
      }

      WinActivate("ahk_exe msedge.exe")
    }

  }
  catch as err {
    debugInfo := "Message: " . err.Message . "`n"
      . "What: " . err.What . "`n"
      . "File: " . err.File . "`n"
      . "Line: " . err.Line . "`n"
      . "Stack:`n" . err.Stack
    Notify(debugInfo, "Execution Error", "+ s t10 ce")
  }
}

UploadSrcCode() {
  WinActivate("ahk_exe msedge.exe")
  CopyProblemID()
  Sleep(1000)
  WinActivate("ahk_exe msedge.exe")
  old_coord_mouse := A_CoordModeMouse
  CoordMode('Mouse', 'Client')
  Send('{End}')
  Sleep(1000)
  Click(900, 580)
  Sleep(2000)
  Click(950, 25)
  Sleep(1000)
  Send("^v")
  Sleep(2000)
  Click(315, 140)
  Sleep(1000)
  Send("{Enter}")
  WinActivate("ahk_exe msedge.exe")
  Sleep(2000)
  Click(1185, 650)
  CoordMode('Mouse', old_coord_mouse)
}

AddCodeFile(isAuto := true, ext := "", path := "", createFolder := false, create := false, openIDE := 'Code') {
  tabInfo := GetBrowserInfo()
  tabTitle := tabInfo.title
  if !RegExMatch(tabTitle, "(?P<id>.*) - (?P<Name>.*)", &m)
    return Notify("❌ Không thể lấy ID/Name từ tiêu đề!", "Lỗi", "+ ce ra rb")

  if (m["Name"] = "Leetcode") {
    problem := RemoveDiacritics(RegExReplace(m["id"], "[-\(\)]"))
    Notify(m.toString())
  }
  else {
    id := m["id"], problem := RemoveDiacritics(RegExReplace(m["Name"], "[-\(\)]"))

    ; Xác định ngôn ngữ & thư mục mặc định (Không đổi)
    if (isAuto) {
      switch true {
        case RegExMatch(id, "i)^(J)"):
          ext := "java"
          ; path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\src"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
        case RegExMatch(id, "i)^(ICPC|PY)"):
          ext := "py"
          ; path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\1. Python\code\src"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\1. Python\code\Python-PTIT"
        case RegExMatch(id, "i)^(SQL|DB|Q)"):
          ext := "sql"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\3. Database\code"
        default:
          ext := "java"
          ; path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\src"
          path := "D:\1. Jack\#Learn\#Uni\.3Year\.Sem5\2. OOP (Java)\code\CPTIT"
      }

    }
    filePath := path "\" id "_" problem "." ext
    targetFolderPath := path "\" id "_" problem
    targetFilePath := path "\" id "_" problem "." ext
  }
  ; ======================
  ; 🧭 Notify 1 - lựa chọn (Không đổi)
  ; ======================
  Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (
    this.chkFolder := this.gui.AddCheckbox("xp y+20", "+ Folder"),
    this.chkFolder.Value := createFolder,
    actionTitle := FileExist(this.data.targetFilePath) || DirExist(this.data.targetFolderPath) ? "Overwrite" :
      "New", ; Điều chỉnh title,
    ; actionTitle .= this.chkFolder.Value ? " Folder" : " File",
    chkVScode := this.gui.AddCheckbox("x+5 yp", openIDE || "Default"),
    chkVScode.Value := openIDE != "",
    btnAction := this.gui.AddButton("x+5 yp-10 w80", actionTitle),
    btnDelete := this.gui.AddButton("x+5 yp w80", "Xóa"), ; Thêm nút Xóa
    btnCancel := this.gui.AddButton("x+5 yp w80", "Hủy"),
    ; this.chkFolder.OnEvent("Click", (*) => (
    ;     btnAction.Value := FileExist(this.data.targetFilePath) || DirExist(this.data.targetFolderPath) ? "Ghi đè" :
    ;         "Tạo mới", ; Điều chỉnh title,
    ;     btnAction.Value .= this.chkFolder.Value ? " Folder" : " File"
    ; )),
    btnAction.OnEvent("Click", (*) => (
      HandleFileOrFolder(this.data, this.chkFolder.Value, chkVScode.Value ? openIDE : ""),
      this.gui.Destroy()
    )),
    btnDelete.OnEvent("Click", (*) => (
      ; Thêm sự kiện cho nút Xóa
      ; Chỉ định đường dẫn cần xóa. Có thể xóa cả 2 nếu muốn.
      DeleteFileOrFolder(this.data.targetFolderPath, true), ; Xóa folder nếu tồn tại
      DeleteFileOrFolder(this.data.targetFilePath, true), ; Xóa file nếu tồn tại
      this.gui.Destroy()
    )),
    btnCancel.OnEvent("Click", (*) => this.gui.Destroy()),
    this.guiPos.h += ((SysGet(80) >= 2) ? 40 : 10)
  ) })

  Notify("Create new " (createFolder ? "folder" : "file") ": " id "_" problem, "📁 " GetRelativePath(path, 3) " ?",
  "+ t5 rb ra cfff8b6 s", , { id: id, problem: problem, ext: ext, basePath: path, targetFilePath: targetFilePath, targetFolderPath: targetFolderPath })
  if (create)
    HandleFileOrFolder({ id: id, problem: problem, ext: ext, basePath: path, targetFilePath: targetFilePath, targetFolderPath: targetFolderPath },
    createFolder, openIDE)
}
; ============================================================
; ⚙️ HandleFileOrFolder - xử lý logic tạo file hoặc folder (Cải tiến)
; ============================================================
HandleFileOrFolder(data, createFolder := true, openIDE := '') {
  basePath := data.basePath
  id := data.id, problem := data.problem, ext := data.ext

  ; 1. DỌN DẸP TRƯỚC: Xóa cả hai phiên bản (File đơn và Folder) nếu chúng tồn tại
  ; Đảm bảo không có xung đột giữa folder cũ và file mới, hoặc ngược lại
  DeleteFileOrFolder(data.targetFilePath, false) ; Xóa file đơn (ví dụ: J001_Ten.java)
  DeleteFileOrFolder(data.targetFolderPath, true)  ; Xóa folder (ví dụ: J001_Ten)

  ; 2. TẠO PHIÊN BẢN MỚI
  if (createFolder) {
    folderPath := data.targetFolderPath
    DirCreate(folderPath) ; Đảm bảo folder được tạo (sau khi đã xóa folder cũ)
    filePath := folderPath "\" id "_" problem "." ext ; Đường dẫn file bên trong folder
  }
  else {
    filePath := data.targetFilePath ; Đường dẫn file đơn
  }

  ; 3. GHI NỘI DUNG VÀO FILE
  className := id "_" problem
  CreateNewFile(filePath, className, ext)

  resultMsg := "Created new " . (createFolder ? "Folder & File" : "File")
  resultMsg .= " " GetRelativePath(filePath, 1)
  ; resultMsg .= '`nPath: ' filePath

  ; ======================
  ; 🧭 Notify 2 - kết quả
  ; ======================
  if (openIDE)
    OpenInIDE(data.ext, filePath, openIDE)

  Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (
    btnOpenFile := this.gui.AddButton("y+10 w120", "Open File"),
    btnOpenFolder := this.gui.AddButton("x+10 yp w120", "Open Folder"),
    btnClose := this.gui.AddButton("yp w100", "Close"),
    btnOpenFile.Tooltip := filePath,
    btnOpenFolder.Tooltp := data.targetFolderPath,
    btnOpenFile.OnEvent("Click", (*) => (OpenInIDE(data.ext, filePath, openIDE), this.gui.Destroy())),
    btnOpenFolder.OnEvent("Click", (*) => (Run(data.targetFolderPath), this.gui.Destroy())),
    btnClose.OnEvent("Click", (*) => this.gui.Destroy()),
    this.guiPos.h += ((SysGet(80) >= 2) ? 40 : 10)) })

  Notify(resultMsg, GetRelativePath(data.basePath, 3), "+ t5 ra rb cw s", , { filePath: filePath, folderPath: data.targetFolderPath })

  ; Tùy chọn: ghi log
  ; LogAction(resultMsg, filePath)
}
; ============================================================
; 🗑️ DeleteFileOrFolder - Xử lý logic xóa file/folder (Cải tiến)
; ============================================================
; isRecursive: Chỉ định xem có xóa đệ quy (chỉ dùng cho folder)
DeleteFileOrFolder(path, isRecursive := false) {
  resultMsg := ""

  if (DirExist(path)) {
    ; Đây là Folder
    DirDelete(path, isRecursive)
    if (!DirExist(path)) {
      resultMsg := "🗑️ Đã xóa Folder"
    }
    else {
      ; Không thể xóa (thường do file bên trong đang mở)
      ; Sử dụng Notify riêng cho việc xóa, không dùng ở đây để tránh spam.
      return ; Không hiển thị Notify nếu không phải là mục đích chính
    }
  }
  else if (FileExist(path)) {
    ; Đây là File đơn
    FileDelete(path)
    if (!FileExist(path)) {
      resultMsg := "🗑️ Đã xóa File"
    }
    else {
      return ; Không hiển thị Notify nếu không phải là mục đích chính
    }
  }
  else {
    return ; Không tồn tại, không cần làm gì
  }

  ; *Ghi chú:* Để tránh thông báo Notify quá nhiều khi tạo file/folder,
  ; tôi đã loại bỏ Notify trong hàm này, chỉ dùng để xóa file/folder.
  ; Nếu bạn muốn thấy thông báo xóa khi nhấn "Ghi đè/Tạo mới", bạn có thể bỏ comment dòng Notify bên dưới.
  ; Notify(resultMsg . " " GetRelativePath(path, 1), GetRelativePath(path, 3), "+ ra rb ci s")
}
; ============================================================
; ✨ Hàm tạo file mẫu
; ============================================================
CreateNewFile(path, className, ext) {
  ; MsgBox(path)
  codeFile := FileOpen(path, "w")
  switch ext {
    case "java":
      content := "public class " className " {`n" . "    public static void main(String[] args) {`n" .
      "        System.out.println(`"Hello from " className "`");`n" . "    }`n" . "}"
    case "py":
      content := "def main():`n" . "    print('Hello from " className "')`n`n" . "if __name__ == '__main__':`n" .
      "    main()"
    case "sql":
      content := "-- " className "`nSELECT * FROM dual;"
    default:
      content := "; File " className "." ext " được tạo tự động."
  }

  codeFile.Write(content)
  codeFile.Close()
}
; ============================================================
; 🧠 Mở bằng IDE hoặc VS Code
; ============================================================
OpenInIDE(ext, path, openIDE := '') {
  if (openIDE = "") {
    switch ext {
      case "java": openIDE := "idea64.exe"
      case "py": openIDE := "pycharm64.exe"
      case "sql": openIDE := "datagrip64.exe"
      default: openIDE := "Code"
    }
  }
  try {
    ; Notify("cmd /c " openIDE " `"" path "`"", "Command", "+ t0 c000000 s")
    Run("cmd /c " openIDE " `"" path "`"", , 'Hide')
  } catch as e {
    Notify(Format("Error while open `"{}`" using {}:`n{}", path, openIDE, e.Message), "Error!", "+ ce t5")
  }
}
; ================================
; 🧾 Ghi log hành động
; ================================
; LogAction(msg, path) {
;     logFile := A_ScriptDir "\create_file_log.txt"
;     FileAppend(Format("[{1}] {2} → {3}`n", A_Now, msg, path), logFile, "UTF-8")
; }
RemoveDiacritics(str) {
  static MAP_COMPOSITE := 0x00000040

  ; cchDest là số ký tự; cấp phát buffer theo byte (UTF-16 = 2 byte/1 ký tự)
  cchDest := StrLen(str) * 4 + 1          ; dư dả để chứa chuỗi đã tách dấu
  buf := Buffer(cchDest * 2, 0)           ; *2 vì byte

  ; cchSrc = -1: xử lý đến ký tự NUL kết thúc
  chars := DllCall("kernel32\FoldStringW", "UInt", MAP_COMPOSITE, "Str", str, "Int", -1, "Ptr", buf, "Int",
    cchDest,
    "Int")

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

SearchName() {
  SoundBeep
  A_Clipboard := ''
  Send('^c')
  ; if (A_Clipboard != '') {
  Send('!``')
  Sleep 500
  SendText 'dịch tên tiếng hàn (theo phong cách Tiểu thuyết võ hiệp, Trung Nguyên) ' A_Clipboard
  Send('{Enter}')
  ; }
}
ModifyNum(increase := true, isPrecise := false, minVal := "", maxVal := "") {
  A_Clipboard := ''
  if (!isPrecise) {
    Send('^l')
    Sleep 300
  }
  Send('^c')
  if !ClipWait(0.5) {
    Send('^l')
    Sleep 300
    Send('^c')
    if !ClipWait(0.5) {
      TrayTip("❌ Không thể lấy nội dung clipboard.", "Lỗi", 16)
      return
    }
  }

  text := A_Clipboard

  ; --- Tăng/giảm tất cả số trong chuỗi, có điều kiện ---
  modified := RegExReplace(text, "\d+", (m, *) => (num := Number(m[0]),
  ; Nếu có min/max thì kiểm tra trước
  (minVal != "" && num < minVal) || (maxVal != "" && num > maxVal) ? num  ; nằm ngoài giới hạn ⇒ giữ nguyên
    : (increase ? num + 1 : num - 1)))

  SendTextFast(modified)
  Send('{Enter}')
}
SendTextFast(txt?) {
  oldClip := A_Clipboard
  A_Clipboard := txt
  ClipWait(0.2)
  Send("^v")
  Sleep 100
  A_Clipboard := oldClip
}
SendToVault_ori(path := "", vaultPath := "D:\1. Jack\#Vault") {
  if (path = "") {
    A_Clipboard := ""
    Send "^+c"
    if !ClipWait(1) {
      Notify("Không có dữ liệu!", "Lỗi", "+ cw")
      return
    }
    path := Trim(A_Clipboard, "`r`n`"")
  }
  if !DirExist(path) && !FileExist(path) {
    Notify("Đường dẫn không hợp lệ:`n" path, "Lỗi", "+ ce")
    return
  }

  SplitPath(path, , , , &filename)
  linkPath := vaultPath "\" filename

  esc := (p) => '"' StrReplace(p, '"', '""') '"'
  escPath := esc(path), escLinkPath := esc(linkPath)

  RunWait('pwsh -NoProfile -Command "Remove-Item -Force `'' escLinkPath '`' -ErrorAction SilentlyContinue"', ,
    "Hide"
  )
  itemType := DirExist(path) ? "Junction" : "SymbolicLink"
  RunWait(Format('pwsh -NoProfile -Command "New-Item -ItemType {1} -Path `'{2}`' -Target `'{3}`' -Force"',
    itemType,
    escLinkPath, escPath), , "Hide")

  if !(DirExist(linkPath) || FileExist(linkPath)) {
    Notify("Không thể tạo link:`n" linkPath, "Lỗi", "+ ce")
    return
  }

  Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (btn := this.gui.AddButton("xm w125", "Open Folder"
  ),
  btn.OnEvent("Click", (*) => Run('*open ' vaultPath)), this.guiPos.h += ((SysGet(80) >= 2) ? 40 : 10)) })
  Notify("Đã tạo link:`n" linkPath, "Thành công", "+ ra ci")
}
SendToVault(path := "", vaultPath := "D:\1. Jack\#Vault") {
  ;--- Nếu không truyền path, lấy từ clipboard (copy bằng Ctrl+Shift+C) ---
  if (path = "") {
    A_Clipboard := ""
    Send "^+c"
    if !ClipWait(1) {
      Notify("Không có dữ liệu!", "Lỗi", "+ cw")
      return
    }
    path := Trim(A_Clipboard, "`r`n`"")
  }

  ;--- Kiểm tra path hợp lệ ---
  if !DirExist(path) && !FileExist(path) {
    Notify("Đường dẫn không hợp lệ:`n" path, "Lỗi", "+ ce")
    return
  }

  ;--- Lấy tên cuối cùng của file hoặc folder ---
  if (DirExist(path))
    SplitPath(path, &name)
  else if (FileExist(path))
    SplitPath(path, , , , &name)
  ;--- Đường dẫn đến link trong vault ---
  linkPath := vaultPath "\" name

  ;--- Nếu link trùng, thêm hậu tố timestamp để tránh ghi đè ---
  if (DirExist(linkPath) || FileExist(linkPath)) {
    now := FormatTime(, "yyyyMMdd_HHmmss")
    linkPath := vaultPath "\" name "_" now
  }

  ;--- Escape ký tự cho PowerShell ---
  esc := (p) => '"' StrReplace(p, '"', '""') '"'
  escPath := esc(path)
  escLinkPath := esc(linkPath)

  ;--- Xóa link cũ nếu tồn tại ---
  RunWait('pwsh -NoProfile -Command "Remove-Item -Force `'' escLinkPath '`' - ErrorAction SilentlyContinue "', ,
    "Hide")
  ;--- Xác định loại link ---
  itemType := DirExist(path) ? "Junction" : "SymbolicLink"
  ;--- Tạo link mới ---
  RunWait(Format('pwsh -NoProfile -Command "New-Item -ItemType {1} -Path `'{2}`' -Target `'{3}`' -Force"',
    itemType,
    escLinkPath, escPath), , "Hide")
  ;--- Kiểm tra kết quả ---
  if !(DirExist(linkPath) || FileExist(linkPath)) {
    Notify("Không thể tạo link:`n" linkPath, "Lỗi", "+ ce")
    return
  }
  ;--- Thêm nút mở Vault trong thông báo ---
  Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (btn := this.gui.AddButton("xm w125", "Open Folder"
  ),
  btn.OnEvent("Click", (*) => Run('*open ' vaultPath)), this.guiPos.h += (SysGet(80) >= 2 ? 40 : 10)) })
  ;--- Thông báo thành công ---
  Notify("Đã tạo link:`n" linkPath, "Thành công", "+ ra ci")
}
CloseManual(simulation := false, sleepTime := 500, checkProcess := true) {
  winID := WinActive("A")
  if !winID {
    Notify("⚠️ Không tìm thấy cửa sổ đang hoạt động.", "AutoHotkey", "+ t5 sound cwarn")
    return
  }

  WinGetPos(&wx, &wy, &ww, &wh, winID)
  procName := WinGetProcessName(winID)
  title := WinGetTitle(winID)

  if (simulation) {
    MouseGetPos(&x, &y)
    closeX := wx + ww - 20
    closeY := wy + 10
    MouseMove(closeX, closeY)
    Sleep sleepTime
    Click
    MouseMove(x, y)
    Notify("🔧 Đã mô phỏng thao tác đóng cửa sổ: " title, "Simulation Mode", "+ t5 sound cinfo")
  }
  else {
    WinClose(winID)
    Sleep sleepTime
    Notify("📘 Đã gửi lệnh đóng cửa sổ: " title, "CloseManual", "+ t4 sound cinfo")
  }

  if (checkProcess) {
    Sleep 1000
    if ProcessExist(procName) {
      Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (btnKill := this.gui.AddButton("xm w220",
        "💀 Kill Process"), btnKill.OnEvent("Click", (*) => (WinKill(winID), Notify(
          "💀 Đã ép tắt tiến trình: " procName,
          "CloseManual", "+ t6 sound cinfo"), this.gui.Destroy())), this.guiPos.h += ((SysGet(80) >= 2) ?
            40 :
            10)) })
      Notify("⚠️ Ứng dụng vẫn đang chạy: " procName, "CloseManual", "+ t5 sound ra cwarn")
    }
    else {
      Notify("✅ Ứng dụng đã đóng thành công: " procName, "CloseManual", "+ t4 sound cinfo")
    }
  }
}
ProcessExist(procName) {
  try {
    for proc in ComObjGet("winmgmts:")
    .ExecQuery("Select * from Win32_Process")
      if (proc.Name = procName)
        return true
  }
  return false
}

ModifiedCopy(
  replaces := [
    []
  ],
  removesMulLines := false,
  removeSpaces := false,
  notifyEnabled := false
) {
  static ClipboardLock := false
  if (ClipboardLock)
    return

  ClipboardLock := true
  old_clip := ClipboardAll()
  A_Clipboard := ""
  Send "^c"
  if !ClipWait(3) {
    Notify("Không thể copy văn bản.", , "+ t3 s ce")
    A_Clipboard := old_clip
    ClipboardLock := false
    return
  }

  text := A_Clipboard

  ; --- Áp dụng replacement theo thứ tự
  for _, pair in replaces {
    find := pair[1]
    replaceWith := pair[2]

    if RegExMatch(replaceWith, "``n")
      replaceWith := RegExReplace(replaceWith, "``n", "`n")

    if (RegExMatch(find, "[\^\$\.\*\+\?\|\(\)\[\]\{\}]"))
      text := RegExReplace(text, find, replaceWith)
    else
      text := StrReplace(text, find, replaceWith)
  }

  ; --- Loại bỏ nhiều dòng trống
  if (removesMulLines)
    text := RegExReplace(text, "\R{2,}", "`n")

  ; --- Loại bỏ khoảng trắng đầu/cuối
  if (removeSpaces)
    text := RegExReplace(text, "m)^\s+|\s+$", "")

  SoundBeep(500, 200)
  A_Clipboard := text
  ClipboardLock := false

  if notifyEnabled
    Notify(A_Clipboard, "Copy to Clipboard", "+ t3 ci")

  return A_Clipboard
}
