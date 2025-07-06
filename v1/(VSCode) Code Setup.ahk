#SingleInstance Force
#Persistent
SetTitleMatchMode, 2

; === Biến toàn cục ===
screenW := A_ScreenWidth
screenH := A_ScreenHeight
defaultRatio := 3
defaultSubRatio := 2
defaultLayout := 4

; === Khởi động các ứng dụng chính nếu chưa mở ===
;RunIfNotExist("C:\Users\jackb\AppData\Local\Programs\Microsoft VS Code\Code.exe", "Code.exe")
RunIfNotExist("C:\Program Files\Google\Chrome\Application\chrome.exe", "chrome.exe")
RunIfNotExist("Microsoft.Whiteboard_8wekyb3d8bbwe!Whiteboard", "MicrosoftWhiteboard.exe", true)

; === Hàm khởi chạy app nếu chưa mở ===
RunIfNotExist(exePathOrShellCmd, exeName, isUWP := false) {
	if !WinExist("ahk_exe " . exeName) {
		if (isUWP)
			Run, explorer shell:AppsFolder\%exePathOrShellCmd%
		else
			Run, %exePathOrShellCmd%
		WinWait, ahk_exe %exeName%, , 7
	}
}

; === Hàm di chuyển cửa sổ ===
MoveAndTileWindow(exeName, x, y, w, h) {
	if WinExist("ahk_exe " . exeName) {
		WinActivate
		WinWaitActive, ahk_exe %exeName%, , 2
		WinRestore, ahk_exe %exeName%
		WinMove, ahk_exe %exeName%, , x, y, w, h
	}
}

; ======================== Clear Microsoft Whiteboard ========================
!^c::
	{
		; === BƯỚC 1: Kích hoạt Whiteboard và định vị cửa sổ ===
		mouseMove, 0, 0, 0
		MouseGetPos, mouseX, mouseY
		WinActivate, Microsoft Whiteboard
		WinWaitActive, Microsoft Whiteboard
		WinGetPos, winX, winY, winW, winH, Microsoft Whiteboard
		screenW := A_ScreenWidth
		screenH := A_ScreenHeight
		if (winX >= 1600)
		{
			winX := (winX - 1600) * 1.25
			winY := (winY + 301) * 1.25
			winW := winW * 1.25
			winH := winH * 1.25
			screenW := screenW * 1.25
			screenH := screenH * 1.25
		}
		centerX := winW // 2 - mouseX
		centerY := winH // 2
		MouseMove, centerX, centerY, 0
		Sleep 100

		; === BƯỚC 2: Click phải và chọn Clear canvas ===
		Click right
		Sleep 200
		Send {Down 3}
		Sleep 100
		Send {Enter}
		Sleep 300
		Send {Tab}
		Sleep 100
		Send {Enter}
		Sleep 300

		; === BƯỚC 3: Zoom 200% ===
		if(winX == 0)
		{
			if (winW <= screenW*0.52)
			{
				zoomX := winW - 40
				zoomY := winH - 150
			}
			else
			{
				zoomX := winW - 150
				zoomY := winH - 40
			}
		}
		else
		{
			if (winW <= screenW*0.52)
			{
				zoomX := winW - 40 - mouseX
				zoomY := winH - 150
			}
			else
			{
				zoomX := winW - 150
				zoomY := winH - 40
			}
		}
		MouseMove, zoomX, zoomY, 0
		Sleep 150
		Click
		Sleep 150
		Send {Down 2}
		Sleep 100
		Send {Enter}
		Sleep 200

		; === BƯỚC 4: Chọn công cụ Pen bằng Alt + W + 1 ===
		Send !w1
		MouseMove, centerX, centerY, 0
	}
return

; ========================================
; 📂 Window Layout Manager + GUI + Toggle
; ========================================
^!1::
	{
		half := screenW // 2
		MoveAndTileWindow("Code.exe", 0, 0, half, screenH)
		MoveAndTileWindow("chrome.exe", half, 0, half, screenH)
	}
return

^!+1::
	{
		oneThird := screenW // 3
		twoThird := screenW - oneThird
		MoveAndTileWindow("Code.exe", 0, 0, twoThird, screenH)
		MoveAndTileWindow("chrome.exe", twoThird, 0, oneThird, screenH)
	}
return

^!2::
	{
		half := screenW // 2
		MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, half, screenH)
		MoveAndTileWindow("chrome.exe", half, 0, half, screenH)
	}
return

^!+2::
	{
		oneThird := screenW // 3
		twoThird := screenW - oneThird
		MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, twoThird, screenH)
		MoveAndTileWindow("chrome.exe", twoThird, 0, oneThird, screenH)
	}
return

^!3::
	{
		half := screenW // 2
		MoveAndTileWindow("Code.exe", half, 0, half, screenH)
		MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, half, screenH)
	}
return

^!+3::
	{
		half := screenW // 2
		MoveAndTileWindow("MicrosoftWhiteboard.exe", half, 0, half, screenH)
		MoveAndTileWindow("Code.exe", 0, 0, half, screenH)
	}
return

^!4::
	{
		w := screenW // 2
		h := screenH // 2
		MoveAndTileWindow("MicrosoftWhiteboard.exe", 0, 0, w, 2*h)
		MoveAndTileWindow("Code.exe", w, 0, w, h)
		MoveAndTileWindow("chrome.exe", w, h, w, h)
	}
return

^!+4::
	{
		w := screenW // 2
		h := screenH // 2
		MoveAndTileWindow("Code.exe", 0, 0, w, 2*h)
		MoveAndTileWindow("MicrosoftWhiteboard.exe", w, 0, w, h)
		MoveAndTileWindow("chrome.exe", w, h, w, h)
	}
return

^!0::
	{
		defaultRatio := 3
		defaultSubRatio := 2
		defaultLayout := 4
		MsgBox, Các cài đặt đã được khôi phục về mặc định!
	}
return

; === GUI chọn Layout và bật/tắt script ===
^!g::
	{
		Gui, New
		Gui, +AlwaysOnTop +Resize
		Gui, Font, s10, Segoe UI
		Gui, Add, Text, , 🖥️ Chọn Layout hiển thị cửa sổ:
		Gui, Add, Button, gLayout1 w220 h30, Layout 1: VSCode + Chrome
		Gui, Add, Button, gLayout2 w220 h30, Layout 2: Whiteboard + Chrome
		Gui, Add, Button, gLayout3 w220 h30, Layout 3: Whiteboard + VSCode
		Gui, Add, Button, gLayout4 w220 h30, Layout 4: 3 Windows

		Gui, Add, Text, , ⚙️ Tùy chọn:
		Gui, Add, Button, gResetDefault w220 h30, Khôi phục mặc định

		Gui, Show, , ⚙️ Window Layout Manager
	}
return

^!+g::
	{
		Gui, New, +Resize +SysMenu +MinimizeBox +MaximizeBox +AlwaysOnTop
		Gui, Font, s10, Segoe UI

		btnHeight := 30
		gapBetweenPair := 6    ; khoảng cách giữa 2 nút của 1 cặp layout (ví dụ Layout 1 và Layout 1')
		gapBetweenRows := 18   ; khoảng cách giữa các hàng layout
		startX := 12
		startY := 12

		pairWidth := 80  ; độ rộng 1 nút (tự định, vừa đủ chứa chữ)
		colGap := 10     ; khoảng cách nhỏ giữa 2 cột trong 1 cặp layout

		; Tính toạ độ nút bên phải trong 1 cặp
		rightBtnX := startX + pairWidth + colGap

		; Hàng 1: Layout 1 và Layout 1'
		Gui, Add, Button, x%startX% y%startY% w%pairWidth% h%btnHeight% gLayout1, Layout 1
		Gui, Add, Button, x%rightBtnX% y%startY% w%pairWidth% h%btnHeight% gLayout1Alt, Layout 1'

		; Hàng 2
		y2 := startY + btnHeight + gapBetweenRows
		Gui, Add, Button, x%startX% y%y2% w%pairWidth% h%btnHeight% gLayout2, Layout 2
		Gui, Add, Button, x%rightBtnX% y%y2% w%pairWidth% h%btnHeight% gLayout2Alt, Layout 2'

		; Hàng 3
		y3 := y2 + btnHeight + gapBetweenRows
		Gui, Add, Button, x%startX% y%y3% w%pairWidth% h%btnHeight% gLayout3, Layout 3
		Gui, Add, Button, x%rightBtnX% y%y3% w%pairWidth% h%btnHeight% gLayout3Alt, Layout 3'

		; Hàng 4
		y4 := y3 + btnHeight + gapBetweenRows
		Gui, Add, Button, x%startX% y%y4% w%pairWidth% h%btnHeight% gLayout4, Layout 4
		Gui, Add, Button, x%rightBtnX% y%y4% w%pairWidth% h%btnHeight% gLayout4Alt, Layout 4'

		; Checkbox bật tắt script dưới cùng
		yCheck := y4 + btnHeight + gapBetweenRows + 6
		Gui, Add, CheckBox, x%startX% y%yCheck% vScriptEnabled gToggleScript Checked1, Bật script

		; Nút reset mặc định bên phải checkbox
		Gui, Add, Button, x%rightBtnX% y%yCheck% w%pairWidth% h%btnHeight% gResetDefault, Khôi phục

		Gui, Show, AutoSize Center, Layout Manager
	}
return

Layout1:
	GoSub, ^!1
return

Layout2:
	GoSub, ^!2
return

Layout3:
	GoSub, ^!3
return

Layout4:
	GoSub, ^!4
return

Layout1Alt:
	GoSub, ^!+1
return

Layout2Alt:
	GoSub, ^!+2
return

Layout3Alt:
	GoSub, ^!+3
return

Layout4Alt:
	GoSub, ^!+4
return

ResetDefault:
	GoSub, ^!0
return

GuiClose:
GuiEscape:
	Gui, Destroy
return

RemoveTooltip:
	Tooltip
return