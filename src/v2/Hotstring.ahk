#Requires AutoHotkey v2.0+
#SingleInstance Force
Persistent

#Include <Log>
;@Ahk2Exe-SetMainIcon exchange.ico
;@Ahk2Exe-SetName Hotstring Modifier
; macro := HotstringUI("x{0} y{0}")
macro := HotstringUI()
class HotstringUI {
    gui := unset
    guiID := ""
    name := "Macro Definition"
    guiOpts := "AlwaysOnTop -DPIScale"
    ; guiOpts := "+AlwaysOnTop +Resize -DPIScale -Caption"

    hasParse := false
    xpos := 1600
    ypos := -300
    guiWidth := 0
    guiHeight := 0

    transparency := 225
    transparencyMin := 120
    transparencyMax := 255
    transparencyStep := 15

    transparencyEdit := ""
    transparencyUpDown := ""

    defaultConfigPath := "C:\Users\jackb\Documents\AutoHotkey\configs\hotstring.config"
    defaultCB := true
    case_sensitive := false

    listView := unset
    settings := []
    hotstringMap := Map()
    hotstringCB := []
    states := []
    default_hstrOpt := "T*"
    hstrOpt := "ST*"
    hstrOpts := ['', 'T', 'T*', 'ST', 'ST*', '*', 'More...']

    __New(options := "", args*) {
        if (this.guiID) {
            if WinExist("ahk_class AutoHotkeyGUI ahk_id " this.guiID) {
                return
            }
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.gui.SetFont("s10", "Arial")
        this.gui.BackColor := "fdfdfd"

        this.LoadConfig()
        if (this.case_sensitive) {
            for idx, val in this.hstrOpts {
                this.hstrOpts[idx] := 'C1' this.hstrOpts[idx]
            }
        }
        this.SetupAll()
        this.ParseAll(options, args*)

        this.Show()
        this.gui.GetPos(&xpos, &ypos, &Width, &Height)
        this.xpos := xpos
        this.ypos := ypos
        this.guiWidth := Width
        this.guiHeight := Height
        ; WinSetTransColor(this.gui.BackColor, this.name)
        ; WinSetTransparent(this.transparency, this.name)
        SetupMessage
        return
        SetupMessage() {
            ; OnMessage(0x0200, On_WM_MOUSEMOVE)
            ; OnMessage(0x4E, On_WM_NOTIFY)
            return
            On_WM_NOTIFY(wParam, lParam, Msg, hWnd) {
                UDN_DELTAPOS := -722
                is64Bit := (A_PtrSize = 8)

                NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
                DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

                hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
                code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
                delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

                if (hwndFrom = this.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
                    newVal := this.transparencyUpDown.Value + delta * this.transparencyStep
                    newVal := Min(Max(newVal, this.transparencyMin), this.transparencyMax)
                    this.transparencyUpDown.Value := newVal
                    this.transparency := newVal
                    WinSetTransparent this.transparency, this.name
                    return true
                }
            }
            On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
                PrevHwnd := 0
                if (Hwnd != PrevHwnd) {
                    Text := ""
                    SetTimer(ToolTip)
                    CurrControl := GuiCtrlFromHwnd(Hwnd)
                    if CurrControl {
                        if !CurrControl.HasProp("ToolTip")
                            return
                        Text := CurrControl.ToolTip
                        ToolTip(Text)
                    }
                    PrevHwnd := Hwnd
                }
            }
        }

    }
    LoadConfig(configPath := this.defaultConfigPath) {
        idx := 1
        loop parse FileRead(configPath, "UTF-8"), '`n', '`r' {
            if RegExMatch(A_LoopField, '^\*\*\*(.*)\*\*\*') {
                RegExMatch(A_LoopField, '^\*\*\*(.*)\*\*\*', &setting)
                setting := StrSplit(setting[1], ':', , 2)
                this.%setting[1]% := (setting[2] = "true") || (setting[2] = "1")
                this.settings.Push(Format("***{}:{}***", setting[1], setting[2]))
                continue
            }
            try {
                if (A_LoopField != "") {
                    pair := StrSplit(A_LoopField, ':', , 2)
                    this.hotstringMap[pair[1]] := [pair[2], idx]
                    this.hotstringCB.Push([this.defaultCB, pair[1]])
                    idx := idx + 1
                }
            }
            catch as err {
                errMsg := "Error: " err.Message
                TrayTip("Wrong File! Try Again!`nError when read line " A_index ': "' A_LoopField '"', errMsg, 3)
                return
            }
        }
    }
    ; -----------------------------------------------------------------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    ; ----------------------------------------------SetupALL-----------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    SetUpAll() {
        SetupControls
        SetupEvents
        SetupToolTips
        SetupHotstring
        DynamicButtonStates
        return
        SetupControls(controlOpts := "") {
            this.gui.AddText(controlOpts 'w95 xm+5', "&Thay thế:")
            this.gui.AddText(controlOpts 'w385 yp', "&Bởi:")
            this.gui.AddText(controlOpts 'w95 x+10 yp', "&Cài đặt")
            this.replace := this.gui.AddEdit(controlOpts 'w90 xm+5 r1 vreplace')
            this.by := this.gui.AddEdit(controlOpts "w390 yp r1 vby")
            this.opts := this.gui.AddDropDownList(controlOpts "w105 yp vopts Choose2", this.hstrOpts)
            this.hstrOpt := this.opts.value
            SetupUpListView
            this.saveBtn := this.gui.AddButton(controlOpts 'w100 yp', "&Lưu")
            this.stopBtn := this.gui.AddButton(controlOpts 'w100', "&Ngừng")
            this.resetBtn := this.gui.AddButton(controlOpts 'w100', "Đặt &lại")
            this.addBtn := this.gui.AddButton(controlOpts 'w100 y+45', "&Thêm")
            this.editBtn := this.gui.AddButton(controlOpts 'w100 xp yp', "&Sửa")
            this.delBtn := this.gui.AddButton(controlOpts 'w100', "&Xóa")
            this.caseSen := this.gui.AddCheckbox(controlOpts 'xm', "Tự động đổi chữ hoa theo phím tắt")
            this.caseSen.Value := this.case_sensitive
            this.gui.AddText(controlOpts, "(Định nghĩa: vn=việt nam, Auto: VN=VIỆT NAM, Vn=Việt nam)")
            this.gui.AddText(controlOpts 'w70', "File gõ tắt:")
            this.file := this.gui.AddText(controlOpts "yp", this.defaultConfigPath)
            this.chooseFileBtn := this.gui.AddButton(controlOpts 'w150 xm', "Chọn &File...")
            this.defaultFile := this.gui.AddButton(controlOpts 'w150 x+22 yp', "File &mặc định")
            this.editConfigFileBtn := this.gui.AddButton(controlOpts 'w150 x+23 yp', '&Mở File')
        }
        ; -----------------------------------------------------------------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        ; ----------------------------------------------List View----------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        SetupUpListView() {
            this.listView := this.gui.AddListView('Grid xm w495 r10 +Checked -Hdr -Multi', ['1', '2'])
            for key, value in this.hotstringMap {
                this.listView.Add(, key, value[1])
            }
            if (this.defaultCB)
                this.listView.Modify(0, "Check")
            else
                this.listView.Modify(0, "-Check")
            this.listView.ModifyCol(1, 100)
            this.listView.ModifyCol(2, "AutoHdr")
            this.listView.OnEvent("Click", LV_Click)
            this.listView.OnEvent("DoubleClick", LV_DoubleClick)
            this.listView.OnEvent("ContextMenu", LV_ContextMenu)
            this.listView.OnEvent("ItemCheck", LV_ItemCheck)
            LV_Click(LV, RowNumber) {
                this.replace.value := LV.GetText(RowNumber, 1)
                this.by.value := Trim(LV.GetText(RowNumber, 2), '`r`n')
                DynamicButtonStates()
            }
            LV_ContextMenu(LV, Item, IsRightClick, X, Y) {
                if (!IsRightClick)
                    return
                A_Clipboard := LV.GetText(Item, 2)
                ToolTip("Đã copy " A_Clipboard " vào Clipboard!")
                SetTimer(Tooltip, -1500)
            }
            ; ItemCheck Alternative
            LV_DoubleClick(LV, RowNumber) {
                if (this.hotstringCB[RowNumber][1])
                    LV.Modify(RowNumber, "-Check")
                else
                    LV.Modify(RowNumber, "Check")
                abb := LV.GetText(RowNumber, 1)
                full := Lv.GetText(RowNumber, 2)
                this.hotstringCB[RowNumber][1] := !this.hotstringCB[RowNumber][1]
                UserHotstring(this.hstrOpt, abb, full, -1)
            }
            LV_ItemCheck(LV, RowNumber, Checked) {
                abb := LV.GetText(RowNumber, 1)
                full := Lv.GetText(RowNumber, 2)
                this.hotstringCB[RowNumber][1] := !this.hotstringCB[RowNumber][1]
                UserHotstring(this.hstrOpt, abb, full, -1)
            }
        }
        ; -----------------------------------------------------------------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        ; --------------------------------------------SetupEvents----------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        ; -----------------------------------------------------------------------------------------------------
        SetupEvents() {
            this.gui.OnEvent("Close", (*) => ExitApp())
            this.gui.OnEvent("Escape", (*) => PromtToSaveInSort())
            this.gui.OnEvent("Size", On_Minimize)
            this.gui.OnEvent("ContextMenu", On_ContextMenu)
            this.replace.OnEvent('Change', (*) => DynamicButtonStates())
            this.by.OnEvent('Change', (*) => DynamicButtonStates())
            this.opts.OnEvent('Change', (*) => UpdateOpts())
            this.saveBtn.OnEvent('Click', (*) => SaveConfig())
            this.stopBtn.OnEvent('Click', (*) => StopAll())
            this.resetBtn.OnEvent("Click", (*) => ResetAll())
            this.editBtn.OnEvent("Click", (*) => Edit(this.replace.value, this.by.value))
            this.addBtn.OnEvent("Click", (*) => Edit(this.replace.value, this.by.value))
            this.delBtn.OnEvent("Click", (*) => Del(this.replace.value, this.by.value))
            this.caseSen.OnEvent("Click", (*) => On_CaseSenChanged(this.caseSen.value))
            this.chooseFileBtn.OnEvent("Click", (*) => ChooseFile())
            this.defaultFile.OnEvent("Click", (*) => ChooseFile(this.defaultConfigPath))
            this.editConfigFileBtn.OnEvent("Click", (*) => Run(this.file.value))
            return
            On_Minimize(myGui, MinMax, Width, Height) {
                if(MinMax = -1) {
                    myGui.Hide
                    return
                }
            }
            On_ContextMenu(*) {
                A_TrayMenu.Show(0, 0)
            }
            PromtToSaveInSort(filePath := this.defaultConfigPath) {
                if(A_IsCompiled)
                    inp_height := 150
                else
                    inp_height := 100
                inp := InputBox("Bạn có muốn lưu Macros không?", , 'w250 h' inp_height ' x' this.xpos + this.guiWidth ' y' this
                    .ypos ' t5', 'Y')
                if (inp.value := 'N' || inp.Result != "OK") {
                    return
                }
                if (inp.Value = 'Y' || inp.Result = "OK") {
                    SaveConfig(filePath)
                    ChooseFile(filePath)
                    Sleep(1000)
                    SaveConfig(filePath)
                    TrayTip("Đã lưu gõ tắt vào " filepath "!", "Thành công!")
                }
                return
            }
            UpdateOpts() {
                if (this.opts.value = this.hstrOpts.Length) {
                    this.opts.Delete(this.opts.value)
                    inp := InputBox("Hãy nhập cài đặt cho gõ tắt:", , 'w220 h100 t5')
                    if (inp.Result != 'Ok') {
                        TrayTip("Chưa nhập cài đặt!`n Xin vui lòng lựa chọn sau!", , 2)
                        return
                    }
                    newVal := inp.Value
                    for idx, val in this.hstrOpts {
                        if (idx = this.hstrOpts.Length) {
                            this.hstrOpts.InsertAt(idx, newVal)
                            this.opts.Add([newVal, "More..."])
                            this.opts.Choose(idx)
                            loop this.listView.GetCount() {
                                i := A_Index
                                abb := this.listView.GetText(i, 1)
                                full := this.listView.GetText(i, 2)
                                UserHotstring(this.hstrOpt, abb, full, 0)
                                UserHotstring(this.opts.Text, abb, full, GetState(i))
                            }
                            this.hstrOpt := this.opts.Text
                            return
                        }
                        if (newVal = val) {
                            TrayTip("Cài đặt '" newVal "' đã tồn tại trong danh sách!`nXin vui lòng lựa chọn lại!", , 2
                            )
                            return
                        }
                    }
                    return
                }
                loop this.listView.GetCount() {
                    idx := A_Index
                    abb := this.listView.GetText(idx, 1)
                    full := this.listView.GetText(idx, 2)
                    UserHotstring(this.hstrOpt, abb, full, 0)
                    UserHotstring(this.opts.Text, abb, full, GetState(idx))
                }
                this.hstrOpt := this.opts.Text
            }
            On_CaseSenChanged(Checked) {
                selectedIdx := this.opts.value
                if (Checked) {
                    for idx, val in this.hstrOpts {
                        if (idx = this.hstrOpts.Length)
                            break
                        this.hstrOpts[idx] := 'C1 ' this.hstrOpts[idx]
                    }
                    this.opts.Delete()
                    this.opts.Add(this.hstrOpts)
                    this.opts.Choose(selectedIdx)
                }
                else {
                    for idx, val in this.hstrOpts {
                        if (idx = this.hstrOpts.Length)
                            break
                        this.hstrOpts[idx] := RegExReplace(this.hstrOpts[idx], '(.*)\s(.*)', '$2')
                    }
                    this.opts.Delete()
                    this.opts.Add(this.hstrOpts)
                    this.opts.Choose(selectedIdx)
                }
                loop this.listView.GetCount() {
                    idx := A_Index
                    abb := this.listView.GetText(idx, 1)
                    full := this.listView.GetText(idx, 2)
                    UserHotstring(this.hstrOpt, abb, full, 0)
                    UserHotstring(this.opts.Text, abb, full, GetState(idx))
                }
                this.hstrOpt := this.opts.Text
            }
            SaveConfig(filePath := this.defaultConfigPath) {
                erf(filePath)
                for value in this.settings
                    WriteFile(filePath, value, 0, 'l')
                loop this.listView.GetCount() {
                    hstr := this.listView.GetText(A_index, 1) ":" this.listView.GetText(A_Index, 2)
                    WriteFile(filePath, hstr, 0, 'l')
                }
            }
            StopAll() {
                for idx, value in this.hotstringCB {
                    if (this.hotstringCB[idx][1] = true) {
                        this.listView.Modify(idx, '-Check')
                    }
                    this.hotstringCB[idx][1] := false
                    UserHotstring(this.hstrOpt, value[2], this.hotstringMap[value[2]][1], 0)
                }
            }
            ResetAll() {
                for idx, value in this.hotstringCB {
                    if (this.hotstringCB[idx][1] = false) {
                        this.listView.Modify(idx, 'Check')
                    }
                    this.hotstringCB[idx][1] := true
                    UserHotstring(this.hstrOpt, value[2], this.hotstringMap[value[2]][1], 1)
                }
            }
            Edit(replace, by) {
                ; Add New Hotstring
                if (!this.hotstringMap.Has(replace)) {
                    idx := this.hotstringCB.Length + 1
                    UserHotstring(this.hstrOpt, replace, by, this.defaultCB)
                    this.hotstringMap[replace] := [by, idx]
                    this.hotstringCB.Push([this.defaultCB, replace])
                    this.listView.Add(, replace, by)
                    if (this.defaultCB)
                        this.listView.Modify(idx, 'Check')
                    else
                        this.listView.Modify(idx, '-Check')
                }
                ; Edit Existed Hotstring
                else if (this.hotstringMap[replace][1] != by) {
                    idx := this.hotstringMap[replace][2]
                    UserHotstring(this.hstrOpt, replace, this.hotstringMap[replace][1], 0)
                    UserHotstring(this.hstrOpt, replace, by, GetState(idx))
                    this.hotstringMap[replace][1] := by
                    this.listView.Modify(idx, 'Col2', by)
                    if (this.hotstringCB[idx][1] = false) {
                        this.listView.Modify(idx, 'Check')
                        this.hotstringCB[idx][1] := true
                    }
                }
                DynamicButtonStates()
            }
            Del(replace, by) {
                if (this.hotstringMap.Has(replace) && this.hotstringMap[replace][1] = by) {
                    UserHotstring(this.hstrOpt, replace, by, 0)
                    idx := this.hotstringMap[replace][2]
                    this.hotstringMap.Delete(this.hotstringCB[idx][2])
                    for key, value in this.hotstringMap {
                        if (value[2] < idx)
                            continue
                        value[2] -= 1
                    }
                    this.hotstringCB.RemoveAt(idx)
                    this.listView.Delete(idx)
                }
                DynamicButtonStates()
            }
            ChooseFile(filePath := "") {
                if (filePath = "") {
                    fileChosen := FileSelect('S', this.defaultConfigPath, "Chọn File gõ tắt")
                    this.file.value := (fileChosen != "" ? fileChosen : this.defaultConfigPath)
                }
                else
                    this.file.value := filePath
                for key, value in this.hotstringMap {
                    UserHotstring(this.hstrOpt, key, value[1], 0)
                }
                this.case_sensitive := false
                this.conditions := []
                this.hotstringCB := []
                this.hotstringMap := Map()
                this.LoadConfig(this.file.value)
                this.listView.Delete()
                for key, value in this.hotstringMap {
                    this.listView.Add(, key, value[1])
                }
                if (this.defaultCB)
                    this.listView.Modify(0, "Check")
                else
                    this.listView.Modify(0, "-Check")
                SetupHotstring()
            }

        }
        SetupHotstring() {
            loop this.listView.GetCount() {
                idx := A_Index
                abb := this.listView.GetText(idx, 1)
                full := this.listView.GetText(idx, 2)
                UserHotstring(this.hstrOpt, abb, full, GetState(idx))
            }
        }
        GetState(RowNumber, *) {
            state := (SendMessage(0x102C, RowNumber - 1, 0xF000, this.listView) >> 12) - 1
            return state
        }
        SetupToolTips() {
        }
        DynamicButtonStates() {
            ; Pass the current values of the edit controls to EditCondition
            conditionResult := EditCondition(this.replace.value, this.by.value)
            EditCondition(replace, by) {
                if (replace != "" && by != "") {
                    if (!this.hotstringMap.Has(replace)) {
                        return 1
                    }
                    else if (this.hotstringMap[replace][1] != by) {
                        return 2
                    }
                    return 0
                }
                return -1
            }
            if (conditionResult = 1) {
                this.addBtn.Enabled := true
                this.addBtn.Visible := true ; Visible might be redundant if always visible, but okay if you use it for toggling
                this.editBtn.Enabled := false
                this.editBtn.Visible := false
                this.delBtn.Enabled := false
            }
            ; Edit Valid (conditionResult = 2)
            else if (conditionResult = 2) {
                this.addBtn.Enabled := false
                this.addBtn.Visible := false
                this.editBtn.Enabled := true
                this.editBtn.Visible := true
                this.delBtn.Enabled := false
            }
            ; Erase Valid / Edit Invalid (conditionResult = 0)
            else if (conditionResult = 0) {
                this.addBtn.Enabled := false
                this.addBtn.Visible := false
                this.editBtn.Enabled := false
                this.editBtn.Visible := true ; Keep editBtn visible even if invalid to show it's disabled
                this.delBtn.Enabled := true
            }
            ; Add Invalid (conditionResult = -1 or any other case)
            else { ; This covers the -1 case from EditCondition
                this.addBtn.Enabled := false
                this.addBtn.Visible := true ; Keep addBtn visible even if invalid
                this.editBtn.Enabled := false
                this.editBtn.Visible := false
                this.delBtn.Enabled := false
            }
        }
    }
    ; -----------------------------------------------------------------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    ; ----------------------------------------------Default------------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    ; -----------------------------------------------------------------------------------------------------
    ParseAll(options, args*) {
        if(options != "" || args.Length != 0)
            this.hasParse := true
        ParseOptions(options)
        ParseArgs(args*)
        return
        ParseOptions(options) {
            flags := {
                w: "(\d+)",
                h: "(\d+)",
                x: "(\d+)",
                y: "(\d+)",
            }
            for flag, regex in flags.OwnProps() {
                while RegExMatch(options, flag . "\{" . regex . "}", &Match) {
                    switch flag {
                        case "w": this.guiWidth := Match[1]
                        case "h": this.guiHeight := Match[1]
                        case "x": this.xPos := Match[1]
                        case "y": this.yPos := Match[1]
                    }
                    break
                }
            }
            if RegExMatch(options, "\b(?!w|h|x|y)(\w+)\{([^}]+)}", &match) {
                invalid_flag := match[1]
                invalid_value := match[2]
                TrayTip(":x: Invalid flag: `"" invalid_flag "`" with value: `"" invalid_value "`"",
                    ":x: Invalid flag detected!", 3)
                return
            }
        }
        ParseArgs(args*) {
            for index, arg in args {
                if (arg ~= "^p\{(.+)}(.+)$") {
                    key := RegExMatch(arg, "^p\{(.+)}(.+)$", &Match)
                    if (key) {
                        this.%Match[1]% := Match[2]
                    }
                } else {
                    TrayTip ":x: Invalid argument format in args."
                    OutputDebug ":x: Invalid argument format in args: " arg
                }
            }
        }
    }

    Show(options := "") {
        ShowOpts := "Restore "
        if (!this.hasParse) {
            if (this.xpos != 0)
                ShowOpts .= Format("x{} ", this.xpos)
            if (this.ypos != 0)
                ShowOpts .= Format("y{} ", this.ypos)
            if (this.guiWidth != 0)
                ShowOpts .= Format("w{} ", this.guiWidth)
            if (this.guiHeight != 0)
                ShowOpts .= Format("h{} ", this.guiHeight)
        }
        this.gui.Show(ShowOpts options)
    }

    Toggle() {
        if !WinExist("ahk_id " this.gui.hwnd)
            this.Show()
        else
            this.gui.Hide()
    }

}

UserHotstring(hstrOpt := "", abb := "", full := "", state := -1) {
    Hotstring(':' hstrOpt ':' abb, full, state)
}

; F2:: {
;     input := InputBox("this.GetState of: ")
;     abb := macro.listView.GetText(input.value, 1)
;     full := macro.listView.GetText(input.value, 2)
;     status := macro.GetState(input.value)
;     notify := Format("[{}] {}::{}", status, abb, full)
;     ToolTip(notify)
;     SetTimer(Tooltip, -3000)
; }

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
if (A_IsCompiled) {
    A_TrayMenu.Insert("&Suspend Hotkeys", "Reload Script", (*) => Reload())
    A_TrayMenu.Insert("&Suspend Hotkeys", "Edit Script", (*) => Run("*edit " "C:\Users\jackb\Documents\AutoHotkey\src\v2\Hotstring.ahk"
    ))
    A_TrayMenu.Insert("&Suspend Hotkeys")
}
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "&Open File Location", (*) => Run("*open " "C:\Users\jackb\Documents\AutoHotkey\src\v2\"))
A_TrayMenu.SetIcon("&Open File Location", "C:\Windows\System32\shell32.dll", 4)
A_TrayMenu.Insert("E&xit", "&Show/&Hide", (*) => macro.Toggle())
A_TrayMenu.SetIcon("&Show/&Hide", "C:\Users\jackb\Documents\AutoHotkey\icon\exchange.ico")
A_TrayMenu.Default := "&Show/&Hide"
A_TrayMenu.ClickCount := 1