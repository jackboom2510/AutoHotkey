#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

; === Configuration ===
global configFile := A_ScriptDir "\config.ini"
global section := "AutoRename"
global maxRecent := 10

lineSpacing := 10
btnSpacing := 10

defaultPath := IniRead(configFile, section, "DefaultPath", A_ScriptDir)
recentPaths := IniRead(configFile, section, "RecentPaths", defaultPath)
removeKeyword := IniRead(configFile, section, "RemoveKeyword", "")
extDefault := IniRead(configFile, section, "Extension", ".cpp")

recentArray := (recentPaths != "") ? StrSplit(recentPaths, "|") : []
if !recentArray.Has(defaultPath)
    recentArray.InsertAt(1, defaultPath)

; === GUI ===
myGui := Gui("+AlwaysOnTop +Resize", "AutoRename Tool")
myGui.SetFont("s10", "Segoe UI")

; --- Folder Selection ---
; myGui.AddText("section", "Folder:")
folderEdit := myGui.AddEdit("x10 w450 vFolderPath", defaultPath)
btnBrowse := myGui.AddButton("x+" btnSpacing " yp w40", "📂")
btnSave := myGui.AddButton("x+" btnSpacing " yp w40", "💾")
btnBrowse.ToolTip := "Browse Folder"
btnSave.ToolTip := "Save to Recent"

; --- Keyword Removal & Extension ---
myGui.AddText("xs y+" lineSpacing, "Remove Keyword:")
removeEdit := myGui.AddEdit("x+5 yp-3 w250 vRemoveKeyword", removeKeyword)

myGui.AddText("x+" (btnSpacing + 20) " yp+3", "Extension:")
extEdit := myGui.AddEdit("x+5 yp-3 w100 vExtension", extDefault)

; --- Processing Buttons ---
btnRename := myGui.AddButton("xs y+" lineSpacing " w100", "✂️ Remove")
btnAddExt := myGui.AddButton("x+" btnSpacing " yp w80", "📄 Add")
btnDelExt := myGui.AddButton("x+" btnSpacing " yp w80", "🗑 Delete")

; --- Settings and Exit ---
btnSaveConfig := myGui.AddButton("x+" btnSpacing " yp w80", "💾 Save")
btnApplyAll := myGui.AddButton("x+" btnSpacing " yp w80", "✅ Apply")
btnExit := myGui.AddButton("x+" btnSpacing " w80", "❌ Exit")

; --- Event bindings ---
btnBrowse.OnEvent("Click", ChooseFolder)
btnSave.OnEvent("Click", SaveFolder)
btnSaveConfig.OnEvent("Click", SaveAsDefault)
btnApplyAll.OnEvent("Click", ApplyAll)
btnExit.OnEvent("Click", (*) => ExitApp())

btnDelExt.OnEvent("Click", DeleteFilesByExtension)
btnRename.OnEvent("Click", RenameRemoveKeyword)
btnAddExt.OnEvent("Click", AddExtensionIfMissing)

myGui.Show()
return

; === Folder Picker ===
ChooseFolder(*) {
    global folderEdit
    picked := DirSelect("Select Folder")
    if picked
        folderEdit.Value := picked
}

; === Save to Recent List ===
SaveFolder(*) {
    global configFile, section, folderEdit, recentArray, maxRecent
    newPath := Trim(folderEdit.Value)
    if (newPath = "") || !DirExist(newPath) {
        TrayTip("Error", "Invalid folder path.", 1)
        return
    }

    if !recentArray.Has(newPath) {
        recentArray.InsertAt(1, newPath)
        if recentArray.Length > maxRecent
            recentArray.RemoveAt(recentArray.Length)
    } else {
        idx := 0
        for i, val in recentArray {
            if (val = newPath) {
                idx := i
                break
            }
        }
        if (idx) {
            recentArray.RemoveAt(idx)
            recentArray.InsertAt(1, newPath)
        }
    }

    IniWrite(newPath, configFile, section, "DefaultPath")
    IniWrite(recentArray.Join("|"), configFile, section, "RecentPaths")
    TrayTip("Success", "Saved folder path.", 1)
}

; === Save All Config ===
SaveAsDefault(*) {
    global configFile, section, folderEdit, removeEdit, extEdit
    IniWrite(Trim(folderEdit.Value), configFile, section, "DefaultPath")
    IniWrite(Trim(removeEdit.Value), configFile, section, "RemoveKeyword")
    IniWrite(Trim(extEdit.Value), configFile, section, "Extension")
    TrayTip("Settings Saved", "Default values stored.", 1)
}

; === Apply Dummy ===
ApplyAll(*) {
    TrayTip("Applied", "Values applied temporarily.", 1)
}

; === Delete files by extension ===
DeleteFilesByExtension(*) {
    folderPath := Trim(folderEdit.Value)
    ext := Trim(extEdit.Value)

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

; === Rename files by removing keyword ===
RenameRemoveKeyword(*) {
    folderPath := Trim(folderEdit.Value)
    key := Trim(removeEdit.Value)
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

; === Add extension if missing ===
AddExtensionIfMissing(*) {
    folderPath := Trim(folderEdit.Value)
    ext := Trim(extEdit.Value)
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
