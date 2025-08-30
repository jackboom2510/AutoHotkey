#Requires AutoHotkey v2.0.18+
#Include <ui\NotificationUI>
#Include <core\Gdip_All>  ; cần Gdip_All.ahk (thư viện GDI+)

^+o:: {
    ; Bắt đầu chọn
    ToolTip "Drag to select area..."
    KeyWait "LButton", "D"
    MouseGetPos &startX, &startY

    ; Device Context của màn hình
    hdc := DllCall("GetDC", "ptr", 0, "ptr")
    pen := DllCall("CreatePen", "int", 0, "int", 2, "uint", 0x0000FF, "ptr") ; đỏ (BGR)
    oldPen := DllCall("SelectObject", "ptr", hdc, "ptr", pen, "ptr")

    UpdateBorder() {
        static lastX := 0, lastY := 0, lastW := 0, lastH := 0
        MouseGetPos &mx, &my
        x := Min(startX, mx), y := Min(startY, my)
        w := Abs(mx - startX), h := Abs(my - startY)

        ; Xóa border cũ (XOR pen)
        DllCall("SetROP2", "ptr", hdc, "int", 7) ; R2_NOTXORPEN
        if (lastW > 0 && lastH > 0)
            DllCall("Rectangle", "ptr", hdc, "int", lastX, "int", lastY, "int", lastX + lastW, "int", lastY + lastH)

        ; Vẽ border mới
        if (w > 0 && h > 0)
            DllCall("Rectangle", "ptr", hdc, "int", x, "int", y, "int", x + w, "int", y + h)

        lastX := x, lastY := y, lastW := w, lastH := h
    }

    SetTimer UpdateBorder, 15
    KeyWait "LButton"
    MouseGetPos &endX, &endY
    SetTimer UpdateBorder, 0

    ; Xóa border cuối cùng
    UpdateBorder()

    ; Dọn dẹp pen/DC
    DllCall("SelectObject", "ptr", hdc, "ptr", oldPen)
    DllCall("DeleteObject", "ptr", pen)
    DllCall("ReleaseDC", "ptr", 0, "ptr", hdc)
    ToolTip

    ; --- Chụp ảnh vùng ---
    x := Min(startX, endX), y := Min(startY, endY)
    w := Abs(endX - startX), h := Abs(endY - startY)

    if (w < 5 || h < 5) {
        NotificationUI "Vùng chọn quá nhỏ!"
        return
    }

    if !pToken := Gdip_Startup() {
        NotificationUI "Không khởi tạo GDI+!"
        return
    }

    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
    path := A_Temp "\snip.png"
    Gdip_SaveBitmapToFile(pBitmap, path)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)

    ; --- OCR (dùng Windows.Media.Ocr nếu có) ---
    try {
        ocr := ComObject("Windows.Media.Ocr.OcrEngine").TryCreateFromUserProfileLanguages()
        stream := ComObject("Windows.Storage.Streams.InMemoryRandomAccessStream")
        file := ComObject("Windows.Storage.StorageFile").GetFileFromPathAsync(path).GetResults()
        stream2 := file.OpenAsync(0).GetResults()
        decoder := ComObject("Windows.Graphics.Imaging.BitmapDecoder").CreateAsync(stream2).GetResults()
        bmp := decoder.GetSoftwareBitmapAsync().GetResults()
        result := ocr.RecognizeAsync(bmp).GetResults()
        text := result.Text
    } catch {
        text := "(OCR failed or not supported on this Windows)"
    }

    ; --- Hiển thị kết quả ---
    NotificationUI(text, "OCR Result")
}
