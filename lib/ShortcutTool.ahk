waitTime := 300
CheckIfValueExists(arr, value) {
    for idx, item in arr {
        if (IsSet(item)) {
            if (item = value)
                return true
        }
    }
    return false
}

class ShortcutTool {
    static configFile := "C:\Users\jackb\Documents\AutoHotkey\configs\config.ini"
    static defaultPath := ""
    static gui := unset
    static pathLabel := ""
    static btnBrowse := ""
    static btnApply := ""
    static btnInsertDdl := ""
    static ddlPath := ""
    static ddlOptions := []
    static transparency := 200

    static pathMap := {
        Desktop: "C:\Users\jackb\Desktop",
        Documents: "C:\Users\jackb\Documents",
        Downloads: "C:\Users\jackb\Downloads",
        Music: "C:\Users\jackb\Music",
        Pictures: "C:\Users\jackb\Pictures",
        Videos: "C:\Users\jackb\Videos"
    }

    static CreateGui() {
        ShortcutTool.gui := Gui("+AlwaysOnTop -Caption +Resize", "Shortcut Tool")
        ShortcutTool.gui.SetFont("s10", "Segoe UI")
        ShortcutTool.gui.BackColor := "eaffff"
        ShortcutTool.InitDefaultPath()
        ShortcutTool.LoadDdlOptionsFromConfig()

        ShortcutTool.ddlPath := ShortcutTool.gui.Add("DropDownList", "x10 y+5 w250 Choose" . ShortcutTool.ddlOptions.Length,
            ShortcutTool.ddlOptions)
        ShortcutTool.btnInsertDdl := ShortcutTool.gui.Add("Button", "x+5 yp w55", "Insert")
        ShortcutTool.btnRemoveDdl := ShortcutTool.gui.Add("Button", "x+5 yp w50", "Del")
        ShortcutTool.pathLabel := ShortcutTool.gui.Add("Edit", "x10 y+5 w225", ShortcutTool.defaultPath)
        ShortcutTool.btnApply := ShortcutTool.gui.Add("Button", "x+5 yp w30", "✅")
        ShortcutTool.btnBrowse := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "🗂")
        ShortcutTool.btnPaste := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "📋")
        ShortcutTool.btnSetDefault := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "💾")
        ShortcutTool.gui.Add("Button", "xp y+5 w30", "❌").OnEvent("Click", (*) => ExitApp())
        ShortcutTool.btnTransparentUp := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "➕")
        ShortcutTool.btnTransparentDown := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "➖")
        ShortcutTool.btnReset := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "↩")
        ShortcutTool.gui.Add("Button", "xm yp w120", "➕ Shortcut").OnEvent("Click", (*) => ShortcutTool.AddShortcut())
        ShortcutTool.btnHide := ShortcutTool.gui.Add("Button", "x+5 w100", "Hide")

        ShortcutTool.ddlPath.OnEvent("Change", (*) => ShortcutTool.OnDropdownChange())
        ShortcutTool.btnInsertDdl.OnEvent("Click", (*) => ShortcutTool.AddPathToDdl())
        ShortcutTool.btnRemoveDdl.OnEvent("Click", (*) => ShortcutTool.RemovePathFromDdl())
        ShortcutTool.btnSetDefault.OnEvent("Click", (*) => ShortcutTool.SetAsDefaultPath())
        ShortcutTool.btnTransparentDown.OnEvent("Click", (*) => ShortcutTool.DecreaseTransparency())
        ShortcutTool.btnTransparentUp.OnEvent("Click", (*) => ShortcutTool.IncreaseTransparency())
        ShortcutTool.btnPaste.OnEvent("Click", (*) => ShortcutTool.PasteFromClipboard())
        ShortcutTool.btnBrowse.OnEvent("Click", (*) => ShortcutTool.ChangePath())
        ShortcutTool.btnApply.OnEvent("Click", (*) => ShortcutTool.ApplyPathFromEdit())
        ShortcutTool.btnReset.OnEvent("Click", (*) => ShortcutTool.ResetPathToDefault())
        ShortcutTool.btnHide.OnEvent("Click", (*) => ShortcutTool.gui.Hide())

        ShortcutTool.gui.OnEvent("Size", (*) => ShortcutTool.ResizeControls)
        ShortcutTool.gui.Show("x1200 y85 AutoSize")
        WinSetTransColor ShortcutTool.gui.BackColor, "Shortcut Tool"
        WinSetTransparent ShortcutTool.transparency, "Shortcut Tool"
    }

    static OnDropdownChange() {
        selectedPath := ShortcutTool.ddlPath.Value
        ShortcutTool.pathLabel.Value := ShortcutTool.ddlOptions[selectedPath]
    }

    static LoadDdlOptionsFromConfig() {
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

    static AddPathToDdl() {
        if !(CheckIfValueExists(ShortcutTool.ddlOptions, ShortcutTool.defaultPath)) {
            ShortcutTool.ddlOptions.Push(ShortcutTool.defaultPath)
            ShortcutTool.ddlPath.Add([ShortcutTool.defaultPath])
            ShortcutTool.ddlPath.Choose(ShortcutTool.defaultPath)
            ShortcutTool.SaveDdlOptionsToConfig()
            TrayTip(ShortcutTool.defaultPath, "✅ Đã thêm đường dẫn mới vào danh sách: ")
        }
        else {
            TrayTip(ShortcutTool.defaultPath, "❌ Đã tồn tại phần tử đường dẫn trong danh sách" 16)

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

    static ResizeControls(guiObj, minMax, width, height) {
        marginRight := 10
        spacing := 5
        btnW := 30

        totalBtnWidth := 6 * btnW + 5 * spacing

        btnStartX := width - marginRight - totalBtnWidth

        x := y := w := h := 0
        ControlGetPos(&x, &y, &w, &h, ShortcutTool.pathLabel)

        ShortcutTool.pathLabel.Move(, , btnStartX - x - spacing)

        ShortcutTool.btnPaste.Move(btnStartX + 0 * (btnW + spacing), y)
        ShortcutTool.btnBrowse.Move(btnStartX + 1 * (btnW + spacing), y)
        ShortcutTool.btnHide.Move(btnStartX + 2 * (btnW + spacing), y)
        ShortcutTool.btnReset.Move(btnStartX + 3 * (btnW + spacing), y)
        ShortcutTool.btnApply.Move(btnStartX + 4 * (btnW + spacing), y)
        ShortcutTool.btnSetDefault.Move(btnStartX + 5 * (btnW + spacing), y)
    }

    static UpdateTransparency() {
        hwnd := ShortcutTool.gui.Hwnd
        if WinExist("ahk_id " hwnd)
            WinSetTransparent(ShortcutTool.transparency, "ahk_id " hwnd)
    }

    static IncreaseTransparency() {
        ShortcutTool.transparency := Min(ShortcutTool.transparency + 25, 255)
        ShortcutTool.UpdateTransparency()
    }

    static DecreaseTransparency() {
        ShortcutTool.transparency := Max(ShortcutTool.transparency - 25, 50)
        ShortcutTool.UpdateTransparency()
    }

    static Toggle() {
        if !ShortcutTool.gui {
            ShortcutTool.CreateGui()
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

    static InitDefaultPath() {
        if FileExist(ShortcutTool.configFile) {
            ShortcutTool.defaultPath := IniRead(ShortcutTool.configFile, "ShortcutTool", "defaultPath", "")
        }
        if ShortcutTool.defaultPath = ""
            ShortcutTool.defaultPath := "D:\5. Jack\#Learn\Language\Japan"
    }

    static SaveDefaultPath() {
        IniWrite(ShortcutTool.defaultPath, ShortcutTool.configFile, "ShortcutTool", "defaultPath")
    }

    static SetAsDefaultPath() {
        newPath := ShortcutTool.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            ShortcutTool.defaultPath := newPath
            ShortcutTool.SaveDefaultPath()
            TrayTip("✅ Đã lưu đường dẫn làm mặc định:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ, không thể lưu.", "Lỗi", 16)
        }
    }

    static ChangePath() {
        newPath := DirSelect(ShortcutTool.defaultPath, 1, "Chọn thư mục lưu shortcut")
        if newPath {
            ShortcutTool.defaultPath := newPath
            ShortcutTool.pathLabel.Value := newPath
            TrayTip("✅ Đã chọn thư mục:`n" . newPath)
        } else {
            TrayTip("❌ Không có thư mục nào được chọn.")
        }
    }

    static ResetPathToDefault() {
        ShortcutTool.pathLabel.Value := ShortcutTool.defaultPath
        TrayTip("🔁 Đã hoàn tác về đường dẫn mặc định.")
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
}
