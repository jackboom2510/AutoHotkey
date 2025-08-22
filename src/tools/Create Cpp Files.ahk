; Bước 1: Nhập tên thư mục
InputBox, folderName, Nhập tên thư mục, Vui lòng nhập tên thư mục bạn muốn tạo:
if (folderName = "")
{
    MsgBox, Bạn chưa nhập tên thư mục. Chương trình sẽ thoát.
    ExitApp
}

; ==== Tạo menu chính ====
Menu, FolderMenu, Add, 📁 Dùng đường dẫn mặc định, UseDefaultFolder
Menu, FolderMenu, Add, ✍️ Nhập đường dẫn thủ công, EnterFolderManually
Menu, FolderMenu, Add, 🌐 Chọn thư mục qua giao diện, SelectFolderGUI
Menu, FolderMenu, Add  ; ngăn cách
Menu, FolderMenu, Add, ❌ Thoát chương trình, ExitScript

; ==== Hiển thị menu ====
Menu, FolderMenu, Show
return

; ==== Xử lý các lựa chọn ====
UseDefaultFolder:
    selectedFolder := "D:\5. Jack\#Learn to Success\#Uni\.2Year\.Sem4\1. DSA\(DSA) code"
    GoSub, ContinueScript
return

EnterFolderManually:
    InputBox, selectedFolder, Nhập đường dẫn thư mục, Vui lòng nhập đường dẫn thư mục bạn muốn sử dụng:, , 500, 140
    if (selectedFolder = "")
    {
        MsgBox, Bạn chưa nhập đường dẫn. Chương trình sẽ thoát.
        ExitApp
    }
    else if (!InStr(FileExist(selectedFolder), "D")) ; Không phải thư mục
    {
        MsgBox, Đường dẫn không hợp lệ hoặc không tồn tại. Chương trình sẽ thoát.
        ExitApp
    }
    GoSub, ContinueScript
return

SelectFolderGUI:
    FileSelectFolder, selectedFolder, , 3, Chọn thư mục gốc
    if (selectedFolder = "")
    {
        MsgBox, Bạn chưa chọn thư mục. Chương trình sẽ thoát.
        ExitApp
    }
    GoSub, ContinueScript
return

; ==== Tiếp tục chương trình ====
ExitScript:
    MsgBox, Bạn đã chọn thoát chương trình.
    ExitApp
return

ContinueScript:
desktopPath := selectedFolder . "\" . folderName
originalDesktopPath := desktopPath
counter := 1

while FileExist(desktopPath)
{
    desktopPath := originalDesktopPath . " (" . counter . ")"
    counter++
}
FileCreateDir, %desktopPath%

; Bước 3: Chọn file input (txt hoặc Excel)
FileSelectFile, inputFile, 3, , Chọn file input, Tệp dữ liệu (*.txt; *.xlsx; *.xls)
if (inputFile = "")
{
    MsgBox, Bạn chưa chọn file dữ liệu. Chương trình sẽ thoát.
    ExitApp
}

SplitPath, inputFile, , , fileExt
fileExt := LTrim(fileExt)

; Bước 4: Xử lý theo định dạng file
if (fileExt = "txt")
{
    FileRead, fileContent, *P65001 %inputFile%
    Loop, Parse, fileContent, `n, `r
    {
        line := Trim(A_LoopField)
        if (line != "")
        {
            parts := StrSplit(line, "`t")
            fileName := parts[1]
            fileDesc := parts[2]

            fileDesc := RemoveDiacritics(fileDesc)
            newFileName := fileName . "_" . fileDesc . ".cpp"
            FileAppend, , % desktopPath . "\" . newFileName
        }
    }
}
else if (fileExt = "xlsx" || fileExt = "xls")
{
    xl := ComObjCreate("Excel.Application")
    xl.Visible := false
    workbook := xl.Workbooks.Open(inputFile)
    sheet := workbook.Sheets(1)

    row := 2
    while true
    {
        fileName := sheet.Cells(row, 1).Value
        fileDesc := sheet.Cells(row, 2).Value

        if (fileName = "" or fileDesc = "")
            break

        fileDesc := RemoveDiacritics(fileDesc)
        newFileName := fileName . "_" . fileDesc . ".cpp"
        FileAppend, , % desktopPath . "\" . newFileName
        row++
    }

    workbook.Close(false)
    xl.Quit()
}
else
{
    MsgBox, Định dạng file không được hỗ trợ. Vui lòng chọn .txt hoặc .xlsx/.xls.
    ExitApp
}

; Bước 5: Hỏi người dùng có muốn mở VS Code không
MsgBox, 4,, Bạn có muốn mở thư mục trong Visual Studio Code không?
IfMsgBox, Yes
{
    vscodePath := "C:\Users\jackb\AppData\Local\Programs\Microsoft VS Code\Code.exe"
    if (FileExist(vscodePath))
    {
        Run, "%vscodePath%" "%desktopPath%"
    }
    else
    {
        ; Kiểm tra xem Visual Studio Code đã chạy chưa
		if WinExist("ahk_exe Code.exe")
		{
			WinActivate ; Kích hoạt cửa sổ VS Code
			WinWaitActive ; Đợi cửa sổ được kích hoạt
			Sleep 100
		}
		else
		{
			MsgBox, VS Code chưa chạy. Không có cửa sổ nào để kích hoạt.
		}
    }
}

; Hàm loại bỏ dấu tiếng Việt + ký tự đặc biệt
RemoveDiacritics(text)
{
    accents := Object()
    accents["á"] := "a", accents["à"] := "a", accents["ả"] := "a", accents["ã"] := "a", accents["ạ"] := "a"
    accents["ă"] := "a", accents["ắ"] := "a", accents["ằ"] := "a", accents["ẳ"] := "a", accents["ẵ"] := "a", accents["ặ"] := "a"
    accents["â"] := "a", accents["ấ"] := "a", accents["ầ"] := "a", accents["ẩ"] := "a", accents["ẫ"] := "a", accents["ậ"] := "a"
    accents["é"] := "e", accents["è"] := "e", accents["ẻ"] := "e", accents["ẽ"] := "e", accents["ẹ"] := "e"
    accents["ê"] := "e", accents["ế"] := "e", accents["ề"] := "e", accents["ể"] := "e", accents["ễ"] := "e", accents["ệ"] := "e"
    accents["í"] := "i", accents["ì"] := "i", accents["ỉ"] := "i", accents["ĩ"] := "i", accents["ị"] := "i"
    accents["ó"] := "o", accents["ò"] := "o", accents["ỏ"] := "o", accents["õ"] := "o", accents["ọ"] := "o"
    accents["ô"] := "o", accents["ố"] := "o", accents["ồ"] := "o", accents["ổ"] := "o", accents["ỗ"] := "o", accents["ộ"] := "o"
    accents["ơ"] := "o", accents["ớ"] := "o", accents["ờ"] := "o", accents["ở"] := "o", accents["ỡ"] := "o", accents["ợ"] := "o"
    accents["ú"] := "u", accents["ù"] := "u", accents["ủ"] := "u", accents["ũ"] := "u", accents["ụ"] := "u"
    accents["ư"] := "u", accents["ứ"] := "u", accents["ừ"] := "u", accents["ử"] := "u", accents["ữ"] := "u", accents["ự"] := "u"
    accents["ý"] := "y", accents["ỳ"] := "y", accents["ỷ"] := "y", accents["ỹ"] := "y", accents["ỵ"] := "y"
    accents["đ"] := "d"
    accents["Á"] := "A", accents["À"] := "A", accents["Ả"] := "A", accents["Ã"] := "A", accents["Ạ"] := "A"
    accents["Ă"] := "A", accents["Ắ"] := "A", accents["Ằ"] := "A", accents["Ẳ"] := "A", accents["Ẵ"] := "A", accents["Ặ"] := "A"
    accents["Â"] := "A", accents["Ấ"] := "A", accents["Ầ"] := "A", accents["Ẩ"] := "A", accents["Ẫ"] := "A", accents["Ậ"] := "A"
    accents["É"] := "E", accents["È"] := "E", accents["Ẻ"] := "E", accents["Ẽ"] := "E", accents["Ẹ"] := "E"
    accents["Ê"] := "E", accents["Ế"] := "E", accents["Ề"] := "E", accents["Ể"] := "E", accents["Ễ"] := "E", accents["Ệ"] := "E"
    accents["Í"] := "I", accents["Ì"] := "I", accents["Ỉ"] := "I", accents["Ĩ"] := "I", accents["Ị"] := "I"
    accents["Ó"] := "O", accents["Ò"] := "O", accents["Ỏ"] := "O", accents["Õ"] := "O", accents["Ọ"] := "O"
    accents["Ô"] := "O", accents["Ố"] := "O", accents["Ồ"] := "O", accents["Ổ"] := "O", accents["Ỗ"] := "O", accents["Ộ"] := "O"
    accents["Ơ"] := "O", accents["Ớ"] := "O", accents["Ờ"] := "O", accents["Ở"] := "O", accents["Ỡ"] := "O", accents["Ợ"] := "O"
    accents["Ú"] := "U", accents["Ù"] := "U", accents["Ủ"] := "U", accents["Ũ"] := "U", accents["Ụ"] := "U"
    accents["Ư"] := "U", accents["Ứ"] := "U", accents["Ừ"] := "U", accents["Ử"] := "U", accents["Ữ"] := "U", accents["Ự"] := "U"
    accents["Ý"] := "Y", accents["Ỳ"] := "Y", accents["Ỷ"] := "Y", accents["Ỹ"] := "Y", accents["Ỵ"] := "Y"
    accents["Đ"] := "D"

    for k, v in accents
        text := StrReplace(text, k, v)

    ; Thay ký tự đặc biệt bằng _
    text := RegExReplace(text, "[^a-zA-Z0-9]", "_")

    ; Làm sạch chuỗi
    text := RegExReplace(text, "_+", "_")        ; Gộp nhiều dấu _
    text := RegExReplace(text, "^_+|_+$", "")    ; Xoá dấu _ ở đầu/cuối

    return text
}
return