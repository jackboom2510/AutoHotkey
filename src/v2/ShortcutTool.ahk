#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
;@Ahk2Exe-SetMainIcon D:\Documents\AutoHotkey\assets\icon\internet.ico

#Include <core\KeyBinding>
#Include <macro\ShortcutTool>

ShortcutToolObj := ShortcutTool()
BindingScript()

scriptPath := 'D:\Documents\AutoHotkey\src\v2\Macros.ahk'
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
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys())
A_TrayMenu.SetIcon("Show Hotkeys", "C:\Windows\System32\shell32.dll", 24)
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Add ShortCut", (*) => ShortcutToolObj.AddShortcut())
A_TrayMenu.SetIcon("Add ShortCut", "C:\Windows\System32\shell32.dll", 44)
A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => ShortcutToolObj.Toggle())
A_TrayMenu.Default := "Show/Hide"
A_TrayMenu.ClickCount := 1