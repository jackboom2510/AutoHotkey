#Include <ui\StatusOverlay>
#Include <core\UserFuncs>
SetWinDelay 2
CoordMode "Mouse"
global moveDistance := 5, mouseSpeed := 0, isMovingByKey := false
moveOverlay := StatusOverlay(
    'SpeedMove Overlay',
    Format('bg1{} tx1{} bg2{} tx2{} y{}',
        "FF5722", "ffffff",   ; trạng thái >>
        "4A90E2", "ffffff",   ; trạng thái >
        42
    ),
    'p{OnIcon}>>', 'p{OffIcon}>'
)

MoveMouseByPixels(upKey, downKey, leftKey, rightKey, modifierKey, freq := 25) {
    global moveDistance, mouseSpeed
    if !isMovingByKey {
        SetTimer(MoveMouseByPixels_Internal, freq)
        MoveMouseByPixels_Internal()
    }
    MoveMouseByPixels_Internal() {
        global isMovingByKey, moveDistance, mouseSpeed
        if modifierKey = "" || GetKeyState(modifierKey, "P") {
            if isMovingByKey := (x := moveDistance * (GetKeyState(rightKey, "P") - GetKeyState(leftKey, "P")))
            | (y := moveDistance * (GetKeyState(downKey, "P") - GetKeyState(upKey, "P"))) {
                MouseMove x, y, mouseSpeed, "R"
            } else {
                try SetTimer , 0
            }
        } else {
            isMovingByKey := false
            try SetTimer , 0
        }
    }
}

#HotIf (GetWindowStatus(0, ("Task Switching")))
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