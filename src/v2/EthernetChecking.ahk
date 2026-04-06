#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <core\Core>

;@Ahk2Exe-SetMainIcon ethernet_2.ico
Sleep(1000)
; --- Cấu hình ---
TargetMAC := "2C-F0-5D-6A-B7-29"
prevStatus := GetEthernetStatus(TargetMAC)

; Notify parameters riêng theo loại thông báo
notifyEthernetUp := "+ t5 s c90ee90"        ; Pastel xanh nhạt (Ethernet Up)
notifyEthernetDown := "+ t10 s cffb6b6"     ; Pastel đỏ nhạt (Ethernet Down)
notifyCheckInternetUp := "+ t5 s c90ee90"   ; Pastel xanh nhạt (Internet Up)
notifyCheckInternetDown := "+ t10 s cffb6b6" ; Pastel đỏ nhạt (Internet Down)
notifyAdapters := "+ t0.15 init s cf0f8ff"         ; Pastel xanh dương nhạt (Adapter list)
notifyCompile := "+ t5 s cafeeee"          ; Pastel xanh dương nhạt (Compile)
notifyReloadEdit := "+ t5 cfffacd"          ; Pastel vàng nhạt (Reload/Edit)

ShowNetworkAdapters()
; --- Kiểm tra Ethernet liên tục ---
SetTimer(CheckEthernet, 3000)

CheckEthernet() {
    global TargetMAC, prevStatus, notifyEthernetUp, notifyEthernetDown
    status := GetEthernetStatus(TargetMAC)
    if (status != prevStatus) {
        if (status = "Up") {
            Notify("Đã khôi phục kết nối mạng", "Ethernet Connected", notifyEthernetUp)
        } else if (status = "Down") {
            Notify("❌ MẤT KẾT NỐI ETHERNET!", "Ethernet Disconnected", notifyEthernetDown)
        }
        prevStatus := status
    }
}

GetEthernetStatus(targetMAC) {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    adapters := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE PhysicalAdapter=True")
    for adapter in adapters {
        mac := adapter.MACAddress
        if !mac
            continue
        mac := StrUpper(mac)
        mac := StrReplace(mac, ":", "-")
        if (mac = targetMAC) {
            connStatus := adapter.NetConnectionStatus
            return (connStatus = 2 ? "Up" : "Down")
        }
    }
    return "Unknown"
}

CheckEthernetNow() {
    global TargetMAC, notifyCheckInternetUp, notifyCheckInternetDown
    status := GetEthernetStatus(TargetMAC)
    if (status = "Up")
        return { content: "Internet Status", title: "Internet Connected ✅", params: notifyCheckInternetUp }
    else
        return { content: "Internet Status", title: "Internet Disconnected ❌", params: notifyCheckInternetDown }
}

ShowNetworkAdapters() {
    global notifyAdapters
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    adapters := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE PhysicalAdapter=True")

    ; Độ rộng cột (bao gồm margin)
    colName := 25
    colDesc := 40
    colStatus := 15
    margin := 1   ; số khoảng trống mỗi bên

    ; Tạo viền trên
    borderTop := "+" . Repeat(colName + margin * 2, "-") . "+" . Repeat(colDesc + margin * 2, "-") . "+" . Repeat(
        colStatus + margin * 2, "-") . "+`n"

    ; Header bảng với margin
    header := "|" . Repeat(margin, " ") . TextAlign("Name", [
        colName
    ], "l") . Repeat(margin, " ")
    header .= "|" . Repeat(margin, " ") . TextAlign("Description", [
        colDesc
    ], "l") . Repeat(margin, " ")
    header .= "|" . Repeat(margin, " ") . TextAlign("Status", [
        colStatus
    ], "m") . Repeat(margin, " ") . "|`n"

    ; Viền phân cách header
    borderMid := "+" . Repeat(colName + margin * 2, "-") . "+" . Repeat(colDesc + margin * 2, "-") . "+" . Repeat(
        colStatus + margin * 2, "-") . "+`n"

    msg := borderTop . header . borderMid

    for adapter in adapters {
        name := adapter.NetConnectionID
        if !name
            name := "N/A"
        desc := adapter.Description
        if !desc
            desc := "N/A"
        status := adapter.NetConnectionStatus
        statusText := (status = 2 ? "Connected" : status = 7 ? "Disconnected" : "Unknown")

        ; Cắt text nếu quá dài
        name := SubStr(name, 1, colName)
        desc := SubStr(desc, 1, colDesc)
        statusText := SubStr(statusText, 1, colStatus)

        ; Thêm dòng dữ liệu với margin
        msg .= "|" . Repeat(margin, " ") . TextAlign(name, [
            colName
        ], "l") . Repeat(margin, " ")
        msg .= "|" . Repeat(margin, " ") . TextAlign(desc, [
            colDesc
        ], "l") . Repeat(margin, " ")
        msg .= "|" . Repeat(margin, " ") . TextAlign(statusText, [
            colStatus
        ], "m") . Repeat(margin, " ") . "|`n"
    }

    ; Viền dưới
    borderBottom := "+" . Repeat(colName + margin * 2, "-") . "+" . Repeat(colDesc + margin * 2, "-") . "+" . Repeat(
        colStatus + margin * 2, "-") . "+`n"
    msg .= borderBottom

    Notify.Prototype.DefineProp("InitSetup", { Call: (this) => (
        this.defaultWidth := 920
    ) })
    Notify(msg, "Internet Adapters", notifyAdapters)
}

; ------------------- TrayMenu -------------------

scriptPath := 'D:\Documents\AutoHotkey\src\v2\EthernetChecking.ahk'
SplitPath(scriptPath, &scriptName, &scriptDir)

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()

A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', '&Recompile Ethernet Script', (*) => (
    Run('cmd /c ""D:\Documents\AutoHotkey\bin\build\ahk2exe-compile.bat" "' scriptPath '" && pause"'),
    Notify('Success!', 'Compile Success: ' scriptName, notifyCompile)
))

if (A_IsCompiled)
    A_TrayMenu.Insert('E&xit', '&Reload Ethernet Script', (*) => (
        Run(scriptPath),
        Notify(scriptName, 'Reload Script', notifyReloadEdit)
    ))
A_TrayMenu.Insert('E&xit', '&Edit Ethernet Script', (*) => (
    Run('code "' scriptPath '"'),
    Notify(scriptName, 'Edit Script', notifyReloadEdit)
))

A_TrayMenu.Insert('E&xit')
A_TrayMenu.Insert('E&xit', '&Check Internet Now', (*) => (
    info := CheckEthernetNow(),
    Notify(info.content, info.title, info.params)
))

A_TrayMenu.Insert('E&xit', '&Show Internet Adapters', (*) => ShowNetworkAdapters())
A_TrayMenu.Default := '&Show Internet Adapters'
A_TrayMenu.ClickCount := 1