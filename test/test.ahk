#Requires AutoHotkey v2.0+
#SingleInstance Force

mygui := Gui("+AlwaysOnTop -DPIScale")
mygui.SetFont("s15", 'Arial')
arr := ['', 'T', 'T*', 'ST', 'ST*', '*']
ddl := mygui.AddDDL('vopts Choose4', arr)
cb := mygui.AddCheckbox('x150', 'Select')
cb.SetFont('s14 italic')

cb.OnEvent("Click", (*) => On_CBClick(cb.value))
On_CBClick(Checked) {
    selectedIdx := ddl.value
    if (Checked) {
        for idx, val in arr {
            arr[idx] := 'C1 ' arr[idx]
        }
        ddl.Delete()
        ddl.Add(arr)
        ddl.Choose(selectedIdx)
    }
    else {
        for idx, val in arr {
            arr[idx] := RegExReplace(arr[idx], '(.*)\s(.*)', '$2')
        }
        ddl.Delete()
        ddl.Add(arr)
        ddl.Choose(selectedIdx)
    }
}

mygui.Show()