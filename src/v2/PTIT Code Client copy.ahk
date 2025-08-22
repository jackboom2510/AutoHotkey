#Requires AutoHotkey v2+
; Script này sẽ tự động tạo một cấu trúc thư mục và file cho các dự án C++ và tích hợp với VS Code & PTIT Code Client

; --- 1. Nhắc người dùng chọn tên thư mục ---
PromptForFolderName() {
    ; Sử dụng InputBox để nhận lựa chọn từ người dùng
    global choice := InputBox(
        "Bạn muốn chọn:`n"
        . "1. Sử dụng tên folder có sẵn " "B23DCKH105 - Nguyen Danh Thai" "`n"
        . "2. Sử dụng định dạng " "[Ngày hôm nay] B23DCKH105 - Nguyen Danh Thai" "`n"
        . "3. Thêm vào sau " "B23DCKH105 - Nguyen Danh Thai" "`n"
        . "4. Thêm vào trước " "B23DCKH105 - Nguyen Danh Thai" "`n"
        . "5. Nhập tên mới hoàn toàn`n"
        . "6. Hủy",
        "Chọn tên thư mục"
    ).Value

    folderName := "" ; Khai báo biến cục bộ

    if (choice = "1") {
        folderName := "B23DCKH105 - Nguyen Danh Thai"
    } else if (choice = "2") {
        todayDate := FormatTime(, "dd-MM-yyyy") ; FormatTime trong v2 trả về string
        folderName := "[" . todayDate . "] B23DCKH105 - Nguyen Danh Thai"
    } else if (choice = "3") {
        customName := InputBox("Nhập phần bạn muốn thêm vào sau " "B23DCKH105 - Nguyen Danh Thai" "",
            "Nhập phần thêm vào").Value
        folderName := "B23DCKH105 - Nguyen Danh Thai " . customName
    } else if (choice = "4") {
        prefixName := InputBox("Nhập phần bạn muốn thêm vào trước " "B23DCKH105 - Nguyen Danh Thai" "",
            "Nhập phần thêm vào trước").Value
        folderName := prefixName . " B23DCKH105 - Nguyen Danh Thai"
    } else if (choice = "5") {
        folderName := InputBox("Nhập tên folder mới", "Tạo Folder").Value
    } else if (choice = "6") {
        TrayTip("Bạn đã chọn Hủy. Chương trình sẽ thoát.", "Hủy Bỏ", "IconStop")
        ExitApp
    } else {
        TrayTip("Bạn đã nhập không đúng. Vui lòng nhập 1, 2, 3, 4, 5 hoặc 6.", "Lỗi Nhập Liệu", 3)
        ExitApp
    }

    ; Kiểm tra nếu tên folder rỗng sau khi chọn Option 5 hoặc do user hủy InputBox
    if (folderName = "") {
        TrayTip("Tên thư mục không hợp lệ hoặc bạn đã hủy nhập liệu. Chương trình sẽ thoát.", "Lỗi Tên Thư Mục",
            3)
        ExitApp
    }
    return folderName
}

; Gọi hàm để lấy tên thư mục
folderName := PromptForFolderName()

; --- 2. Nhắc người dùng nhập số lượng file .cpp ---
fileCount := InputBox("Nhập số lượng file .cpp", "Số lượng file .cpp").Value
; Kiểm tra nếu không phải số hoặc rỗng
if (!IsInteger(fileCount) || fileCount < 0) { ; IsInteger kiểm tra có phải số nguyên không
    TrayTip("Số lượng file không hợp lệ. Chương trình sẽ thoát.", "Lỗi Nhập Liệu", 3)
    ExitApp
}

; --- 3. Nhắc người dùng chọn kiểu đặt tên file ---
fileNaming := InputBox(
    "Bạn muốn tạo file theo kiểu:`n"
    . "1. Theo số`n"
    . "2. Theo chữ hoa`n"
    . "3. Theo chữ thường",
    "Chọn kiểu tên file"
).Value

hasFileNaming := false
for idx, value in ['1', '2', '3'] {
    if fileNaming = value {
        global hasFileNaming := true
        break
    }
}
if not hasFileNaming {
    TrayTip("Bạn đã nhập không đúng. Vui lòng chọn 1, 2 hoặc 3.", "Lỗi Nhập Liệu", 3)
    ExitApp
}
; --- 4. Định nghĩa các đường dẫn và kiểm tra/tạo thư mục ---
desktopPath := A_Desktop . "\" . folderName
originalFolderPath := desktopPath
counter := 1

; Kiểm tra xem thư mục đã tồn tại chưa và tạo thư mục mới nếu cần
while FileExist(desktopPath) {
    desktopPath := originalFolderPath . " (" . counter . ")"
    counter++
}

; Tạo thư mục
DirCreate(desktopPath) ; FileCreateDir được thay thế bằng DirCreate trong v2

; --- 5. Tạo file .cpp dựa trên lựa chọn của người dùng ---
loop fileCount {
    fileName := ""
    if (fileNaming = "1") {
        ; Tạo file với số (1.cpp, 2.cpp, 3.cpp...)
        fileName := A_Index
    } else if (fileNaming = "2") {
        ; Tạo file với chữ hoa (A.cpp, B.cpp, C.cpp...)
        fileName := GetFileNameForIndex(A_Index, false) ; false cho chữ hoa
    } else if (fileNaming = "3") {
        ; Tạo file với chữ thường (a.cpp, b.cpp, c.cpp...)
        fileName := GetFileNameForIndex(A_Index, true) ; true cho chữ thường
    }
    FileAppend("", desktopPath . "\" . fileName . ".cpp") ; FileAppend trong v2 nhận content, sau đó là file path
}

; --- 6. Hàm chuyển đổi chỉ số sang chuỗi ký tự (A-Z, AA-AZ, ...) ---
; Hàm này là Static để có thể gọi trực tiếp hoặc nằm ngoài lớp
GetFileNameForIndex(index, isLowerCase) {
    letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if (isLowerCase)
        letters := "abcdefghijklmnopqrstuvwxyz"

    result := ""
    while (index > 0) {
        ; Điều chỉnh cho chỉ mục 1-based (A=1, B=2, ..., Z=26, AA=27, ...)
        index--
        result := SubStr(letters, Mod(index, 26) + 1, 1) . result
        index := Floor(index / 26)
    }
    return result
}

; --- 7. Tạo thư mục .vscode và các file cấu hình ---
vscodeFolder := desktopPath . "\.vscode"
DirCreate(vscodeFolder)

; Nội dung của file launch.json (không thay đổi)
launchJsonContent :=
    (
        '            {
                "configurations": [
                    {
                        "name": "C/C++: g++.exe build and debug active file",
                        "type": "cppdbg",
                        "request": "launch",
                        "program": "${fileDirname}\\${fileBasenameNoExtension}.exe",
                        "args": [],
                        "stopAtEntry": true,
                        "cwd": "${fileDirname}",
                        "environment": [],
                        "externalConsole": true,
                        "MIMode": "gdb",
                        "miDebuggerPath": "C:\\msys64\\ucrt64\\bin\\gdb.exe",
                        "setupCommands": [
                            {
                                "description": "Enable pretty-printing for gdb",
                                "text": "-enable-pretty-printing",
                                "ignoreFailures": true
                            },
                            {
                                "description": "Set Disassembly Flavor to Intel",
                                "text": "-gdb-set disassembly-flavor intel",
                                "ignoreFailures": true
                            }
                        ],
                        "preLaunchTask": "C/C++: g++.exe build active file"
                    }
                ],
                "version": "2.0.0"
            }'
    )

; Ghi nội dung launch.json vào thư mục .vscode
FileAppend(launchJsonContent, vscodeFolder . "\launch.json")

; Nội dung của file tasks.json (không thay đổi)
tasksJsonContent :=
    (
        '            {
                "tasks": [
                    {
                        "type": "cppbuild",
                        "label": "C/C++: g++.exe build active file",
                        "command": "C:\\msys64\\ucrt64\\bin\\g++.exe",
                        "args": [
                            "-fdiagnostics-color=always",
                            "-g",
                            "${file}",
                            "-o",
                            "${fileDirname}\\${fileBasenameNoExtension}.exe"
                        ],
                        "options": {
                            "cwd": "${fileDirname}"
                        },
                        "problemMatcher": [
                            "$gcc"
                        ],
                        "group": {
                            "kind": "build",
                            "isDefault": true
                        },
                        "detail": "Task generated by Debugger."
                    }
                ],
                "version": "2.0.0"
            }'
    )

; Ghi nội dung tasks.json vào thư mục .vscode
FileAppend(tasksJsonContent, vscodeFolder . "\tasks.json")

; --- 8. Mở Visual Studio Code và trỏ đến thư mục đã tạo ---
vscodePath := "C:\Users\jackb\AppData\\Programs\Microsoft VS Code\Code.exe"

; Kiểm tra xem VS Code có tồn tại không trước khi chạy
if (!FileExist(vscodePath)) {
    TrayTip("Không tìm thấy Visual Studio Code tại đường dẫn: " . vscodePath . "`nVui lòng kiểm tra lại đường dẫn.",
        "Lỗi", 3)
    ExitApp
}

Run(vscodePath)
WinWaitActive("ahk_exe Code.exe", , 10) ; Chờ VS Code mở, tối đa 10 giây
if (!WinExist("ahk_exe Code.exe")) {
    TrayTip("Visual Studio Code không mở kịp hoặc bị lỗi. Chương trình sẽ thoát.", "Lỗi", 3)
    ExitApp
}

WinMaximize("ahk_exe Code.exe") ; Phóng to cửa sổ VS Code

; Mở thư mục trong VS Code
; Sử dụng Ctrl+K Ctrl+O và gửi đường dẫn
Send("^k")
Sleep(100)
Send("o")
Sleep(500)
Send(desktopPath)
Sleep(500)
Send("{Enter}")
Sleep(500)
; Xử lý trường hợp VS Code hỏi "Would you trust the authors of the files in this folder?"
; Thông thường sẽ có 1 hoặc 2 Enter để xác nhận.
Send("{Enter}") ; Thường là Enter đầu tiên để xác nhận đường dẫn
Sleep(1000)
Send("{Enter}") ; Có thể là Enter thứ hai cho "Trust the authors"

; --- 9. Xử lý PTIT Code Client ---
ptitCodePath := "D:\5. Jack\#Learn to Success\#Uni\ptit-code-client-x64\ptit-code-client.exe"

if WinExist("ahk_exe ptit-code-client.exe") {
    TrayTip("PTIT Code Client đã được mở.", , "IconInformation")
} else {
    userChoicePTIT := InputBox("Bạn có muốn mở ứng dụng PTIT Code Client không?`n1. Yes`n2. No",
        "Mở PTIT Code Client").Value
    if (userChoicePTIT = "1") {
        if (!FileExist(ptitCodePath)) {
            TrayTip("Không tìm thấy PTIT Code Client tại đường dẫn: " . ptitCodePath .
                "`nVui lòng kiểm tra lại đường dẫn.", "Lỗi", 3)
            ExitApp
        }
        Run(ptitCodePath)
        WinWaitActive("ahk_exe ptit-code-client.exe", , 15) ; Chờ PTIT Code Client mở, tối đa 15 giây
        if (!WinExist("ahk_exe ptit-code-client.exe")) {
            TrayTip("PTIT Code Client không mở kịp hoặc bị lỗi. Chương trình sẽ thoát.", "Lỗi", 3)
            ExitApp
        }

        ; Đăng nhập PTIT Code Client nếu sử dụng Option 1 hoặc 2 cho tên folder
        if (choice = "1" || choice = "2") {
            ; Đảm bảo cửa sổ PTIT Code Client đang hoạt động
            WinActivate("ahk_exe ptit-code-client.exe")
            WinWaitActive("ahk_exe ptit-code-client.exe")

            ; Gửi thông tin đăng nhập
            ; Các trường hợp Send cần kiểm tra lại thứ tự Tab nếu giao diện thay đổi
            Send("{Tab}") ; Đến trường username
            Sleep(100)
            Send("B23DCKH105")
            Sleep(100)
            Send("{Tab}") ; Đến trường password
            Sleep(100)
            Send("25102005")
            Sleep(100)
            Send("{Tab}") ; Đến checkbox "Tôi đồng ý..."
            Sleep(100)
            Send("{Space}") ; Tích vào checkbox
            Sleep(100)
            Send("{Tab}") ; Đến nút đăng nhập
            Sleep(100)
            Send("{Enter}") ; Gửi form đăng nhập
        }
    }
}

TrayTip("Quá trình hoàn tất!", "Thông Báo", "IconInformation")
ExitApp