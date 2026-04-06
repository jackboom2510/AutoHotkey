#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetMainIcon rename.ico

class AutoRenameTool {
    configFile := 'file:///D:\Documents\AutoHotkey\configs\config.ini'
    name := 'AutoRenameTool'
    maxRecent := 10
    recentArray := []

    __New() {
        this.lineSpacing := 10
        this.btnSpacing := 10

        ; Load config
        this.defaultPath := IniRead(this.configFile, this.name, 'DefaultPath', A_ScriptDir)
        this.recentPaths := IniRead(this.configFile, this.name, 'RecentPaths', this.defaultPath)
        this.removeKeyword := IniRead(this.configFile, this.name, 'RemoveKeyword', '')
        this.extDefault := IniRead(this.configFile, this.name, 'Extension', '.cpp')

        this.recentArray := (this.recentPaths != '') ? StrSplit(this.recentPaths, '|') : []
        if !this.recentArray.Has(this.defaultPath)
            this.recentArray.InsertAt(1, this.defaultPath)

        this.BuildGUI()
    }

    BuildGUI() {
        this.gui := Gui('+AlwaysOnTop +Resize', 'AutoRename Tool')
        this.gui.SetFont('s10', 'Segoe UI')

        this.folderEdit := this.gui.AddEdit('x10 w450', this.defaultPath)
        btnBrowse := this.gui.AddButton('x+' this.btnSpacing ' yp w40', '📂')
        btnSave := this.gui.AddButton('x+' this.btnSpacing ' yp w40', '💾')

        this.gui.AddText('xs y+' this.lineSpacing, 'Remove Keyword:')
        this.removeEdit := this.gui.AddEdit('x+5 yp-3 w250', this.removeKeyword)

        this.gui.AddText('x+' (this.btnSpacing + 20) ' yp+3', 'Extension:')
        this.extEdit := this.gui.AddEdit('x+5 yp-3 w100', this.extDefault)

        btnRename := this.gui.AddButton('xs y+' this.lineSpacing ' w100', '✂️ Rename')
        btnAddExt := this.gui.AddButton('x+' this.btnSpacing ' yp w80', '📄 Add')
        btnDelExt := this.gui.AddButton('x+' this.btnSpacing ' yp w80', '🗑 Delete')
        btnSaveConfig := this.gui.AddButton('x+' this.btnSpacing ' yp w80', '💾 Save')
        btnApplyAll := this.gui.AddButton('x+' this.btnSpacing ' yp w80', '📂 Open')
        btnExit := this.gui.AddButton('x+' this.btnSpacing ' w80', '❌ Exit')

        btnRename.OnEvent('Click', (*) => this.RenameRemoveKeyword())
        btnBrowse.OnEvent('Click', (*) => this.ChooseFolder())
        btnSave.OnEvent('Click', (*) => this.SaveFolder())
        btnSaveConfig.OnEvent('Click', (*) => this.SaveAsDefault())
        btnApplyAll.OnEvent('Click', (*) => this.OpenConfigFile())
        btnExit.OnEvent('Click', (*) => ExitApp())
        btnDelExt.OnEvent('Click', (*) => this.DeleteFilesByExtension())
        btnAddExt.OnEvent('Click', (*) => this.AddExtensionIfMissing())
        SetupToolTip
        SetupToolTip() {
            btnBrowse.ToolTip := 'Browse Folder'
            btnSave.ToolTip := 'Save to Recent'
            btnExit.ToolTip := 'Exit App'
            btnRename.ToolTip := ''
            btnAddExt.ToolTip := 'Add Extension If Missing'
            btnApplyAll.ToolTip := ''
            btnSaveConfig.ToolTip := ''
            btnExit.ToolTip := ''
            btnDelExt.ToolTip := ''
        }
        this.gui.Show()
        OnMessage(0x0200, On_WM_MOUSEMOVE)
        On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
            PrevHwnd := 0
            if (Hwnd != PrevHwnd) {
                Text := ''
                SetTimer(ToolTip)
                CurrControl := GuiCtrlFromHwnd(Hwnd)
                if CurrControl {
                    if !CurrControl.HasProp('ToolTip')
                        return
                    Text := CurrControl.ToolTip
                    ToolTip(Text)
                }
                PrevHwnd := Hwnd
            }
        }
    }

    ChooseFolder() {
        picked := DirSelect('Select Folder')
        if picked
            this.folderEdit.Value := picked
    }

    SaveFolder() {
        newPath := Trim(this.folderEdit.Value)
        if (newPath = '') || !DirExist(newPath) {
            TrayTip('Error', 'Invalid folder path.', 1)
            return
        }

        if !this.recentArray.Has(newPath) {
            this.recentArray.InsertAt(1, newPath)
            if this.recentArray.Length > this.maxRecent
                this.recentArray.RemoveAt(this.recentArray.Length)
        } else {
            idx := this.recentArray.IndexOf(newPath)
            if idx {
                this.recentArray.RemoveAt(idx)
                this.recentArray.InsertAt(1, newPath)
            }
        }

        IniWrite(newPath, this.configFile, this.name, 'DefaultPath')
        IniWrite(this.recentArray.Join('|'), this.configFile, this.name, 'RecentPaths')
        TrayTip('Success', 'Saved folder path.', 1)
    }

    SaveAsDefault() {
        IniWrite(Trim(this.folderEdit.Value), this.configFile, this.name, 'DefaultPath')
        IniWrite(Trim(this.removeEdit.Value), this.configFile, this.name, 'RemoveKeyword')
        IniWrite(Trim(this.extEdit.Value), this.configFile, this.name, 'Extension')
        TrayTip('Settings Saved', 'Default values stored.', 1)
    }

    OpenConfigFile() {
        Run(this.configFile)
    }

    DeleteFilesByExtension() {
        folderPath := Trim(this.folderEdit.Value)
        ext := Trim(this.extEdit.Value)

        if !DirExist(folderPath) {
            TrayTip('Error', 'Invalid folder path.', 1)
            return
        }
        if (ext = '') {
            TrayTip('Error', 'No extension provided.', 1)
            return
        }

        if SubStr(ext, 1, 1) = '.'
            ext := SubStr(ext, 2)

        count := 0
        loop files folderPath '\*.' ext, 'F' {
            try {
                FileDelete(A_LoopFileFullPath)
                count++
            }
        }

        TrayTip('Delete Complete', count ' file(s) with .' ext ' deleted.', 1)
    }

    RenameRemoveKeyword() {
        folderPath := Trim(this.folderEdit.Value)
        key := Trim(this.removeEdit.Value)
        if !DirExist(folderPath) {
            TrayTip('Invalid folder path.', 'Error', 1)
            return
        }
        if (key = '') {
            TrayTip('No keyword provided.', 'Error', 1)
            return
        }

        count := 0
        loop files folderPath '\*', 'F' {
            old := A_LoopFileName
            if InStr(old, key) {
                new := StrReplace(old, key)
                try {
                    FileMove(folderPath '\' old, folderPath '\' new, true)
                    count++
                }
            }
        }
        TrayTip(count ' file(s) renamed.', 'Rename Complete', 1)
    }

    AddExtensionIfMissing() {
        folderPath := Trim(this.folderEdit.Value)
        ext := Trim(this.extEdit.Value)
        if !DirExist(folderPath) {
            TrayTip('Error', 'Invalid folder path.', 1)
            return
        }
        if (ext = '') {
            TrayTip('Error', 'No extension specified.', 1)
            return
        }

        count := 0
        loop files folderPath '\*', 'F' {
            SplitPath A_LoopFileFullPath, , , &e, &n
            if (e = '') {
                newPath := folderPath '\' n ext
                try {
                    FileMove(A_LoopFileFullPath, newPath, true)
                    count++
                }
            }
        }
        TrayTip('Extension Added', count ' file(s) renamed.', 1)
    }
}

tool := AutoRenameTool()