#Include <Log>
#Include <HelpGui>
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetMainIcon C:\Users\jackb\Documents\AutoHotkey\icon\settings.ico
;@Ahk2Exe-exePath C:\Users\jackb\Documents\AutoHotkey

global isSelecting := false
global startX := 0, startY := 0

; CTRL + ALT + R → Ghi tọa độ chuột hiện tại
^!r:: 
{
    global globalLogFile
    MouseGetPos &x, &y, &hwnd
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    
    ; Lấy tiêu đề cửa sổ từ hwnd
    title := WinGetTitle("ahk_id " hwnd)
    
    ; Lấy vị trí và kích thước cửa sổ
    winX := 0
    winY := 0
    width := 0
    height := 0
    WinGetPos(&winX, &winY, &width, &height, "ahk_id " hwnd)
    exePath := ProcessGetPath(WinGetPID("ahk_id " hwnd))
    ; Ghi vào file log
    FileAppend "[Điểm] " timestamp "`n"
        . "Cửa sổ: " title "`n"
        . "Đường dẫn tiến trình: " exePath "`n"
        . "Cửa sổ vị trí: X=" winX ", Y=" winY ", W=" width ", H=" height "`n"
        . "*Mouse: " x ":" y "`n`n", globalLogFile
    
    TrayTip "Vị trí đã lưu", 
        "Chuột: X=" x ", Y=" y "`n"
        . "Cửa sổ: " title "`n"
        . "Cửa sổ vị trí: X=" winX ", Y=" winY ", W=" width ", H=" height
        . "Đường dẫn: " exePath,
        3000
}

; ALT + R → Ghi vùng quét (bắt đầu và kết thúc)
!r::  
{
	global startX, startY, isSelecting
    if (!isSelecting) {
        MouseGetPos &startX, &startY
        ToolTip "Bắt đầu vùng quét"
        SetTimer () => ToolTip(), -1500
        isSelecting := true
    } else {
        MouseGetPos &endX, &endY
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        
        ; Tính lại điểm góc để đảm bảo vùng đúng chiều
        x1 := Min(startX, endX)
        y1 := Min(startY, endY)
        x2 := Max(startX, endX)
        y2 := Min(startY, endY)
        x3 := Min(startX, endX)
        y3 := Max(startY, endY)
        x4 := Max(startX, endX)
        y4 := Max(startY, endY)
        xa := (x1+x4)//2
        ya := (y1+y4)//2
        FileAppend "[Vùng] " timestamp "`n", globalLogFile
        FileAppend "" x1 ":" y1 "`t" x2 ":" y2 "`n" x3 ":" y3 "`t" x4 ":" y4 "`n" xa ":" ya "`n`n", globalLogFile

        TrayTip "Vùng đã lưu", "Từ (" x1 "," y1 ") đến (" x4 "," y4 ")`nTrọng tâm: " xa ":" ya
        isSelecting := false
    }
}

MouseMarcoRecorder_InitTrayMenu()
MouseMarcoRecorder_ShowHelpUI(5)

MouseMarcoRecorder_InitTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Help", (*) => MouseMarcoRecorder_ShowHelpUI())
    A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload Script", (*) => Reload())
    A_TrayMenu.Add("Edit Script", (*) => Edit())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
    A_TrayMenu.Add("Pause Script", (*) => TogglePause())
    A_TrayMenu.Add("Exit", (*) => ExitApp())

    A_TrayMenu.Default := "Help"
    A_TrayMenu.ClickCount = 1
}

MouseMarcoRecorder_ShowHelpUI(hideTimer := 0) {
    sections := [
        {
            title: "📜 Ghi Tọa Độ Chuột",
            lines: [
                "Ctrl + Alt + R → Ghi tọa độ chuột hiện tại.",
                "Lưu vị trí chuột và thông tin cửa sổ tại thời điểm nhấn phím.",
                "Dữ liệu được lưu vào file log và hiển thị trên tray."
            ]
        },
        {
            title: "📐 Ghi Vùng Quét",
            lines: [
                "Alt + R → Bắt đầu và kết thúc vùng quét.",
                "Lưu lại vị trí của vùng quét và trọng tâm của vùng.",
                "Dữ liệu được lưu vào file log và hiển thị trên tray."
            ]
        },
        {
            title: "⚙️ Các Phím Tắt",
            lines: [
                "Các phím tắt có thể được sử dụng để ghi tọa độ chuột và vùng quét."
            ]
        }
    ]
    
    ShowHelp("📚 Hướng Dẫn Sử Dụng Script", sections, hideTimer)
}
