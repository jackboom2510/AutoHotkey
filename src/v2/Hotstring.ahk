#SingleInstance Force
Persistent

#include <core\Log>
#Include <core\KeyBinding>
;@Ahk2Exe-SetMainIcon exchange.ico

class HotstringUI {
    gui := unset
    name := "Macro"
    guiOpts := "AlwaysOnTop"
    isAlwaysOnTop := true
    guiPos := {
        x: 1,
        y: 1,
        w: 0,
        h: 0
    }
    transparency := {
        value: 255,
        min: 1,
        max: 255,
        step: 15
    }
    defaultConfigPath := "C:\Users\jackb\Documents\AutoHotkey\configs\hotstring.config"
    defaultCheckboxState := true
    case_sensitive := false
    hstrOpts := ['', 'T', 'T*', 'ST', 'ST*', '*', 'More...']
    hstrOpt := "ST*"

    __New(options := "", args*) {
        if (this.hasProp("guiID")) {
            if WinExist("ahk_class AutoHotkeyGUI ahk_id " this.guiID) {
                return
            }
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.guiID := this.gui.Hwnd
        this.gui.SetFont("s10", "Arial")
        this.gui.BackColor := "ecffff"
        this.settings := Map()
        this.outline := Object
        this.hotstringMap := Map()
        this.hotstringCB := []

        this.LoadConfig()
        this.allOn := this.defaultCheckboxState
        for idx, val in this.hstrOpts {
            if (idx = this.hstrOpts.Length)
                break
            if (this.case_sensitive)
                this.hstrOpts[idx] := 'C1 ' this.hstrOpts[idx]
        }
        this.SetupControls()
        this.SetupEvents()
        this.SetupHotstring()
        this.DynamicButtonStates()

        this.ParseAll(options, args*)
        this.Show()

        WinSetTransColor(this.gui.BackColor, this.name)
        WinSetTransparent(this.transparency.value, this.name)
        ; OnMessage(0x0200, On_WM_MOUSEMOVE)
        ; OnMessage(0x4E, On_WM_NOTIFY)
        ; OnMessage(0x0216, On_WM_MOVING)
        On_WM_NOTIFY(wParam, lParam, Msg, Hwnd) {
            UDN_DELTAPOS := -722
            is64Bit := (A_PtrSize = 8)

            NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
            DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

            hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
            code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
            delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

            if (hwndFrom = this.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
                newVal := this.transparencyUpDown.Value + delta * this.transparency.step
                newVal := Min(Max(newVal, this.transparency.min), this.transparency.max)
                this.transparencyUpDown.Value := newVal
                this.transparency.value := newVal
                WinSetTransparent this.transparency.value, this.name
                return true
            }
        }
        On_WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
            PrevHwnd := 0
            if (Hwnd != PrevHwnd) {
                Text := ""
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
        On_WM_MOVING(wParam, lParam, Msg, Hwnd) {
            left := Numget(lParam, "INT")
            top := Numget(lParam + 4, "INT")
            right := Numget(lParam + 8, "INT")
            bot := Numget(lParam + 12, "INT")
            this.guiPos.x := left
            this.guiPos.y := top
            this.guiPos.w := right - left
            this.guiPos.h := top - bot
            return true
        }

    }
    OriginalLoadConfig(configPath := this.defaultConfigPath) {
        idx := 1
        loop parse FileRead(configPath, "UTF-8"), '`n', '`r' {
            if RegExMatch(A_LoopField, '^\*\*\*(.*)\*\*\*') {
                RegExMatch(A_LoopField, '^\*\*\*(.*)\*\*\*', &setting)
                setting := StrSplit(setting[1], ':', , 2)
                this.%setting[1]% := (setting[2] = "true") || (setting[2] = "1")
                this.settings[setting[1]] := setting[2]
                continue
            }
            try {
                text := A_LoopField
                if (text != "") {
                    pair := StrSplit(text, ':', , 2)
                    this.hotstringMap[pair[1]] := [pair[2], idx]
                    this.hotstringCB.Push([this.defaultCheckboxState, pair[1]])
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
    LoadConfig(configPath := this.defaultConfigPath) {
        idx := 1
        fileContent := FileRead(configPath, "UTF-8")
        lines := StrSplit(fileContent, '`n', '`r')

        i := 1
        while i <= lines.Length {
            currentLine := lines[i]
            if (Trim(currentLine) = "") {
                i++
                continue
            }
            if RegExMatch(currentLine, '^\*\*\*(.*)\*\*\*') {
                RegExMatch(currentLine, '^\*\*\*(.*)\*\*\*', &setting)
                setting := StrSplit(setting[1], ':', , 2)
                this.%setting[1]% := (setting[2] = "true") || (setting[2] = "1") ? true : setting[2]
                this.settings[setting[1]] := setting[2]
                i++
                continue
            }
            try {
                pair := StrSplit(currentLine, ':', , 2)
                if (pair.Length < 2) {
                    i++
                    continue
                }

                hotstringTrigger := pair[1]
                hotstringReplacement := pair[2]
                if (Trim(hotstringReplacement) = "(") {
                    multiLineContent := []
                    i++

                    while (i <= lines.Length) {
                        nextLine := lines[i]
                        if (Trim(nextLine) = "") {
                            i++
                            continue
                        }
                        if (Trim(nextLine) = ")") {
                            break
                        }
                        multiLineContent.Push(nextLine)
                        i++
                    }
                    if (i > lines.Length) {
                        errMsg := "Lỗi: Hotstring nhiều dòng cho '" hotstringTrigger "' không được đóng bằng ')'."
                        TrayTip("Tệp cấu hình sai! Thử lại!", errMsg, 3)
                        return
                    }
                    hotstringReplacement := ''
                    for contend_idx, content in multiLineContent {
                        hotstringReplacement .= content
                        if (contend_idx < multiLineContent.Length)
                            hotstringReplacement .= '`n'
                    }
                }
                this.hotstringMap[hotstringTrigger] := [hotstringReplacement, idx]
                this.hotstringCB.Push([this.defaultCheckboxState, hotstringTrigger])
                idx := idx + 1
            }
            catch as err {
                errMsg := "Lỗi: " err.Message
                TrayTip("Tệp cấu hình sai! Thử lại!`nLỗi khi đọc dòng " i ': "' currentLine '"', errMsg, 3)
                return
            }
            i++
        }
    }
    SetupControls(controlOpts := "") {
        this.gui.AddText(controlOpts 'w95 xm+5', "&Thay thế:")
        this.gui.AddText(controlOpts 'w385 yp', "&Bởi:")
        this.gui.AddText(controlOpts 'w95 x+10 yp', "&Cài đặt")
        this.replace := this.gui.AddEdit(controlOpts 'w90 xm+5 r2 VScroll')
        this.by := this.gui.AddEdit(controlOpts "w390 yp r2 VScroll")
        this.opts := this.gui.AddDropDownList(controlOpts "w105 yp vopts Choose2", this.hstrOpts)
        this.hstrOpt := this.opts.text
        this.SetupUpListView

        this.saveBtn := this.gui.AddButton(controlOpts 'w100 yp', "&Lưu")

        this.stopBtn := this.gui.AddButton(controlOpts 'w100 y+25', "&Ngừng")
        this.resetBtn := this.gui.AddButton(controlOpts 'w100', "Đặt &lại")
        this.addBtn := this.gui.AddButton(controlOpts 'w100 y+25', "&Thêm")
        this.editBtn := this.gui.AddButton(controlOpts 'w100 xp yp', "&Sửa")
        this.delBtn := this.gui.AddButton(controlOpts 'w100', "&Xóa")

        this.gui.AddText('xm y+10', 'View Mode').SetFont('italic')
        this.lv_viewMode := this.gui.AddDDL('x+10 yp-5 w80 Choose1', ['Default', 'List', 'Icon', 'Icon Small'])
        ; this.lv_filterBy := this.gui.AddDDL('x+10 yp-5 w100 Choose1', ['Default', 'List', 'Icon', 'Icon Small'])
        this.lv_filter := this.gui.AddDDL('x+10 yp w80 Choose1', ['All', 'Text', 'Fucntion'])
        this.lv_search := this.gui.AddEdit('yp w250 r1', 'Search')
        this.lv_search.SetFont('italic')

        this.caseSen := this.gui.AddCheckbox(controlOpts 'xm', "Tự động đổi chữ hoa theo phím tắt")
        this.caseSen.Value := this.case_sensitive
        this.gui.AddText(controlOpts 'w400', "(Định nghĩa: vn=việt nam, Auto: VN=VIỆT NAM, Vn=Việt nam)").SetFont(
            'italic')
        this.gui.AddText(controlOpts 'w70', "File gõ tắt:")
        this.file := this.gui.AddText(controlOpts "yp", this.defaultConfigPath)
        this.gui.AddEdit("w60 xm y+8 Right")
        this.transparencyUpDown := this.gui.AddUpDown("Range" this.transparency.min "-" this.transparency.max,
            this.transparency.value)
        this.chooseFileBtn := this.gui.AddButton(controlOpts 'w150 x+22 yp-2', "Chọn &File...")
        this.defaultFile := this.gui.AddButton(controlOpts 'w150 x+22 yp', "File &mặc định")
        this.editConfigFileBtn := this.gui.AddButton(controlOpts 'w150 x+23 yp', '&Mở File')
    }
    SetupIML(capacity := 2, iconPath := "C:\Users\jackb\Documents\AutoHotkey\assets\icon\") {
        this.ImageListID := IL_Create(2)
        IL_Add(this.ImageListID, iconPath 'text.ico')
        IL_Add(this.ImageListID, iconPath 'function.ico')
    }
    SetupUpListView() {
        this.SetupIML()

        this.listView := this.gui.AddListView(
            'xm w500 r10 Checked -Hdr -Multi', ['1', '2']
        )
        this.listView.SetImageList(this.ImageListID)
        for key, value in this.hotstringMap
            this.AddLV(key, value[1])
        if (this.defaultCheckboxState)
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
            this.DynamicButtonStates()
        }
        LV_ContextMenu(LV, Item, IsRightClick, X, Y) {
            if (!IsRightClick)
                return
            A_Clipboard := LV.GetText(Item, 2)
            TrayTip("Đã copy " A_Clipboard " vào Clipboard!")
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
    SetupEvents() {
        this.gui.OnEvent("Escape", (*) => PromptToSaveOnExit())
        this.gui.OnEvent("Size", On_Minimize)
        this.replace.OnEvent('Change', (*) => this.DynamicButtonStates())
        this.by.OnEvent('Change', (*) => this.DynamicButtonStates())
        this.opts.OnEvent('Change', (*) => UpdateOpts())
        this.saveBtn.OnEvent('Click', (*) => SaveConfig())
        this.stopBtn.OnEvent('Click', (*) => this.StopAll())
        this.resetBtn.OnEvent("Click", (*) => this.ResetAll())
        this.editBtn.OnEvent("Click", (*) => this.Edit(this.replace.value, this.by.value))
        this.addBtn.OnEvent("Click", (*) => this.Edit(this.replace.value, this.by.value))
        this.delBtn.OnEvent("Click", (*) => Del(this.replace.value, this.by.value))
        this.caseSen.OnEvent("Click", (*) => On_CaseSenChanged(this.caseSen.value))
        this.chooseFileBtn.OnEvent("Click", (*) => ChooseFile())
        this.defaultFile.OnEvent("Click", (*) => ChooseFile(this.defaultConfigPath))
        this.editConfigFileBtn.OnEvent("Click", (*) => Run(this.file.value))
        return
        On_Minimize(myGui, MinMax, Width, Height) {
            if (MinMax = -1) {
                myGui.Hide()
                return
            }
        }
        PromptToSaveOnExit(filePath := this.defaultConfigPath) {
            if (A_IsCompiled)
                inp_height := 150
            else
                inp_height := 100
            inp_x := this.guiPos.x + this.guiPos.w
            inp_y := this.guiPos.y
            if (inp_x > A_ScreenWidth)
                inp_x := this.guiPos.x - 250
            inp := InputBox("Bạn có muốn lưu Macros không?", , 'w250 h' inp_height ' x' inp_x ' y' inp_y ' t5', 'Y')
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
            ExitApp()
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
                            UserHotstring(this.opts.Text, abb, full, this.GetState(i))
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
                UserHotstring(this.opts.Text, abb, full, this.GetState(idx))
            }
            this.hstrOpt := this.opts.Text
        }
        On_CaseSenChanged(Checked) {
            selectedIdx := this.opts.value
            for idx, val in this.hstrOpts {
                if (idx = this.hstrOpts.Length)
                    break
                if (Checked)
                    this.hstrOpts[idx] := 'C1 ' this.hstrOpts[idx]
                else
                    this.hstrOpts[idx] := RegExReplace(this.hstrOpts[idx], '(.*)\s(.*)', '$2')
            }
            this.opts.Delete()
            this.opts.Add(this.hstrOpts)
            this.opts.Choose(selectedIdx)
            loop this.listView.GetCount() {
                idx := A_Index
                abb := this.listView.GetText(idx, 1)
                full := this.listView.GetText(idx, 2)
                UserHotstring(this.hstrOpt, abb, full, 0)
                UserHotstring(this.opts.Text, abb, full, this.GetState(idx))
            }
            this.hstrOpt := this.opts.Text
        }
        SaveConfig(filePath := this.defaultConfigPath) {
            erf(filePath)
            for key, value in this.settings {
                setting := Format('***{}:{}***', key, value)
                WriteFile(filePath, setting, 0, 'l')
            }
            loop this.listView.GetCount() {
                hstr := this.listView.GetText(A_index, 1) ":" this.listView.GetText(A_Index, 2)
                WriteFile(filePath, hstr, 0, 'l')
            }
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
            this.DynamicButtonStates()
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
            for key, value in this.hotstringMap
                this.AddLV(key, value[1])
            if (this.defaultCheckboxState)
                this.listView.Modify(0, "Check")
            else
                this.listView.Modify(0, "-Check")
            this.SetupHotstring()
        }

    }
    SetupHotstring() {
        loop this.listView.GetCount() {
            idx := A_Index
            abb := this.listView.GetText(idx, 1)
            full := this.listView.GetText(idx, 2)
            UserHotstring(this.hstrOpt, abb, full, this.GetState(idx))
        }
    }
    AddLV(abb := "", full := "") {
        if (RegExMatch(full, '^%'))
            iconIdx := 2
        else
            iconIdx := -1
        this.listView.Add('Icon' iconIdx, abb, full)
    }
    GetState(RowNumber, *) {
        state := (SendMessage(0x102C, RowNumber - 1, 0xF000, this.listView) >> 12) - 1
        return state
    }
    DynamicButtonStates() {
        replace := this.replace.value
        by := this.by.value

        isEmpty := (replace = "" || by = "")
        existsAndMatches := (!isEmpty && this.hotstringMap.Has(replace) && this.hotstringMap[replace][1] = by)
        existsAndDiffers := (!isEmpty && this.hotstringMap.Has(replace) && this.hotstringMap[replace][1] != by)
        notExists := (!isEmpty && !this.hotstringMap.Has(replace))

        this.addBtn.Enabled := false
        this.addBtn.Visible := false
        this.editBtn.Enabled := false
        this.editBtn.Visible := false
        this.delBtn.Enabled := false

        if (notExists) {
            this.addBtn.Enabled := true
            this.addBtn.Visible := true
        } else if (existsAndDiffers) {
            this.editBtn.Enabled := true
            this.editBtn.Visible := true
            this.addBtn.Visible := true
        } else if (existsAndMatches) {
            this.delBtn.Enabled := true
            this.editBtn.Visible := true
            this.addBtn.Visible := true
        } else {
            this.addBtn.Visible := true
            this.editBtn.Visible := true
        }
    }
    Edit(replace, by) {
        ; Add New Hotstring
        if (!this.hotstringMap.Has(replace)) {
            idx := this.hotstringCB.Length + 1
            UserHotstring(this.hstrOpt, replace, by, 1)
            this.hotstringMap[replace] := [by, idx]
            this.hotstringCB.Push([true, replace])
            this.AddLV(replace, by)
            this.listView.Modify(idx, 'Check')
        }
        ; Edit Existed Hotstring
        else if (this.hotstringMap[replace][1] != by) {
            idx := this.hotstringMap[replace][2]
            UserHotstring(this.hstrOpt, replace, this.hotstringMap[replace][1], 0)
            UserHotstring(this.hstrOpt, replace, by, this.GetState(idx))
            this.hotstringMap[replace][1] := by
            this.listView.Modify(idx, 'Col2', by)
            if (this.hotstringCB[idx][1] = false) {
                this.listView.Modify(idx, 'Check')
                this.hotstringCB[idx][1] := true
            }
        }
        this.DynamicButtonStates()
    }
    PromptAddHotstring() {
        inp := InputBox("Nhập phím tắt mới:", , 'w100 h100')
        if (inp.Result = 'Ok') {
            if (RegExMatch(inp.value, '(?P<abb>.*):(?P<full>.*)', &inp)) {
                this.Edit(inp.abb, inp.full)
                TrayTip('Đã thêm phím tắt ' inp[0])
            }
            else {
                TrayTip('Cú pháp không hợp lệ: "' inp.value '"`n Xin vui lòng thử lại sau!', "Lỗi!", 3)
            }
            return
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
    ParseAll(options, args*) {
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
                        case "w": this.guiPos.w := Match[1]
                        case "h": this.guiPos.h := Match[1]
                        case "x": this.guiPos.x := Match[1]
                        case "y": this.guiPos.y := Match[1]
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
        displayOptions := "Restore "
        if (this.guiPos.x != 0)
            displayOptions .= Format("x{} ", this.guiPos.x)
        if (this.guiPos.y != 0)
            displayOptions .= Format("y{} ", this.guiPos.y)
        if (this.guiPos.w != 0)
            displayOptions .= Format("w{} ", this.guiPos.w)
        if (this.guiPos.h != 0)
            displayOptions .= Format("h{} ", this.guiPos.h)
        this.gui.Show(displayOptions options)
    }

    Toggle() {
        if !WinExist("ahk_id " this.gui.hwnd)
            this.Show()
        else
            this.gui.Hide()
    }
    ToggleAOT() {
        if (this.isAlwaysOnTop = true) {
            this.gui.Opt("-AlwaysOnTop")
            this.gui.Opt("-Border")
        }
        else {
            this.gui.Opt("+AlwaysOnTop")
            loop 3
                this.gui.OPt('Border')
        }
        A_TrayMenu.ToggleCheck("AlwaysOnTop")
        this.isAlwaysOnTop := !this.isAlwaysOnTop
    }
    ToggleAllHotstring() {
        if (this.allOn) {
            SoundBeep(200, 100)
            ToolTip("Phím tắt đã tắt!")
            SetTimer(ToolTip, -1500)
            this.StopAll()
        }
        else {
            SoundBeep(1000, 100)
            ToolTip("Phím tắt đã bật!")
            SetTimer(ToolTip, -1500)
            this.ResetAll()
        }
        this.allOn := !this.allOn
    }
}

UserHotstring(hstrOpt := "", abb := "", full := "", state := -1) {
    if (InStr(full, "%")) {
        RegExMatch(full, '^%\s*(?P<funcExp>.*)', &fn)
        full := fn.funcExp
        ; _wl("Đã gán thành công hotstring [" state "] :" hstrOpt ":" abb "::" full)
        ; Outputdebug("Đã gán thành công hotstring [" state "] :" hstrOpt ":" abb "::" full)
        Hotstring(':' hstrOpt ':' abb, (*) => RunParsedCode(full), state)
    }
    else
        Hotstring(':' hstrOpt ':' abb, full, state)
    return
}
RunParsedCode(expr, *) {
    tempFile := 'C:\Users\jackb\Documents\AutoHotkey\temp' "\run_temp.ahk"
    fileObj := FileOpen(tempFile, 'w', 'UTF-8')
    code := Format("
    (
    run_expr() {
        {}
        return
    }
    run_expr()
    )", expr)
    fileObj.Write(code)
    fileObj.Close()
    RunWait(A_AhkPath " /script " tempFile)
    TrayTip("Chạy thành công tập lệnh:`n" expr)
    Sleep(1000)
}

macro := HotstringUI()
BindingScript()

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
A_TrayMenu.Insert('&Suspend Hotkeys', 'Recompile Script', (*) => (
    Run(
        'cmd /c ""C:\Users\jackb\Documents\AutoHotkey\bin\build\ahk2exe-compile.bat" "C:\Users\jackb\Documents\AutoHotkey\src\v2\Hotstring.ahk" & pause"'
    ),
    TrayTip('Compile Success: Hotstring.ahk', 'Success!', 1)
))
if (A_IsCompiled) {
    A_TrayMenu.Insert("&Suspend Hotkeys", "Reload Script", (*) => Reload())
    A_TrayMenu.Insert("&Suspend Hotkeys", "Edit Script", (*) => Run("*edit " "C:\Users\jackb\Documents\AutoHotkey\src\v2\Hotstring.ahk"
    ))
    A_TrayMenu.Insert("&Suspend Hotkeys")
}
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "&Open File Location", (*) => Run("*open " "C:\Users\jackb\Documents\AutoHotkey\src\v2\"))
A_TrayMenu.SetIcon("&Open File Location", "shell32.dll", 4)
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys(, , 4))
A_TrayMenu.SetIcon("Show Hotkeys", "shell32.dll", 24)
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "&Show/&Hide", (*) => macro.Toggle())
A_TrayMenu.SetIcon("&Show/&Hide", "C:\Users\jackb\Documents\AutoHotkey\assets\icon\exchange.ico")
A_TrayMenu.Insert("E&xit", "AlwaysOnTop", (*) => macro.ToggleAOT())
A_TrayMenu.Check("AlwaysOnTop")

A_TrayMenu.Default := "&Show/&Hide"
A_TrayMenu.ClickCount := 1