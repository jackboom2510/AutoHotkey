#Include <macro\ClickTracker>
#Include <core\KeyBinding>
;@Ahk2Exe-SetMainIcon click.ico

TextAlign_widths := [
    5
]
ClickTrackerObj := ClickTracker()

StartTracking() {
    return ClickTrackerObj.isTracking
}
BindingScript

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
if (A_IsCompiled) {
    A_TrayMenu.Insert("&Suspend Hotkeys", "Reload Script", (*) => Reload())
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Edit Script', (*) => Run(
        'edit* "D:\Documents\AutoHotkey\src\v2\ClickTracker.ahk"'
    ))
    A_TrayMenu.Insert("&Suspend Hotkeys")
}
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Open File Location", (*) => Run("*open " "D:\Documents\AutoHotkey\src\v2\"))
A_TrayMenu.SetIcon("Open File Location", "C:\Windows\System32\shell32.dll", 4)
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys())
A_TrayMenu.SetIcon("Show Hotkeys", "C:\Windows\System32\shell32.dll", 24)
A_TrayMenu.Insert("E&xit", "StartTracking", (*) => ClickTrackerObj.StartTracking())
A_TrayMenu.Insert("E&xit")
A_TrayMenu.SetIcon("StartTracking", "C:\Windows\System32\shell32.dll", 44)
A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => ClickTrackerObj.Toggle())
A_TrayMenu.Default := "Show/Hide"
A_TrayMenu.ClickCount := 1