#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <KeyBinding>
Persistent()

Test(a, b) {
    MsgBox(a " > " b " = " (a > b ? "True" : "False"))
}

args := [5, 2]

AssignHotkey("!^t", "Test", , ,[1, 2])