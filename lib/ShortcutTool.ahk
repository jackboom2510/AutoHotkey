#Include <Log>
waitTime := 300

OnMessage(0x0200, On_WM_MOUSEMOVE)
OnMessage(0x4E, ObjBindMethod(ShortcutTool, "WM_NOTIFY"))

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

ShortcutTool
class ShortcutTool {
    static configFile := "C:\Users\jackb\Documents\AutoHotkey\configs\config.ini"
    static defaultPath := ""
    static gui := unset
    static pathLabel := ""
    static ddlPath := ""
    static ddlOptions := []
    static transparencyUpDown := unset
    static transparency := 225
    static transparencyStep := 10
    static transparencyMin := 50
    static transparencyMax := 255

    static pathMap := {
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

        ShortcutTool.InitVars()

        ShortcutTool.SetUpAll()

        ShortcutTool.Show()
        WinSetTransColor ShortcutTool.gui.BackColor, "Shortcut Tool"
        WinSetTransparent ShortcutTool.transparency, "Shortcut Tool"
    }

    static Show() {
        ShortcutTool.gui.Show("x1200 y85 AutoSize")
    }

    static SetUpAll() {
        SetupControls
        SetupEvents
        SetupTooltips

        SetupControls() {
            ShortcutTool.ddlPath := ShortcutTool.gui.AddDropDownList("xm y+5 w250 Choose" . ShortcutTool.ddlOptions.Length,
                ShortcutTool.ddlOptions)
            ShortcutTool.btnInsertDdl := ShortcutTool.gui.AddButton("x+5 yp w55", "Insert")
            ShortcutTool.btnRemoveDdl := ShortcutTool.gui.AddButton("x+5 yp w50", "Del")

            ShortcutTool.pathLabel := ShortcutTool.gui.AddEdit("xm y+5 w225 r1", ShortcutTool.defaultPath)
            ShortcutTool.btnApply := ShortcutTool.gui.AddButton("x+5 yp w30", "✅")
            ShortcutTool.btnBrowse := ShortcutTool.gui.AddButton("xp+35 yp w30", "🗂")
            ShortcutTool.btnPaste := ShortcutTool.gui.AddButton("xp+35 yp w30", "📋")
            ShortcutTool.btnSetDefault := ShortcutTool.gui.AddButton("xp+35 yp w30", "💾")

            ShortcutTool.btnExit := ShortcutTool.gui.AddButton("xp y+5 w30", "❌")
            ShortcutTool.btnReset := ShortcutTool.gui.AddButton("xp-35 yp w30", "↩")
            ShortcutTool.transparencyEdit := ShortcutTool.gui.AddEdit("xp-70 yp+3 w60 h25", ShortcutTool.transparency)
            ShortcutTool.transparencyUpDown := ShortcutTool.gui.AddUpDown("Range" ShortcutTool.transparencyMin "-" ShortcutTool
                .transparencyMax,
                ShortcutTool.transparency)

            ShortcutTool.btnAdd := ShortcutTool.gui.AddButton("xm yp-3 w120", "➕ Shortcut")
            ShortcutTool.btnHide := ShortcutTool.gui.AddButton("x+5 w100", "Hide")
        }

        SetupEvents() {
            ShortcutTool.ddlPath.OnEvent("Change", (*) => (
                ShortcutTool.pathLabel.Value := ShortcutTool.ddlOptions[ShortcutTool.ddlPath.Value]))

            ShortcutTool.btnInsertDdl.OnEvent("Click", (*) => ShortcutTool.AddPathToDdl())
            ShortcutTool.btnRemoveDdl.OnEvent("Click", (*) => ShortcutTool.RemovePathFromDdl())
            ShortcutTool.btnAdd.OnEvent("Click", (*) => ShortcutTool.AddShortcut())

            ShortcutTool.btnSetDefault.OnEvent("Click", (*) => ShortcutTool.SetAsDefaultPath())
            ShortcutTool.btnPaste.OnEvent("Click", (*) => ShortcutTool.PasteFromClipboard())
            ShortcutTool.btnBrowse.OnEvent("Click", (*) => ShortcutTool.ChangePath())
            ShortcutTool.btnApply.OnEvent("Click", (*) => ShortcutTool.ApplyPathFromEdit())
            ShortcutTool.btnReset.OnEvent("Click", (*) => (
                ShortcutTool.pathLabel.Value := ShortcutTool.defaultPath
                TrayTip("🔁 Đã hoàn tác về đường dẫn mặc định.")
            ))
            ShortcutTool.btnHide.OnEvent("Click", (*) => ShortcutTool.gui.Hide())
            ShortcutTool.btnExit.OnEvent("Click", (*) => ExitApp())
        }

        SetupTooltips() {
            ShortcutTool.btnInsertDdl.ToolTip := "Insert the selected path into the list."
            ShortcutTool.btnRemoveDdl.ToolTip := "Remove the selected path from the list."
            ShortcutTool.btnApply.ToolTip := "Apply the path from the input field."
            ShortcutTool.btnBrowse.ToolTip := "Browse and select a new path."
            ShortcutTool.btnPaste.ToolTip := "Paste a path from the clipboard."
            ShortcutTool.btnSetDefault.ToolTip := "Set the current path as the default.`nCurrent DefaultPath: " ShortcutTool
                .defaultPath
            ShortcutTool.btnReset.ToolTip := "Reset the path to the default."
            ShortcutTool.btnAdd.ToolTip := "Add a new shortcut."
            ShortcutTool.btnHide.ToolTip := "Hide the Shortcut Tool window."
            ShortcutTool.transparencyEdit.ToolTip := "Adjust transparency value (50–255)."
        }
    }

    static ChangePath() {
        newPath := DirSelect(ShortcutTool.pathLabel, 1, "Chọn thư mục lưu shortcut")
        if newPath {
            ShortcutTool.pathLabel.Value := newPath
            TrayTip("✅ Đã chọn thư mục:`n" . newPath)
        } else {
            TrayTip("❌ Không có thư mục nào được chọn.")
        }
    }

    static AddPathToDdl() {
        if !(CheckIfValueExists(ShortcutTool.ddlOptions, ShortcutTool.pathLabel.Value)) {
            ShortcutTool.ddlOptions.Push(ShortcutTool.pathLabel.Value)
            ShortcutTool.ddlPath.Add([ShortcutTool.pathLabel.Value])
            ShortcutTool.ddlPath.Choose(ShortcutTool.pathLabel.Value)
            ShortcutTool.SaveDdlOptionsToConfig()
            TrayTip(ShortcutTool.pathLabel.Value, "✅ Đã thêm đường dẫn mới vào danh sách: ")
        }
        else {
            TrayTip(ShortcutTool.pathLabel.Value, "❌ Đã tồn tại phần tử đường dẫn trong danh sách", 16)
        }
    }

    static RemovePathFromDdl() {
        selectedPath := ShortcutTool.ddlPath.Value
        if (selectedPath != 0) {
            value := ShortcutTool.ddlOptions.RemoveAt(selectedPath)
            ShortcutTool.ddlPath.Delete(selectedPath)
            ShortcutTool.SaveDdlOptionsToConfig()
            TrayTip("✅ Đã xóa phần tử " . value)
        }
        else {
            TrayTip("❌ Danh sách trống.", "Lỗi", 16)
        }
    }

    static SaveDdlOptionsToConfig() {
        if (ShortcutTool.ddlOptions.Length != 0) {
            paths := ""
            for index, value in ShortcutTool.ddlOptions {
                if (IsSet(value))
                    paths .= value . ","
            }
            paths := RTrim(paths, ",")
            IniWrite(paths, ShortcutTool.configFile, "DropdownOptions", "paths")
        }
    }

    static InitVars() {
        if FileExist(ShortcutTool.configFile) {
            ShortcutTool.defaultPath := IniRead(ShortcutTool.configFile, "ShortcutTool", "defaultPath", "")
        }
        if ShortcutTool.defaultPath = ""
            ShortcutTool.defaultPath := "D:\5. Jack\#Learn\Language\Japan"
        paths := ""
        if FileExist(ShortcutTool.configFile) {
            paths := IniRead(ShortcutTool.configFile, "DropdownOptions", "paths", "")
        }
        if (paths = "") {
            paths := ShortcutTool.pathMap
            IniWrite(ShortcutTool.defaultPath, ShortcutTool.configFile, "DropdownOptions", "paths")
        }
        loop parse, paths, "," {
            ShortcutTool.ddlOptions.Push(A_LoopField)
        }
    }

    static SetAsDefaultPath() {
        newPath := ShortcutTool.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            ShortcutTool.defaultPath := newPath
            IniWrite(ShortcutTool.defaultPath, ShortcutTool.configFile, "ShortcutTool", "defaultPath")
            ShortcutTool.btnSetDefault.ToolTip := "Set the current path as the default.`nCurrent DefaultPath: " newPath
            TrayTip("✅ Đã lưu đường dẫn làm mặc định:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ, không thể lưu.", "Lỗi", 16)
        }
    }

    static PasteFromClipboard() {
        if A_Clipboard != "" {
            ShortcutTool.pathLabel.Value := A_Clipboard
            TrayTip("📋 Đã dán từ clipboard.")
        }
        else {
            TrayTip("❌ Clipboard đang trống.")
        }
    }

    static ApplyPathFromEdit() {
        if (ShortcutTool.pathLabel.Value = "Desktop")
            ShortcutTool.pathLabel.Value := A_Desktop
        newPath := ShortcutTool.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            ShortcutTool.defaultPath := newPath
            TrayTip("✅ Cập nhật đường dẫn thành:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ.", "Lỗi", 16)
        }
    }
    
    static Toggle() {
        if !ShortcutTool.gui {
            ShortcutTool
            return
        }
        hwnd := ShortcutTool.gui.Hwnd
        if !WinExist("ahk_id " hwnd) {
            ShortcutTool.gui.Show("x1200 y85 AutoSize")
            return
        }
        winState := WinGetMinMax("ahk_id " hwnd)
        if winState = -1
            ShortcutTool.gui.Show("x1200 y85 AutoSize")
        else
            ShortcutTool.gui.Hide()
    }

    static WM_NOTIFY(wParam, lParam, Msg, hWnd) {
        static UDN_DELTAPOS := -722
        static is64Bit := (A_PtrSize = 8)

        NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
        DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

        hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
        code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
        delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

        if (hwndFrom = ShortcutTool.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
            newVal := ShortcutTool.transparencyUpDown.Value + delta * ShortcutTool.transparencyStep
            newVal := Min(Max(newVal, ShortcutTool.transparencyMin), ShortcutTool.transparencyMax)
            ShortcutTool.transparencyUpDown.Value := newVal
            ShortcutTool.transparencyEdit.Value := newVal
            ShortcutTool.transparency := newVal
            WinSetTransparent ShortcutTool.transparency, "Shortcut Tool"
            return true
        }
    }

    static AddShortcut() {

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

        DirCreate(ShortcutTool.defaultPath)

        if WinExist("ahk_class CabinetWClass") {
            WinActivate("ahk_class CabinetWClass")
            Send("!d")
            Sleep 200
            SendText(ShortcutTool.defaultPath)
            Send("{Enter}")
        } else {
            Run("explorer.exe " . ShortcutTool.defaultPath)
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