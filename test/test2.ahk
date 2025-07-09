; Chuyển đổi file .json -> .json
#Requires AutoHotkey v2.0
#Include <JSON>
#SingleInstance Force
Persistent

infile := "input.json"
outfile := "output.json"
logFile := "log.txt"

obj := JSON.LoadFile(infile)
FileDelete(outfile)
FileAppend(JSON.Dump(obj), outfile)
Run(outFile)
Sleep(500)
Send("^+j")
Sleep(1000)
Send("^w")