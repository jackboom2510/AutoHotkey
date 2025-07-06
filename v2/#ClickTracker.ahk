#Requires AutoHotkey v2.0
#Include "lib\ClickTracker.ahk"
#Include "lib\HelpGui.ahk"
#SingleInstance Force
Persistent()

ClickTracker.Init()

; Phím tắt
!t:: ClickTracker.StartTracking()
!b:: ClickTracker.StopTracking()
MButton:: ClickTracker.OnMouseClick()

ClickTracker_InitTrayMenu()
ClickTracker_ShowHelpUI(5)

ClickTracker_InitTrayMenu() {
    A_TrayMenu.Delete()
	A_TrayMenu.Add("Help", (*) => ClickTracker_ShowHelpUI())
    A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload Script", (*) => Reload())
    A_TrayMenu.Add("Edit Script", (*) => Edit())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
    A_TrayMenu.Add("Pause Script", (*) => TogglePause())
	A_TrayMenu.Add("Show/Hide", (*) => ClickTracker.Toggle())
    A_TrayMenu.Add("Exit", (*) => ExitApp())

    A_TrayMenu.Default := "Show/Hide"
    A_TrayMenu.ClickCount := 1
}

ClickTracker_ShowHelpUI(hideTimer := 0) {
    sections := [
        {
            title: "",
            lines: [
				"Middle Button`t→ Theo dõi một lần nhấp chuột thủ công",
                "Alt+T`t→ Bắt đầu theo dõi nhấp chuột",
                "Alt+B`t→ Dừng theo dõi và xuất kết quả",
            ]
        },
    ]
    
    ShowHelp("🧩 ClickTracker Script Hotkey Help", sections, hideTimer)
}