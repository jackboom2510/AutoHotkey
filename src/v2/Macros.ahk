#Include <core\Core>
#Include <core\KeyBinding>
#Include <core\UserFuncs>
#Include <ui\StatusOverlay>
#Include <ui\UINumpad>
#Include <macro\AppAutomation>
#Include <macro\SystemControls>
#Include <macro\KeyMacro>
#Include <macro\MouseMacro>
#Include <macro\Timer>
#Include utils.ahk

if (MonitorGetCount() > 1)
  overlay := StatusOverlay(, 'y860 w18 h24 bg1Green bg2Red')
else
  overlay := StatusOverlay(, 'y1035 w18 h24 bg1Green bg2Red')
MyNumpad := UINumpad()
options := KeyBindingUI(, [], [
  'Button',
  'Reload',
  'xp-80 yp w75',
  (*) => Reload()
], [
  'Button',
  'hotkeys.json',
  'xm y+10 w125',
  (*) => Run(
    'pwsh -command "code -n . && code -g D:\Documents\AutoHotkey\configs\hotkeys.json:70:103',
    'D:\Documents\AutoHotkey', 'Hide')
])
SetTimer (*) => options.Hide(), -3000
SetTimer (*) => StatusOverlay.ToggleAll(), -3000

BindingScript()
GetScriptStatus() {
  return overlay.isScriptEnabled
}
GetOption(option, *) {
  return options.Checkbox[option].Value
}
scriptPath := 'D:\Documents\AutoHotkey\src\v2\Macros.ahk'
SplitPath(scriptPath, &scriptName, &scriptDir)
A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert('&Suspend Hotkeys', 'Recompile Script', (*) => (
  Run('cmd /c ""D:\Documents\AutoHotkey\bin\build\ahk2exe-compile.bat" "' scriptPath '" && pause"'),
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
A_TrayMenu.Insert('E&xit', 'hotkeys.json', (*) => Run(
  'pwsh -command "code -n . && code -g D:\Documents\AutoHotkey\configs\hotkeys.json:70:103',
  'D:\Documents\AutoHotkey', 'Hide'))
A_TrayMenu.SetIcon('hotkeys.json', 'D:\Documents\AutoHotkey\assets\icon\keyboard.ico')
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Show/Hide', (*) => options.Toggle())
A_TrayMenu.Default := 'Show/Hide'
A_TrayMenu.ClickCount := 1