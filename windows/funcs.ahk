;windows

;;FUNCTIONS

;kill active app or all it's instances
winAppKill(cmd := "show") { ;cmd: show|active|all instances
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)

  splitHotkey(A_ThisHotkey, &key)

  try {
    procName := WinGetProcessName("A")
  } catch {
    DetectHiddenWindows(dhw)
    return
  } else {
    title := WinGetTitle("A")
    if StrLen(title) > 25 {
      title := SubStr(title, 1, 25) Chr(0x2026)
    }
  }

  switch cmd, 0 {
    case "show":
      hk(procName "`n" title)

    case "active":
      WinKill("A")
      hk("Kill`n" procName "`n" title)

    case "all":
      WinKill("A")
      Run("taskkill /f /im " procName " /t",, "Hide")
      hk("Kill all instances of`n" procName)
  }
  DetectHiddenWindows(dhw)
}

;move window to prev/next desktop
winAppToDesktop(direction) {
  try {
    id := WinGetID("A")
    WinSetExStyle("^0x80", id)
    Sleep(50)
    Send("^#{" direction "}")
    WinSetExStyle("^0x80", id)
    Sleep(50)
    WinActivate(id)
  } catch {
    Send("^#{" direction "}")
  }
}

winCalculator() {
  static m := WidgetWindow("/windows/calculator.html",,, "center", "center")
  SetTimer((*) => m.Show(), -150)
}

;change dir in current file dialog, console, explorer or desktop
winChangeDir(path) {
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)

  try {
    id := WinGetID("A")
  } catch {
    DetectHiddenWindows(dhw)
    return
  }

  wClass := WinGetClass(id)

  total := "ahk_class TTOTAL_CMD"
  if path = "total" {
    if WinExist(total) {
      text := SendMessage(0x432, 0x11, 0, , total)
      path := StrSplit(WinGetText(text), ">")[1]
    } else {
      DetectHiddenWindows(dhw)
      return
    }
  }

  input := "Edit1"
  path := expandEnvVars(path)
  switch wClass, 0 {
    ;desktop
    case "Progman":
      Run('explorer.exe "' path '"')

    ;adobe bridge
    case "bridge14":
      selectLine()
      SendText(path "`n")

    ;files.app
    case "ApplicationFrameWindow":
      Send("^" wk("l"))
      Sleep(100)
      SendText(path "`n")

    ;cmd console, windows terminal
    case "ConsoleWindowClass", "CASCADIA_HOSTING_WINDOW_CLASS":
      clip := ClipboardAll()
      ; "Windows.UI.Composition.DesktopWindowContentBridge1": ;wsl console
      ;   path := StrReplace(StrReplace(path, ":", ""), "\", "/")
      ;   A_Clipboard := 'cd /mnt/"' path '"'
      A_Clipboard := 'cd /d "' path '"'
      Send("{Escape}")
      Sleep(50)
      Send("+{Insert}")
      Sleep(50)
      Send("{Enter}")
      A_Clipboard := clip

    ;explorer
    case "CabinetWClass":
      try {
        ControlClick("ToolbarWindow323", id, , , , "NA x1 y1")
        Sleep(200)
        ControlFocus(input, id)
        ControlSetText(path, input, id)
        ControlSend("{Right}{Enter}", input, id)
      } catch {
        Send("^" wk("l"))
        Sleep(200)
        SendText(path "`n")
        Sleep(100)
        Send("{Escape}")
      }

    ;file dialog
    default:
      text := ControlGetText(input, id)
      if !WinGetControls(id).indexOf("#327701") {
        Send("^" wk("l"))
        Sleep(500)
        Send("^{Home}")
        Sleep(0)
        Send("^{End}")
        focus := ControlGetFocus(id)
        input := ControlGetClassNN(focus)
      }

      ControlSetText(path, input, id)
      ControlFocus(input, id)
      Sleep(50)
      ControlSend("{Right}{Enter}", input, id)
      if input = "Edit1" {
        Sleep(100)
        ControlSetText(text, "Edit1", id)
      }
      ControlFocus("Edit1", id)
  }
  DetectHiddenWindows(dhw)
  hk('cd "' path '"')
}

;expand dropbox link in clipboard
winDropbox(*) {
  if InStr(A_Clipboard, "https://www.dropbox") {
    db := "www.dropbox.com"
    dl := "dl.dropboxusercontent.com"
    A_Clipboard := StrReplace(A_Clipboard, db, dl)
    info("ok")
  }
}

;switch keyboard layout: one or two languages (second with longtap)
winLayout(firstLayout := "", secondLayout := "") {
  static oldTickCount := 0
  static delay := 250
  static x := 0
  static y := 0

  if !IsSpace(firstLayout) {
    if LTrim(A_ThisHotkey, "~*") = (A_PriorKey " up") {
      CoordMode("Caret", "Screen")
      CoordMode("Mouse", "Screen")

      CaretGetPos(&x, &y) or MouseGetPos(&x, &y)

      time := A_TickCount - oldTickCount
      if time < delay {
        layout := firstLayout
      } else if !IsSpace(secondLayout) and (time < delay * 2) {
        layout := secondLayout
      } else {
        layout := ""
      }

      if !IsSpace(layout) {
        setKeyboardLayout(layout)
        Sleep(50)
        conf := { time: 0.3, x: x, y: y + 20 }
        hint(getKeyboardLayout().lang, conf)
      }
    }
    oldTickCount := 0

  } else if !oldTickCount {
    oldTickCount := A_TickCount
  }
}

;pass generate
winPwGen(length, low := 33, hight := 126) {
  loop length {
    pass .= Chr(Random(low, hight))
  }
  A_Clipboard := pass
}

winToggleLockKeyboardLayout() {
  static layoutsList := ttk.LockLayout? ?? false
  static indent := "    "

  if !layoutsList {
    return
  }

  if toggle("layoutsLock") {
    layouts := layoutsList.keys().join("`n   ")
    SetTimer((*) => info("Keyboard layout locked:`n   " layouts), -50)
    watcherTimeout := 250
  } else {
    SetTimer((*) => info("Keyboard layout unlocked"), -50)
    watcherTimeout := 0
  }

  SetTimer(() {
    for app, layout in layoutsList {
      if WinActive("ahk_exe " app ".exe") {
        setKeyboardLayout(layout)
      }
    }
  }, watcherTimeout)
}

;window manipulation
winWindow(action, ThisHotkey?) {
  ThisHotkey ??= A_ThisHotkey
  splitHotkey(ThisHotkey, &key)

  switch action, 0 {
    default: ;resize - "WxH"
      if RegExMatch(action, "(\d+)x(\d+)", &match) {
          x := match[1]
          y := match[2]
          w := x + 7 * 2
          h := y + 28 + 7
          WinMove(, , w, h, "A")
          hk("Window: " x "x" y)
        } else {
          err("Check " A_ThisFunc " args")
        }

    case "expand":
      try {
        WinRestore("A")
      } catch {
        return
      }

      if getViewport(&l, &t, &r, &b, &w, &h) {
        off := { l: -6, t: -1, r: 12, b: 1 }
        WinMove(l + off.l, t + off.t, w + off.r, h + off.b, "A")
        hk("Window: Expand")
      } else {
        err("Can't detect monitor")
      }

    case "ghost": ;toggle window opacity & clickthrough
      try {
        static ghostTransparent := 192
        if (WinGetExStyle("A") & 0x20) {
          WinSetExStyle("-0x20", "A")
          WinSetTransparent("Off", "A")
          WinSetAlwaysOnTop(0, "A")
          hk("Ghost: Off")
        } else {
          WinSetExStyle("+0x20", "A")
          WinSetTransparent(ghostTransparent, "A")
          WinSetAlwaysOnTop(1, "A")
          hk("Ghost: On")
        }
      }

    case "maximize":
      if WinGetMinMax("A") {
        WinRestore("A")
        hk("Window: Restore")
      } else {
        WinMaximize("A")
        hk("Window: Maximize")
      }

    case "move", "resize", "resize symmetric":
      dhw := A_DetectHiddenWindows
      DetectHiddenWindows(1)

      hwnd := WinActive("A")
      DetectHiddenWindows(dhw)

      try {
        if !WinGetMinMax(hwnd) {
          CoordMode("Mouse", "Screen")
          MouseGetPos(&x1, &y1)
          loop {
            MouseGetPos(&x2, &y2)
            dx := x2 - x1
            dy := y2 - y1
            WinGetPos(&x, &y, &ofR, &ofB, hwnd)

            if KeyWait(key, "T.001") {
              break
            }

            switch action, 0 {
              case "move":
                x1 := x2
                y1 := y2
                WinMove(x + dx, y + dy,,, hwnd)
                hk("Window: move")

              case "resize":
                MouseMove(x1, y1)
                WinMove(x, y, ofR + dx, ofB + dy, hwnd)
                hk("Window: resize")

              case "resize symmetric":
                MouseMove(x1, y1)
                WinMove(x - dx/2, y - dy/2, ofR + dx, ofB + dy, hwnd)
                hk("Window: resize symmetric")
            }
          }
        }
      }

    case "opacity":
      hk(opacity())

    case "pixels":
      getPixelsUnderMouse()
      hk("Get pixels under mouse")

    case "always on top":
      dhw := A_DetectHiddenWindows
      DetectHiddenWindows(1)
      WinSetAlwaysOnTop(-1, "A")
      hk("Always on top: " (WinGetExStyle("A") & 0x8 ? "On" : "Off"))
      DetectHiddenWindows(dhw)

    case "typematic":
      reg := "HKCU\Control Panel\Accessibility\Keyboard Response"
      try {
        if RegRead(reg, "Flags") = 26 {
          RegWrite("27", "REG_SZ", reg, "Flags")
          hk("typematic: off")
        } else {
          RegWrite("26", "REG_SZ", reg, "Flags")
          hk("typematic: on")
        }
      }

    case "zen": ;fullscreen without menu and titlebar
      static menuArray := Map()

      if id := WinExist("A") {
        WinSetStyle("^" 0xC00000, "A")

        if menuArray.Has(id) { ;exit zen
          winState := menuArray[id].winState
          hMenu := menuArray[id].hMenu
          menuArray.Delete(id)
          WinRestore()
          if winState {
            WinMaximize()
          }
          hk("Zen: Off")

        } else { ;enter zen
          hMenu := 0
          winState := WinGetMinMax()
          menuArray[id] := {
            hMenu: DllCall("GetMenu", "uInt", id),
            winState: winState
          }
          if winState {
            WinRestore()
          }
          WinMaximize()
          hk("Zen: On")
        }
        DllCall("SetMenu", "uInt", id, "uInt", hMenu)
      }
  }
}