Array.Prototype.DefineProp("Slice", { call: Slice })
Slice(this, start := 1, end := "") {
    out := []
    if (end = "")
        end := this.Length
    if (start < 0)
        start := this.Length + start + 1
    if (end < 0)
        end := this.Length + end + 1
    loop end - start + 1
        out.Push(this[start + A_Index - 1])
    return out
}

class UserFunc {
    ; --- Universal Call ---
    static uCall(callable, args*) {
        if callable is Func || callable is BoundFunc
            return callable.Call(args*)
        if callable is String {
            if RegExMatch(callable, "^(?<obj>\w+)\.(?<meth>\w+)$", &m) && IsSet(%m.obj%)
                return %m.obj%.%m.meth%(args*)
            if RegExMatch(callable, "^\(\*\)\s*=>\s*(?<fn>\w+)$", &m)
                return %m.fn%(args*)
            if %callable% is Func
                return %callable%(args*)
        }
        throw Error("uCall: cannot resolve → " callable)
    }
    ; --- IfCall ---
    static uCallIf(condition, trueDo := "", falseDo := "", args*) {
        result := UserFunc.uCall(condition, args*)
        if result && trueDo {
            args2 := (trueDo.Length = 1) ? [] : (trueDo[2] is Array ? trueDo[2] : trueDo.Slice(2))
            return UserFunc.uCall(trueDo[1], args2*)
        }
        else if !result && falseDo {
            args2 := (falseDo.Length = 1) ? [] : (falseDo[2] is Array ? falseDo[2] : falseDo.Slice(2))
            return UserFunc.uCall(falseDo[1], args2*)
        }
    }
    ; --- Multi-call with modes ---
    ; mode: "first" | "last" | "map" | "or" | "and" | "concat" | "chain"
    static uCalls(mode, calls*) {
        results := []
        switch mode {
            case "chain":
                acc := ""
                for idx, fn in calls {
                    args2 := (fn.Length = 1) ? [] : (fn[2] is Array ? fn[2] : fn.Slice(2))
                    acc := (idx = 1) ? UserFunc.uCall(fn[1], args2*) : UserFunc.uCall(fn[1], acc, args2*)
                }
                return acc
            default:
                for fn in calls {
                    args2 := (fn.Length = 1) ? [] : (fn[2] is Array ? fn[2] : fn.Slice(2))
                    results.Push(UserFunc.uCall(fn[1], args2*))
                }
                switch mode {
                    case "first": return results[1]
                    case "last": return results[-1]
                    case "map": return results
                    case "or": for r in results
                        if r
                            return true
                        return false
                    case "and": for r in results
                        if !r
                            return false
                        return true
                    case "concat": out := ""
                        for r in results
                            out .= r
                        return out
                    default: throw Error("UserFunc.uCalls: unknown mode → " mode)
                }
        }
    }
    static uRun(calls*) {
        for fn in calls {
            args2 := (fn.Length = 1) ? [] : (fn[2] is Array ? fn[2] : fn.Slice(2))
            UserFunc.uCall(fn[1], args2*)
        }
    }
}
RunIfNotExist(exePathOrShellCmd, exeName, isUWP := false) {
    if !WinExist("ahk_exe " exeName) {
        Run(isUWP ? "explorer shell:AppsFolder\" exePathOrShellCmd : exePathOrShellCmd)
        if !WinWait("ahk_exe " exeName, , 7) {
            TrayTip("❌ Không thể khởi động hoặc tìm thấy cửa sổ: " exeName)
            return false
        }
    }
    return true
}
global cycleIdx := Map()
CycleAndSend(idx, sends) {
    global cycleIdx
    if !cycleIdx.Has(idx)
        cycleIdx[idx] := 1
    else {
        cycleIdx[idx]++
        if (cycleIdx[idx] > sends.Length)
            cycleIdx[idx] := 1
    }
    current := sends[cycleIdx[idx]]
    try {
        Send current
    } catch as Err {
        TrayTip "❌ Error sending: " current "`n" Type(Err) ": " Err.Message, A_ScriptFullPath
        FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
        "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
    }
    SetTimer(ToolTip, -1000)
}
CycleAndExecute(idx, funcsAndArgs) {
    global cycleIdx
    if !cycleIdx.Has(idx)
        cycleIdx[idx] := 1
    else {
        cycleIdx[idx]++
        if (cycleIdx[idx] > funcsAndArgs.Length)
            cycleIdx[idx] := 1
    }
    current := funcsAndArgs[cycleIdx[idx]]
    func := current[1]
    args := current.Length > 1 ? current[2] : []
    try {
        if (Type(func) = "String") {
            fn := %func%
            fn(args*)
        } else {
            func(args*)
        }
    } catch as Err {
        TrayTip "❌ Error calling function: " Type(func) "`n" Type(Err) ": " Err.Message, A_ScriptFullPath
        FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
        "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
    }
    SetTimer(ToolTip, -1000)
}
DynamicSet(varName, value) {
    global
    %varName% := value
}
ClickAndSleep(x, y, clickDelay := 200, moveAfterClick := false, clickInit := false) {
    MouseGetPos(&xp, &yp)
    Click(x, y)
    Sleep(clickDelay)
    if (moveAfterClick) {
        if (clickInit)
            Click(xp, yp)
        else
            MouseMove(xp, yp, 0)
    }
}
GetWindowStatus(Status := 1, WinTitle := '', WinText := '', NoWinTitle := '', NoWinText := '', *) {
    if (Status)
        return WinActive(WinTitle, WinText, NoWinTitle, NoWinText)
    return !WinActive(WinTitle, WinText, NoWinTitle, NoWinText)
}
WinGetPosEx(hWindow, &X := "", &Y := "", &Width := "", &Height := "", &Offset_X := "", &Offset_Y := "") {
    static S_OK := 0x0
        , DWMWA_EXTENDED_FRAME_BOUNDS := 9
    RECTPlus := Buffer(24, 0)
    DWMRC := DllCall("dwmapi\DwmGetWindowAttribute"
        , "Ptr", hWindow
        , "UInt", DWMWA_EXTENDED_FRAME_BOUNDS
        , "Ptr", RECTPlus
        , "UInt", 16
        , "UInt")
    if (DWMRC != S_OK) {
        if (DWMRC = -3 || DWMRC = -4) {
            RECT := Buffer(16, 0)
            DllCall("GetWindowRgnBox", "Ptr", hWindow, "Ptr", RECT)
            DllCall("GetWindowRect", "Ptr", hWindow, "Ptr", RECTPlus)
        }
        else {
            OutputDebug "
        ( LTrim Join`s
            Function: " A_ThisFunc " -
            Unknown error calling the 'dwmapi\DwmGetWindowAttribute'
            function. RC=" DWMRC ",
            A_LastError=" A_LastError "
        )"
            return false
        }
    }
    X := NumGet(RECTPlus, 0, "Int")
    Y := NumGet(RECTPlus, 4, "Int")
    Right := NumGet(RECTPlus, 8, "Int")
    Bottom := NumGet(RECTPlus, 12, "Int")
    Width := Right - X
    Height := Bottom - Y
    if (DWMRC != S_OK) {
        Offset_X := NumGet(RECT, 0, "Int")
        Offset_Y := NumGet(RECT, 4, "Int")
        NumPut("Int", Offset_X, RECTPlus, 16)
        NumPut("Int", Offset_Y, RECTPlus, 20)
        return RECTPlus
    }
    RECT := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", hWindow, "Ptr", RECT)
    GWR_Width := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
    GWR_Height := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
    Offset_X := (Width - GWR_Width) // 2
    Offset_Y := (Height - GWR_Height) // 2
    NumPut("Int", Offset_X, RECTPlus, 16)
    NumPut("Int", Offset_Y, RECTPlus, 20)
    return RECTPlus
}
MoveWindow(WinTittle := "A") {
    DetectHiddenWindows 1
    old_coordmode := A_CoordModeMouse
    CoordMode 'mouse', 'screen'
    if !(winID := WinActive(WinTittle)) || SysGet(80) <= 1 {
        return
    }
    WinGetPosEx(winID, &X, &Y, &W, &H, &offx, &offy)
    ; MsgBox(X ' ' Y ' ' W ' ' H '`n' offx ' ' offy)
    MonitorGet(1, &l, &t, &r, &b)
    if (X < A_ScreenWidth) {
        SoundBeep
        X += l + offx
        Y += t + offy
    } else {
        X -= l - offx
        Y -= t - offy
    }
    ; MsgBox(X ' ' Y ' ' W ' ' H)
    WinMove(X, Y, W, H, "ahk_id " winID)
    DetectHiddenWindows 0
    CoordMode 'mouse', old_coordmode
}
