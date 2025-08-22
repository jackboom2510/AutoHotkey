#Requires AutoHotkey v2.0
#SingleInstance Force

filePath := FileSelect("3", , "Chọn file bất kỳ", "All Files (*.*)")
if (filePath = "") {
    TrayTip("Bạn chưa chọn file!", "Lỗi", 3)
    ExitApp
}

try
    prefix := InputBox("Nhập prefix cho snippet:", "Prefix snippet", 'w200 h100').value
catch as e
    ExitApp

try
    description := InputBox("Nhập mô tả cho snippet:", "Mô tả snippet", 'w200 h100').value
catch as e
    ExitApp


try
    fileContent := FileRead(filePath)
catch as e {
    TrayTip("Không thể đọc nội dung file: " e.Message, "Lỗi", 3)
    ExitApp
}
if (fileContent = "")
    TrayTip("Nội dung file trống!", "Cảnh báo", 3)

lines := StrSplit(fileContent, "`n")

jsonBody := ""

for index, line in lines {
    line := StrReplace(line, "`r", "")
    line := StrReplace(line, "\", "\\")
    line := StrReplace(line, "" "", "\" "")
    line := RegExReplace(line, "\$\{(.*?)\}", "\\$\{$1\}")
    line := StrReplace(line, "``", "````")
    jsonBody .= " `"" . line . "`""
    if (index < lines.Length)
        jsonBody .= ",`n"
    else
        jsonBody .= "`n"
}

SplitPath(filePath, , &fileDir, , &fileName)
outputFile := fileDir . "\" . fileName . ".code-snippets"

snippetJSON := Format(
    (
        '{
    "{1}": {
        "prefix": "{2}",
        "body": [
{3}        ],
        "description": "{4}"
    }
}'
    ), fileName, prefix, jsonBody, description
)

try {
    fileObj := FileOpen(outputFile, 'w', 'UTF-8')
    fileObj.Write(snippetJSON)
    TrayTip("✅ Snippet đã được tạo tại:`n" outputFile, "Thành công", 2)
} catch as e
    TrayTip("Lỗi khi ghi file: " e.Message, "Lỗi", 3)
Run(outputFile)
ExitApp