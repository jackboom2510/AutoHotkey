#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>

MyGui := Gui("+AlwaysOnTop +Resize -DPIScale", "Simple Tab GUI")
MyGui.SetFont("s10", "Segoe UI")

; Thêm control Tab
tabs := MyGui.Add("Tab3", "w400 h250", ["Tab 1", "Tab 2"])

; ===== Tab 1 =====
MyGui.UseTab(1)
MyGui.Add("Text", "x+10 yp+30", "Đây là Tab 1")
MyGui.Add("Edit", "w300", "Nội dung cho Tab 1")

; ===== Tab 2 =====
MyGui.UseTab(2)
MyGui.Add("Text", , "Đây là Tab 2")
MyGui.Add("Button", "w150", "Nhấn vào đây")

; Quay lại mặc định (không tab nào)
MyGui.UseTab(1)

; Hiển thị GUI
MyGui.Show("w420 h300")

FileObj.Close()