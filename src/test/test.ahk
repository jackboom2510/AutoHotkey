#SingleInstance
Persistent
; #Include <core\Log>

scriptPath := 'C:\Users\jackb\Documents\AutoHotkey\src\v2\.ahk'
SplitPath(scriptPath, &scriptName, &scriptDir)
A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert('&Suspend Hotkeys', 'Recompile Script', (*) => (
    Run('cmd /c ""C:\Users\jackb\Documents\AutoHotkey\build\ahk2exe-compile.bat" "' scriptPath '" & pause"'),
    TrayTip('Compile Success: ' scriptName, 'Success!', 1)
))
if (A_IsCompiled) {
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Reload Script', (*) => Reload())
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Edit Script', (*) => Run('"D:\2. Program Files\cursor\Cursor.exe" ' scriptPath))
    A_TrayMenu.Insert('&Suspend Hotkeys')
}
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Open File Location', (*) => Run('*open ' scriptDir))
A_TrayMenu.SetIcon('Open File Location', 'shell32.dll', 4)
A_TrayMenu.Insert('E&xit', 'Show Hotkeys', (*) => ShowHotkeys())
A_TrayMenu.SetIcon('Show Hotkeys', 'shell32.dll', 24)
A_TrayMenu.Insert('E&xit', 'Favorites', (*) => .Favorites)
A_TrayMenu.Insert('E&xit')
A_TrayMenu.SetIcon('Favorites', 'shell32.dll', 44)
A_TrayMenu.Insert('E&xit', 'Show/Hide', (*) => .Toggle())
A_TrayMenu.Default := 'Show/Hide'
A_TrayMenu.ClickCount := 1