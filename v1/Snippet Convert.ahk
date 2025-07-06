; AutoHotkey v1.1+ - Chuyển file bất kỳ thành VSCode snippet JSON

FileSelectFile, filePath, 3,, Chọn file bất kỳ, All Files (*.*)
if (filePath = "")
{
    MsgBox, Bạn chưa chọn file!
    ExitApp
}

InputBox, prefix, Prefix snippet, Nhập prefix cho snippet:
if ErrorLevel
    ExitApp

InputBox, description, Mô tả snippet, Nhập mô tả cho snippet:
if ErrorLevel
    ExitApp

FileRead, fileContent, %filePath%
if (fileContent = "")
{
    MsgBox, Không thể đọc nội dung file!
    ExitApp
}

; Tách thành dòng và escape đúng cách
lines := StrSplit(fileContent, "`n")

jsonBody := ""
for index, line in lines
{
    line := StrReplace(line, "`r", "")            ; Xóa ký tự \r
    line := StrReplace(line, "\", "\\")           ; Escape backslash 1 lần
    line := StrReplace(line, """", "\""")         ; Escape dấu "
    line := RegExReplace(line, "\$\{", "`$\{")    ; Escape ${...}
    line := StrReplace(line, "$", "`$")           ; Escape dấu $
    line := StrReplace(line, "%", "`%")           ; Escape dấu %
    line := StrReplace(line, "`", "``")           ; Escape backtick
    jsonBody .= "        """ . line . """"        ; Format JSON dòng
    if (index < lines.MaxIndex())
        jsonBody .= ",`n"
    else
        jsonBody .= "`n"
}

SplitPath, filePath, fileName, dir, ext, name_no_ext
outputFile := dir . "\" . name_no_ext . ".code-snippets"

snippetJSON =
(
{
    "%name_no_ext%": {
        "prefix": "%prefix%",
        "body": [
%jsonBody%        ],
        "description": "%description%"
    }
}
)

FileDelete, %outputFile%
FileAppend, %snippetJSON%, %outputFile%

MsgBox, ✅ Snippet đã được tạo tại:`n%outputFile%
ExitApp
