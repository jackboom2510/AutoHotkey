; Prompt user to choose folder name option by entering 1, 2, 3, 4, 5 or 6 (Hủy)
InputBox, choice, Chọn tên thư mục, Bạn muốn chọn: `n1. Sử dụng tên folder có sẵn "B23DCKH105 - Nguyen Danh Thai"`n2. Sử dụng định dạng "[Ngày hôm nay] B23DCKH105 - Nguyen Danh Thai"`n3. Thêm vào sau "B23DCKH105 - Nguyen Danh Thai"`n4. Thêm vào trước "B23DCKH105 - Nguyen Danh Thai"`n5. Nhập tên mới hoàn toàn`n6. Hủy
if (choice = 1)
{
    ; Option 1: Use the predefined folder name
    folderName := "B23DCKH105 - Nguyen Danh Thai"
}
else if (choice = 2)
{
    ; Option 2: Use today's date format "[Ngày hôm nay] B23DCKH105 - Nguyen Danh Thai"
    FormatTime, todayDate,, dd-MM-yyyy
    folderName := "[" . todayDate . "] B23DCKH105 - Nguyen Danh Thai"
}
else if (choice = 3)
{
    ; Option 3: Add user input to the end of predefined name
    InputBox, customName, Nhập phần thêm vào, Nhập phần bạn muốn thêm vào sau "B23DCKH105 - Nguyen Danh Thai"
    folderName := "B23DCKH105 - Nguyen Danh Thai " . customName
}
else if (choice = 4)
{
    ; Option 4: Add user input before "B23DCKH105 - Nguyen Danh Thai"
    InputBox, prefixName, Nhập phần thêm vào trước, Nhập phần bạn muốn thêm vào trước "B23DCKH105 - Nguyen Danh Thai"
    folderName := prefixName . " B23DCKH105 - Nguyen Danh Thai"
}
else if (choice = 5)
{
    ; Option 5: Enter a completely new folder name
    InputBox, folderName, Tạo Folder, Nhập tên folder mới
}
else if (choice = 6)
{
    ; Option 6: Exit the script if user chooses "Hủy"
    MsgBox, Bạn đã chọn Hủy. Chương trình sẽ thoát.
    ExitApp
}
else
{
    MsgBox, Bạn đã nhập không đúng. Vui lòng nhập 1, 2, 3, 4, 5 hoặc 6.
    ExitApp
}

; Prompt user to input number of .cpp files
InputBox, fileCount, Số lượng file .cpp, Nhập số lượng file .cpp
if (fileCount = "" or !RegExMatch(fileCount, "^\d+$"))
{
    MsgBox, Số lượng file không hợp lệ. Chương trình sẽ thoát.
    ExitApp
}

; Prompt user to choose naming convention for files
InputBox, fileNaming, Chọn kiểu tên file, Bạn muốn tạo file theo kiểu:`n1. Theo số`n2. Theo chữ hoa`n3. Theo chữ thường
if (fileNaming not in [1, 2, 3]) 
{
    MsgBox, Bạn đã nhập không đúng. Vui lòng chọn 1, 2 hoặc 3.
    ExitApp
}

; Define paths
desktopPath := A_Desktop . "\" . folderName
originalFolderPath := desktopPath
counter := 1

; Check if folder already exists and create a new one if necessary
while FileExist(desktopPath)
{
    desktopPath := originalFolderPath . " (" . counter . ")"
    counter++
}

; Create the folder
FileCreateDir, %desktopPath%

; Create files based on user choice
Loop, %fileCount%
{
    if (fileNaming = 1)
    {
        ; Create files with numbers (1.cpp, 2.cpp, 3.cpp...)
		FileAppend, , %desktopPath%\%A_Index%.cpp
    }
    else if (fileNaming = 2)
    {
        ; Create files with uppercase letters (A.cpp, B.cpp, C.cpp...)
        letter := GetFileNameForIndex(A_Index, 0) ; Get name for index in uppercase letters
        FileAppend, , %desktopPath%\%letter%.cpp
    }
    else if (fileNaming = 3)
    {
        ; Create files with lowercase letters (a.cpp, b.cpp, c.cpp...)
        letter := GetFileNameForIndex(A_Index, 1) ; Get name for index in lowercase letters
        FileAppend, , %desktopPath%\%letter%.cpp ; Append index in parentheses
    }
}

; Function to convert an index to a string in base 26 (letters A-Z or a-z)
GetFileNameForIndex(index, isLowerCase)
{
    letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if (isLowerCase)
        letters := "abcdefghijklmnopqrstuvwxyz"
    
    result := ""
    while (index > 0)
    {
        ; Adjust for 1-based index (A=1, B=2, ..., Z=26, AA=27, ...)
        index--
        result := SubStr(letters, Mod(index, 26) + 1, 1) . result
        index := Floor(index / 26)
    }
    return result
}

; Tạo thư mục .vscode trong folder đã tạo
vscodeFolder := desktopPath . "\.vscode"
FileCreateDir, %vscodeFolder%

; Nội dung của file launch.json
launchJsonContent =
(
{
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
}
)

; Ghi nội dung launch.json vào thư mục .vscode
FileAppend, %launchJsonContent%, %vscodeFolder%\launch.json

; Nội dung của file tasks.json
tasksJsonContent =
(
{
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
}
)

; Ghi nội dung tasks.json vào thư mục .vscode
FileAppend, %tasksJsonContent%, %vscodeFolder%\tasks.json

; Path to Visual Studio Code
vscodePath := "C:\Users\jackb\AppData\Local\Programs\Microsoft VS Code\Code.exe"
; Path to PTIT Code Client
ptitCodePath := "D:\5. Jack\#Learn to Success\#Uni\ptit-code-client-x64\ptit-code-client.exe"

; Open Visual Studio Code and link to the created folder
Run, %vscodePath%
Sleep, 2000 ; Wait for VS Code to open

; Maximize the Visual Studio Code window
WinWaitActive, ahk_exe Code.exe
WinMaximize ; Maximizes the VS Code window

Send, ^k ; Trigger Ctrl + K
Sleep, 500
Send, ^o ; Trigger Ctrl + O
Sleep, 500
Send, %desktopPath% ; Input the folder path
Sleep, 500
Send, {Enter}
Sleep, 500
Send, {Enter}
Sleep, 1000
Send, {Enter}

; Check if PTIT Code Client is already running
IfWinExist, ahk_exe ptit-code-client.exe
{
	; If PTIT Code Client is already running, do nothing
	MsgBox, PTIT Code Client đã được mở.
}
else
{
	; Prompt user to choose whether to open PTIT Code Client
	InputBox, userChoice, Mở PTIT Code Client, Bạn có muốn mở ứng dụng PTIT Code Client không?`n1. Yes`n2. No
	if (userChoice = "1")
	{
		; Open PTIT Code Client if not running
		Run, %ptitCodePath%
		Sleep, 5000 ; Wait for PTIT Code Client to open
		; Log into PTIT Code Client if using Option 1 or 2
		if (choice = 1 or choice = 2)
		{
			; Wait for the PTIT Code Client login window
			WinWaitActive, ahk_exe ptit-code-client.exe

			; Send the login information
			Send, {Tab}
			Send, B23DCKH105{Tab} ; Send the username and Tab to next field
			Sleep, 500
			Send, 25102005{Tab} ; Send the password and Tab to checkbox
			Sleep, 500
			; Tick the checkbox for "Tôi đồng ý cho phép phần mềm giám sát máy tính trong thời gian làm bài"
			Send, {Space}{Tab} ; Press Space to check the box
			Sleep, 500
			; Submit the login form (press Enter)
			Send, {Enter}
		}
	}
}
