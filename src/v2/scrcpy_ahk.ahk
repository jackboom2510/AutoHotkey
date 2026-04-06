#SingleInstance Force
#Include <core\Core>
#Include <core\cJSON>
;@Ahk2Exe-SetMainIcon D:\2. Program Files\scrcpy-win64-v3.3.2\scrcpy.ico

try {
    config := cJSON.LoadFile("D:\Documents\AutoHotkey\configs\scrcpy.json", "UTF-8")
} catch as err {
    Run("D:\Documents\AutoHotkey\configs\scrcpy.json")
    Notify("Error while Load Config: " err.Message, "Scrcpy - ERROR!", "+ w t10 ce")
    ExitApp
}

try {
    GetCmdOutput(cmd) {
        shell := ComObject("WScript.Shell")
        exec := shell.Exec("cmd.exe /c " cmd)
        return exec.StdOut.ReadAll()
    }
    devices := GetCmdOutput("adb devices")
    devices := Trim(devices, '`r`n `t')
    start := A_TickCount
    while (!devices || A_TickCount - start <= 5000)
        Sleep(100)
}
catch as err {
    Notify("Error: " err.Message, "Error", "+ t3 w ce")
    ExitApp
}

if RegExMatch(devices, "i)List of devices attached\s*$") {
    Notify("Không có thiết bị nào được kết nối", "ADB Devices", "+ t3 w ce")
    ExitApp
}
else {
    runTime := A_TickCount - start
    Notify.Prototype.DefineProp("AfterSetup", { Call: (this) => (
        btn1 := this.gui.AddButton("y+10 w100", "USB"),
        btn2 := this.gui.AddButton("yp w100", "Wi-fi"),
        btn3 := this.gui.AddButton("yp w100", "Close"),
        btn1.OnEvent("Click", (*) => (
            usb := config["usb_bat"],
            Notify("scrcpy --keyboard=uhid -d --select-usb", , "+ t5"),
            Run(usb, config["bin_folder"], 'Hide'),
            ExitApp
        )),
        btn2.OnEvent("Click", (*) => (
            wifi := config["wifi_bat"],
            phone_ip := config["phone_ip_address"],
            Notify("scrcpy --keyboard=uhid -s " phone_ip, , "+ t5"),
            Run(wifi, config["bin_folder"], 'Hide'),
            ExitApp
        )),
        btn3.OnEvent("Click", (*) => ExitApp()),
        this.guiPos.h += ((SysGet(80) >= 2) ? 40 : 10)
    ) })
    try {
        Notify(devices, "ADB Devices",
            "+ w t15 ra ci"
            ; " sb{+right xm+330 yp+15 w140}{" runTime "ms}"
        )
    }
}

ExitApp