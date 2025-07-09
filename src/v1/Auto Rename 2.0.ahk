; Script: RenameFiles_CleanupEXE_AddCPP.ahk
; Tính năng: Chọn thư mục, xóa file .exe, thêm đuôi .cpp cho file không có phần mở rộng

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
Menu, tray, Icon

; --- Bước 1: Chọn thư mục ---
choiceText =
(
Chọn cách nhập thư mục:

1. Chọn thư mục thủ công (dùng hộp thoại)
2. Dán đường dẫn thư mục (nhập bằng tay)

Nhập 1 hoặc 2:
)
InputBox, userChoice, Chọn phương thức nhập, %choiceText%, , 400, 200

if ErrorLevel {
    MsgBox, 48, Đã hủy, Bạn đã hủy thao tác.
    ExitApp
}

userChoice := Trim(userChoice)

if (userChoice = "1") {
    FileSelectFolder, folderPath, , 3, Chọn thư mục chứa code
} else if (userChoice = "2") {
    InputBox, folderPath, Nhập đường dẫn thư mục, Vui lòng dán đường dẫn thư mục:`n(Ví dụ: C:\MyProject), , 400, 150
} else {
    MsgBox, 48, Lỗi, Lựa chọn không hợp lệ! Vui lòng chỉ nhập 1 hoặc 2.
    ExitApp
}

; --- Bước 2: Kiểm tra đường dẫn ---
if (!FileExist(folderPath)) {
    MsgBox, 48, Lỗi, Đường dẫn không hợp lệ hoặc không tồn tại!
    ExitApp
}

; --- Bước 3: Xóa file .exe ---
deletedExe := 0
Loop, Files, %folderPath%\*.exe, F
{
    FileDelete, %A_LoopFileFullPath%
    if !ErrorLevel
        deletedExe++
}

; --- Bước 4: Rename file không có phần mở rộng thành .cpp ---
renamedCpp := 0
Loop, Files, %folderPath%\*, F
{
    ext := A_LoopFileExt
    fullPath := A_LoopFileFullPath
    fileName := A_LoopFileName

    if (ext = "") {
        newPath := fullPath . ".cpp"
        FileMove, %fullPath%, %newPath%
        if !ErrorLevel
            renamedCpp++
    }
}

; --- Bước 5: Thông báo kết quả ---
MsgBox, 64, Hoàn tất,
(
Đã xóa %deletedExe% file .exe
Đã thêm đuôi .cpp cho %renamedCpp% file

Thư mục: %folderPath%
)
ExitApp
