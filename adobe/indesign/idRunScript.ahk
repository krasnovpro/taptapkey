#NoTrayIcon
#SingleInstance force

progID   := A_Args.RemoveAt(1)
fileName := A_Args.RemoveAt(1)

ScriptLanguage := {
  JAVASCRIPT:         1246973031,
}

UndoModes := {
  AUTO_UNDO:          1699963221, ;Automatically undo the entire script as part of the previous step
  ENTIRE_SCRIPT:      1699963733, ;Undo the entire script as a single step
  FAST_ENTIRE_SCRIPT: 1699964501, ;Fast undo the entire script as a single step
  SCRIPT_REQUEST:     1699967573, ;Undo each script request as a separate step
}

args := ComObjArray(VT_VARIANT := 12, A_Args.Length)
loop A_Args.Length {
  args[A_Index - 1] := A_Args[A_Index]
}

app := ComObject(progID)
result := app.DoScript(
  fileName,
  ScriptLanguage.JAVASCRIPT,
  args,
  UndoModes.ENTIRE_SCRIPT,
  'main'
)

FileAppend(result, "*")
