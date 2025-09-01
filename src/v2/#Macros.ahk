#Include <core\KeyBinding>
#Include <core\UserFuncs>
#Include <ui\StatusOverlay>
#Include <ui\NotificationUI>
#Include <util\AppAutomation>
#Include <util\SystemControls>
#Include <util\KeyMacro>
#Include <util\MouseMacro>
#Include <util\Timer>
#Include utils.ahk


overlay := StatusOverlay(, 'y863 w18 h24 bg1Green bg2Red')
options := KeyBindingUI(['Button', 'Hotkeys', 'xp-80 yp w75', (*) => ShowHotkeys(), 'Show Hotkeys'])
SetTimer (*) => options.Hide(), -3000
overlay.ToggleVisibility()
BindingScript()

GetScriptStatus() {
    return overlay.isScriptEnabled
}

GetOption(option, *) {
    return options.Checkbox[option].Value
}

scriptPath := 'C:\Users\jackb\Documents\AutoHotkey\src\v2\#Macros.ahk'
SplitPath(scriptPath, &scriptName, &scriptDir)
A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert('&Suspend Hotkeys', 'Recompile Script', (*) => (
    Run('cmd /c ""C:\Users\jackb\Documents\AutoHotkey\bin\build\ahk2exe-compile.bat" "' scriptPath '" & pause"'),
    TrayTip('Compile Success: ' scriptName, 'Success!', 1)
))
if (A_IsCompiled) {
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Reload Script', (*) => Reload())
    A_TrayMenu.Insert('&Suspend Hotkeys', 'Edit Script', (*) => Run('*edit ' scriptPath))
    A_TrayMenu.Insert('&Suspend Hotkeys')
}
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Open File Location', (*) => Run('*open ' scriptDir))
A_TrayMenu.SetIcon('Open File Location', 'C:\Windows\System32\shell32.dll', 4)
A_TrayMenu.Insert('E&xit', 'Show Hotkeys', (*) => ShowHotkeys())
A_TrayMenu.SetIcon('Show Hotkeys', 'C:\Windows\System32\shell32.dll', 24)
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Show/Hide', (*) => options.Toggle())
A_TrayMenu.Default := 'Show/Hide'
A_TrayMenu.ClickCount := 1

#Hotif (GetWindowStatus(1, 'Demon Bluff'))
{
    XButton1:: Send '{1}'
    XButton2:: Send '{2}'
    MButton:: Send '{3}'
    !MButton:: Send '{4}'
}

#Hotif (GetOption(2))
PgUp:: return
+PgUp:: return
^PgUp:: return
!PgUp:: return
#PgUp:: return
^+PgUp:: return
^!PgUp:: return
!+PgUp:: return
#+PgUp:: return
#^PgUp:: return
#!PgUp:: return
^!+PgUp:: return
^!#PgUp:: return
>^PgUp:: return
PgDn:: return
+PgDn:: return
^PgDn:: return
!PgDn:: return
#PgDn:: return
^+PgDn:: return
^!PgDn:: return
!+PgDn:: return
#+PgDn:: return
#^PgDn:: return
#!PgDn:: return
^!+PgDn:: return
^!#PgDn:: return
#Hotif