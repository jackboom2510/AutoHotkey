#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Screen"

#include <core\Log>
#Include <core\KeyBinding>
#Include <ui\HelpUI>
#Include <util\MouseMacro>
;@Ahk2Exe-SetMainIcon dictionary.ico

LookUp.CreateGui()

BindingScript()

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert("&Suspend Hotkeys", "Reload Script", (*) => Reload())
A_TrayMenu.Insert('&Suspend Hotkeys', 'Edit Script', (*) => Run(
    '"D:\2. Program Files\cursor\Cursor.exe" "C:\Users\jackb\Documents\AutoHotkey\src\v2LookUp.ahk"'
))
A_TrayMenu.Insert("&Suspend Hotkeys")
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Open File Location", (*) => Run("*open " "C:\Users\jackb\Documents\AutoHotkey\src\v2\"))
A_TrayMenu.SetIcon("Open File Location", "C:\Windows\System32\shell32.dll", 4)
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys())
A_TrayMenu.SetIcon("Show Hotkeys", "C:\Windows\System32\shell32.dll", 24)
A_TrayMenu.Insert("E&xit", "Search", (*) => LookUp.SearchFromClipBoard())
A_TrayMenu.SetIcon("Search", "C:\Windows\System32\shell32.dll", 23)
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => LookUp.Toggle())
A_TrayMenu.Default := "Show/Hide"
A_TrayMenu.ClickCount := 1

class LookUp {
    static gui := unset
    static lookUpWord := ""
    static btnApply := ""
    static btnSearch := ""
    static btnSearchFromClipboard := ""
    static dictionaryDdl := ""
    static wordEdit := ""
    static dictionary := ["hv", "nom", "py"]
    static dictionaryMap := ["Tra Hán Việt", "Tra Nôm", "Tra Pinyin"]
    static transparency := 225

    static CreateGui() {
        LookUp.gui := Gui("+AlwaysOnTop +Resize -DPIScale", "LookUp Tool")
        LookUp.gui.SetFont("s11", "Tahoma")
        LookUp.gui.BackColor := "eaffff"

        LookUp.dictionaryDdl := LookUp.gui.AddDropDownList("x10 y+5 w125 Choose1", LookUp.dictionaryMap)
        ; LookUp.dictionaryDdl.OnEvent("Change", (*) => LookUp.UpdateDictionary())
        LookUp.wordEdit := LookUp.gui.AddEdit("x+5 yp w150 h25", LookUp.lookUpWord)
        ; LookUp.wordEdit.OnEvent("LoseFocus", (*) => LookUp.Apply())
        ; LookUp.btnApply := LookUp.gui.AddButton("x+5 yp w30", "✅")
        ; LookUp.btnApply.OnEvent("Click", (*) => LookUp.Apply())
        LookUp.btnSearch := LookUp.gui.AddButton("x+5 yp w27 h27 Center", "↩️").OnEvent("Click", (*) => LookUp.Search())
        LookUp.btnSearchFromClipboard := LookUp.gui.AddButton("x+5 yp w27 h27 Center", "📋").OnEvent("Click", (*) =>
            LookUp.SearchFromClipBoard())

        LookUp.gui.Show("x1160 y80 AutoSize")
        ControlFocus(LookUp.wordEdit, "LookUp Tool")
        Send("^+1")
        WinSetTransColor LookUp.gui.BackColor, "LookUp Tool"
        WinSetTransparent LookUp.transparency, "LookUp Tool"
    }

    static Apply() {
        word := LookUp.wordEdit.Value
        if word != "" {
            LookUp.lookUpWord := word
        } else {
            TrayTip("❌ Từ không hợp lệ.", "Lỗi", 16)
        }
    }

    static Search() {
        MouseGetPos(&mouseX, &mouseY)
        word := LookUp.wordEdit.Value
        dic := LookUp.dictionary[LookUp.dictionaryDdl.Value]
        if word != "" {
            LookUp.lookUpWord := word
            Run("https://hvdic.thivien.net/" dic "/" word)
            Sleep(500)
            ClickAndSleep(650, 500)
            MouseMove(mouseX, mouseY)
            TrayTip("✅ " LookUp.dictionaryDdl.Text ": " word)
        }
        else {
            TrayTip("❌ Từ không hợp lệ.", "Lỗi", 16)
        }
    }

    static SearchFromClipBoard() {
        word := A_Clipboard
        dic := LookUp.dictionary[LookUp.dictionaryDdl.Value]
        if word != "" {
            LookUp.lookUpWord := word
            Run("https://hvdic.thivien.net/" dic "/" word)
            Sleep(500)
            ClickAndSleep(650, 500)
            TrayTip("✅ " LookUp.dictionaryDdl.Text ": " word)
        }
        else {
            TrayTip("❌ Clipboard đang trống.", "Lỗi", 16)
        }
    }

    static Toggle() {
        if !LookUp.gui {
            LookUp.CreateGui()
            return
        }

        hwnd := LookUp.gui.Hwnd
        editHwnd := LookUp.wordEdit.Hwnd
        if !WinExist("ahk_id " hwnd) {
            LookUp.gui.Show("x1160 y80 AutoSize")
            ControlFocus(LookUp.wordEdit, "LookUp Tool")
            Send("^+1")
            return
        }

        winState := WinGetMinMax("ahk_id " hwnd)

        if winState = -1 {
            LookUp.gui.Show("x1160 y80 AutoSize")
            ControlFocus(LookUp.wordEdit, "LookUp Tool")
            Send("^+1")
        }
        else
            LookUp.gui.Hide()
    }
}
