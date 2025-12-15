#NoTrayIcon
#SingleInstance force

progID   := A_Args.RemoveAt(1)
fileName := A_Args.RemoveAt(1)

args := ComObjArray(VT_VARIANT := 12, A_Args.Length)
loop A_Args.Length {
  args[A_Index - 1] := A_Args[A_Index]
}

app := ComObject(progID)
result := app.DoJavaScriptFile(fileName, args, 1)
FileAppend(result, "*")