#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode(2)
Persistent()

waitTime := 300

class ShortcutTool
{
    static configFile := A_ScriptDir "\config.ini"
    static defaultPath := ""
    static gui := unset
    static pathLabel := ""
    static btnBrowse := ""
    static btnApply := ""
    static transparency := 200

    static CreateGui()
    {
        ShortcutTool.gui := Gui("+AlwaysOnTop -Caption +Resize", "Shortcut Tool")
        ; ShortcutTool.gui.BackColor := "Fuchsia"
        ShortcutTool.gui.SetFont("s10", "Segoe UI")

        ; ShortcutTool.gui.Add("Text", , "Thư mục mặc định:")
        ShortcutTool.pathLabel := ShortcutTool.gui.Add("Edit", "x10 y+5 w225", ShortcutTool.defaultPath)
        ShortcutTool.btnBrowse := ShortcutTool.gui.Add("Button", "x+5 yp w30", "🗂")
        ShortcutTool.btnPaste := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "📋")
        ShortcutTool.btnSetDefault := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "💾")
        ShortcutTool.btnHide := ShortcutTool.gui.Add("Button", "xp+35 yp w30", "👁️‍🗨")
        ShortcutTool.btnReset := ShortcutTool.gui.Add("Button", "xp y+5 w30", "↩")
        ShortcutTool.btnTransparentUp := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "➕")
        ShortcutTool.btnTransparentDown := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "➖")
        ShortcutTool.btnApply := ShortcutTool.gui.Add("Button", "xp-35 yp w30", "✅")
        ShortcutTool.gui.Add("Button", "xm yp w120", "➕ Shortcut").OnEvent("Click", (*) => ShortcutTool.AddShortcut())
        ShortcutTool.gui.Add("Button", "x+5 w100", "Exit").OnEvent("Click", (*) => ExitApp())
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
        WinSetTransparent 200, "Shortcut Tool"
    }
    
    static ResizeControls(guiObj, minMax, width, height)
    {
        marginRight := 10
        spacing := 5
        btnW := 30

        ; Tổng chiều rộng 6 nút: 6 nút + 5 khoảng spacing
        totalBtnWidth := 6 * btnW + 5 * spacing

        ; Tính vị trí bắt đầu của nút đầu tiên (btnPaste) sao cho nút cuối cùng (btnApply) sát lề phải
        btnStartX := width - marginRight - totalBtnWidth

        ; Lấy vị trí Y từ pathLabel
        x := y := w := h := 0
        ControlGetPos(&x, &y, &w, &h, ShortcutTool.pathLabel)

        ; Resize Edit để chiếm phần còn lại bên trái
        ShortcutTool.pathLabel.Move(, , btnStartX - x - spacing)

        ; Di chuyển các nút theo chiều ngang, từ phải sang trái
        ShortcutTool.btnPaste.Move(btnStartX + 0 * (btnW + spacing), y)
        ShortcutTool.btnBrowse.Move(btnStartX + 1 * (btnW + spacing), y)
        ShortcutTool.btnHide.Move(btnStartX + 2 * (btnW + spacing), y)
        ShortcutTool.btnReset.Move(btnStartX + 3 * (btnW + spacing), y)
        ShortcutTool.btnApply.Move(btnStartX + 4 * (btnW + spacing), y)
        ShortcutTool.btnSetDefault.Move(btnStartX + 5 * (btnW + spacing), y)
    }

    static UpdateTransparency()
    {
        hwnd := ShortcutTool.gui.Hwnd
        if WinExist("ahk_id " hwnd)
            WinSetTransparent(ShortcutTool.transparency, "ahk_id " hwnd)
    }

    static IncreaseTransparency()
    {
        ShortcutTool.transparency := Min(ShortcutTool.transparency + 25, 255)
        ShortcutTool.UpdateTransparency()
    }

    static DecreaseTransparency()
    {
        ShortcutTool.transparency := Max(ShortcutTool.transparency - 25, 50)
        ShortcutTool.UpdateTransparency()
    }


    static Toggle()
    {
        if !ShortcutTool.gui
        {
            ShortcutTool.CreateGui()
            return
        }

        hwnd := ShortcutTool.gui.Hwnd

        ; Kiểm tra cửa sổ có tồn tại hay không
        if !WinExist("ahk_id " hwnd)
        {
            ShortcutTool.gui.Show("x1200 y85 AutoSize")
            return
        }

        winState := WinGetMinMax("ahk_id " hwnd)  ; -1: hidden, 0: normal, 1: maximized

        if winState = -1
            ShortcutTool.gui.Show("x1200 y85 AutoSize")
        else
            ShortcutTool.gui.Hide()
    }

    static AddShortcut()
    {
        ; B1: Kiểm tra Chrome và lấy URL
        if !WinExist("ahk_exe chrome.exe") {
            MsgBox("Không tìm thấy cửa sổ Chrome đang mở!", "Lỗi", 16)
            return
        }

        ; Lấy tiêu đề Chrome trước khi chuyển URL
        WinActivate("ahk_exe chrome.exe")
        winTitle := WinGetTitle("A")

        ; B2: Lấy URL từ thanh địa chỉ
        Send("^l")
        Send("^c")
        Sleep 300
        if !ClipWait(2) || A_Clipboard = "" {
            MsgBox("Clipboard trống hoặc không lấy được URL!", "Lỗi", 16)
            return
        }
        url := A_Clipboard

        ; B3: Tạo tiêu đề hợp lệ
        title := StrReplace(winTitle, " - Google Chrome")              ; Xoá hậu tố Chrome
        title := Trim(title)

        ; B3.1: Thêm tiền tố và xử lý đặc biệt nếu là YouTube
        if InStr(url, "youtube.com") || InStr(url, "youtu.be") {
            title := StrReplace(title, " - YouTube")                   ; Xoá hậu tố YouTube nếu có
            prefix := "(Y) "
        } else {
            prefix := "(L) "
        }

        ; B3.2: Xoá ký tự không hợp lệ và thêm tiền tố
        title := prefix . RegExReplace(title, "[\\/:*?" "<>|]", "")      ; Tên file hợp lệ

        ; B4: Tạo thư mục nếu chưa có
        DirCreate(ShortcutTool.defaultPath)

        ; B5: Mở hoặc chuyển thư mục trong Explorer
        if WinExist("ahk_class CabinetWClass") {
            WinActivate("ahk_class CabinetWClass")
            Send("!d")
            Sleep 200
            SendText(ShortcutTool.defaultPath)
            Send("{Enter}")
        } else {
            Run("explorer.exe " . ShortcutTool.defaultPath)
            if !WinWaitActive("ahk_class CabinetWClass", , 3) {
                MsgBox("Không thể mở File Explorer!", "Lỗi", 16)
                return
            }
        }
        Sleep 300

        ; B6: Mô phỏng tạo shortcut
        Send("{AppsKey}")
        Sleep(waitTime)
        Send("!w")
        Sleep(waitTime)
        Send("1")
        Sleep(waitTime)
        Send("s")
        Sleep(waitTime)

        ; B7: Nhập URL
        SendText(url)
        Send("{Enter}")
        Sleep(waitTime)

        ; B8: Nhập tiêu đề đã xử lý
        SendText(title)
        Send("{Enter}")
        Sleep(waitTime)

        TrayTip("✅ Shortcut đã được tạo với tiêu đề:`n" . title, "Hoàn tất")
    }
    
    static InitDefaultPath()
    {
        ; Nếu file tồn tại, đọc giá trị
        if FileExist(ShortcutTool.configFile)
        {
            ShortcutTool.defaultPath := IniRead(ShortcutTool.configFile, "ShortcutTool", "defaultPath", "")
        }

        ; Nếu không có giá trị (lần đầu), dùng giá trị mặc định
        if ShortcutTool.defaultPath = ""
            ShortcutTool.defaultPath := "D:\5. Jack\#Learn\Language\Japan"
    }

    static SaveDefaultPath()
    {
        IniWrite(ShortcutTool.defaultPath, ShortcutTool.configFile, "ShortcutTool", "defaultPath")
    }

    static SetAsDefaultPath()
    {
        newPath := ShortcutTool.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            ShortcutTool.defaultPath := newPath
            ShortcutTool.SaveDefaultPath()
            TrayTip("✅ Đã lưu đường dẫn làm mặc định:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ, không thể lưu.", "Lỗi", 16)
        }
    }

    static ChangePath()
    {
        newPath := DirSelect(ShortcutTool.defaultPath, 1, "Chọn thư mục lưu shortcut")
        if newPath {
            ShortcutTool.defaultPath := newPath
            ShortcutTool.pathLabel.Value := newPath
            TrayTip("✅ Đã chọn thư mục:`n" . newPath)
        } else {
            TrayTip("❌ Không có thư mục nào được chọn.")
        }
    }

    static ResetPathToDefault()
    {
        ShortcutTool.pathLabel.Value := ShortcutTool.defaultPath
        TrayTip("🔁 Đã hoàn tác về đường dẫn mặc định.")
    }

    static PasteFromClipboard()
    {
        if A_Clipboard != ""
        {
            ShortcutTool.pathLabel.Value := A_Clipboard
            TrayTip("📋 Đã dán từ clipboard.")
        }
        else
        {
            TrayTip("❌ Clipboard đang trống.")
        }
    }

    static ApplyPathFromEdit()
    {
        newPath := ShortcutTool.pathLabel.Value
        if newPath != "" && DirExist(newPath) {
            ShortcutTool.defaultPath := newPath
            TrayTip("✅ Cập nhật đường dẫn thành:`n" . newPath)
        } else {
            TrayTip("❌ Đường dẫn không hợp lệ.", "Lỗi", 16)
        }
    }
}
