#Include <ui\StatusOverlay>
#Include <core\Core>
#Include <core\UserFuncs>

SetWinDelay 2
CoordMode "Mouse"
global moveDistance := 5, mouseSpeed := 0, isMovingByKey := false
moveOverlay := StatusOverlay('SpeedMove Overlay', Format('bg1{} tx1{} bg2{} tx2{} x{}', "FF5722", "ffffff",   ; trạng thái >>
    "4A90E2", "ffffff",   ; trạng thái >
    44,), 'p{OnIcon}>>', 'p{OffIcon}>')

moveOverlay.statusTextControl.OnEvent("Click", (*) => UserFuncs.uCallIf("moveOverlay.ToggleScript", [
    "DynamicSet",
    "moveDistance",
    15
], [
    "DynamicSet",
    "moveDistance",
    5
]))

CopyMousePos() {
    old_coord_mode := A_CoordModeMouse
    CoordMode('Mouse', 'Client')
    MouseGetPos(&x, &y)
    A_Clipboard := Format("{}, {}", x, y)
    Notify(A_Clipboard, "Copy to Clipboard", "+ t5 ci")
    CoordMode('Mouse', old_coord_mode)
}

MoveMouseByPixels(upKey, downKey, leftKey, rightKey, modifierKey, freq := 25) {
    global moveDistance, mouseSpeed
    if !isMovingByKey {
        SetTimer(MoveMouseByPixels_Internal, freq)
        MoveMouseByPixels_Internal()
    }
    MoveMouseByPixels_Internal() {
        global isMovingByKey, moveDistance, mouseSpeed
        if modifierKey = "" || GetKeyState(modifierKey, "P") {
            if isMovingByKey := (x := moveDistance * (GetKeyState(rightKey, "P") - GetKeyState(leftKey, "P"))) | (y :=
                moveDistance * (GetKeyState(downKey, "P") - GetKeyState(upKey, "P"))) {
                MouseMove x, y, mouseSpeed, "R"
            }
            else {
                try SetTimer , 0
            }
        }
        else {
            isMovingByKey := false
            try SetTimer , 0
        }
    }
}

#HotIf ((GetWindowStatus(0, "Task Switching")) && (GetWindowStatus(0, "ahk_exe idea64.exe")) && (GetWindowStatus(0,
    "ahk_exe pycharm64.exe")) && (GetWindowStatus(0, "ahk_exe datagrip64.exe")) && (GetWindowStatus(0,
        "ahk_exe Code.exe")))
!LButton::
{
    MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
    if WinGetMinMax(KDE_id)
        return
    WinGetPos &KDE_WinX1, &KDE_WinY1, , , KDE_id
    loop {
        if !GetKeyState("LButton", "P")
            break
        MouseGetPos &KDE_X2, &KDE_Y2
        KDE_X2 -= KDE_X1
        KDE_Y2 -= KDE_Y1
        KDE_WinX2 := (KDE_WinX1 + KDE_X2)
        KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
        WinMove KDE_WinX2, KDE_WinY2, , , KDE_id
    }
}
#HotIf

MouseJump() {
    monCount := MonitorGetCount()
    if (monCount < 2)
        return
    oldCoordMode := A_CoordModeMouse
    CoordMode "Mouse", "Screen"
    MouseGetPos(&x, &y)
    curMon := 0
    loop monCount {
        if MonitorGet(A_Index, &L, &T, &R, &B) {
            if (x >= L && x < R && y >= T && y < B) {
                curMon := A_Index
                monSrc := { L: L, T: T, R: R, B: B }
                break
            }
        }
    }
    if (curMon = 0) {
        CoordMode "Mouse", oldCoordMode
        return
    }
    targetMon := (curMon = 1) ? 2 : 1
    if !MonitorGet(targetMon, &L, &T, &R, &B) {
        CoordMode "Mouse", oldCoordMode
        return
    }
    monDst := { L: L, T: T, R: R, B: B }
    scale := 1
    newX := monDst.L + (x - monSrc.L) * scale
    newY := monDst.T + (y - monSrc.T) * scale
    MouseMove newX, newY
    SendInput("{RCtrl}")
    Sleep 500
    SendInput("{RCtrl}")
    CoordMode "Mouse", oldCoordMode
}
