#Requires AutoHotkey v2.0.18+
#Include <core\Core>
Persistent
!F6:: adb.PullImage()
;@Ahk2Exe-SetMainIcon D:\Documents\AutoHotkey\assets\icon\adb.ico
On_WM_MOUSEMOVE := 0x0200
On_WM_NOTIFY := 0x4E
class AdbImagePuller {
    gui := unset
    guiID := ""
    configFile := "D:\Documents\AutoHotkey\configs\adb_imagepuller.ini"
    ddlOptions := []
    defaultPath := ""
    fileNameEdit := ""
    ddlPath := ""
    pathLabel := ""
    transparency := 225
    transparencyStep := 10
    transparencyMin := 50
    transparencyMax := 255
    transparencyEdit := ""
    transparencyUpDown := ""
    __New() {
        this.gui := Gui("+AlwaysOnTop -Caption +Resize +ToolWindow", "ADB Puller")
        this.guiID := this.gui.Hwnd
        this.gui.SetFont("s10", "Segoe UI")
        this.gui.BackColor := "F0FFFF"
        this.InitVars()
        this.SetupAll()
        this.Show()
        WinSetTransColor this.gui.BackColor, "ADB Puller"
        WinSetTransparent this.transparency, "ADB Puller"
        OnMessage(On_WM_MOUSEMOVE, ObjBindMethod(this, "On_WM_MOUSEMOVE"))
        OnMessage(On_WM_NOTIFY, ObjBindMethod(this, "On_WM_NOTIFY"))
    }
    Show() {
        this.gui.Show("x1200 y130 AutoSize")
    }
    InitVars() {
        if FileExist(this.configFile)
            this.defaultPath := IniRead(this.configFile, "General", "defaultPath", "")
        if this.defaultPath = ""
            this.defaultPath := A_Desktop
        paths := ""
        if FileExist(this.configFile)
            paths := IniRead(this.configFile, "DropdownOptions", "paths", "")
        if (paths = "") {
            paths := A_Desktop "," "D:\Pictures" "," "D:\Downloads"
            IniWrite(paths, this.configFile, "DropdownOptions", "paths")
        }
        loop parse, paths, ","
            this.ddlOptions.Push(A_LoopField)
    }
    SetupAll() {
        this.fileNameEdit := this.gui.AddEdit("xm y+5 w365 h25", "")
        this.fileNameEdit.ToolTip := "Nhập tên ảnh cần kéo từ điện thoại (VD: /sdcard/DCIM/Screenshots/${tên_ảnh}.jpg)"
        this.ddlPath := this.gui.AddDropDownList("xm y+5 w225 Choose1", this.ddlOptions)
        this.ddlPath.ToolTip := "Chọn thư mục lưu ảnh"
        this.openDir := this.gui.AddButton("x+5 yp w30", "📂")
        this.openDir.ToolTip := "Mở thư mục đang chọn"
        this.btnInsertDdl := this.gui.AddButton("x+5 yp w50", "Insert")
        this.btnInsertDdl.ToolTip := "Thêm đường dẫn vào danh sách"
        this.btnRemoveDdl := this.gui.AddButton("x+5 yp w45", "Del")
        this.btnRemoveDdl.ToolTip := "Xoá đường dẫn khỏi danh sách"
        this.pathLabel := this.gui.AddEdit("xm y+5 w225 r1", this.defaultPath)
        this.pathLabel.ToolTip := "Đường dẫn thư mục lưu ảnh"
        this.btnApply := this.gui.AddButton("x+5 yp w30", "✅")
        this.btnApply.ToolTip := "Áp dụng đường dẫn từ ô nhập"
        this.btnBrowse := this.gui.AddButton("xp+35 yp w30", "🗂️")
        this.btnBrowse.ToolTip := "Chọn thư mục lưu ảnh"
        this.btnPaste := this.gui.AddButton("xp+35 yp w30", "📋")
        this.btnPaste.ToolTip := "Dán đường dẫn từ clipboard"
        this.btnSetDefault := this.gui.AddButton("xp+35 yp w30", "💾")
        this.btnSetDefault.ToolTip := "Đặt làm thư mục mặc định"
        this.btnExit := this.gui.AddButton("xp y+5 w30", "❌")
        this.btnExit.ToolTip := "Thoát ứng dụng"
        this.btnReset := this.gui.AddButton("xp-35 yp w30", "↩")
        this.btnReset.ToolTip := "Khôi phục đường dẫn mặc định"
        this.transparencyEdit := this.gui.AddEdit("xp-70 yp+3 w60 h25", this.transparency)
        this.transparencyEdit.ToolTip := "Độ trong suốt của cửa sổ"
        this.transparencyUpDown := this.gui.AddUpDown("Range" this.transparencyMin "-" this.transparencyMax,
            this.transparency)
        this.btnPull := this.gui.AddButton("xm yp-3 w110", "⬇ Pull")
        this.btnPull.ToolTip := "Kéo ảnh từ điện thoại về máy"
        this.btnHide := this.gui.AddButton("x+5 yp w110", "Hide")
        this.btnHide.ToolTip := "Ẩn cửa sổ này"
        this.ddlPath.OnEvent("Change", (*) => this.pathLabel.Value := this.ddlPath.Text)
        this.openDir.OnEvent("Click", (*) => Run(this.ddlPath.Text))
        this.btnInsertDdl.OnEvent("Click", (*) => this.InsertPathToDDL())
        this.btnRemoveDdl.OnEvent("Click", (*) => this.RemovePathFromDDL())
        this.btnApply.OnEvent("Click", (*) => this.ApplyPath())
        this.btnBrowse.OnEvent("Click", (*) => this.BrowsePath())
        this.btnPaste.OnEvent("Click", (*) => this.PasteClipboard())
        this.btnSetDefault.OnEvent("Click", (*) => this.SetDefaultPath())
        this.btnExit.OnEvent("Click", (*) => ExitApp())
        this.btnReset.OnEvent("Click", (*) => this.pathLabel.Value := this.defaultPath)
        this.btnPull.OnEvent("Click", (*) => this.PullImage(this.fileNameEdit.Value))
        this.btnHide.OnEvent("Click", (*) => this.gui.Hide())
    }
    PullImage(pathOnDevice := "") {
        if (pathOnDevice = "") {
            inp := InputBox("Vui lòng nhập tên ảnh hoặc đường dẫn ảnh trên thiết bị Android:`n"
                "Ví dụ:`n   1. /sdcard/DCIM/Screenshots/screenshot.jpg`n    2. screenshot.jpg",
                "Pull Image`nVui lòng nhập tên ảnh hoặc đường dẫn ảnh trên thiết bị Android", 'w400 h150',
                '/sdcard/DCIM/Screenshots/.jpg')
            if (inp.result != 'Ok') {
                TrayTip("❌ Đã hủy thao tác kéo ảnh.")
                return
            }
            pathOnDevice := Trim(inp.value)
            if (pathOnDevice = "") {
                TrayTip("❌ Tên ảnh không hợp lệ.")
                return
            }
        }
        else {
            pathOnDevice := Trim(pathOnDevice)
            if (pathOnDevice = "") {
                TrayTip("❌ Tham số đường dẫn không hợp lệ.")
                return
            }
        }
        if !InStr(pathOnDevice, "/") {
            pathOnDevice := "/sdcard/DCIM/Screenshots/" . pathOnDevice
        }
        localFileName := RegExReplace(pathOnDevice, ".*/", "")
        if !RegExMatch(localFileName, "\.jpg$") {
            localFileName .= ".jpg"
        }
        localPath := this.pathLabel.Value . "\" . localFileName
        if !DirExist(this.pathLabel.Value)
            DirCreate(this.pathLabel.Value)
        RunWait(Format('adb pull "{}" "{}"', pathOnDevice, localPath), , "Hide")
        if FileExist(localPath) {
            Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (
                btn := this.gui.AddButton("w150", "Open Image"),
                btn.OnEvent("Click", (*) => Run("*open " localPath)),
                this.guipos.h += 40
            ) })
            Notify("Đã thêm ảnh vào " localPath ".", "✅ AdbImagePuller", "+ t5 ra ci")
        }
        else
            TrayTip("❌ Không tìm thấy ảnh trên thiết bị.", "ADB Pull Lỗi", 16)
    }
    InsertPathToDDL() {
        val := this.pathLabel.Value
        if !this.ddlOptions.Has(val) {
            this.ddlOptions.Push(val)
            this.ddlPath.Add(val)
            this.ddlPath.Choose(val)
            this.SaveDdl()
            TrayTip("✅ Đã thêm vào danh sách.")
        }
    }
    RemovePathFromDDL() {
        idx := this.ddlPath.Value
        if (idx > 0) {
            removed := this.ddlOptions.RemoveAt(idx)
            this.ddlPath.Delete(idx)
            this.SaveDdl()
            TrayTip("🗑️ Đã xoá: " . removed)
        }
    }
    SaveDdl() {
        paths := ""
        for _, v in this.ddlOptions
            paths .= v . ","
        paths := RTrim(paths, ",")
        IniWrite(paths, this.configFile, "DropdownOptions", "paths")
    }
    ApplyPath() {
        val := this.pathLabel.Value
        if DirExist(val) {
            this.defaultPath := val
            TrayTip("📁 Đã cập nhật đường dẫn.")
        }
        else
            TrayTip("❌ Đường dẫn không hợp lệ.")
    }
    BrowsePath() {
        p := DirSelect(this.pathLabel.Value)
        if p
            this.pathLabel.Value := p
    }
    PasteClipboard() {
        if A_Clipboard != ""
            this.pathLabel.Value := A_Clipboard
        else
            TrayTip("📋 Clipboard đang trống.")
    }
    SetDefaultPath() {
        p := this.pathLabel.Value
        if p != "" && DirExist(p) {
            this.defaultPath := p
            IniWrite(p, this.configFile, "General", "defaultPath")
            TrayTip("💾 Đã lưu mặc định.")
        }
        else
            TrayTip("❌ Đường dẫn không hợp lệ.")
    }
    Toggle() {
        if this.guiID && WinExist("ahk_id " this.guiID)
            this.gui.Hide()
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
            WinSetTransparent this.transparency, "ADB Puller"
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
adb := AdbImagePuller()
scriptPath := 'D:\Documents\AutoHotkey\src\v2\ADBImagePuller.ahk'
SplitPath(scriptPath, &scriptName, &scriptDir)
A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert('&Suspend Hotkeys', 'Recompile Script', (*) => (
    Run('cmd /c ""D:\Documents\AutoHotkey\bin\build\ahk2exe-compile.bat" "' scriptPath '" & pause"'),
    TrayTip('Compile Success: ' scriptName, 'Success!', 1)
))
if (A_IsCompiled) {
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Reload Script', (*) => Reload())
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Edit Script', (*) => Run('*edit ' scriptPath))
    A_TrayMenu.Insert('&Suspend Hotkeys')
}
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Open File Location", (*) => Run("*open " scriptDir))
A_TrayMenu.SetIcon("Open File Location", "C:\Windows\System32\shell32.dll", 4)
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Pull Image", (*) => adb.PullImage())
A_TrayMenu.SetIcon("Pull Image", "D:\Documents\AutoHotkey\assets\icon\adb.ico")
A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => adb.Toggle())
A_TrayMenu.Default := "Show/Hide"
A_TrayMenu.ClickCount := 1