#include <core\Log>
#Include <core\Chrome>
#Include <other\UIA-v2\Lib\UIA_Browser>
#Include <other\UIA-v2\Lib\UIA>
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
        ShortcutTool.gui := Gui("+AlwaysOnTop -Caption +Resize", "Shortcut Tool")
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
            this.ddlPath := ShortcutTool.gui.AddDropDownList("xm y+5 w225 Choose" . this.ddlOptions.Length,
                this.ddlOptions)
            this.openDir := ShortcutTool.gui.AddButton("x+5 yp w30", "📂")
            this.btnInsertDdl := ShortcutTool.gui.AddButton("x+5 yp w50", "Insert")
            this.btnRemoveDdl := ShortcutTool.gui.AddButton("x+5 yp w45", "Del")

            this.pathLabel := ShortcutTool.gui.AddEdit("xm y+5 w225 r1", this.defaultPath)
            this.btnApply := ShortcutTool.gui.AddButton("x+5 yp w30", "✅")
            this.btnBrowse := ShortcutTool.gui.AddButton("xp+35 yp w30", "🗂️")
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
            this.openDir.OnEvent("Click", (*) => Run(this.ddlPath.Text))
            this.ddlPath.OnEvent("Change", (*) => (
                this.pathLabel.Value := this.ddlPath.Text))

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
            this.openDir.ToolTipo := "Open current directory"
            this.btnInsertDdl.ToolTip := "Insert the selected path into the list."
            this.btnRemoveDdl.ToolTip := "Remove the selected path from the list."
            this.btnApply.ToolTip := "Apply the path from the input field."
            this.btnBrowse.ToolTip := "Browse and select a new path."
            this.btnPaste.ToolTip := "Paste a path from the clipboard."
            this.btnSetDefault.ToolTip := "Set the current path as the default.`nCurrent DefaultPath: " this.defaultPath
            this.btnReset.ToolTip := "Reset the path to the default."
            this.btnAdd.ToolTip := "Add a new shortcut."
            this.btnHide.ToolTip := "Hide the Shortcut Tool window."
            this.transparencyEdit.ToolTip := Format("Adjust transparency value ({}–{}).", this.transparencyMin, this.transparencyMax
            )
        }
    }

    InitVars() {
        if FileExist(this.configFile) {
            this.defaultPath := IniRead(this.configFile, "ShortcutTool", "defaultPath", "")
        }
        if this.defaultPath = ""
            this.defaultPath := "D:\1. Jack"
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
        info := GetBrowserInfo()
        if (info.url = "")
            return
        title := StrReplace(info.title, " - Google Chrome")
        title := Trim(title)
        if InStr(info.url, "youtube.com") || InStr(info.url, "youtu.be") {
            title := StrReplace(title, " - YouTube")
            prefix := "(Y) "
        } else {
            prefix := "(L) "
        }

        title := prefix . RegExReplace(title, "[\\/:*?" "<>|]", "")

        shortcutDir := this.pathLabel.Value
        DirCreate(shortcutDir)

        CreateShortcutFile(shortcutDir, info.url, title)
        GetBrowserInfo() {
            try {
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
                return { url: url, title: title }
            }
            throw Error
        }
        CreateShortcutFile(shortcutPath, targetUrl, shortcutTitle) {
            try {
                shell := ComObject("WScript.Shell")
                shortcut := shell.CreateShortcut(shortcutPath . "\" . shortcutTitle . ".url")
                shortcut.TargetPath := targetUrl
                shortcut.Save()
                TrayTip("✅ Shortcut đã được tạo thành công.", "Hoàn tất")
            } catch as ex {
                TrayTip("❌ Lỗi khi tạo shortcut: " . ex.Message, "Lỗi", 16)
            }
        }
    }

    ChangePath() {
        newPath := DirSelect(this.pathLabel.Value, 1, "Chọn thư mục lưu shortcut")
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
