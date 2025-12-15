;adobe photoshop functions

;;INIT
  ps := { scriptsPath: dirName(A_LineFile) "\scripts" }

;;FUNCTIONS

psRunScript(script, arguments*) {
  scriptPath := StrReplace(script, " > ", "\")

  if !(FileExist(scriptName := ps.scriptsPath "\" scriptPath ".js")
    or FileExist(scriptName .= "x")
    or FileExist(scriptName := scriptPath)
  ) {
    err("Can't find script file:`n" script)

  } else {
    hk(A_ThisFunc "`n" script)
    Run('"' WinGetProcessPath("A") '" "' scriptName '"')
  }
}

psMode(title := "") {
  if !IsSpace(title) {
    title .= " "
  }
  return WinActive(title "ahk_exe Photoshop.exe")
     and isMouseOn("active app")
     and !isWinActive("modal")
     and !isMouseOn("screen's top edge")
}