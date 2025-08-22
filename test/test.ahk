; Get the current thread ID
threadID := DllCall("GetCurrentThreadId")

; Get the keyboard layout for this thread
currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "UPtr")

; Show it
A_Clipboard := Format("0x{:08x}", currentHKL)