#Include <core\Core>

class UserFuncsOriginal {
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
        result := UserFuncs.uCall(condition, args*)
        if result && trueDo {
            args2 := (trueDo.Length = 1) ? [] : (trueDo[2] is Array ? trueDo[2] : trueDo.Slice(2))
            return UserFuncs.uCall(trueDo[1], args2*)
        }
        else if !result && falseDo {
            args2 := (falseDo.Length = 1) ? [] : (falseDo[2] is Array ? falseDo[2] : falseDo.Slice(2))
            return UserFuncs.uCall(falseDo[1], args2*)
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
                    acc := (idx = 1) ? UserFuncs.uCall(fn[1], args2*) : UserFuncs.uCall(fn[1], acc, args2*)
                }
                return acc
            default:
                for fn in calls {
                    args2 := (fn.Length = 1) ? [] : (fn[2] is Array ? fn[2] : fn.Slice(2))
                    results.Push(UserFuncs.uCall(fn[1], args2*))
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
                    default: throw Error("UserFuncs.uCalls: unknown mode → " mode)
                }
        }
    }
    static uRun(calls*) {
        for fn in calls {
            args2 := (fn.Length = 1) ? [] : (fn[2] is Array ? fn[2] : fn.Slice(2))
            UserFuncs.uCall(fn[1], args2*)
        }
    }
}

class UserFuncs {
    ; ========================================================================
    ; SETTINGS
    ; ========================================================================
    static notifyTime := 3000     ; traytip duration (ms)
    static showStack := true    ; include stack trace in traytip?

    ; ========================================================================
    ; Universal function caller with safe exception handling
    ; ========================================================================
    static uCall(callable, args*) {
        try {
            if (callable is Func || callable is BoundFunc)
                return callable.Call(args*)

            if (callable is Object && HasMethod(callable, "Call"))
                return callable.Call(args*)

            if (callable is String) {
                ; --- Case 1: "Obj.Method"
                if RegExMatch(callable, "^(?<obj>\w+)\.(?<meth>\w+)$", &m) {
                    if IsSet(%m.obj%) {
                        obj := %m.obj%
                        if HasMethod(obj, m.meth)
                            return obj.%m.meth%(args*)
                    }
                }

                ; --- Case 2: "(() => fnName)" or "=> fnName"
                if RegExMatch(callable, "^\(\*\)\s*=>\s*(?<fn>\w+)$", &m)
                    return UserFuncs.uCall(m.fn, args*)

                ; --- Case 3: direct function name
                if IsSet(%callable%) && %callable% is Func
                    return %callable%(args*)
            }

            throw Error("Cannot resolve callable → " callable)
        }
        catch as err {
            UserFuncs.__notifyError("uCall", err, callable)
            return ""
        }
    }

    ; ========================================================================
    ; Conditional call with built-in error handling
    ; ========================================================================
    static uCallIf(condition, trueDo := "", falseDo := "", args*) {
        try {
            result := UserFuncs.uCall(condition, args*)

            if result && trueDo
                return UserFuncs.__callWithArgs(trueDo)
            else if !result && falseDo
                return UserFuncs.__callWithArgs(falseDo)
        }
        catch as err {
            UserFuncs.__notifyError("uCallIf", err, condition)
        }
    }

    ; ========================================================================
    ; Multi-call with modes: "first" | "last" | "map" | "or" | "and" | "concat" | "chain"
    ; ========================================================================
    static uCalls(mode, calls*) {
        mode := StrLower(mode)
        results := []

        try {
            if (mode = "chain") {
                acc := ""
                for idx, fn in calls {
                    args2 := UserFuncs.__extractArgs(fn)
                    acc := (idx = 1)
                        ? UserFuncs.uCall(fn[1], args2*)
                        : UserFuncs.uCall(fn[1], acc, args2*)
                }
                return acc
            }

            for fn in calls
                results.Push(UserFuncs.uCall(fn[1], UserFuncs.__extractArgs(fn)*))

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
                default: throw Error("Unknown mode → " mode)
            }
        }
        catch as err {
            UserFuncs.__notifyError("uCalls", err, mode)
        }
    }

    ; ========================================================================
    ; Sequential execution (ignore return values)
    ; ========================================================================
    static uRun(calls*) {
        try {
            for fn in calls
                UserFuncs.uCall(fn[1], UserFuncs.__extractArgs(fn)*)
        }
        catch as err {
            UserFuncs.__notifyError("uRun", err)
        }
    }

    ; ========================================================================
    ; --- Helpers ---
    ; ========================================================================
    static __extractArgs(fn) {
        if (fn.Length < 2)
            return []
        return (fn[2] is Array) ? fn[2] : fn.Slice(2)
    }

    static __callWithArgs(spec) {
        if !(spec is Array)
            return UserFuncs.uCall(spec)
        args := UserFuncs.__extractArgs(spec)
        return UserFuncs.uCall(spec[1], args*)
    }

    ; ========================================================================
    ; --- Error handler with safe stack access ---
    ; ========================================================================
    static __notifyError(src, err, context := "") {
        msg := "⚠️ UserFuncs." src " error:`n" err.Message
        if context
            msg .= "`nContext: " context

        ; Safe stack retrieval (AHK v2.0.18 compatible)
        stackInfo := ""
        try stackInfo := err.Stack
        catch
            stackInfo := ""

        if (UserFuncs.showStack && stackInfo != "")
            msg .= "`n`nStack:`n" stackInfo

        Notify(msg, "UserFuncs Error", "+ t0 cwarn")
        OutputDebug "UserFuncs error in " src ": " err.Message "`n"
    }
}

RunIfNotExist(exePathOrShellCmd, exeName?, isUWP := false) {
    if (isUWP)
        searchParam := exeName
    else
        searchParam := "ahk_exe " exeName
    if (!WinExist(searchParam)) {
        Run(isUWP ? "explorer shell:AppsFolder\" exePathOrShellCmd : exePathOrShellCmd)
        if (!WinWait(searchParam, , 7)) {
            Notify("❌ Không thể khởi động hoặc tìm thấy cửa sổ: " exeName, "Error", "+ t3 ce")
            return false
        }
    }
    else
        WinActivate(searchParam)
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
        "D:\Documents\AutoHotkey\configs\error_log.txt"
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
        "D:\Documents\AutoHotkey\configs\error_log.txt"
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

MoveWindow_2(WinTitle := "A") {
    DetectHiddenWindows true

    if !(winID := WinExist(WinTitle)) || SysGet(80) <= 1
        return

    WinGetTitle(&title, "ahk_id " winID)

    initialWinState := WinGetMinMax("ahk_id " winID)
    if (initialWinState = 1)
        WinRestore("ahk_id " winID)

    ; Vị trí & size hiện tại
    WinGetPos(&X, &Y, &W, &H, "ahk_id " winID)

    ; Monitor hiện tại
    curMon := 1
    MonitorGet(curMon, &ml, &mt, &mr, &mb)
    mw := mr - ml
    mh := mb - mt

    ; Tính scale
    sx := (X - ml) / mw
    sy := (Y - mt) / mh
    sw := W / mw
    sh := H / mh

    ; Monitor đích (kế tiếp)
    totalMon := SysGet(80)
    newMon := (curMon = totalMon) ? 1 : curMon + 1
    MonitorGet(newMon, &nl, &nt, &nr, &nb)
    nmw := nr - nl
    nmh := nb - nt

    newX := nl + Round(sx * nmw)
    newY := nt + Round(sy * nmh)
    newW := Round(sw * nmw)
    newH := Round(sh * nmh)

    ; === MSGBOX THÔNG BÁO ===
    MsgBox(
        "Cửa sổ: " title "`n"
        "Monitor: " curMon "  →  " newMon "`n`n"
        "Tọa độ cũ:`n"
        "X=" X ", Y=" Y ", W=" W ", H=" H "`n`n"
        "Tọa độ mới:`n"
        "X=" newX ", Y=" newY ", W=" newW ", H=" newH,
        "MoveWindowScaled",
        "Iconi"
    )

    WinMove(newX, newY, newW, newH, "ahk_id " winID)

    if (initialWinState = 1)
        WinMaximize("ahk_id " winID)

    DetectHiddenWindows false
}

MoveWindow(WinTitle := "A") {
    DetectHiddenWindows 1
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Screen'
    if !(winID := WinActive(WinTitle)) || SysGet(80) <= 1 {
        return
    }
    initialWinState := WinGetMinMax(WinTitle)
    if initialWinState = 1 {
        WinRestore(WinTitle)
    }
    WinGetPosEx(winID, &X, &Y, &W, &H, &offx, &offy)
    MonitorGet(1, &l, &t, &r, &b)
    if (X < l)
        X += l, Y += t
    else
        X -= l, Y -= t
    WinMove(X, Y, W, H, "ahk_id " winID)
    if initialWinState = 1 {
        WinMaximize(WinTitle)
    }
    DetectHiddenWindows 0
    CoordMode 'mouse', old_coordmode
}
