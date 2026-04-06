#Requires AutoHotkey v2.0.18+
#Include <core\Core>
Persistent

class ScrcpyLauncher {
    configFile := A_ScriptDir "\config\scrcpy.ini"
    tmpBatPath := A_ScriptDir "\tmp\scrcpy_tmp.bat"
    ddlCommands := []
    gui := unset
    inputEdit := unset
    listBox := unset
    checkboxOptions := Map()
    checkOptionList := [
        "--turn-screen-off",
        "--always-on-top",
        "--fullscreen",
        "--stay-awake"
    ]

    __New() {
        this.LoadHistory()
        this.BuildGUI()
        this.gui.Show("AutoSize Center")
    }

    LoadHistory() {
        if !FileExist(this.configFile)
            return
        history := IniRead(this.configFile, "History", "commands", "")
        loop parse, history, "`n"
            if (A_LoopField != "")
                this.ddlCommands.Push(A_LoopField)
    }

    SaveHistory(cmd) {
        if this.ddlCommands.Has(cmd)
            return
        this.ddlCommands.InsertAt(1, cmd)
        if this.ddlCommands.Length() > 10
            this.ddlCommands.Pop()
        IniWrite(StrJoin("`n", this.ddlCommands*), this.configFile, "History", "commands")
    }

    BuildGUI() {
        this.gui := Gui("+AlwaysOnTop -Caption +Resize", "scrcpy Launcher")
        this.gui.BackColor := "F0F0F0"
        this.gui.SetFont("s10", "Segoe UI")
        this.inputEdit := this.gui.AddEdit("xm y+10 w400 h25")
        this.listBox := this.gui.AddListBox("xm y+5 w400 r5", this.ddlCommands)
        this.listBox.OnEvent("Change", (*) => this.inputEdit.Value := this.listBox.Text)

        for opt in this.checkOptionList {
            cb := this.gui.AddCheckbox("xm y+5", opt)
            this.checkboxOptions[opt] := cb
        }

        this.gui.AddButton("xm y+10 w150", "▶ Run Normally")
        .OnEvent("Click", (*) => this.RunScrcpy(false))
        this.gui.AddButton("x+5 w150", "🛡 Run as Admin")
        .OnEvent("Click", (*) => this.RunScrcpy(true))
        this.gui.AddButton("x+5 w80", "❌ Exit")
        .OnEvent("Click", (*) => ExitApp())
    }

    RunScrcpy(asAdmin := false) {
        cmd := this.inputEdit.Value
        if (cmd = "") {
            TrayTip("⚠️ Vui lòng nhập lệnh scrcpy")
            return
        }

        for opt, cb in this.checkboxOptions
            if cb.Value
                cmd .= " " . opt

        ; Lưu command
        this.SaveHistory(cmd)

        ; Tạo file bat
        FileCreateDir(A_ScriptDir "\tmp")
        FileDelete(this.tmpBatPath)
        FileAppend("scrcpy " cmd, this.tmpBatPath)

        ; Dùng Windows Terminal để chạy
        args := asAdmin ? "/c start wt -w 0 powershell Start-Process '" this.tmpBatPath "' -Verb RunAs"
            : "/c start wt -w 0 cmd /c " "" this.tmpBatPath "" ""
        Run("cmd.exe " args, , "Hide")
    }
}

launcher := ScrcpyLauncher()