class UINumpad {
    gui := 0
    hwnd := 0
    lastTargetHwnd := 0

    __New() {
        g := Gui("+AlwaysOnTop -Caption +ToolWindow +Border +E0x08000008", "NumPad")
        g.BackColor := "1e1e1e"
        g.SetFont("s12 cWhite", "Segoe UI")

        btnW := 50, btnH := 40, pad := 5
        x0 := 10, y0 := 10

        ; ─────── Hàng 1 ───────
        b7 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 0 * (btnW + pad), y0 + 0 * (btnH + pad), btnW, btnH), "7")
        b8 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 1 * (btnW + pad), y0 + 0 * (btnH + pad), btnW, btnH), "8")
        b9 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 2 * (btnW + pad), y0 + 0 * (btnH + pad), btnW, btnH), "9")

        ; ─────── Hàng 2 ───────
        b4 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 0 * (btnW + pad), y0 + 1 * (btnH + pad), btnW, btnH), "4")
        b5 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 1 * (btnW + pad), y0 + 1 * (btnH + pad), btnW, btnH), "5")
        b6 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 2 * (btnW + pad), y0 + 1 * (btnH + pad), btnW, btnH), "6")

        ; ─────── Hàng 3 ───────
        b1 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 0 * (btnW + pad), y0 + 2 * (btnH + pad), btnW, btnH), "1")
        b2 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 1 * (btnW + pad), y0 + 2 * (btnH + pad), btnW, btnH), "2")
        b3 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 2 * (btnW + pad), y0 + 2 * (btnH + pad), btnW, btnH), "3")

        ; ─────── Hàng 4 ───────
        bd := g.AddButton(Format("x{} y{} w{} h{}", x0 + 0 * (btnW + pad), y0 + 3 * (btnH + pad), btnW, btnH), ".")
        b0 := g.AddButton(Format("x{} y{} w{} h{}", x0 + 1 * (btnW + pad), y0 + 3 * (btnH + pad), btnW, btnH), "0")
        bb := g.AddButton(Format("x{} y{} w{} h{}", x0 + 2 * (btnW + pad), y0 + 3 * (btnH + pad), btnW, btnH), "←")

        ; ─────── Enter ───────
        be := g.AddButton(Format("x{} y{} w{} h{}", x0, y0 + 4 * (btnH + pad), btnW * 3 + pad * 2, btnH), "Enter")

        ; Gán sự kiện từng nút
        for ctrl in [b7, b8, b9, b4, b5, b6, b1, b2, b3, bd, b0, bb, be]
            ctrl.OnEvent("Click", (btn, *) => (
                SetTimer(() => this.SendKey(btn.Text), -10)  ; Trì hoãn nhẹ để GUI không ăn phím
            ))


        g.OnEvent("Escape", (*) => g.Hide())
        g.OnEvent("Close", (*) => g.Hide())
        OnMessage(0x6, (wParam, lParam, msg, hwndFrom) => (hwndFrom = this.gui.hwnd && !wParam && g.Hide()))

        this.gui := g
        this.hwnd := this.gui.hwnd
    }

    Toggle() {
        if WinExist("ahk_id " this.hwnd)
            this.gui.Hide()
        else {
            this.Show()
        }
    }

    Show() {
        this.lastTargetHwnd := WinExist("A")
        MouseGetPos(&x, &y)
        this.gui.Show(Format("AutoSize NoActivate x{} y{}", x, y))

    }

    SendKey(key) {
        if !this.lastTargetHwnd || !WinExist("ahk_id " this.lastTargetHwnd)
            this.lastTargetHwnd := WinExist("A")
        target := this.lastTargetHwnd

        keyMap := Map("←", "BackSpace")
        sendText := keyMap.Has(key) ? keyMap[key] : key

        PostMessage(0x100, GetKeyVK(sendText), 0, , "ahk_id " target) ; WM_KEYDOWN
        ; PostMessage(0x101, GetKeyVK(sendText), 0, , "ahk_id " target) ; WM_KEYUP
    }
}