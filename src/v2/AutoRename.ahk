#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetMainIcon rename.ico

class AutoRenameTool {
    static configFile := "C:\Users\jackb\Documents\AutoHotkey\configs\config.ini"
    static name := "AutoRenameTool"
    static maxRecent := 10
    static recentArray := []

    __New() {
        this.lineSpacing := 10
        this.btnSpacing := 10

        ; Load config
        this.defaultPath := IniRead(AutoRenameTool.configFile, AutoRenameTool.name, "DefaultPath", A_ScriptDir)
        recentPaths := IniRead(AutoRenameTool.configFile, AutoRenameTool.name, "RecentPaths", this.defaultPath)
        this.removeKeyword := IniRead(AutoRenameTool.configFile, AutoRenameTool.name, "RemoveKeyword", "")
        this.extDefault := IniRead(AutoRenameTool.configFile, AutoRenameTool.name, "Extension", ".cpp")

        AutoRenameTool.recentArray := (recentPaths != "") ? StrSplit(recentPaths, "|") : []
        if !AutoRenameTool.recentArray.Has(this.defaultPath)
            AutoRenameTool.recentArray.InsertAt(1, this.defaultPath)

        this.BuildGUI()
    }

    BuildGUI() {
        this.myGui := Gui("+AlwaysOnTop +Resize", "AutoRename Tool")
        this.myGui.SetFont("s10", "Segoe UI")

        this.folderEdit := this.myGui.AddEdit("x10 w450 vFolderPath", this.defaultPath)
        btnBrowse := this.myGui.AddButton("x+" this.btnSpacing " yp w40", "📂")
        btnSave := this.myGui.AddButton("x+" this.btnSpacing " yp w40", "💾")
        btnBrowse.ToolTip := "Browse Folder"
        btnSave.ToolTip := "Save to Recent"

        this.myGui.AddText("xs y+" this.lineSpacing, "Remove Keyword:")
        this.removeEdit := this.myGui.AddEdit("x+5 yp-3 w250 vRemoveKeyword", this.removeKeyword)

        this.myGui.AddText("x+" (this.btnSpacing + 20) " yp+3", "Extension:")
        this.extEdit := this.myGui.AddEdit("x+5 yp-3 w100 vExtension", this.extDefault)

        btnRename := this.myGui.AddButton("xs y+" this.lineSpacing " w100", "✂️ Remove")
        btnAddExt := this.myGui.AddButton("x+" this.btnSpacing " yp w80", "📄 Add")
        btnDelExt := this.myGui.AddButton("x+" this.btnSpacing " yp w80", "🗑 Delete")
        btnSaveConfig := this.myGui.AddButton("x+" this.btnSpacing " yp w80", "💾 Save")
        btnApplyAll := this.myGui.AddButton("x+" this.btnSpacing " yp w80", "✅ Apply")
        btnExit := this.myGui.AddButton("x+" this.btnSpacing " w80", "❌ Exit")

        btnBrowse.OnEvent("Click", (*) => this.ChooseFolder())
        btnSave.OnEvent("Click", (*) => this.SaveFolder())
        btnSaveConfig.OnEvent("Click", (*) => this.SaveAsDefault())
        btnApplyAll.OnEvent("Click", (*) => this.ApplyAll())
        btnExit.OnEvent("Click", (*) => ExitApp())

        btnDelExt.OnEvent("Click", (*) => this.DeleteFilesByExtension())
        btnRename.OnEvent("Click", (*) => this.RenameRemoveKeyword())
        btnAddExt.OnEvent("Click", (*) => this.AddExtensionIfMissing())

        this.myGui.Show()
    }

    ChooseFolder() {
        picked := DirSelect("Select Folder")
        if picked
            this.folderEdit.Value := picked
    }

    SaveFolder() {
        newPath := Trim(this.folderEdit.Value)
        if (newPath = "") || !DirExist(newPath) {
            TrayTip("Error", "Invalid folder path.", 1)
            return
        }

        if !AutoRenameTool.recentArray.Has(newPath) {
            AutoRenameTool.recentArray.InsertAt(1, newPath)
            if AutoRenameTool.recentArray.Length > AutoRenameTool.maxRecent
                AutoRenameTool.recentArray.RemoveAt(AutoRenameTool.recentArray.Length)
        } else {
            idx := AutoRenameTool.recentArray.IndexOf(newPath)
            if idx {
                AutoRenameTool.recentArray.RemoveAt(idx)
                AutoRenameTool.recentArray.InsertAt(1, newPath)
            }
        }

        IniWrite(newPath, AutoRenameTool.configFile, AutoRenameTool.name, "DefaultPath")
        IniWrite(AutoRenameTool.recentArray.Join("|"), AutoRenameTool.configFile, AutoRenameTool.name, "RecentPaths")
        TrayTip("Success", "Saved folder path.", 1)
    }

    SaveAsDefault() {
        IniWrite(Trim(this.folderEdit.Value), AutoRenameTool.configFile, AutoRenameTool.name, "DefaultPath")
        IniWrite(Trim(this.removeEdit.Value), AutoRenameTool.configFile, AutoRenameTool.name, "RemoveKeyword")
        IniWrite(Trim(this.extEdit.Value), AutoRenameTool.configFile, AutoRenameTool.name, "Extension")
        TrayTip("Settings Saved", "Default values stored.", 1)
    }

    ApplyAll() {
        TrayTip("Applied", "Values applied temporarily.", 1)
    }

    DeleteFilesByExtension() {
        folderPath := Trim(this.folderEdit.Value)
        ext := Trim(this.extEdit.Value)

        if !DirExist(folderPath) {
            TrayTip("Error", "Invalid folder path.", 1)
            return
        }
        if (ext = "") {
            TrayTip("Error", "No extension provided.", 1)
            return
        }

        if SubStr(ext, 1, 1) = "."
            ext := SubStr(ext, 2)

        count := 0
        Loop Files folderPath "\*." ext, "F" {
            try {
                FileDelete(A_LoopFileFullPath)
                count++
            }
        }

        TrayTip("Delete Complete", count " file(s) with ." ext " deleted.", 1)
    }

    RenameRemoveKeyword() {
        folderPath := Trim(this.folderEdit.Value)
        key := Trim(this.removeEdit.Value)
        if !DirExist(folderPath) {
            TrayTip("Error", "Invalid folder path.", 1)
            return
        }
        if (key = "") {
            TrayTip("Error", "No keyword provided.", 1)
            return
        }

        count := 0
        Loop Files folderPath "\*", "F" {
            old := A_LoopFileName
            if InStr(old, key) {
                new := StrReplace(old, key)
                try {
                    FileMove(folderPath "\" old, folderPath "\" new, true)
                    count++
                }
            }
        }
        TrayTip("Rename Complete", count " file(s) renamed.", 1)
    }

    AddExtensionIfMissing() {
        folderPath := Trim(this.folderEdit.Value)
        ext := Trim(this.extEdit.Value)
        if !DirExist(folderPath) {
            TrayTip("Error", "Invalid folder path.", 1)
            return
        }
        if (ext = "") {
            TrayTip("Error", "No extension specified.", 1)
            return
        }

        count := 0
        Loop Files folderPath "\*", "F" {
            SplitPath A_LoopFileFullPath,,,&e,&n
            if (e = "") {
                newPath := folderPath "\" n ext
                try {
                    FileMove(A_LoopFileFullPath, newPath, true)
                    count++
                }
            }
        }
        TrayTip("Extension Added", count " file(s) renamed.", 1)
    }
}

; === Run the tool ===
tool := AutoRenameTool()
