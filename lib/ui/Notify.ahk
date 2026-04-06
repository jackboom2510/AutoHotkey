#Include <core\Core>
#Include <util\ColorProps>
/**
 * Class Notify
 * ---------------------
 * @description Hiển thị thông báo nổi với nhiều tùy chọn (timeout, màu nền, status bar, info, âm thanh...).
 * @param {(String)} what          Nội dung thông báo chính.
 * @param {(String)} title         Tiêu đề cửa sổ (mặc định: `A_ScriptName`).
 * @param {(String)} setupFlags    Các flag cấu hình (vd: `t10`, `cE0FFFF`, `sb{opt}{content}`, `before`, `after`...).
 * ### Flags đặc biệt
 * |   | Flag                |   | Ý nghĩa                                                            |
 * |---|:-------------------:|---|--------------------------------------------------------------------|
 * |   | `t#`                |   | Timeout `#` giây (`t0` = không tự đóng)                              |
 * |   | `c#`                |   | Màu nền (hex hoặc alias: `ci`, `cw`, `ce`)                         |
 * |   | `sb` / `info`       |   | Hiển thị status bar hoặc info bar (`sb{opt}{text}`, `sb{}{text}`)  |
 * |   | `(r)eturn (b)efore` |   | Gọi `BeforeSetup()`, thêm nút/trước nội dung                       |
 * |   | `(a)fter`           |   | Gọi `AfterSetup()`, thêm nút/sau nội dung                         |
 * |   | `(s)ound`           |   | Phát âm thanh thông báo                                            |
 * |   | `(w)ait`            |   | Chờ hết timeout trước khi tiếp tục script                         |
 * @param {(String)} options       Tuỳ chọn hiển thị Gui.Show().
 * @param {(Any*)}   args          Tham số mở rộng (chưa dùng).
 */
class Notify {
    ; =================================================================
    ; 🧠 STATIC PROPERTIES - Quản lý Hàng đợi và Màn hình
    ; =================================================================
    static Queue := []
    static MaxColsPerMonitor := Map()
    static MaxMonitors := 2
    static ColWidth := 500

    static MAX_LINE_CONTENT := 30
    static _PrototypeBackup := {}

    ; =================================================================
    ; ⚙️ INSTANCE PROPERTIES
    ; =================================================================
    gui := unset
    guiID := ''
    guiOpts := '+AlwaysOnTop +ToolWindow'
    defaultWidth := 500
    defaultFont := [
        's12',
        'Cascadia Code'
    ]
    defaultTitleFont := [
        's14 bold',
        'Cascadia Code'
    ]
    defaultBackgroundColor := '333333'
    defaultSetupFlags := 'ra rb rin t10 c333333 q1 hoverpause'
    transparencyValue := 225
    charLimit := 50
    timeout := 10

    hasInit := false
    hasAfter := false
    hasBefore := false

    monitorIndex := 1
    columnIndex := 0
    fullPromt := ''
    data := Map()

    ; =================================================================
    ; 📌 HELPER: Xử lý nội dung StatusBar
    ; =================================================================
    ; Hàm riêng biệt để thực hiện logic truy cập biến/hằng số, tránh lỗi cú pháp trong Notify
    ; Tên biến đổi thành 'c' và 'e' để tránh xung đột
    ; static ResolveStatusBarContent(content) {
    ;     if (SubStr(content, 1, 1) = "$") {
    ;         varName := SubStr(content, 2)

    ;         ; Tạo hàm tạm thời để chạy lệnh Run-time
    ;         RunTimeVar := %varName%.()
    ;         if (IsObject(RunTimeVar)) {
    ;             return RunTimeVar.Call() ; Thực thi để lấy giá trị biến
    ;         }
    ;         return "[Undefined: " varName "]"
    ;     }
    ;     return content
    ; }

    ; =================================================================
    ; 🚀 CONSTRUCTOR VÀ LOGIC CHÍNH
    ; =================================================================

    __New(what := "", title := A_ScriptName, setupFlags := "", options := "", args*) {
        Notify.InitializeQueue()
        setupFlags := this.MergeFlags(setupFlags, this.defaultSetupFlags)
        ; this.setupFlags := setupFlags
        if RegExMatch(setupFlags, "\br?(init|in)\b") {
            this.hasInit := true
            if !Notify.HasOwnProp("_PrototypeBackup") {
                Notify._PrototypeBackup := {}
                for name, value in Notify.Prototype.OwnProps() {
                    if IsObject(value)
                        Notify._PrototypeBackup[name] := value.Clone()
                    else
                        Notify._PrototypeBackup[name] := value
                }
            }
            this.InitSetup()
            if (RegExMatch(setupFlags, "\br(b|before)\b"))
                Notify.Prototype.DefineProp("InitSetup", { Call: (*) => {} })
        }
        if RegExMatch(setupFlags, "\bt(\d+(\.\d+)?)\b", &m)
            this.timeout := m[1]
        this.hoverPause := RegExMatch(setupFlags, "\bhoverpause\b")

        if RegExMatch(setupFlags, "\bc(\w+(\.\w+)?)\b", &m)
            this.defaultBackgroundColor := m[1]

        this.fullPromt := what
        if (args.Length > 0)
            this.data := (args.Length == 1) ? args[1] : args
        this.SetPosition()
        queue := Notify.Queue[this.monitorIndex][this.columnIndex]
        if (queue.Length > 0) {
            if (this.queueMode = 1) {
                old := queue.Pop()
                old.gui.Destroy()
                queue.Push(this)
                this.ConstructGui(what, title, setupFlags, options, this.data)
            }
            else
                queue.Push(this)
        }
        else {
            queue.Push(this)
            this.ConstructGui(what, title, setupFlags, options, this.data)
        }
    }

    ConstructGui(what, title, setupFlags, options, data) {

        if (this.guiID && WinExist('ahk_class AutoHotkeyGUI ahk_id ' this.guiID)) {
            return
        }

        if (this.timeout >= 1)
            this.guiOpts .= " -Caption"
        else
            this.timeout *= 100

        this.notificationTimer := this.timeout * 1000
        this.gui := Gui(this.guiOpts, title)
        this.guiID := this.gui.Hwnd
        this.gui.SetFont(this.defaultFont*)
        this.gui.BackColor := this.defaultBackgroundColor

        wrappedText := this.WordWrap(what, this.defaultWidth / 10)
        lines := StrSplit(wrappedText, '`n')
        this.lineCount := lines.Length
        if (this.lineCount > Notify.MAX_LINE_CONTENT) {
            this.vscroll_on := true
        }
        else {
            this.vscroll_on := false
        }
        autoHeight := this.lineCount * 20

        this.guiPos := { w: this.defaultWidth, h: autoHeight }

        ; Tái tạo Controls
        this.SetupControls(title, wrappedText, setupFlags)

        if (RegExMatch(setupFlags, '\b(s|sound)\b'))
            SoundPlay("D:\Downloads\Music\mixkit-positive-notification-951.wav")

        this.Show("NoActivate Autosize" options)

        this.gui.OnEvent('Close', this.OnClose.Bind(this))
        this.gui.OnEvent('Escape', this.OnClose.Bind(this))

        OnMessage(0x0200, ObjBindMethod(this, "On_WM_MOUSEMOVE"))
        try WinSetTransColor(this.defaultBackgroundColor, title)
        try WinSetTransparent(this.transparencyValue, title)

        if (this.timeout != 0)
            SetTimer(this._TryAutoClose.Bind(this), -this.timeout * 1000)
        if RegExMatch(setupFlags, "\br(init|in)\b") {
            if Notify.HasOwnProp("_PrototypeBackup") {
                for name, _ in Notify.Prototype.OwnProps() {
                    Notify.Prototype.DeleteProp(name)
                }
                for name, value in Notify._PrototypeBackup.OwnProps() {
                    if IsObject(value)
                        Notify.Prototype.DefineProp(name, { Value: value.Clone() })
                    else
                        Notify.Prototype.DefineProp(name, { Value: value })
                }
            }
        }
        if (RegExMatch(setupFlags, '\b(w|wait)\b') && this.timeout != 0)
            Sleep(this.notificationTimer + 500)
    }

    ; =================================================================
    ; 🎯 STATIC METHODS
    ; =================================================================

    static InitializeQueue() {
        if (Notify.Queue.Length > 0)
            return
        MonitorCount := (SysGet(80) >= 2) ? 2 : 1
        loop MonitorCount {
            monitorIdx := A_Index
            MonitorGet(monitorIdx, &x, &y, &w, &h)
            dpiScale := A_ScreenDPI / 96

            maxCols := Floor(w / (Notify.ColWidth * dpiScale))

            Notify.Queue.Push([])
            ; Notify.Queue[monitorIdx] := []
            loop maxCols {
                Notify.Queue[monitorIdx].Push([])
            }
            Notify.MaxColsPerMonitor[monitorIdx] := maxCols
        }
    }

    static ProcessNextInQueue(monitorIdx, colIdx) {
        queue := Notify.Queue[monitorIdx][colIdx]
        if (queue.Length > 0)
            queue.RemoveAt(1)
        if (queue.Length = 1 && queue[1].queueMode = 1) {
            next := queue[1]
            next.ConstructGui(
                next.fullPromt,
                next.gui.Title,
                next.defaultSetupFlags,
                "",
                next.data
            )
            return
        }
        if (queue.Length > 0) {
            next := queue[1]
            next.ConstructGui(
                next.fullPromt,
                next.gui.Title,
                next.defaultSetupFlags,
                "",
                next.data
            )
        }
    }

    /** @description Tìm vị trí cột trống đầu tiên (từ phải sang trái). */
    SetPosition() {
        MonitorCount := (SysGet(80) >= 2) ? 2 : 1
        if (MonitorCount > 1) {
            MouseGetPos(&mx, &my)
            monitorIdx := (mx >= 0 && mx <= A_ScreenWidth && my >= 0 && my <= A_ScreenHeight) ? 1 : 2
        } else {
            monitorIdx := 1
        }

        maxCols := Notify.MaxColsPerMonitor.Has(monitorIdx) ? Notify.MaxColsPerMonitor[monitorIdx] : 1
        found := false
        loop maxCols {
            colIdx := A_Index
            if (Notify.Queue[monitorIdx][colIdx].Length == 0) {
                this.monitorIndex := monitorIdx
                this.columnIndex := colIdx
                found := true
                break
            }
        }
        if (!found) {
            this.monitorIndex := monitorIdx
            this.columnIndex := 1
        }
    }

    Show(options := '') {
        MonitorCount := (SysGet(80) >= 2) ? 2 : 1
        old_coordmode_mouse := A_CoordModeMouse
        CoordMode('Mouse', 'Window')
        if (MonitorCount > 1) {
            MouseGetPos(&mx, &my)
            monitorIdx := (mx >= 0 && mx <= A_ScreenWidth && my >= 0 && my <= A_ScreenHeight) ? 2 : 1
        } else {
            monitorIdx := 1
        }
        CoordMode('Mouse', old_coordmode_mouse)
        MonitorGet(monitorIdx, &x_start, &y_start, &x_end, &y_end)
        ; MonitorGet(1, &x_start, &y_start, &x_end, &y_end)
        w_monitor := x_end - x_start
        h_monitor := y_end - y_start

        dpiScale := monitorIdx == 1 ? (125 / 96) : (100 / 96)
        scaledWidth := this.guiPos.w * dpiScale
        scaledHeight := this.guiPos.h * dpiScale
        bottomMargin := 10 * dpiScale
        ; sideMargin := 20 * dpiScale    ; Lề bên phải (Khoảng cách từ Cột 1 đến mép màn hình)
        sideMargin := 10 * dpiScale
        columnSpacing := 10 * dpiScale
        stackMargin := 20 * dpiScale
        ; Tính toán vị trí X (Xếp theo CỘT NGANG, 1 = Phải nhất)
        ; Công thức: Vị trí bắt đầu X của màn hình + Chiều rộng màn hình
        ;           - (Chiều rộng cột * columnIndex)
        ;           - (Khoảng cách tích lũy giữa các cột: columnSpacing * (columnIndex - 1))
        ;           - (Lề bên phải cho toàn bộ khối cột: sideMargin)
        xPos := x_start + w_monitor
            - (scaledWidth * this.columnIndex)
            - (columnSpacing * (this.columnIndex - 1))
            - sideMargin
        currentQueue := Notify.Queue[monitorIdx][this.columnIndex]

        stackHeight := 0

        for i, item in currentQueue {
            if (item == this) {
                break
            }

            stackHeight += (item.guiPos.h * dpiScale) + stackMargin
        }

        yPos := y_start + h_monitor - scaledHeight - bottomMargin - stackHeight
        if (this.timeout = 0) {
            xPos -= 30 * dpiScale
            yPos -= 40 * dpiScale
        }

        ShowOpts := Format('x{} y{} w{} h{} ', xPos, yPos, scaledWidth, scaledHeight)
        this.gui.Show(ShowOpts options)
    }

    OnClose(*) {
        if (this.gui) {
            if(this.timeout != 0)
              SetTimer(this._TryAutoClose.Bind(this), 0)
            this.guiID := 0
            this.gui.Destroy()
        }
        Notify.ProcessNextInQueue(this.monitorIndex, this.columnIndex)
    }

    _TryAutoClose() {
        if (!this.guiID || !this.gui || this.guiID = 0)
            return
        if (!this.hoverPause) {
            this.OnClose()
            return
        }
        this.gui.GetPos(, , &w, &h)
        sw := A_ScreenWidth
        sh := A_ScreenHeight
        if (w * h >= sw * sh * 0.8) {
            this.OnClose()
            return
        }
        MouseGetPos , , &winId
        if (winId = this.guiID)
            SetTimer(this._WaitMouseLeave.Bind(this), 50)
        else
            this.OnClose()
    }
    
    _WaitMouseLeave() {
        MouseGetPos( , , &winId)
        if (winId != this.guiID) {
            SetTimer(this._WaitMouseLeave.Bind(this), 0)
            this.OnClose()
        }
    }

    MergeFlags(setupFlags, defaultSetupFlags) {
        if (setupFlags = "")
            return defaultSetupFlags
        if (SubStr(setupFlags, 1, 1) != "+")
            return setupFlags
        setupFlags := Trim(SubStr(setupFlags, 2))
        input := []
        pattern := "([^\s{}]+(?:\{[^}]*\}(?:\{[^}]*\})?)?)"
        pos := 1
        while RegExMatch(setupFlags, pattern, &m, pos) {
            input.Push(m[1])
            pos := m.Pos + m.Len
        }

        defaultFlags := StrSplit(defaultSetupFlags, " ", " `t")
        final := Map()
        hasT := false
        hasC := false

        specialColors := Map(
            "cwarn", "cffd586", "cerror", "cca5454", "cinfo", "c88ff88",
            "cw", "cffd586", "ce", "cca5454", "ci", "c88ff88"
        )

        conflicts := Map(
            "a", [
                "ra"
            ], "ra", [
                "a"
            ],
            "b", [
                "rb"
            ], "rb", [
                "b"
            ],
            "in", [
                "rin"
            ], "rin", [
                "in"
            ]
        )

        queueModes := Map(
            "q0", 0, "queue0", 0,
            "q1", 1, "queue1", 1,
            "q2", 2, "queue2", 2
        )

        queueConflicts := Map(
            "q0", [
                "q1",
                "q2",
                "queue1",
                "queue2"
            ],
            "queue0", [
                "q1",
                "q2",
                "queue1",
                "queue2"
            ],
            "q1", [
                "q0",
                "q2",
                "queue0",
                "queue2"
            ],
            "queue1", [
                "q0",
                "q2",
                "queue0",
                "queue2"
            ],
            "q2", [
                "q0",
                "q1",
                "queue0",
                "queue1"
            ],
            "queue2", [
                "q0",
                "q1",
                "queue0",
                "queue1"
            ]
        )

        processFlag(flag) {
            ; global hasT, hasC, specialColors, queueModes, queueConflicts, conflicts, final
            if !flag
                return ""
            fl := StrLower(flag)
            if RegExMatch(fl, "^(sb|info)(?:\{(.*?)\}(?:\{(.*?)\})?)?$", &m)
                return "sb{" Trim(m[2]) "}{" Trim(m[3]) "}"

            if RegExMatch(fl, "^t(\d+(\.\d+)?)$")
                return (!hasT ? (hasT := true, flag) : "")

            if RegExMatch(fl, "^c[a-z0-9]+$")
                return (!hasC ? (hasC := true, specialColors.Get(fl, flag)) : "")

            if (queueModes.Has(fl)) {
                for cf in queueConflicts[fl]
                    if final.Has(cf)
                        final.Delete(cf)
                return flag
            }

            if conflicts.Has(fl) {
                for cf in conflicts[fl]
                    if final.Has(cf)
                        final.Delete(cf)
                return flag
            }

            return flag
        }

        for f in input {
            out := processFlag(f)
            if (out != "")
                final[StrLower(out)] := out
        }

        for df in defaultFlags {
            fl := StrLower(df)
            if final.Has(fl)
                continue
            if (RegExMatch(fl, "^t") && hasT)
                continue
            if (RegExMatch(fl, "^c") && hasC)
                continue
            if conflicts.Has(fl) {
                skip := false
                for cf in conflicts[fl]
                    if final.Has(cf)
                        skip := true
                if skip
                    continue
            }
            final[fl] := df
        }

        result := StrJoin(" ", final*)
        this.queueMode := 2

        for k, v in final {
            fl := StrLower(k)
            if queueModes.Has(fl) {
                this.queueMode := queueModes[fl]
                break
            }
        }

        return result
    }

    SetupControls(title, wrappedText, setupFlags) {

        this.guiPos.h += 30

        if (RegExMatch(setupFlags, '\br?(b|before)\b')) {
            this.hasBefore := true
            this.BeforeSetup()
            if (RegExMatch(setupFlags, '\br(b|before)\b'))
                Notify.Prototype.DefineProp("BeforeSetup", { Call: (*) => {} })
        }

        if (title != "") {
            this.title := this.gui.AddText(Format('Center w{} h25', this.guiPos.w - 50), title)
            titleColorsProps := ColorProps(this.defaultBackgroundColor)
            if (titleColorsProps.isLight)
                this.defaultTitleFont[1] .= " c" SubStr(titleColorsProps.colors.monochromatic[3],
                    2)
            else
                this.defaultTitleFont[1] .= " c" SubStr(titleColorsProps.colors.monochromatic[6],
                    2)
            this.title.SetFont(this.defaultTitleFont*)
            this.guiPos.h += 40
        }

        if (this.vscroll_on) {
            contentHeight := 500
            this.content := this.gui.AddEdit(Format('+Wrap VScroll w{} h{}', this.guiPos.w - 25, contentHeight),
            wrappedText)
            this.guiPos.h += -(this.lineCount * 20) + contentHeight
        }
        else {
            this.content := this.gui.AddEdit(Format('+Wrap -VScroll w{}', this.guiPos.w - 25), wrappedText)
            this.guiPos.h += 30
        }

        if (RegExMatch(setupFlags, '\br?(a|after)\b')) {
            this.hasAfter := true
            this.AfterSetup()
            if (RegExMatch(setupFlags, '\br(a|after)\b'))
                Notify.Prototype.DefineProp("AfterSetup", { Call: (*) => {} })
        }

        if RegExMatch(setupFlags, "\b(sb|info)(?:\{(.*?)\}(?:\{(.*?)\})?)?", &m) {
            kind := m[1] ? m[1] : ""
            opt := Trim(m[2] ? m[2] : "")
            content := Trim(m[3] ? m[3] : "")
            if (setupFlags = kind)
                opt := content := ""
            if (content = "" && opt != "" && !InStr(setupFlags, "}{"))
                content := opt, opt := ""
            opt := opt ||
                ((this.hasAfter ? "yp+10" : "yp") " xm +Right w" this.defaultWidth - 30)
            content := content || "$setupflags"
            if (SubStr(content, 1, 1) = "$") {
                try
                    text := %SubStr(content, 2)%
                catch
                    text := "[Undefined: " SubStr(content, 2) "]"
            } else {
                text := content
            }
            statusBar := this.gui.AddText(opt, text)
            if (kind = "sb")
                statusBar.SetFont("s10 underline italic")
            else
                statusBar.SetFont("s10 underline bold cee00ff")
            this.guiPos.h += !this.hasAfter ? 40 : 40
        }
    }

    InitSetup() {
    }

    BeforeSetup() {
    }

    AfterSetup() {
    }

    WordWrap(text, limit) {
        if (StrLen(text) - 1 < 2 * limit) {
            text := RegExReplace(text, "\n->", " ->")
        }
        pattern := '\n|[ \t]+|\S+'
        words := []
        pos := 1
        while pos := RegExMatch(text, pattern, &m, pos) {
            words.Push(m[0])
            pos += StrLen(m[0])
        }
        lines := []
        currentLine := ""
        ; Phải dùng vòng lặp, không thể dùng biểu thức ternary
        for word in words {
            if (word = "`n") {
                lines.Push(currentLine)
                currentLine := ""
                continue
            }
            if (StrLen(word) > limit) {
                if (currentLine != "") {
                    lines.Push(currentLine)
                    currentLine := ""
                }
                ; Phải dùng vòng lặp, không thể dùng biểu thức ternary
                while (StrLen(word) > limit) {
                    lines.Push(SubStr(word, 1, limit))
                    word := SubStr(word, limit + 1)
                }
                currentLine := word
                continue
            }
            if (StrLen(currentLine) + StrLen(word) > limit) {
                lines.Push(currentLine)
                currentLine := (RegExMatch(word, "^\s+$") ? "" : word)
            } else
                currentLine .= word
        }
        if (currentLine != "")
            lines.Push(currentLine)
        out := ""
        for i, line in lines
            out .= (i > 1 ? "`n" : "") . line
        return out
    }

    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd) {
            Text := "", ToolTip()
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
