; AutoHotkey Script: Chọn hoặc nhập thư mục, xử lý file trùng tên

#SingleInstance Force
#NoEnv
SetBatchLines, -1

; --- Hỏi người dùng muốn chọn thư mục thủ công hay nhập tay ---
MsgBox, 4,, Bạn muốn chọn thư mục bằng cách nào?`n`nYes - Chọn thủ công (bằng cửa sổ)`nNo - Nhập địa chỉ thư mục
IfMsgBox Yes
{
    FileSelectFolder, RootFolder, , 3, Chọn thư mục gốc
    if (RootFolder = "")
    {
        MsgBox, ❌ Bạn chưa chọn thư mục. Thoát script.
        ExitApp
    }
}
else
{
    InputBox, RootFolder, Nhập địa chỉ thư mục, Nhập đường dẫn đầy đủ đến thư mục cần kiểm tra:, , 500, 150
    if ErrorLevel
    {
        MsgBox, ❌ Bạn đã hủy. Thoát script.
        ExitApp
    }
    if (!FileExist(RootFolder))
    {
        MsgBox, ❌ Thư mục không tồn tại: %RootFolder%
        ExitApp
    }
}

; --- Hỏi người dùng muốn làm gì với file trùng ---
MsgBox, 4,, Bạn muốn làm gì với các file trùng tên?`n`nYes - Xóa file trùng lặp, giữ bản đầu tiên`nNo - Đổi tên file trùng lặp
IfMsgBox Yes
    Mode := "delete"
else
    Mode := "rename"

; --- Bắt đầu xử lý ---
FileMap := {}
ChangedCount := 0

Loop, Files, %RootFolder%\*.*, R
{
    FileName := A_LoopFileName
    FilePath := A_LoopFileFullPath

    if !FileMap.HasKey(FileName)
        FileMap[FileName] := [FilePath]
    else
        FileMap[FileName].Push(FilePath)
}

for FileName, Paths in FileMap
{
    if (Paths.Length() > 1)
    {
        Loop, % Paths.Length()
        {
            index := A_Index
            Path := Paths[index]

            if (Mode = "delete")
            {
                if (index = 1)
                    continue
                FileDelete, %Path%
                ChangedCount++
                TrayTip, Đã xóa file, %Path%, 1
            }
            else if (Mode = "rename")
            {
                if (index = 1)
                    continue
                SplitPath, Path, name, dir, ext, name_no_ext
                NewPath := dir . "\" . name_no_ext . "_dup" . (index - 1) . "." . ext
                FileMove, %Path%, %NewPath%
                ChangedCount++
                TrayTip, Đã đổi tên file, %NewPath%, 1
            }
        }
    }
}

MsgBox, ✅ Hoàn tất! %ChangedCount% file đã được xử lý.`nChế độ: %Mode%
ExitApp
