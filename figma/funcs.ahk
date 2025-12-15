;figma functions

;;INIT
  fg := {}

  fg.sidebar := Map("left", 240, "right", 240)
  fg.confPath := dirName(A_LineFile)

  fg.dict := { keys: YAML.parse(FileRead(fg.confPath "\dicts\keys.yaml"), 0) }

;;FUNCTIONS

fgAction(text?, enter := true, timeout := 600) {
  fgTap("actions...")

  if !IsSet(text) {
    return
  }

  Sleep(50)
  Send("{Raw}" text)
  Sleep(timeout)

  if enter {
    Send("{Enter}")
  }

  return text
}

fgMode() {
  return (WinActive("ahk_exe Figma.exe")
          or WinActive("ahk_exe Figma Beta.exe"))
     and isMouseOn("active app")
     and !isWinActive("modal")
}

fgTap(alias, blind := false) {
  if !fg.dict.keys.Has(alias) {
    err("Cant't find hotkey in dict")
  } else {
    Sleep(50)
    blind := blind ? "{Blind}" : "{Blind!^+#}"
    tap(blind fg.dict.keys[alias])
    hk(StrTitle(alias))
  }
}

fgZeroValue(cmd := "down") {
  static oldTickCount := 0
  static x0 := 0
  static y0 := 0

  CoordMode("Mouse", "Window")

  if cmd = "down" {
    MouseGetPos(&x0, &y0)
    oldTickCount := A_TickCount

  } else { ;cmd = up
    Sleep(50)
    MouseGetPos(&x1, &y1)
    WinGetPos(,, &w,, "A")
    if (x1 - x0 = 0) and (y1 - y0 = 0)
    and (x1 > w - fg.sidebar["right"]) {
      mousePos("push")

      if A_Cursor = "SizeWE" {
        Click("30 0 Relative")
      } else {
        Click(1)
      }

      if A_TickCount - oldTickCount < 250 {
        selectLine()
        Send("0{Enter}")
        hk("zero input value")
      }
      mousePos("pop")
    }
  }
}