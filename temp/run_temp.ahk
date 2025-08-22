run_expr() {
    (WinActivate('ahk_exe code.exe'), Sleep(300), Send('^p'), Sleep(300), SendText('>Python: Start Terminal RepL'), Sleep(1000), Send('{Enter}'))
    return
}
run_expr()