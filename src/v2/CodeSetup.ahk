#Include <core\KeyBinding>
SetTitleMatchMode(2)
;@Ahk2Exe-SetMainIcon desktop.ico
class WindowManager {
    static screenW := A_ScreenWidth
    static screenH := A_ScreenHeight
    static defaultRatio := 3
    static defaultSubRatio := 2
    static defaultLayout := 4
    static guiID := ['', '']
    static myGui := [,]
    static StartEssentialApps() {
        WindowManager.RunIfNotExist("C:\Program Files\Google\Chrome\Application\chrome.exe", "chrome.exe")
        WindowManager.RunIfNotExist("Microsoft.Whiteboard_8wekyb3d8bbwe!Whiteboard", "MicrosoftWhiteboard.exe", true)
    }
    static RunIfNotExist(exePathOrShellCmd, exeName, isUWP := false) {
        if !WinExist("ahk_exe " . exeName) {
            if (isUWP)
                Run("explorer shell:AppsFolder\" . exePathOrShellCmd)
            else
                Run(exePathOrShellCmd)
            WinWait("ahk_exe " . exeName, , 7)
        }
    }
    static MoveAndTileWindow(exeName, x, y, w, h) {
        if WinExist("ahk_exe " . exeName) {
            WinActivate("ahk_exe " . exeName)
            WinWaitActive("ahk_exe " . exeName, , 2)
            WinRestore("ahk_exe " . exeName)
            WinMove(x, y, w, h, "ahk_exe " . exeName)
        }
    }
    static ClearWhiteboard() {
        MouseMove(0, 0, 0)
        MouseGetPos(&mouseX, &mouseY)
        WinActivate("Microsoft Whiteboard")
        WinWaitActive("Microsoft Whiteboard")
        WinGetPos(&winX, &winY, &winW, &winH, "Microsoft Whiteboard")
        WindowManager.screenW := A_ScreenWidth
        WindowManager.screenH := A_ScreenHeight

        if (winX >= 1600) {
            winX := (winX - 1600) * 1.25
            winY := (winY + 301) * 1.25
            winW := winW * 1.25
            winH := winH * 1.25
            WindowManager.screenW := WindowManager.screenW * 1.25
            WindowManager.screenH := WindowManager.screenH * 1.25
        }
        centerX := winW // 2 - mouseX
        centerY := winH // 2
        MouseMove(centerX, centerY, 0)
        Sleep(100)
        Click("Right")
        Sleep(200)
        Send("{Down 3}")
        Sleep(100)
        Send("{Enter}")
        Sleep(300)
        Send("{Tab}")
        Sleep(100)
        Send("{Enter}")
        Sleep(300)
        if (winX == 0) {
            if (winW <= WindowManager.screenW * 0.52) {
                zoomX := winW - 40
                zoomY := winH - 150
            } else {
                zoomX := winW - 150
                zoomY := winH - 40
            }
        } else {
            if (winW <= WindowManager.screenW * 0.52) {
                zoomX := winW - 40 - mouseX
                zoomY := winH - 150
            } else {
                zoomX := winW - 150
                zoomY := winH - 40
            }
        }
        MouseMove(zoomX, zoomY, 0)
        Sleep(150)
        Click()
        Sleep(150)
        Send("{Down 2}")
        Sleep(100)
        Send("{Enter}")
        Sleep(200)
        Send("!w1")
        MouseMove(centerX, centerY, 0)
    }
    static Layout1(*) {
        half := WindowManager.screenW // 2
        WindowManager.MoveAndTileWindow("Code.exe", 0, 0, half, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("chrome.exe", half, 0, half, WindowManager.screenH)
    }

    static Layout1Alt(*) {
        oneThird := WindowManager.screenW // 3
        twoThird := WindowManager.screenW - oneThird
        WindowManager.MoveAndTileWindow("Code.exe", 0, 0, twoThird, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("chrome.exe", twoThird, 0, oneThird, WindowManager.screenH)
    }

    static Layout2(*) {
        half := WindowManager.screenW // 2
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, half, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("chrome.exe", half, 0, half, WindowManager.screenH)
    }

    static Layout2Alt(*) {
        oneThird := WindowManager.screenW // 3
        twoThird := WindowManager.screenW - oneThird
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, twoThird, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("chrome.exe", twoThird, 0, oneThird, WindowManager.screenH)
    }

    static Layout3(*) {
        half := WindowManager.screenW // 2
        WindowManager.MoveAndTileWindow("Code.exe", half, 0, half, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, half, WindowManager.screenH)
    }

    static Layout3Alt(*) {
        half := WindowManager.screenW // 2
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", half, 0, half, WindowManager.screenH)
        WindowManager.MoveAndTileWindow("Code.exe", 0, 0, half, WindowManager.screenH)
    }

    static Layout4(*) {
        w := WindowManager.screenW // 2
        h := WindowManager.screenH // 2
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, w, 2 * h)
        WindowManager.MoveAndTileWindow("Code.exe", w, 0, w, h)
        WindowManager.MoveAndTileWindow("chrome.exe", w, h, w, h)
    }

    static Layout4Alt(*) {
        w := WindowManager.screenW // 2
        h := WindowManager.screenH // 2
        WindowManager.MoveAndTileWindow("Code.exe", 0, 0, w, 2 * h)
        WindowManager.MoveAndTileWindow("MicrosoftWhiteboard.exe", w, 0, w, h)
        WindowManager.MoveAndTileWindow("chrome.exe", w, h, w, h)
    }

    static ResetDefault(*) {
        WindowManager.defaultRatio := 3
        WindowManager.defaultSubRatio := 2
        WindowManager.defaultLayout := 4
        MsgBox("Các cài đặt đã được khôi phục về mặc định!")
    }
    static ShowLayoutGUI1() {
        if (WindowManager.guiID[1] && WinExist("⚙️ Window Layout Manager ahk_id " WindowManager.guiID[1]))
            return
        myGui := Gui(, "⚙️ Window Layout Manager")
        WindowManager.guiID[1] := myGui.Hwnd
        myGui.Opt("+AlwaysOnTop +Resize")
        myGui.SetFont("s10", "Segoe UI")
        myGui.Add("Text", , "🖥️ Chọn Layout hiển thị cửa sổ:")
        myGui.Add("Button", "w220 h30", "Layout 1: VSCode + Chrome").OnEvent("Click", WindowManager.Layout1)
        myGui.Add("Button", "w220 h30", "Layout 2: Whiteboard + Chrome").OnEvent("Click", WindowManager.Layout2)

        myGui.Add("Button", "w220 h30", "Layout 3: Whiteboard + VSCode").OnEvent("Click", WindowManager.Layout3)

        myGui.Add("Button", "w220 h30", "Layout 4: 3 Windows").OnEvent("Click", WindowManager.Layout4)
        myGui.Add("Text", , "⚙️ Tùy chọn:")
        myGui.Add("Button", "w220 h30", "Khôi phục mặc định").OnEvent("Click", WindowManager.ResetDefault)
        myGui.OnEvent("Close", (*) => myGui.Hide())
        myGui.OnEvent("Escape", (*) => myGui.Hide())
        myGui.Show("w240")
    }

    static ShowLayoutGUI2() {
        if (WindowManager.guiID[2] && WinExist("Layout Manager ahk_id " WindowManager.guiID[2]))
            return
        myGui := Gui(, "Layout Manager")
        WindowManager.guiID[2] := myGui.Hwnd
        myGui.Opt("+Resize +SysMenu +MinimizeBox +MaximizeBox +AlwaysOnTop")
        myGui.SetFont("s10", "Segoe UI")

        btnHeight := 30
        gapBetweenPair := 6
        gapBetweenRows := 18
        startX := 12
        startY := 12
        pairWidth := 80
        colGap := 10

        rightBtnX := startX + pairWidth + colGap
        btn1 := myGui.Add("Button", "x" . startX . " y" . startY . " w" . pairWidth . " h" . btnHeight,
            "Layout 1")
        btn1.OnEvent("Click", WindowManager.Layout1)
        btn1Alt := myGui.Add("Button", "x" . rightBtnX . " y" . startY . " w" . pairWidth . " h" . btnHeight,
            "Layout 1'")
        btn1Alt.OnEvent("Click", WindowManager.Layout1Alt)
        y2 := startY + btnHeight + gapBetweenRows
        btn2 := myGui.Add("Button", "x" . startX . " y" . y2 . " w" . pairWidth . " h" . btnHeight, "Layout 2")
        btn2.OnEvent("Click", WindowManager.Layout2)
        btn2Alt := myGui.Add("Button", "x" . rightBtnX . " y" . y2 . " w" . pairWidth . " h" . btnHeight,
            "Layout 2'")
        btn2Alt.OnEvent("Click", WindowManager.Layout2Alt)
        y3 := y2 + btnHeight + gapBetweenRows
        btn3 := myGui.Add("Button", "x" . startX . " y" . y3 . " w" . pairWidth . " h" . btnHeight, "Layout 3")
        btn3.OnEvent("Click", WindowManager.Layout3)
        btn3Alt := myGui.Add("Button", "x" . rightBtnX . " y" . y3 . " w" . pairWidth . " h" . btnHeight,
            "Layout 3'")
        btn3Alt.OnEvent("Click", WindowManager.Layout3Alt)
        y4 := y3 + btnHeight + gapBetweenRows
        btn4 := myGui.Add("Button", "x" . startX . " y" . y4 . " w" . pairWidth . " h" . btnHeight, "Layout 4")
        btn4.OnEvent("Click", WindowManager.Layout4)
        btn4Alt := myGui.Add("Button", "x" . rightBtnX . " y" . y4 . " w" . pairWidth . " h" . btnHeight,
            "Layout 4'")
        btn4Alt.OnEvent("Click", WindowManager.Layout4Alt)
        yCheck := y4 + btnHeight + gapBetweenRows + 6
        scriptToggle := myGui.Add("CheckBox", "x" . startX . " y" . yCheck . " vScriptEnabled Checked" . (
            A_IsSuspended ? "0" : "1"), "Bật script")
        scriptToggle.OnEvent("Click", (*) => WindowManager.ToggleScript(scriptToggle.value))
        resetButton := myGui.Add("Button", "x" . rightBtnX . " y" . yCheck . " w" . pairWidth . " h" . btnHeight,
            "Khôi phục")
        resetButton.OnEvent("Click", WindowManager.ResetDefault)

        myGui.OnEvent("Close", (*) => myGui.Hide())
        myGui.OnEvent("Escape", (*) => myGui.Hide())
        myGui.Show("AutoSize")
    }
    static ToggleScript(ctrl, *) {
        if (ctrl) {
            Suspend(0)
        } else {
            Suspend(1)
        }
    }
    static Toggle(which) {
        if (!WindowManager.guiID[which]) {
            if (which = 1)
                WindowManager.ShowLayoutGUI1
            else if (which = 2)
                WindowManager.ShowLayoutGUI2
            return
        }
        if (WindowManager.guiID[which] && !WinExist('ahk_id ' WindowManager.guiID[which])) {
            WinShow('ahk_id ' WindowManager.guiID[which])
        }
        else
            WinHide('ahk_id ' WindowManager.guiID[which])
    }
}
WindowManager.StartEssentialApps()
BindingScript()
scriptPath := 'D:\Documents\AutoHotkey\src\v2\CodeSetup.ahk'
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
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Open File Location', (*) => Run('*open ' scriptDir))
A_TrayMenu.SetIcon('Open File Location', 'shell32.dll', 4)
A_TrayMenu.Insert('E&xit', 'Show Hotkeys', (*) => ShowHotkeys())
A_TrayMenu.SetIcon('Show Hotkeys', 'shell32.dll', 24)
A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', 'Show/Hide #1', (*) => WindowManager.Toggle(1))
A_TrayMenu.Insert('E&xit', 'Show/Hide #2', (*) => WindowManager.Toggle(2))
A_TrayMenu.Default := 'Show/Hide #2'
A_TrayMenu.ClickCount := 1