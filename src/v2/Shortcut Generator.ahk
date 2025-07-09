#Include <ShortcutTool>
#Include <HelpGui>
#Include <KeyBinding>
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetMainIcon C:\Users\jackb\Documents\AutoHotkey\icon\internet.ico

; ====== Hotkeys ======
hotkeys := LoadHotkeys(, "ShortcutGenerator")
AssignHotkey(hotkeys["AddShortcut"], ShortcutTool.AddShortcut)
AssignHotkey(hotkeys["ChangePath"], ShortcutTool.ChangePath)
AssignHotkey(hotkeys["Toggle"], ShortcutTool.Toggle)

; ====== Start ====
ShortcutTool.CreateGui()
ShortcutGen_InitTrayMenu()
ShortcutGen_ShowHelpUI(5)

ShortcutGen_InitTrayMenu() {
    A_TrayMenu.Delete()
	A_TrayMenu.Add("Help", (*) => ShortcutGen_ShowHelpUI())
    A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload Script", (*) => Reload())
    A_TrayMenu.Add("Edit Script", (*) => Edit())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
    A_TrayMenu.Add("Pause Script", (*) => TogglePause())
	A_TrayMenu.Add("Show/Hide", (*) => ShortcutTool.Toggle())
    A_TrayMenu.Add("Exit", (*) => ExitApp())

    A_TrayMenu.Default := "Show/Hide"
	A_TrayMenu.ClickCount := 1
}

ShortcutGen_ShowHelpUI(hideTimer := 0) {
    sections := [
        {
            title: "📜 Shortcut Tool Help",
            lines: [
                HK(hotkeys["AddShortcut"]) " → Thêm Shortcut mới",
                HK(hotkeys["ChangePath"]) " → Thay đổi đường dẫn của Shortcut",
                HK(hotkeys["Toggle"]) " → Ẩn/Hiện tính năng của Shortcut Tool",
            ]
        },
        {
            title: "💡 Lưu ý",
            lines: [
                "Sử dụng các phím tắt để tương tác nhanh với công cụ.",
            ]
        }
    ]
    
    ShowHelp("📚 Công cụ Shortcut - Hướng dẫn sử dụng", sections, hideTimer)
}