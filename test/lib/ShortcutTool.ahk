#Include <Log>
waitTime := 300
class ShortcutTool {
    static gui := unset
    configFile := "C:\Users\jackb\Documents\AutoHotkey\configs\config.ini"

    defaultPath := ""
    pathLabel := ""
    ddlPath := ""
    ddlOptions := []

    transparencyUpDown := unset
    transparency := 225
    transparencyStep := 10
    transparencyMin := 50
    transparencyMax := 255

    pathMap := {
        Desktop: "C:\Users\jackb\Desktop",
        Documents: "C:\Users\jackb\Documents",
        Downloads: "C:\Users\jackb\Downloads",
        Music: "C:\Users\jackb\Music",
        Pictures: "C:\Users\jackb\Pictures",
        Videos: "C:\Users\jackb\Videos"
    }

    __New() {
        ShortcutTool.gui := Gui("+AlwaysOnTop -Caption +Resize -DPIScale", "Shortcut Tool")
        ShortcutTool.gui.SetFont("s10", "Segoe UI")
        ShortcutTool.gui.BackColor := "eaffff"

        this.InitVars()

        this.SetUpAll()

        this.Show()
        WinSetTransColor ShortcutTool.gui.BackColor, "Shortcut Tool"
        WinSetTransparent this.transparency, "Shortcut Tool"
        OnMessage(0x0200, ObjBindMethod(this, "On_WM_MOUSEMOVE"))
        OnMessage(0x4E, ObjBindMethod(this, "On_WM_NOTIFY"))
    }

    Show() {
        if (ShortcutTool.gui)
            ShortcutTool.gui.Show("x1200 y85 AutoSize")
        else
            ShortcutTool
    }

    SetUpAll() {
        SetupControls
        SetupEvents
        SetupTooltips

        SetupControls() {
            this.ddlPath := ShortcutTool.gui.AddDropDownList("xm y+5 w250 Choose" . this.ddlOptions.Length,
                this.ddlOptions)
            this.btnInsertDdl := ShortcutTool.gui.AddButton("x+5 yp w55", "Insert")
            this.btnRemoveDdl := ShortcutTool.gui.AddButton("x+5 yp w50", "Del")

            this.pathLabel := ShortcutTool.gui.AddEdit("xm y+5 w225 r1", this.defaultPath)
            this.btnApply := ShortcutTool.gui.AddButton("x+5 yp w30", "✅")
            this.btnBrowse := ShortcutTool.gui.AddButton("xp+35 yp w30", "🗂")
            this.btnPaste := ShortcutTool.gui.AddButton("xp+35 yp w30", "📋")
            this.btnSetDefault := ShortcutTool.gui.AddButton("xp+35 yp w30", "💾")

            this.btnExit := ShortcutTool.gui.AddButton("xp y+5 w30", "❌")
            this.btnReset := ShortcutTool.gui.AddButton("xp-35 yp w30", "↩")
            this.transparencyEdit := ShortcutTool.gui.AddEdit("xp-70 yp+3 w60 h25", this.transparency)
            this.transparencyUpDown := ShortcutTool.gui.AddUpDown("Range" this.transparencyMin "-" this.transparencyMax,
                this.transparency)
            this.btnAdd := ShortcutTool.gui.AddButton("xm yp-3 w120", "➕ Shortcut")
            this.btnHide := ShortcutTool.gui.AddButton("x+5 w100", "Hide")
        }

        SetupEvents() {
            this.ddlPath.OnEvent("Change", (*) => (
                this.pathLabel.Value := this.ddlOptions[this.ddlPath.Value]))

            this.btnInsertDdl.OnEvent("Click", (*) => this.AddPathToDdl())
            this.btnRemoveDdl.OnEvent("Click", (*) => this.RemovePathFromDdl())
            this.btnAdd.OnEvent("Click", (*) => this.AddShortcut())

            this.btnSetDefault.OnEvent("Click", (*) => this.SetAsDefaultPath())
            this.btnPaste.OnEvent("Click", (*) => this.PasteFromClipboard())
            this.btnBrowse.OnEvent("Click", (*) => this.ChangePath())
            this.btnApply.OnEvent("Click", (*) => this.ApplyPathFromEdit())
            this.btnReset.OnEvent("Click", (*) => (
                this.pathLabel.Value := this.defaultPath
                TrayTip("🔁 Đã hoàn tác về đường dẫn mặc định.")
            ))
            this.btnHide.OnEvent("Click", (*) => ShortcutTool.gui.Hide())
            this.btnExit.OnEvent("Click", (*) => ExitApp())
        }

        SetupTooltips() {
            this.btnInsertDdl.ToolTip := "Insert the selected path into the list."
            this.btnRemoveDdl.ToolTip := "Remove the selected path from the list."
            this.btnApply.ToolTip := "Apply the path from the input field."
            this.btnBrowse.ToolTip := "Browse and select a new path."
            this.btnPaste.ToolTip := "Paste a path from the clipboard."
            this.btnSetDefault.ToolTip := "Set the current path as the default.`nCurrent DefaultPath: " this.defaultPath
            this.btnReset.ToolTip := "Reset the path to the default."
            this.btnAdd.ToolTip := "Add a new shortcut."
            this.btnHide.ToolTip := "Hide the Shortcut Tool window."
            this.transparencyEdit.ToolTip := Format("Adjust transparency value ({}–{}).", this.transparencyMin, this.transparencyMax)
        }
    }

    InitVars() {
        if FileExist(this.configFile) {
            this.defaultPath := IniRead(this.configFile, "ShortcutTool", "defaultPath", "")
        }
        if this.defaultPath = ""
            this.defaultPath := "D:\5. Jack\#Learn\Language\Japan"
        paths := ""
        if FileExist(this.configFile) {
            paths := IniRead(this.configFile, "DropdownOptions", "paths", "")
        }
        if (paths = "") {
            paths := this.pathMap
            IniWrite(this.defaultPath, this.configFile, "DropdownOptions", "paths")
        }
        loop parse, paths, "," {
            this.ddlOptions.Push(A_LoopField)
        }
    }

    AddShortcut() {
        if !WinExist("ahk_exe chrome.exe") {
            TrayTip("Không tìm thấy cửa sổ Chrome đang mở!", "Lỗi", 16)
            return
        }

        WinActivate("ahk_exe chrome.exe")
        winTitle := WinGetTitle("A")

        Send("^l")
        Send("^c")
        Sleep 300
        if !ClipWait(2) || A_Clipboard = "" {
            TrayTip("Clipboard trống hoặc không lấy được URL!", "Lỗi", 16)
            return
        }
        url := A_Clipboard

        title := StrReplace(winTitle, " - Google Chrome")
        title := Trim(title)

        if InStr(url, "youtube.com") || InStr(url, "youtu.be") {
            title := StrReplace(title, " - YouTube")
            prefix := "(Y) "
        } else {
            prefix := "(L) "
        }

        title := prefix . RegExReplace(title, "[\\/:*?" "<>|]", "")

        DirCreate(this.pathLabel)

        if WinExist("ahk_class CabinetWClass") {
            WinActivate("ahk_class CabinetWClass")
            Send("!d")
            Sleep 200
            SendText(this.pathLabel)
            Send("{Enter}")
        } else {
            Run("explorer.exe " . this.pathLabel)
            if !WinWaitActive("ahk_class CabinetWClass", , 3) {
                TrayTip("Không thể mở File Explorer!", "Lỗi", 16)
                return
            }
        }
        Sleep 300

        Send("{AppsKey}")
        Sleep(waitTime)
        Send("!w")
        Sleep(waitTime)
        Send("1")
        Sleep(waitTime)
        Send("s")
        Sleep(waitTime)

        SendText(url)
        Send("{Enter}")
        Sleep(waitTime)

        SendText(title)
        Send("{Enter}")
        Sleep(waitTime)

        TrayTip("✅ Shortcut đã được tạo với tiêu đề:`n" . title, "Hoàn tất")
    }

    ChangePath() {
        newPath := DirSelect(this.pathLabel, 1, "Chọn thư mục lưu shortcut")
        if newPath {
            this.pathLabel.Value := newPath
            TrayTip("✅ Đã chọn thư mục:`n" . newPath)
        } else {
            TrayTip("❌ Không có thư mục nào được chọn.")
        }
    }

    AddPathToDdl() {
        if !(CheckIfValueExists(this.ddlOptions, this.pathLabel.Value)) {
            this.ddlOptions.Push(this.pathLabel.Value)
            this.ddlPath.Add([this.pathLabel.Value])
            this.ddlPath.Choose(this.pathLabel.Value)
            this.SaveDdlOptionsToConfig()
            TrayTip(this.pathLabel.Value, "✅ Đã thêm đường dẫn mới vào danh sách: ")
        }
        else {
            TrayTip(this.pathLabel.Value, "❌ Đã tồn tại phần tử đường dẫn trong danh sách", 16)
        }
    }

    RemovePathFromDdl() {
        selectedPath := this.ddlPath.Value
        if (selectedPath != 0) {
            value := this.ddlOptions.RemoveAt(selectedPath)
            this.ddlPath.Delete(selectedPath)
            this.SaveDdlOptionsToConfig()
            TrayTip("✅ Đã xóa phần tử " . value)
        }
        else {
            TrayTip("❌ Danh sách trống.", "Lỗi", 16)
        }
    }

    SaveDdlOptionsToConfig() {
        if (this.ddlOptions.Length != 0) {
            paths := ""
            for index, value in this.ddlOptions {
                if (IsSet(value))
                    paths .= value . ","
            }
            paths := RTrim(paths, ",")
            IniWrite(paths, this.configFile, "DropdownOptions", "paths")
        }
    }

    SetAsDefaultPath() {
        newPath := this.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            this.defaultPath := newPath
            IniWrite(this.defaultPath, this.configFile, "ShortcutTool", "defaultPath")
            this.btnSetDefault.ToolTip := "Set the current path as the default.`nCurrent DefaultPath: " newPath
            TrayTip("✅ Đã lưu đường dẫn làm mặc định:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ, không thể lưu.", "Lỗi", 16)
        }
    }

    PasteFromClipboard() {
        if A_Clipboard != "" {
            this.pathLabel.Value := A_Clipboard
            TrayTip("📋 Đã dán từ clipboard.")
        }
        else {
            TrayTip("❌ Clipboard đang trống.")
        }
    }

    ApplyPathFromEdit() {
        if (this.pathLabel.Value = "Desktop")
            this.pathLabel.Value := A_Desktop
        newPath := this.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            this.defaultPath := newPath
            TrayTip("✅ Cập nhật đường dẫn thành:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ.", "Lỗi", 16)
        }
    }

    Toggle() {
        if WinExist("ahk_id " ShortcutTool.gui.Hwnd)
            ShortcutTool.gui.Hide()
        else
            this.Show()
    }

    On_WM_NOTIFY(wParam, lParam, Msg, hWnd) {
        static UDN_DELTAPOS := -722
        static is64Bit := (A_PtrSize = 8)

        NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
        DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

        hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
        code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
        delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

        if (hwndFrom = this.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
            newVal := this.transparencyUpDown.Value + delta * this.transparencyStep
            newVal := Min(Max(newVal, this.transparencyMin), this.transparencyMax)
            this.transparencyUpDown.Value := newVal
            this.transparencyEdit.Value := newVal
            this.transparency := newVal
            WinSetTransparent this.transparency, "Shortcut Tool"
            return true
        }
    }

    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd) {
            Text := "", ToolTip()
            CurrControl := GuiCtrlFromHwnd(Hwnd)
            if CurrControl {
                if !CurrControl.HasProp("ToolTip")
                    return
                Text := CurrControl.ToolTip
                ToolTip(Text)
            }
            PrevHwnd := Hwnd
        }
    }


}

CheckIfValueExists(arr, value) {
    for idx, item in arr {
        if (IsSet(item)) {
            if (item = value)
                return true
        }
    }
    return false
}