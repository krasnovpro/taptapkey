;taptapkey functions
;created by @krasnovpro

ttk := {} ;taptapkey variables object
ttk.dir := A_ScriptDir
ttk.link := "https://github.com/krasnovpro/taptapkey"

;;CLASSES
  class WidgetBase {
    ;TODO: switch to WebViewToo
    ;TODO: check files in the constructor
    __New(setTransparent := true) {
      this.host := "localhost"
      this.url := "http://" this.host "/lib/widget/index.html"
      this._WebView2(setTransparent)
      this._AddHostObject()

      CoordMode("Mouse", "Screen")
      MouseGetPos(&mouseX, &mouseY)
      this.mouseX := mouseX
      this.mouseY := mouseY
    }

    _WebView2(setTransparent := true) {
      this.gui := Gui("-Caption -Resize -DPIScale +ToolWindow")
      this.gui.OnEvent('Close', (*) => (this.wvc := this.wv := 0))

      ;setting a transparent background
      if setTransparent {
        this.gui.BackColor := "Black"
        NumPut("int",-1, "int",-1, "int",-1, "int",-1, MARGINS := Buffer(16))
        DllCall(
          "dwmapi\DwmExtendFrameIntoClientArea",
          "ptr", this.gui.hwnd, "ptr", MARGINS
        )
      }

      this.Show()

      ;binding webview2 to the gui window
      this.wvc := WebView2.CreateControllerAsync(this.gui.hwnd).await2()
      this.wvc.DefaultBackgroundColor := 0
      this.wvc.MoveFocus(0)
      this.wv := this.wvc.CoreWebView2

      this.wv.SetVirtualHostNameToFolderMapping(
        this.host,
        ttk.dir,
        WebView2.HOST_RESOURCE_ACCESS_KIND.ALLOW
      )
    }

    _AddHostObject() {
      hostObject := this._GetHostObject()
      this.wv.AddHostObjectToScript('ahk', hostObject)
    }

    _CheckFiles(args*) {
      for file in args {
        if !FileExist(ttk.dir file) {
          err("File not found:`n" file)
          return false
        }
      }
    }

    _GetHostObject() {
      hostObject := {}
      hostObject.fun  := ObjBindMethod(this, "Fun"),
      hostObject.hide := ObjBindMethod(this, "Hide")
      hostObject.open := ObjBindMethod(this, "Open")
      return hostObject
    }

    _Navigate(args) {
      ;TODO: change url params to the ExecuteScript
      result := ""
      for k, v in args {
        result .= k "=" urlEncode(v) "&"
      }
      this.wv.Navigate(this.url "?" result)
    }

    Open(text) => Run(text)

    Fun(text) {
      args := []
      if (text is ComObjArray) {
        for k, v in text {
          args.push(v)
        }
        funcName := args.RemoveAt(1)

      } else if (text is String) {
        if IsSpace(text) {
          err("The function's name is empty")
          return
        }
        text := YAML.parse(text)
        if !(text is Array) {
          err("Parsed string is not an array: " Type(text) "`n" string(text))
          return
        }
        funcName := text.RemoveAt(1)
        args := text
      } else {
        err("Error in arg type: " Type(text))
        return
      }
      if IsSet(%funcName%) and (%funcName% is Func) {
        %funcName%.Call(args*)
      } else {
        err("Can't find '" funcName "' function")
      }
    }

    RunScript(arg) => this.wv.ExecuteScriptAsync(arg)

    Hide() => this.gui.Hide()

    Show(icons := "") {
      this.gui.Show(
        "x" SysGet(SM_XVIRTUALSCREEN  := 76) " "
        "y" SysGet(SM_YVIRTUALSCREEN  := 77) " "
        "w" SysGet(SM_CXVIRTUALSCREEN := 78) " "
        "h" SysGet(SM_CYVIRTUALSCREEN := 79) " "
      )

      if (this.wv? ?? false) {
        CoordMode("Mouse", "Window")
        MouseGetPos(&mouseX, &mouseY)

        code := "window.moveWindow(" mouseX ", " mouseY ");"
        if icons {
          icons := jsEscape(icons)
          code .= " window.syncIcons('" icons "');"
        }

        this.wv.ExecuteScriptAsync(code)
      }
    }
  }

  class WidgetWindow extends WidgetBase {
    __New(
      dataFile      := "",
      spritesFile   := "",
      stylesFile    := "",
      offsetX       := 0,
      offsetY       := 0
    ) {
      this._CheckFiles(dataFile, spritesFile, stylesFile)
      MonitorGetWorkArea(, &winLeft, &winTop, &winRight, &winBottom)

      super.__New()
      this._Navigate(Map(
        "windowType",  "window",
        "dataFile",    dataFile,
        "spritesFile", spritesFile,
        "stylesFile",  stylesFile,
        "mouseX",      this.mouseX,
        "mouseY",      this.mouseY,
        "offsetX",     offsetX,
        "offsetY",     offsetY,
        "winLeft",     winLeft,
        "winTop",      winTop,
        "winRight",    winRight,
        "winBottom",   winBottom,
      ))
    }
  }

  class WidgetMenu extends WidgetBase {
    ;TODO: prevent the menu from flying off the screen
    __New(
      dataFile      := "",
      spritesFile   := "",
      stylesFile    := "",
      helpPath      := "",
      offsetX       := 0,
      offsetY       := 0
    ) {
      this._CheckFiles(dataFile, spritesFile, stylesFile)

      if !DirExist(ttk.dir helpPath) {
        err("Help folder not found:`n" helpPath)
      }

      MonitorGetWorkArea(, &winLeft, &winTop, &winRight, &winBottom)

      super.__New()
      this._Navigate(Map(
        "windowType",  "menu",
        "dataFile",    dataFile,
        "spritesFile", spritesFile,
        "stylesFile",  stylesFile,
        "helpPath",    helpPath,
        "mouseX",      this.mouseX,
        "mouseY",      this.mouseY,
        "offsetX",     offsetX,
        "offsetY",     offsetY,
        "winLeft",     winLeft,
        "winTop",      winTop,
        "winRight",    winRight,
        "winBottom",   winBottom,
      ))
    }
  }

  class WidgetFuncs extends WidgetBase {
    __New(
      dataFile      := "",
      spritesFile   := "",
      stylesFile    := "",
      offsetX       := 0,
      offsetY       := 0,
      cols          := 8,
      rows          := 3
    ) {
      this._CheckFiles(dataFile, spritesFile, stylesFile)
      this.parentPid := 0

      ;set window size
      u := 4
      for v in ["vars", "user"] {
        f := ttk.dir "\lib\widget\" v ".css"
        if FileExist(f) {
          vars := FileRead(f)
          if RegExMatch(vars, "--u:\s*(\d+)px;", &m) {
            u := m[1]
          }
        }
      }

      s := Map(
        "icon-size"   , u *  6,
        "tab-cell"    , u * 10,
        "shadow-shift", u *  4,
        "shadow-size" , u * 12,
      )

      this.width   := cols * s["tab-cell"] + 2 * s["shadow-size"]
      this.height  := rows * s["tab-cell"] + 2 * (s["shadow-size"] + s["icon-size"] + u)
      this.offsetX := offsetX - s["shadow-size"]
      this.offsetY := offsetY - (s["shadow-size"] - s["shadow-shift"])

      ;hide child window, when parent window loses focus
      this.hideChildWin := ObjBindMethod(this, "_hideChildWin")
      this.hideChildWinTimeout := 350

      super.__New(true)
      this._Navigate(Map(
        "windowType",  "funcs",
        "dataFile",    dataFile,
        "spritesFile", spritesFile,
        "stylesFile",  stylesFile,
      ))

      OnMessage(WM_ACTIVATE := 0x6,
        (wp, lp, msg, hwnd) {
          if hwnd = this.gui.hwnd {
            this.RunScript('window.focusFuncs("' (wp ? 'add' : 'remove') '")')
          }
        }
      )
    }

    _GetHostObject() {
      hostObject := super._GetHostObject()
      hostObject.dragWindow := ObjBindMethod(this, "DragWindow")
      return hostObject
    }

    _hideChildWin() {
      isActiveWin() {
        isThisWindow   := WinActive("ahk_id" this.gui.Hwnd)
        isParentWindow := ((this.parentPid) and WinActive("ahk_pid" this.parentPid))
        isAHKWindow    := WinActive("ahk_pid" ProcessExist())
        isDebug        := ttk?.widgetDebug? ?? false

        return (isThisWindow or isParentWindow or isAHKWindow or isDebug)
      }

      if !isActiveWin() {
        Sleep(100)
        if !isActiveWin() {
          this.Hide()
          SetTimer(this.hideChildWin, 0)
        }
      }
    }

    DragWindow() {
      DllCall("ReleaseCapture")
      SendMessage(0x00A1, 2,, this.gui)
    }

    Show(activateHotkey := "", parentPid := 0) {
      static x, y
      static showFuncsAtMousePos := "true"
      CoordMode("Mouse", "Screen")

      if !IsSpace(activateHotkey) {
        HotIfWinActive("ahk_id" this.gui.Hwnd)
        Hotkey(activateHotkey, (*) => this.Show())
      }

      if (this.wv? ?? false) {
        showFuncsAtMousePos := this.wv
        .ExecuteScriptWithResultAsync('window.appState.showFuncsAtMousePos')
        .Await().ResultAsJson
      }

      if parentPid {
        this.parentPid := parentPid
        this.gui.Opt("+AlwaysOnTop")
        SetTimer(this.hideChildWin, this.hideChildWinTimeout)
      }

      if !IsSet(x) or (showFuncsAtMousePos = "true")  {
        MouseGetPos(&mouseX, &mouseY)
        x := mouseX + this.offsetX
        y := mouseY + this.offsetY

        this.gui.Show(
          "x" x " "
          "y" y " "
          "w" this.width " "
          "h" this.height " "
        )
      } else {
        this.gui.Show()
      }
    }
  }

;;FUNCTIONS

;return active app process id
appGetPID() {
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)
  try {
    result := WinGetPID("A")
  } catch {
    result := 0
  }
  DetectHiddenWindows(dhw)
  return result
}

;get active app version
appGetVer() => FileGetVersion(ProcessGetPath(appGetPID()))

bin2dec(n) => convertBase( 2, 10, n)

blindSend(key) {
  static aliases := strMap("
  (LTrim Join`s
    Up ⏶ Down ⏷ Left ⏴ Right ⏵
    PgUp Page⏶ PgDn Page⏷ Enter ↩
    NumpadUp Numpad⏶ NumpadDown Numpad⏷
    NumpadLeft Numpad⏴ NumpadRight Numpad⏵
    NumpadPgUp NumpadPage⏶ NumpadPgDn NumpadPage⏷
    NumpadMult Numpad * NumpadDiv Numpad /
    NumpadAdd Numpad + NumpadSub Numpad −
    NumpadEnter Numpad ↩ NumpadClear o_O
  )")

  static numSubst := strMap("
    (LTrim Join`s
      Numpad1 NumpadEnd Numpad2 NumpadDown Numpad3 NumpadPgDn
      Numpad4 NumpadLeft Numpad5 NumpadClear Numpad6 NumpadRight
      Numpad7 NumpadHome Numpad8 NumpadUp Numpad9 NumpadPgUp
      Numpad0 NumpadIns Numpad. NumpadDel
    )")

  if (SubStr(key, 1, 6) = "NumPad") and GetKeyState("NumLock", "T") {
    key := numSubst.Get(key, key)
  }

  Send("{Blind}{" key "}")
  splitHotkey(isKeyDown("mods"),, &mods, "verb")
  hk(mods aliases.Get(key, key))
}

;build custom windows popup menu
buildMenu(text) {
  result := menu()
  for v in loadTable(text) {
    if v["title"] = "-" { ;separator
      result.Add()
    } else {
      title := v["title"]
      key   := v["key"]
      fun   := v["fun"]
      icon  := v["icon"]

      if IsSpace(v["args"]) or (v["args"] = "·") {
        args := [unset]
      } else {
        args := []
        loop Parse v["args"], "CSV" {
          args.push(Trim(A_LoopField))
          if A_LoopField == "" {
            args.Delete(A_Index)
          }
        }
      }

      keys := strMap("Tab|`tTab|Space|`sSpace|``|``~|~|``~|·|", "|")
      key := keys.Get(key, key)

      if IsSpace(key) {
        fullTitle := title
      } else {
        fullTitle := title "`t&" key
      }

      result.Add(
        fullTitle, (
          (title, fun, args, *) => (hint(title) "`n" %fun%(args*))
        ).Bind(title, fun, args)
      )

      if !IsSpace(icon) {
        iconArr := []
        loop Parse icon, "CSV" {
          iconArr.push(A_LoopField)
        }
        result.SetIcon(
          fullTitle, expandEnvVars(iconArr[1]),
          iconArr.Has(2) ? iconArr[2] : 1
        )
      }
    }
  }
  return result
}

;call string func or object with args
call(var, args*) {
  switch getType(var), 0 {
    default:
      err("The '" var "' is not function")

    case "Func":
      return var(args*)

    case "'Func'":
      return %var%(args*)

    case "'ObjFunc'":
      obj := StrSplit(var, '.')
      method := t := %obj[1]%
      loop obj.Length - 1 {
        method := method.%obj[A_Index + 1]%
      }
      if Type(method) = "Func" {
        return method(t, args*)
      } else {
        err("The '" var "' is not object")
      }
  }
}

;toggle capslock key
capsLock(ThisHotkey?) {
  static oldTickCount := 0
  static delay := 250
  result := ""

  if SubStr(ThisHotkey ?? A_ThisHotkey, -2) = "up" {
    delta := A_TickCount - oldTickCount
    if (A_PriorKey = "CapsLock") and (delta < delay) {
      if ttk?.capsLockEnable? ?? true {
        if GetKeyState("CapsLock", "T") {
          SetCapsLockState("AlwaysOff")
          result := "Off"
        } else {
          SetCapsLockState("AlwaysOn")
          result := "On"
        }
      } else SetCapsLockState("AlwaysOff")
    }
    oldTickCount := 0
  } else {
    if oldTickCount = 0 {
      oldTickCount := A_TickCount
    }
  }

  if result {
    hk(result)
  }
}

;set working dir from current file's dir + subpath
cd(file, subPath := "") {
  result := dirName(file) subPath
  SetWorkingDir(result)
  return result
}

;convert string of chars to hex with separator
chr2hex(str, separator := "") {
  hex := Array()
  ; loop Parse str {
  ;   VarSetStrCapacity(&s, 65)
  ;   DllCall(
  ;     "msvcrt.dll\_i64tow",
  ;     "Int64",Ord(A_LoopField), "Str",s, "UInt",16, "CDECL"
  ;   )
  ;   hex.Push(s)
  ; }

  u16to8(arg) {
    if arg < 0x80 {
      result := toHex2(arg)
    } else {
      if arg < 0x800 {
        result := toHex2(arg >> 6 & 0x1f | 0xc0)
      } else {
        result := toHex2(arg >> 12 | 0xe0)
                . toHex2(arg >> 6 & 0x3f | 0x80)
      }
      result .= toHex2(arg & 0x3f | 0x80)
    }
    return result
  }

  toHex2(num) => SubStr(Format("{:X}", num), -2)

  loop Parse str {
    hex.Push(u16to8(Ord(A_LoopField)))
    ; hex.Push(Format("{:X}", Ord(A_LoopField)))
  }
  return hex.join(separator)
}

;measure time, first run - start, second - stop
clock(slot := 1) { ;any unique number
  static timers := Map()
  if timers.Get(slot, false) {
    delta := A_TickCount - timers[slot]
    timers[slot] := 0
    return delta
  } else {
    timers[slot] := A_TickCount
  }
}

;convert ComObjArray to Array
comArr(arr) {
  if arr is ComObjArray {
    result := []
    for t in arr {
      result.Push(t)
    }
    return result
  } else {
    throw ValueError("The argument is not ComObjArray", -2, arr)
  }
}

;click right mouse button for context menu
contextMenu() => SetTimer((*) => Send("{RButton}"), -100)

;number converter
convertBase(InputBase, OutputBase, number) { ;Base 2 - 36
  VarSetStrCapacity(&s, 66)
  v := DllCall(
    "msvcrt.dll\_wcstoui64",
    "Str",number, "UInt",0, "UInt",InputBase, "CDECL Int64"
  )
  DllCall(
    "msvcrt.dll\_i64tow",
    "Int64",v, "Str",s, "UInt",OutputBase, "CDECL"
  )
  return s
}

;print current date
date(format := "dd.MM.yyyy", daysOffset := 0) {
  if daysOffset {
    result := FormatTime(DateAdd(A_Now, daysOffset, "Days"), format)
  } else {
    result := FormatTime(, format)
  }
  Send(result)
}

dec2bin(n) => convertBase(10,  2, n)

dec2hex(n) => convertBase(10, 16, n)

;read decimal separator from system
decSeparator() {
  static ds := RegRead("HKCU\Control panel\International", "sDecimal", ",")
  return ds
}

;delete the word to the position of the cusros
deleteWord(position) {
  Send("{Control down}{Shift down}")
  Sleep(10)
  Send("{" position "}")
  Sleep(10)
  Send("{Shift up}{Control up}")
  Send("{Delete}")
}

dirName(path) => (SplitPath(path,, &dir), dir)

;show error
err(msg?) {
  conf := { time:3, slot:9, x:100, y:(A_ScreenHeight - 100) }

  if IsSet(msg) {
    hint("Error:`n" msg, conf)
    log("err(" msg ")")
  } else {
    hint(, conf)
  }
}

;expand batch %vars%
expandEnvVars(path) {
  VarSetStrCapacity(&dest, 2000)
  DllCall(
    "ExpandEnvironmentStrings",
    "Str",path, "Str",dest, "Int",1999,
    "Cdecl int"
  )
  return dest
}

fileGetProductName(filePath) {
  if !FileExist(filePath) {
    return err("File does not exist")
  }

  ;get buffer size
  size := DllCall(
    "version.dll\GetFileVersionInfoSizeW",
    "Ptr",StrPtr(filePath), "Ptr",0, "UInt"
  )
  if size <= 0 {
    return err("No version data in the file")
  }

  ;allocate buffer and extract version data
  buf := Buffer(size, 0)
  if !DllCall(
    "version.dll\GetFileVersionInfoW",
    "Ptr",StrPtr(filePath), "UInt",0, "UInt",size, "Ptr",buf.Ptr
  ) {
    return err("Failed to extract version data (HRESULT: " . A_LastError . ")")
  }

  ;dynamically get Translation for langCode (universal for any language)
  transQuery := "\\VarFileInfo\\Translation"
  transPtr := 0
  transLen := 0
  if !DllCall(
    "version.dll\VerQueryValueW",
    "Ptr",buf.Ptr, "Ptr",StrPtr(transQuery), "Ptr*",&transPtr, "UInt*",&transLen
  ) {
    langCode := "040904E4" ;fallback to US English
  } else if (transLen > 0) {
    ;translation is WORD low (lang) + WORD high (codepage), in little-endian
    lowWord  := NumGet(transPtr, 0, "UShort") ;lang ID (e.g., 0409)
    highWord := NumGet(transPtr, 2, "UShort") ;codepage (e.g., 04E4)
    langCode := Format("{:04X}{:04X}", lowWord, highWord)
  } else {
    langCode := "040904E4" ;default
  }

  ;form the key for ProductName
  query := "\\StringFileInfo\\" langCode "\\ProductName"

  ;query the value
  valPtr := 0
  len    := 0
  if !DllCall(
    "version.dll\VerQueryValueW",
    "Ptr",buf.Ptr, "Ptr",StrPtr(query), "Ptr*",&valPtr, "UInt*",&len
  ) {
    return err("Failed to find ProductName (HRESULT: " . A_LastError . ")")
  }

  ;read the string from the buffer (fixed: to null-terminator, without len//2!)
  if valPtr = 0 || len <= 0 {
    return err("ProductName not found or empty")
  }
  productName := StrGet(valPtr, "UTF-16")  ;read to null — full string!

  ;additional check for emptiness (rare, but for robustness)
  if (StrLen(productName) = 0) {
    return err("ProductName found, but empty (possibly corrupted resource)")
  }

  return productName
}

fileReadLine(filePath, line) {
  data := ""
  loop Read filePath {
    if A_Index = line {
      data := A_LoopReadLine
      break
    }
  }
  return data
}

fileWrite(text, file, encoding?) {
  if IsSet(encoding) {
    f := FileOpen(file, "w", encoding)
  } else {
    f := FileOpen(file, "w")
  }
  f.write(text)
  f.close()
  ; try FileMove(file, file ".bak", 1)
  ; FileAppend(text, file, option ?? "")
  ; try FileDelete(file ".bak")
}

getClsIdFromProgId(progID) {
  clsid := Buffer(16)
  result := DllCall("ole32\CLSIDFromProgID", "Str", ProgID, "Ptr", clsid)

  if result = 0 {
    guid := Buffer(39 * 2)

    CharsWritten := DllCall(
      "ole32\StringFromGUID2",
      "Ptr",clsid,
      "Ptr",guid,
      "Int",guid.Size // 2
    )

    if (CharsWritten > 0) {
      return StrGet(guid, "UTF-16")
    } else {
      err("Failed to convert CLSID to string. LastError: " A_LastError)
    }
  } else {
    err(
      "Failed to get CLSID for '" ProgID
      . "'`nHRESULT: " . Format("0x{:X}", result)
      . ".`nLastError: " A_LastError
    )
  }
}

getKeyboardLayout() {
  ;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=28258
  try {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(1)
    if WinGetClass("A") = "ConsoleWindowClass" {
      ;detect layout in console windows:
      ;https://github.com/Elfy/getconkbl
      ;https://www.autohotkey.com/boards/viewtopic.php?f=76&t=69414&hilit=0x4090409

      ctrlID := WinGetID("A")
      static conkblPath := ttk.dir "\lib\getconkbl.dll"
      static GetConsoleKbLayoutModule := DllCall("LoadLibrary", "Str", conkblPath)
      static GetConsoleKbLayoutInit := DllCall("getconkbl\Initialize", "Int",0)

      langID := DllCall(
        "getconkbl\GetConsoleAppKbLayout",
        "UInt",WinGetPID("A")
      ) & 0xFFFF
    } else {
      try {
        ctrlID := ControlGetHwnd(ControlGetFocus("A"), "A")
      } catch {
        ctrlID := WinGetID("A")
      }
      pid := DllCall("GetWindowThreadProcessId", "Ptr",ctrlID, "Ptr",0)
      langID := DllCall("GetKeyboardLayout", "UInt",pid, "Ptr") & 0xFFFF
    }
    DetectHiddenWindows(dhw)

    size := DllCall(
      "GetLocaleInfo",
      "UInt",LangID, "UInt",LOCALE_SENGLANGUAGE := 0x1001,
      "UInt",0, "UInt",0 * 2
    )
    VarSetStrCapacity(&lang, size)
    DllCall(
      "GetLocaleInfo",
      "UInt",LangID, "UInt",LOCALE_SENGLANGUAGE := 0x1001,
      "Str",lang, "UInt",Size
    )

    return { lang: lang, ctrlID: ctrlID }
  } catch {
    return { lang: 'Unknown', ctrlID: 0 }
  }
}

getMonitorUnderMouse(&l, &t, &r, &b, &w, &h) {
  CoordMode("Mouse", "Screen")
  MouseGetPos(&x, &y)
  monitorNum := 0
  loop MonitorGetCount() {
    monitorNum := A_Index
    if MonitorGet(monitorNum, &l, &t, &r, &b) {
      if (x >= l) and (x < r) and (y >= t) and (y < b) {
        w := r - l
        h := b - t
        return monitorNum
      }
    }
  }
}

getPixelsUnderMouse(radius := 10, x := 0, y := 0, file?) {
  hint("pixels: starting screenshot…")
  content := "
  (
    <html><head><meta charset="utf-8"><style>:root {--x: 30px}
    body {font-family: sans-serif} div {float: none; clear: both}
    i {display: block; float: left; width: var(--x); height: var(--x);
    cursor: default; position: relative; padding: 0; margin: 0 1px 1px 0;
    border: #00000009 1px solid} .i {outline: 1px solid red}</style></head><body>
  )"

  CoordMode("Mouse", "Screen")
  MouseGetPos(&xS, &yS)

  CoordMode("Mouse", "Window")
  CoordMode("Pixel", "Window")

  if !x and !y {
    MouseGetPos(&x, &y)
  }

  content .= "<p>Mouse position on screen: " xS "," yS "</p>"
  loop radius * 2 + 1 {
    cy := A_Index
    content .= "<div>"
    loop radius * 2 + 1 {
      cx := A_Index
      px := x + cx - radius - 1
      py := y + cy - radius - 1
      pixel := PixelGetColor(px, py)
      content .= "<i style='background:#" SubStr(pixel, 3)
              . ((px = x) and (py = y) ? "' class='i" : "")
              . "' title='" px "," py " #" SubStr(pixel, 3) "'></i>"
    }
    content .= "</div>`n"
  }

  file ??= EnvGet("userprofile") "\Downloads\ahk_pixels.html"
  try FileDelete(file)
  FileAppend(content, file)
  Run(file)
  hint("pixels: opening screenshot")
}

getTapTime(cmd := "down", ThisHotkey?) { ;cmd: down/up, key: this key
  static lastKey := ""
  static time := 0

  splitHotkey(ThisHotkey ?? A_ThisHotkey, &key)

  switch cmd, 0 {
    case "down":
      if (lastKey = "") or (key != lastKey) {
        lastKey := key
        time := A_TickCount
      }

    case "up":
      if key = lastKey {
        result := A_TickCount - time
        lastKey := ""
        time := 0
        return result
      } else {
        time := 0
      }
  }
  return 9999
}

getType(var) {
  if var is String {
    result := "String"
    if InStr(var, ".") {
      obj := StrSplit(var, ".")
      method := %obj[1]%
      loop obj.Length - 1 {
        try {
          method := method.%obj[A_Index + 1]%
        } catch {
          err("can't find prop '" obj[A_Index + 1] "' in '" var "'")
        }
      }
      if Type(method) = "Func" {
        result := "'ObjFunc'"
      } else {
        result := "unset 'ObjFunc'"
      }
    } else {
      try {
        if IsSet(%var%) {
          result := "'" Type(%var%) "'"
        }
      }
    }
  }
  return result ?? Type(var)
}

;get working desktop area (without taskbar)
getViewport(&left, &top, &right, &bottom, &width, &height) {
  mon := getMonitorUnderMouse(&left, &top, &right, &bottom, &width, &height)
  if mon {
    if !isTaskbarHidden() and (mon = MonitorGetPrimary()) {
      WinGetPos(
        &x, &y, &taskbarWidth, &taskbarHeight,
        "ahk_class Shell_TrayWnd"
      )

      if (x = 0) and (y = 0) {
        if taskbarHeight = A_ScreenHeight {
          left := taskbarWidth
        }
        if taskbarWidth = A_ScreenWidth {
          top := taskbarHeight
        }
      }
      if taskbarHeight = A_ScreenHeight {
        width := A_ScreenWidth - taskbarWidth
      } else {
        width := A_ScreenWidth
      }
      if taskbarWidth = A_ScreenWidth {
        height := A_ScreenHeight - taskbarHeight
      } else {
        height := A_ScreenHeight
      }
    }
    return true
  } else {
    return false
  }
}

;notice: tooltip hint key
hk(msg?, ThisHotkey?) {
  conf := {
    time: 2, x: Integer(A_ScreenWidth // 2 - 100),
    slot: 2, y: (A_ScreenHeight - 100)
  }

  if IsSet(msg) {
    ThisHotkey ??= A_ThisHotkey
    splitHotkey(ThisHotkey, &key, &mods, "verb")
    if StrLen(key) = 1 {
      key := StrTitle(key)
    }
    hint(mods vk2chr(key) "`n" msg, conf)
    log("hk(" mods vk2chr(key) ", " msg ")")
  } else {
    hint(, conf)
  }
}

hex2chr(arg) { ;'abcdef' => '«Íï' or 'ab cd ef' => '«Íï'
  text := StrReplace(arg, " ")
  if Mod(StrLen(text), 2) { ;check string length for even
    Throw ValueError("The length of the string is not even", -1, arg)
  }

  len := StrLen(text) // 2
  buf := ''
  loop len {
    hexCode := SubStr(text, (A_Index - 1) * 2 + 1, 2)
    character := DllCall(
      "msvcrt.dll\_wcstoui64",
      "Str",hexCode, "Uint",0, "UInt",16,
      "CDECL Int64"
    )
    buf .= Chr(character)
  }
  return buf
}

;conversion: hex to dec
hex2dec(n) => convertBase(16, 10, n)

hex2utf8(arg) {
  text := StrReplace(arg, " ")
  if Mod(StrLen(text), 2) {
    Throw ValueError("The length of the string is not even", -1, arg)
  }
  len := StrLen(text) // 2
  buf := Buffer(len, 0)
  loop len {
    hexCode := "0x" SubStr(text, (A_Index - 1) * 2 + 1, 2)
    NumPut("UChar", Integer(hexCode), buf, A_Index - 1)
  }

  return StrGet(buf, "UTF-8")
}

;notice: tooltip
hint(msg?, customConf?) {
  static s := Map()
  conf := {
    ; font: "Segoe UI",
    ; fg: "Black",
    ; bg: "White",
    ; size: 8,
    ; margins: [3, 3, 3, 3],
    ; options: "",
    opacity: 100,
    slot: 1,
    time: 1,
    x: -1,
    y: -1,
  }

  if IsSet(customConf) {
    Object.merge(conf, customConf)
  }

  if !conf.time or !IsSet(msg) {
    return ToolTip(,,, conf.slot)
  }

  ; ToolTipOptions.Init()
  ; ToolTipOptions.SetFont("s" conf.size " " conf.options, conf.font)
  ; ToolTipOptions.SetMargins(conf.margins*)
  ; ToolTipOptions.SetColors(conf.bg, conf.fg)

  CoordMode("ToolTip", "Screen")
  id := ToolTip(msg, conf.x = -1 ? unset : conf.x,
                     conf.y = -1 ? unset : conf.y, conf.slot)

  if (id) and (conf.opacity < 100) {
    try WinSetTransparent(Ceil(conf.opacity * 256 /100), "ahk_id " id)
  }

  s[conf.slot] := A_TickCount
  SetTimer(
    ((t) {
      if t = s[conf.slot] {
        ToolTip(, , , conf.slot)
      }
    }).Bind(s[conf.slot]),
    -1000 * Abs(conf.time)
  )

  return msg

}

;notice: hint
info(msg?) {
  static conf := {
    time:3, x:Integer(A_ScreenWidth // 2 - 100),
    slot:3, y:(A_ScreenHeight - 100)
  }

  if IsSet(msg) {
    hint(msg, conf)
    log("info(" msg ")")
  } else {
    hint(, conf)
  }
}

;notice: msgbox informatin
infoBox(msg, title := "Info", opt := "") {
  g := Gui("+OwnDialogs")
  g.Show()
  result := MsgBox(msg, title, "Iconi " opt)
  g.Destroy()
  return result
}

;checks whether the application hangs or not
isHungAppWindow(hwnd) => DllCall("user32\IsHungAppWindow", "Ptr", hwnd)

;checks whether the classnn is input type
isInput(classNN) {
  return (SubStr(classNN, 1,  4) = "edit")
      or (SubStr(classNN, 1,  6) = "chrome")
      or (SubStr(classNN, 1, 12) = "intermediate")
}

;keyboard: advanced getkeystate alias
isKeyDown(keys*) {
  simpleMods := "Alt ! Control ^ Shift + LWin # RWin #"
  pairMods   := "LAlt <! LControl ^ LShift <+ LWin <# "
             .  "RAlt >! RControl >^ RShift >+ RWin >#"

  switch keys[1], 0 {
    case "mods":
      ;inspect modifiers state (alt/control/shift/win)
      ;arg2: "!^+#" - list of mods for exclusion,
      ;arg3: boolean - separate left/right mods
      ;isKeyDown("mods", "!", true) - left/right mods, except alt
      excludeMods := keys.Has(2) ? keys[2] : ""
      separate := keys.Has(3) ? keys[3] : false
      mods := strMap(separate ? pairMods : simpleMods)

      result := ""
      for k, v in mods {
        if !InStr(excludeMods, k) and GetKeyState(k, "P") {
          result .= v
        }
      }

    case "|", "or":
      ;isKeyDown("or", "F1", "F2", "F3") -> F1 or F2 or F3 pressed
      keys.RemoveAt(1)
      result := false
      for v in keys {
        if vk(v) = "vk0" {
          return false
        } else {
          try result |= GetKeyState(v, "P")
        }
      }

    default:
      ;isKeyDown("F1", "F2", "F3") -> F1 and F2 and F3 pressed
      result := true
      for v in keys {
        if vk(v) = "vk0" {
          return false
        } else {
          try result &= GetKeyState(v, "P")
        }
      }
  }
  return result
}

;mouse: check position
isMouseOn(condition) {
  static border := 2

  CoordMode("Mouse", "Screen")
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)

  x := y := winUnderMouse := control := 0
  topEdge := rightEdge := bottomEdge := leftEdge := anyEdge := 0

  try {
    MouseGetPos(&x, &y, &winUnderMouse, &control)
    if getMonitorUnderMouse(&l, &t, &r, &b, &w, &h) {
      topEdge    := (y - t) < border
      rightEdge  := x >= (r - border)
      bottomEdge := y >= (b - border)
      leftEdge   := (x - l) < border
      anyEdge    := topEdge or rightEdge or bottomEdge or leftEdge
    }
  }

  try {
    winActive := WinGetID("A")
  } catch {
    winActive := 0
  }

  DetectHiddenWindows(dhw)

  switch condition, 0 {
    default:
      err("Invalid mouse condition: '" condition "'")

    case "active app":
      return (winUnderMouse) and (winActive)
         and (WinGetPID(winUnderMouse) = WinGetPID(winActive))

    case "active window":
      return (winUnderMouse) and (winActive) and (winUnderMouse = winActive)

    case "screen's top left corner":
      return (topEdge) and (leftEdge)

    case "screen's top right corner":
      return (topEdge) and (rightEdge)

    case "screen's bottom left corner":
      return (bottomEdge) and (leftEdge)

    case "screen's bottom right corner":
      return (bottomEdge) and (rightEdge)

    case "screen's top edge":
      return (topEdge)

    case "screen's bottom edge":
      return (bottomEdge)

    case "screen's left edge":
      return (leftEdge)

    case "screen's right edge":
      return (rightEdge)

    case "taskbar":
      return (winUnderMouse)
         and WinExist("ahk_class Shell_TrayWnd ahk_id " winUnderMouse)
         and !(anyEdge)

    case "tray":
      return isMouseOn("taskbar") and (control = "TrayNotifyWnd1")
  }
}

;keyboard: check if tapped the key long
isTapLong(ThisHotkey?, customConf := unset) {
  conf := { delay: 250, hint: [[], []] }

  if IsSet(customConf) {
    Object.merge(conf, customConf)
  }

  conf.delay /= 1000
  ThisHotkey ??= A_ThisHotkey
  splitHotkey(ThisHotkey, &key)

  hint(
    " " Chr(0x00B7) " " (StrLen(conf.hint[1]) ? " " conf.hint[1] : ""),
    { time:conf.delay, slot:9 }
  )

  if KeyWait(key, "T" conf.delay) {
    return false
  }

  hint(Chr(0x231A) (StrLen(conf.hint[2]) ? " " conf.hint[2] : ""), { slot: 9 })
  KeyWait(key)
  return true
}

;keyboard: check if double tapped the key
isTapTwice(ThisHotkey?) {
  ThisHotkey ??= A_ThisHotkey
  splitHotkey(ThisHotkey, &key)
  KeyWait(key)
  Sleep(10)
  return KeyWait(key, "D T.1")
}

;keyboard: return number of taps
;negative value means that the last tap was with delay
isTaps(ThisHotkey?, customConf := unset) {
  ThisHotkey ??= A_ThisHotkey
  conf := { delay:250, time:1, hint:[[], []], silent:false }

  if IsSet(customConf) {
    Object.merge(conf, customConf)
  }

  conf.delay /= 1000
  splitHotkey(ThisHotkey, &key, &mods, "verb")
  hintKey := StrTitle(vk2chr(key))

  ;tap count
  count := 1
  loop {
    if !conf.silent {
      if conf.hint.Has(1)
      and conf.hint[1].Has(count)
      and StrLen(conf.hint[1][count]) {
        text := "`n" conf.hint[1][count]
      } else {
        text := ""
      }
      msg := mods hintKey " " Chr(0x00D7) count "  " Chr(0x00B7) text
      hint(msg, { time:conf.time, slot: 9 })
    }

    if !KeyWait(key, "T" conf.delay) {
      break
    }

    if KeyWait(key, "D T.1") {
      count++
    } else {
      return count
    }
  }

  ;longtap count
  if !conf.silent {
    if conf.hint.Has(2)
    and conf.hint[2].Has(count)
    and StrLen(conf.hint[2][count]) {
      text :=  "`n" conf.hint[2][count]
    } else {
      text := ""
    }
    msg := mods hintKey " " Chr(0x00D7) count " " Chr(0x231A) text
    hint(msg, { time:conf.time, slot: 9 })
  }

  if KeyWait(key, "T" conf.delay * 2) {
    return -count
  }

  if !conf.silent {
    msg := mods hintKey " " Chr(0x00D7) count " " Chr(0x2014)
    hint(msg, { time:conf.time, slot: 9 })
  }

  KeyWait(key)
  return 0
}

;returns true if the taskbar is hidden
isTaskbarHidden() {
  return DllCall(
    "shell32\SHAppBarMessage",
    "UInt",0x4, "Ptr",Buffer(A_PtrSize = 8 ? 48 : 36, 0).ptr,
    "UPtr"
  )
}

;window: match active with regular expressions in title
isWinActive(win, title?) {
  switch win, 0 {
    default:
      err("Invalid window or control type: '" win "'")

    case "dropdown":
      return WinActive("Title")

    case "popup":
      return WinExist("OS_PopupWindow")

    case "input":
      try {
        classNN := ControlGetClassNN(ControlGetFocus("A"))
      } catch {

      } else {
        return isInput(classNN)
      }

    case "input:hover":
      MouseGetPos(,,, &classNN)
      return isInput(classNN)

    case "menu":
      return WinExist("ahk_class #32768")
          or WinExist("ahk_class MozillaDropShadowWindowClass")

    case "modal":
      if IsSet(title) {
        title .= " "
      } else {
        title := ""
      }
      return WinActive(title "ahk_class #32770")

    case "modal:files":
      return (isWinActive("modal") and !isWinActive("dropdown"))
          or  WinActive("ahk_class CabinetWClass ahk_exe explorer.exe")
          or  WinActive("Program Manager ahk_class Progman ahk_exe explorer.exe")
          or  WinActive("ahk_class ConsoleWindowClass")
          or  WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS "
                      . "ahk_exe WindowsTerminal.exe")

    case "regex":
      if IsSet(title) {
        matchMode := A_TitleMatchMode
        SetTitleMatchMode("RegEx")
        result := WinActive(title)
        SetTitleMatchMode(matchMode)
        return result
      }

    case "task list":
      return WinExist("ahk_class MultitaskingViewFrame")
          or WinExist("ahk_class TaskSwitcherWnd")
          or WinExist("ahk_class #32771")
  }
}

;check folder for write access
isWritable(folder) {
  DACL_SECURITY_INFORMATION := 0x00000004
  GENERIC_WRITE := 0x40000000
  result := DllCall(
    "CreateFile",
    "Str",folder, "UInt",GENERIC_WRITE, "UInt",0, "Ptr",0,
    "UInt",3, "UInt",0x02000000, "Ptr",0,
    "Ptr"
  )

  if result != -1 {
    DllCall("CloseHandle", "Ptr",result)
    return true
  } else {
    return false
  }
}

jsEscape(text) {
  text := StrReplace(text, "\", "\\")
  text := StrReplace(text, "'", "\'")
  text := StrReplace(text, '"', '\"')
  return text
}

;js calculator
jsCalc(val) {
  static obj := ComObject("HTMLfile")
  static code := "<body><script>a = Number(eval('{}').toFixed(10));"
              .  "document.body.innerText = a;</script>"
  obj.write(Format(code, val))
  return obj.body.innerText
}

;file: load map from file or group of text lines
loadDict(text) {
  static columnSeparator := "   "

  result := Map()
  result.CaseSense := 0

  loop Parse text, "`n", "`r" {
    ;skip empty lines and comments
    if IsSpace(A_LoopField)
    or SubStr(LTrim(A_LoopField), 1, 1) = ";" {
      continue
    }

    ;split line columns
    pair := RegExReplace(A_LoopField, columnSeparator "+", columnSeparator)
    pair := StrSplit(pair, columnSeparator).map(v => Trim(v))
    if SubStr(pair[1], 1, 2) = "\;" { ;unescape
      pair[1] := SubStr(pair[1], 2)
    }

    try {
      if pair[2] = "·" { ;empty value
        pair[2] := ""
      }
      result[pair[1]] := pair[2]
    } catch {
      infoBox("Error at line (" A_Index "):`n"
      . A_LoopField "`n`n" pair.toString(),, 16)
    }

  }
  return result
}

;file: load array of maps
loadTable(text) {
  static columnSeparator := "   "
  static columnEmpty := "·"

  result := []

  loop Parse text, "`n", "`r" {
    ;skip empty lines and comments
    if IsSpace(A_LoopField)
    or ((SubStr(LTrim(A_LoopField), 1, 1) = ";") and (A_Index != 1)) {
      continue
    }

    ;split line columns
    columns := RegExReplace(A_LoopField, columnSeparator "+", columnSeparator)
    columns := StrSplit(columns, columnSeparator).map(v => Trim(v))

    if A_Index = 1 {
      if columns.Length {
        if SubStr(columns[1], 1, 1) = ";" {
          columns[1] := SubStr(columns[1], 2)
        }
        titles := columns
      } else {
        err("Can't find column titles in first line")
        return
      }

    } else {
      if SubStr(columns[1], 1, 2) = "\;" { ;unescape
        columns[1] := SubStr(columns[1], 2)
      }

      items := Map()
      loop titles.Length {
        if columns.Has(A_Index) and (columns[A_Index] != columnEmpty) {
          item := columns[A_Index]
        } else { ;empty value
          item := ""
        }
        items[titles[A_Index]] := item
      }
      result.Push(items)
    }
  }
  return result
}

;notice: log message to the DebugView
log(text) => (OutputDebug("·· " RegExReplace(text, "`n", " | ")), text)

;notice: log message to the temp file
logF(text, showTime := true) {
  if showTime {
    time := "`n_" FormatTime(, "hh:mm:ss") "." A_MSec "`n"
  } else {
    time := ""
  }

  FileAppend(time text "`n", A_Temp "\taptapkey.log") ;view
  return text
}

;notice: log message to the notepad window
logN(message, showTime := true) {
  static notepad := "ahk_exe notepad.exe"

  winid := 0
  controlid := 0

  time := showTime ? ("`n_" FormatTime(, "hh:mm:ss") "." A_MSec "`n") : ""

  winid := WinExist(notepad)
  if !winid {
    Run("notepad")
    winid := WinWait(notepad, , 2)
    if !winid {
      err("Can't find notepad")
    }
  }

  if winid {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(1)
    try {
      controlid := ControlGetHwnd("Edit1", winid)
    } catch {
      loop 50 {
        try {
          controlid := ControlGetHwnd("RichEditD2DPT1", winid)
          if controlid {
            break
          } else {
            Sleep(50)
          }
        }
        if A_Index = 50 {
          err("Can't find notepad's control id")
        }
      }
    }

    if controlid {
      text := ControlGetText(controlid, "ahk_id " winid)
      ControlSetText(time message "`n" text, controlid, "ahk_id " winid)
    }
    DetectHiddenWindows(dhw)
  }
}

;mouse: emulate click with modifiers
mouse(keys*) {
  splitHotkey(A_ThisHotkey, &k)
  MouseGetPos(&xDown, &yDown)

  loop keys.Length {
    Send("{Blind}{" keys[A_Index] " down}")
  }

  KeyWait(k)

  loop keys.Length {
    Send("{Blind}{" keys[A_Index] " up}")
  }

  MouseGetPos(&xUp, &yUp)
  if (xDown = xUp) and (yDown = yUp) {
    Send("{Blind}" wk(k))
    return false
  } else {
    return true
  }
}

;mouse: show/hide cursor
mouseCursor(action)  { ;Show|Hide|Toggle|Reload
  static visible := true
  static cursors := Map()
  static IDs := [
    32512, 32513, 32514, 32515, 32516, 32642,
    32643, 32644, 32645, 32646, 32648, 32649, 32650
  ]
  static AndMask := Buffer(32 * 4, 0xFF)
  static XorMask := Buffer(32 * 4, 0)

  if (action = "reload") or (cursors.Count = 0) {
    for v in IDs {
      h_cursor := DllCall(
        "LoadCursor", "Ptr", 0, "Ptr", v
      )

      h_default := DllCall(
        "CopyImage",
        "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0
      )

      h_blank   := DllCall(
        "CreateCursor",
        "Ptr",0, "Int",0, "Int",0,, "Int",32, "Int",32,
        "Ptr",AndMask, "Ptr",XorMask
      )

      cursors[v] := { default: h_default, blank: h_blank }
    }
  }

  switch action, 0 {
    case  1, "show":
      visible := true

    case  0, "hide":
      visible := false

    case -1, "toggle":
      visible := !visible

    default:
      return
  }

  for id, handles in cursors {
    handle := visible ? handles.default : handles.blank
    h_cursor := DllCall(
      "CopyImage",
      "Ptr",handle, "UInt",2, "Int",0, "Int",0, "UInt",0
    )
    DllCall(
      "SetSystemCursor",
      "Ptr",h_cursor, "UInt",id
    )
  }
}

;mouse: save/restore position
mousePos(action := "", mode := "Screen") {
  ;action: push/pop/clear, mode: screen/window/client
  static mouse := [{ x:0, y:0, mode:"Screen", win:0, control:0 }]

  restoreMode := A_CoordModeMouse
  result := ""
  if !mouse.Length {
    return
  }

  switch action, 0 {
    case "check":
      saved := mouse[mouse.Length]
      CoordMode("Mouse", saved.mode)
      MouseGetPos(&x, &y)
      result := "x:" x - saved.x ", y:" y - saved.y
      ; return Abs(saved.x - x) or Abs(saved.y - y) ? 1 : 0

    case "clear":
      mouse.Pop()

    case "get":
      saved := mouse[mouse.Length]
      CoordMode("Mouse", saved.mode)
      result := saved

    case "pop":
      saved := mouse.Pop()
      CoordMode("Mouse", saved.mode)
      MouseMove(saved.x, saved.y)

    case "push":
      CoordMode("Mouse", mode)
      MouseGetPos(&x, &y, &win, &control)
      mouse.Push({ x: x, y: y, mode: mode, win: win, control: control })
  }

  CoordMode("Mouse", restoreMode)
  return result
}

;search variants of the image, like 'image#1', 'image#2' etc
multiImageSearch(&x, &y, x1, y1, x2, y2, path) {
  ; multiple images must all end with a number
  ; separated from the name by '#', starts from 1
  counter := 1
  SplitPath(path, , &dir, &ext, &name, &drive)
  loop {
    file := dir "\" name "#" counter "." ext
    if FileExist(file) {
      if ImageSearch(&x, &y, x1, y1, x2, y2, file) {
        return counter
      }
      counter++
    } else {
      if counter = 1 {
        err("File not found: '" file "'`nin '" A_WorkingDir "'")
      }
      break
    }
  }
}

;window: toggle opacity
opacity(opacity?, lastFound := false) { ;opacity in %
  static minimum := 25
  static maximum := 100
  static opacities := [maximum, 75, 50, minimum]

  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)

  trans := WinGetTransparent("A")
  trans := trans ? Ceil(trans * maximum / 256) : opacities[1]

  if !IsSet(opacity) {
    step := opacities.indexOf(trans)
    if step {
      if ++step > opacities.length {
        step := 1
      }
    } else {
      step := 1
    }
    opacity := opacities[step]

  } else if opacity ~= "^[+-]" {
    opacity := trans + opacity
    if opacity < minimum {
      opacity := minimum
    } else if opacity > maximum {
      opacity := maximum
    }
  }

  if opacity = maximum {
    trans := "Off"
  } else {
    trans := Floor(opacity * 256 / 100)
  }

  try {
    if lastFound {
      WinSetTransparent(trans)
    } else {
      WinSetTransparent(trans, "A")
    }
  }
  DetectHiddenWindows(dhw)
  return "Opacity " opacity "%"
}

;notice: onscreen display
osd(text := "", customConf := unset) {
  conf := {
    title   : "blkOsdWnd",
    align   : "Center",
    bg      : 0x000000,
    fg      : 0xFFFFFE,
    font    : "Tahoma",
    marginX : 20,
    marginY : 10,
    opacity : 70,
    shadow  : false,
    size    : 20,
    time    : 3,
    weight  : 100,
    x       : "Center",
    y       : Round(A_ScreenHeight * .8),
  }

  if IsSpace(String(text)) {
    text := ""
    SetTimer(onScreenDisplay, -1)
    return
  }

  if IsSet(customConf) {
    Object.merge(conf, customConf)
  }

  if !(conf.bg is String) {
    conf.bg := format("{:X}", conf.bg)
  }

  if !(conf.fg is String){
    conf.fg := format("{:X}", conf.fg)
  }

  SetTimer(onScreenDisplay, -1)

  onScreenDisplay() {
    if conf.title and WinExist(conf.title) {
      WinClose()
    }

    if IsSpace(String(text)) {
      return
    }

    w := Gui("+LastFound +AlwaysOnTop +ToolWindow -Caption ", conf.title)
    if conf.shadow {
      shadow(w.Hwnd)
    }
    w.MarginX   := conf.HasProp("marginX") ? conf.marginX : conf.size / 2
    w.MarginY   := conf.HasProp("marginY") ? conf.marginY : conf.size / 5
    w.BackColor := conf.bg
    w.SetFont("c" conf.fg " s" conf.size " w" conf.weight " q5 ", conf.font)
    w.Add("Text", "+0x80 v&blkOsdCtrlName " conf.align " ", text)
    ;0x80 = SS_NOPREFIX -> Ampersand (&) is shown instead
    ;of underline one letter for Alt+letter navigation

    WinSetExStyle("+0x20") ;WS_EX_TRANSPARENT -> mouse clickthrough
    WinSetTransColor("FFFFFF " Ceil(conf.opacity * 256 / 100))
    WinRedraw()

    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    x := (conf.x = "mouse") ? mx + 10 : conf.x
    y := (conf.y = "mouse") ? my + 10 : conf.y

    w.Show("x" x " y" y " NoActivate")
    try {
      WinGetPos(,, &ww, &wh, conf.title)
      WinSetRegion("0-0 W" ww " H" wh " R" conf.size/3
      . "-" conf.size/3, conf.title)
      WinRedraw()
    }

    Sleep(conf.time * 1000)
    w.Destroy()
  }

  shadow(HGui) {
    _ISENABLED := 0
    ;Get if DWM Manager is Enabled
    DllCall("dwmapi\DwmIsCompositionEnabled", "IntP", _ISENABLED)
    ;if DWM is not enabled, Make Basic Shadow
    if !_ISENABLED {
      DllCall(
        "SetClassLong",
        "UInt",HGui, "Int",-26,
        "Int", DllCall(
          "GetClassLong",
          "UInt",HGui, "Int",-26
        ) | 0x20000
      )
    } else {
      _MARGINS := Buffer(16)
      NumPut("UInt", 1, _MARGINS.Ptr, 0)
      NumPut("UInt", 1, _MARGINS.Ptr, 4)
      NumPut("UInt", 1, _MARGINS.Ptr, 8)
      NumPut("UInt", 1, _MARGINS.Ptr, 12)
      DllCall(
        "dwmapi\DwmSetWindowAttribute",
        "Ptr",HGui, "UInt",2, "Int*",2, "UInt",4
      )
      DllCall(
        "dwmapi\DwmExtendFrameIntoClientArea",
        "Ptr",HGui, "Ptr",_MARGINS.Ptr
      )
    }
  }
}

;keyboard: send ThisHotkey
passTap(ThisHotkey?, level := 0) {
  ThisHotkey ??= A_ThisHotkey
  if SubStr(ThisHotkey, 1, 1) = "~" {
    return
  }
  SendLevel(level)
  splitHotkey(ThisHotkey, &key, &mods)
  Send(mods wk(key))
}

;paste without formatting
pasteWithoutFormatting() {
  clip := ClipboardAll()
  A_Clipboard := A_Clipboard
  Send("+{Insert}")
  Sleep(50)
  A_Clipboard := clip
  hk("Paste without formatting")
}

;get list of pids from name
pidList(app) {
  pids := []
  for v in WinGetList(app) {
    pid := WinGetPID("ahk_id " v)
    if !pids.includes(pid) {
      pids.Push(pid)
    }
  }
  return pids
}

;escape string for regular expression match
regExEscape(arg, chars := "\.*?+[{|()^$]") {
  result := arg
  for v in StrSplit(chars) {
    result := StrReplace(result, v, "\" v)
  }
  result := StrReplace(result, '"', '`"')
  result := StrReplace(result, '``', '````')
  return result
}

;window: remove minmax/close buttons of the active window
removeWindowButtons(button, win := "A") {
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)
  switch button, 0 {
    case "close":
      hWnd     := WinGetID(win)
      hSysMenu := DllCall("GetSystemMenu", "UInt",hWnd, "Int",False)
      nIndex   := DllCall("GetMenuItemCount", "UInt",hSysMenu)
      if nIndex > 5 {
        DllCall("RemoveMenu", "UInt",hSysMenu, "Int",nIndex - 1, "UInt",0x400)
        DllCall("RemoveMenu", "UInt",hSysMenu, "Int",nIndex - 2, "UInt",0x400)
        DllCall("DrawMenuBar", "UInt",hSysMenu)
      }

    case "minmax":
      if !(WinGetExStyle(win) & 0x30000) {
        WinSetStyle(-0x30000, win)
      }
  }
  DetectHiddenWindows(dhw)
}

;run ahk code in separated process
runAhkCode(code, waitReturn := false) {
  commandline := A_AhkPath " /ErrorStdOut *"
  shell := ComObject("WScript.Shell")

  if waitReturn {
    code := "FileAppend((" code "), '*')"
  }

  exec := shell.Exec(commandline)
  exec.StdIn.WriteLine("#NoTrayIcon")
  exec.StdIn.Write(code)
  exec.StdIn.Close()

  if waitReturn {
    return exec.StdOut.ReadAll()
  }
}

;run ahk file in separated process
runAhkFile(fileName, waitReturn := false, args*) {
  commandLine := A_AhkPath ' "' fileName '" "' args.join('" "') '"'
  shell := ComObject("WScript.Shell")

  exec := shell.Exec(commandLine)

  if waitReturn {
    return exec.StdOut.ReadAll()
  }
}

runAhkFileAsAdmin(fileName, waitReturn := false, args*) {
  if !FileExist(fileName) {
    err("Can't find:`n" fileName)
    Sleep(200)
    return -1
  } else {
    commandLine := '*RunAs "' A_AhkPath '" "'
    . fileName '" "' args.join('" "') '"'
    if waitReturn {
      return RunWait(commandLine)
    } else {
      Run(commandLine)
    }
  }
}

;write alpha png from clipboard to the %temp%\clip.png and return true if success
saveClipPngAlpha() {
  file := ttk.dir "\lib\ClipboardToPNG.exe"
  if FileExist(file) {
    try FileDelete(A_Temp "\clip.png")
    return !RunWait(file)
  } else {
    err("Can't find`n" file)
  }
}

;select all chars in line
selectLine() {
  Send("{Home 2}")
  Sleep(30), Send("{Shift down}")
  Sleep(30), Send("{End}")
  Sleep(30), Send("{Shift up}")
}

;keyboard: set layout
setKeyboardLayout(lang, ctrlID := getKeyboardLayout().ctrlID) {
  static locale := strMap("
  (LTrim Join`s
    Cycle -1 Afrikaans 0x0436 Albanian 0x041c Arabic_Saudi_Arabia 0x0401
    Arabic_Iraq 0x0801 Arabic_Egypt 0x0c01 Arabic_Libya 0x1001
    Arabic_Algeria 0x1401 Arabic_Morocco 0x1801 Arabic_Tunisia 0x1c01
    Arabic_Oman 0x2001 Arabic_Yemen 0x2401 Arabic_Syria 0x2801
    Arabic_Jordan 0x2c01 Arabic_Lebanon 0x3001 Arabic_Kuwait 0x3401
    Arabic_UAE 0x3801 Arabic_Bahrain 0x3c01 Arabic_Qatar 0x4001 Armenian 0x042b
    Azeri_Latin 0x042c Azeri_Cyrillic 0x082c Basque 0x042d Belarusian 0x0423
    Bulgarian 0x0402 Catalan 0x0403 Chinese_Taiwan 0x0404 Chinese_PRC 0x0804
    Chinese_Hong_Kong 0x0c04 Chinese_Singapore 0x1004 Chinese_Macau 0x1404
    Croatian 0x041a Czech 0x0405 Danish 0x0406 Dutch_Standard 0x0413
    Dutch_Belgian 0x0813 English 0x0409 English_United_States 0x0409
    English_United_Kingdom 0x0809 English_Australian 0x0c09
    English_Canadian 0x1009 English_New_Zealand 0x1409 English_Irish 0x1809
    English_South_Africa 0x1c09 English_Jamaica 0x2009 English_Caribbean 0x2409
    English_Belize 0x2809 English_Trinidad 0x2c09 English_Zimbabwe 0x3009
    English_Philippines 0x3409 Estonian 0x0425 Faeroese 0x0438 Farsi 0x0429
    Finnish 0x040b French_Standard 0x040c French_Belgian 0x080c
    French_Canadian 0x0c0c French_Swiss 0x100c French_Luxembourg 0x140c
    French_Monaco 0x180c Georgian 0x0437 German_Standard 0x0407
    German_Swiss 0x0807 German_Austrian 0x0c07 German_Luxembourg 0x1007
    German_Liechtenstein 0x1407 Greek 0x0408 Hebrew 0x040d Hindi 0x0439
    Hungarian 0x040e Icelandic 0x040f Indonesian 0x0421 Italian_Standard 0x0410
    Italian_Swiss 0x0810 Japanese 0x0411 Kazakh 0x043f Konkani 0x0457
    Korean 0x0412 Latvian 0x0426 Lithuanian 0x0427 Macedonian 0x042f
    Malay_Malaysia 0x043e Malay_Brunei_Darussalam 0x083e Marathi 0x044e
    Norwegian_Bokmal 0x0414 Norwegian_Nynorsk 0x0814 Polish 0x0415
    Portuguese_Brazilian 0x0416 Portuguese_Standard 0x0816 Romanian 0x0418
    Russian 0x0419 Sanskrit 0x044f Serbian_Latin 0x081a Serbian_Cyrillic 0x0c1a
    Slovak 0x041b Slovenian 0x0424 Spanish_Traditional_Sort 0x040a
    Spanish_Mexican 0x080a Spanish_Modern_Sort 0x0c0a Spanish_Guatemala 0x100a
    Spanish_Costa_Rica 0x140a Spanish_Panama 0x180a
    Spanish_Dominican_Republic 0x1c0a Spanish_Venezuela 0x200a
    Spanish_Colombia 0x240a Spanish_Peru 0x280a Spanish_Argentina 0x2c0a
    Spanish_Ecuador 0x300a Spanish_Chile 0x340a Spanish_Uruguay 0x380a
    Spanish_Paraguay 0x3c0a Spanish_Bolivia 0x400a Spanish_El_Salvador 0x440a
    Spanish_Honduras 0x480a Spanish_Nicaragua 0x4c0a Spanish_Puerto_Rico 0x500a
    Swahili 0x0441 Swedish 0x041d Swedish_Finland 0x081d Tamil 0x0449
    Tatar 0x0444 Thai 0x041e Turkish 0x041f Ukrainian 0x0422 Urdu 0x0420
    Uzbek_Latin 0x0443 Uzbek_Cyrillic 0x0843 Vietnamese 0x042a
  )")

  if locale.Has(lang) {
    try PostMessage(0x50, , locale[lang], , "ahk_id " ctrlID)
  } else {
    err("Wrong layout name: '" lang "'")
  }
}

setLaunchAtLogin(action := "", *) {
  title := "&Launch at Login"
  key := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
  value := "Taptapkey"
  validPath := (RegRead(key, value, "") = A_AhkPath)

  if action = "toggle" {
    if validPath {
      try RegDelete(key, value)
      A_TrayMenu.Uncheck(title)
    } else {
      RegWrite(A_AhkPath, "REG_SZ", key, value)
      A_TrayMenu.Check(title)
    }
  } else {
    A_TrayMenu.Insert("2&", title, %A_ThisFunc%.Bind("toggle"))
    if validPath {
      A_TrayMenu.Check(title)
    }
  }
}

setTrayMenu() {
  A_TrayMenu.Insert("1&", "&About " chr(0x1F517), (*) => Run(ttk.link))
  A_TrayMenu.Add("&Window Spy", (*) => Run('"' A_AhkPath '" "lib\WindowSpy.ahk"'))
  A_TrayMenu.Add("&Edit Script", (*) => Edit("settings.ahk"))
  A_TrayMenu.Rename("&Edit Script", "&Edit Settings")
  A_TrayMenu.Rename("&Open", "Autohotkey")
  A_TrayMenu.Delete("&Help")
  A_TrayMenu.Delete("3&")
  A_TrayMenu.Insert("2&")

  A_TrayMenu.Default := "&Reload Script"

  themeKey := "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
  i := RegRead(themeKey, "SystemUsesLightTheme", false) ? "b" : "w"
  TraySetIcon("lib\ttk" i ".ico")

  setLaunchAtLogin()
}

;keyboard: split given hotkey to key and mods
splitHotkey(hotkey, key?, mods?, opts := "") { ;opts: verb, leftright
  static separator := "-"
  static modList := StrMap(
    "! Alt <! LAlt >! RAlt ^ Control <^ LControl >^ RControl "
    . "+ Shift <+ LShift >+ RShift # Win <# LWin ># RWin"
  )
  ;TODO: asterisk mods (*), refactor

  if !IsSet(key) and !IsSet(mods) {
    throw ValueError("Both parameters (#2 and #3) are missing.", -1)
  }

  ;parsing key
  if IsSet(key) {
    if !(key is VarRef) {
      throw ValueError("Parameter #2 must be a VarRef.", -1, key)
    }

    if InStr(hotkey, " & ") {
      needle := "^.*?(\S*?)(?: up)*$"
    } else {
      needle := "^(.*?)(?: up)*$"
    }
    k := RegExReplace(hotkey, needle, "$1")
    k := RegExReplace(k, "^[~<>!\^\+#\*\$]*")
    %key% := k
  }

  ;parsing mod
  if IsSet(mods) {
    if !(mods is VarRef) {
      throw ValueError("Parameter #3 must be a VarRef.", -1, mods)
    }

    if InStr(hotkey, " & ") {
      m := RegExReplace(LTrim(hotkey, "~$"), " & .*$")
      if (opts ~= "i)verb") {
        m .= separator
      }
    } else {
      m := RegExReplace(hotkey, "[^<>!\^\+#]")
    }

    ;verbose mods
    if !IsSpace(m) and (opts ~= "i)verb") {
      leftRight := (opts ~= "i)lr") or (opts ~= "i)leftright")

      ;alt, ctrl, shift, win
      chain := ""
      if m ~= "[!\^\+#]" {
        pattern := "([<>]*)([!^\+#])"
        if leftRight {
          replacement := "$1$2`n"
        } else {
          replacement := "$2`n"
        }

        m := RegExReplace(m, pattern, replacement)

        for val in StrSplit(m, "`n") {
          if modList.Has(val) {
            chain .= modList[val] "`n"
          }
        }
        m := StrReplace(Sort(chain), "`n", separator)
      }
    }

    %mods% := m
  }
}

;expand string to map array
strMap(str, separator := " ") => Map(StrSplit(str, separator)*)

;keyboard: send keys with specific layout
tap(string := "", layout?, restore?, allowInTextField := true) {
  if !allowInTextField {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(1)
    try {
      focused := SubStr(ControlGetClassNN(ControlGetFocus("A")), 1, 4)
    } catch {
      focused := ""
    }
    DetectHiddenWindows(dhw)
    if focused = "Edit" {
      return
    }
  }

  if !IsSet(layout) {
    layout := ttk?.tap?.layout? ?? false
  }

  if !IsSet(restore) {
    restore := ttk?.tap?.restore ?? false
  }

  if layout {
    kbd := getKeyboardLayout()
    if kbd.lang != layout {
      setKeyboardLayout(layout, kbd.ctrlID)
    }
  }

  if !IsSpace(string) {
    Send(string)
  }

  if restore {
    if (restore = "prev") or (restore = true) {
      if kbd.lang != layout {
        Sleep(70)
        setKeyboardLayout(kbd.lang, kbd.ctrlID)
      }
    } else if kbd.lang != layout {
      setKeyboardLayout(restore, kbd.ctrlID)
    }
  }

  return string
}

;toggle/get/set static vars
toggle(arg, cmd := "toggle", val?) {
  static vars := Map()

  switch cmd, 0 {
    case "?" "get":
      return vars.Get(arg, false)

    case "=", "set":
      return vars[arg] := val

    case "x", "del", "delete":
      vars.Delete(arg)

    case "^", "toggle":
      return vars[arg] := !vars.Get(arg, false)
  }
}

;file: unpack zip to the folder
unzip(zipFilename, destFolder := ".") {
  static fileObj := ComObject("Scripting.FileSystemObject")
  static shellObj := ComObject("Shell.Application")

  if !fileObj.FolderExists(destFolder) {
    fileObj.CreateFolder(destFolder)
  }
  source := shellObj.NameSpace(fileObj.getFile(zipFilename).Path)
  destination := shellObj.NameSpace(fileObj.getFolder(destFolder).Path)
  if fileObj.FileExists(zipFilename) {
    destination.CopyHere(source.Items(), 4|16)
    return true
  }
}

urlDecode(url, flags := 0x00140000) {
   return !DllCall(
    "Shlwapi.dll\UrlUnescape",
    "Ptr",StrPtr(url), "Ptr",0, "UInt",0, "UInt",flags,
    "UInt"
  ) ? url : ""
}

urlEncode(url, Flags := 0x000C3000) {
	cc := 4096, esc := "", result := ""
	loop {
		VarSetStrCapacity(&esc, cc)
    result := DllCall(
      "Shlwapi.dll\UrlEscapeW",
      "Str",url, "Str",&esc, "UIntP",&cc, "UInt",flags,
      "UInt"
    )
  }	Until result != 0x80004003 ; E_POINTER
	Return esc
}

verClosest(verList, ver) { ;finds the closest version in the list
  found := false

  for key in verList {
    if VerCompare(ver, key) >= 0 {
      if !found or VerCompare(key, found) > 0 {
        found := String(key)
      }
    }
  }

  if found and (StrSplit(ver, ".")[1] != StrSplit(found, ".")[1]) {
    return false
  }

  return found
}

;keyboard: convert char to vkNN
vk(char, soft := false) { ;if soft = true, convert only chars from out map
  out := StrMap("`` C0 [ DB ] DD `; BA ' DE , BC . BE / BF")
  if out.Has(char) {
    result := "vk" out[char]
  } else if soft {
    result := char
  } else {
    result := "vk" Format("{:X}", GetKeyVK(char))
  }
  return result
}

;keyboard: convert vkNN to char
vk2chr(key) {
  if key ~= "vk[a-fA-F\d]{2}" {
    vkKey := SubStr(key, InStr(key, "vk"), 4)
    result := StrReplace(key, vkKey, GetKeyName(vkKey))
    return result
  } else {
    return key
  }
}

;keyboard: keywait alias
waitTap(ThisHotkey?, opts := "") {
  ThisHotkey ??= A_ThisHotkey
  splitHotkey(ThisHotkey, &key)
  return KeyWait(key, opts)
}

;notice: msgbox warning
warn(msg, title := "Warning", opt := "O T3") {
  return infoBox(msg, title, "Icon! " opt)
}

winGetParentID(id?) {
  try id ??= WinGetID("A")
  if id {
    parentId := DllCall("GetWindow", "Ptr",id, "UInt",GW_OWNER := 4)
    return parentId or id
  }
}

;keyboard: convert each char arg to {vkNN}
wk(chars*) => chars.map(v => ("{" vk(v) "}")).join("")

;TODO: locale list
/*
https://www.autohotkey.com/boards/viewtopic.php?t=28258
locale := strMap("Cycle -1 Afrikaans 0x0436 Albanian 0x041c Arabic_Saudi_Arabia 0x0401 Arabic_Iraq 0x0801 Arabic_Egypt 0x0c01 Arabic_Libya 0x1001 Arabic_Algeria 0x1401 Arabic_Morocco 0x1801 Arabic_Tunisia 0x1c01 Arabic_Oman 0x2001 Arabic_Yemen 0x2401 Arabic_Syria 0x2801 Arabic_Jordan 0x2c01 Arabic_Lebanon 0x3001 Arabic_Kuwait 0x3401 Arabic_UAE 0x3801 Arabic_Bahrain 0x3c01 Arabic_Qatar 0x4001 Armenian 0x042b Azeri_Latin 0x042c Azeri_Cyrillic 0x082c Basque 0x042d Belarusian 0x0423 Bulgarian 0x0402 Catalan 0x0403 Chinese_Taiwan 0x0404 Chinese_PRC 0x0804 Chinese_Hong_Kong 0x0c04 Chinese_Singapore 0x1004 Chinese_Macau 0x1404 Croatian 0x041a Czech 0x0405 Danish 0x0406 Dutch_Standard 0x0413 Dutch_Belgian 0x0813 English 0x0409 English_United_States 0x0409 English_United_Kingdom 0x0809 English_Australian 0x0c09 English_Canadian 0x1009 English_New_Zealand 0x1409 English_Irish 0x1809 English_South_Africa 0x1c09 English_Jamaica 0x2009 English_Caribbean 0x2409 English_Belize 0x2809 English_Trinidad 0x2c09 English_Zimbabwe 0x3009 English_Philippines 0x3409 Estonian 0x0425 Faeroese 0x0438 Farsi 0x0429 Finnish 0x040b French_Standard 0x040c French_Belgian 0x080c French_Canadian 0x0c0c French_Swiss 0x100c French_Luxembourg 0x140c French_Monaco 0x180c Georgian 0x0437 German_Standard 0x0407 German_Swiss 0x0807 German_Austrian 0x0c07 German_Luxembourg 0x1007 German_Liechtenstein 0x1407 Greek 0x0408 Hebrew 0x040d Hindi 0x0439 Hungarian 0x040e Icelandic 0x040f Indonesian 0x0421 Italian_Standard 0x0410 Italian_Swiss 0x0810 Japanese 0x0411 Kazakh 0x043f Konkani 0x0457 Korean 0x0412 Latvian 0x0426 Lithuanian 0x0427 Macedonian 0x042f Malay_Malaysia 0x043e Malay_Brunei_Darussalam 0x083e Marathi 0x044e Norwegian_Bokmal 0x0414 Norwegian_Nynorsk 0x0814 Polish 0x0415 Portuguese_Brazilian 0x0416 Portuguese_Standard 0x0816 Romanian 0x0418 Russian 0x0419 Sanskrit 0x044f Serbian_Latin 0x081a Serbian_Cyrillic 0x0c1a Slovak 0x041b Slovenian 0x0424 Spanish_Traditional_Sort 0x040a Spanish_Mexican 0x080a Spanish_Modern_Sort 0x0c0a Spanish_Guatemala 0x100a Spanish_Costa_Rica 0x140a Spanish_Panama 0x180a Spanish_Dominican_Republic 0x1c0a Spanish_Venezuela 0x200a Spanish_Colombia 0x240a Spanish_Peru 0x280a Spanish_Argentina 0x2c0a Spanish_Ecuador 0x300a Spanish_Chile 0x340a Spanish_Uruguay 0x380a Spanish_Paraguay 0x3c0a Spanish_Bolivia 0x400a Spanish_El_Salvador 0x440a Spanish_Honduras 0x480a Spanish_Nicaragua 0x4c0a Spanish_Puerto_Rico 0x500a Swahili 0x0441 Swedish 0x041d Swedish_Finland 0x081d Tamil 0x0449 Tatar 0x0444 Thai 0x041e Turkish 0x041f Ukrainian 0x0422 Urdu 0x0420 Uzbek_Latin 0x0443 Uzbek_Cyrillic 0x0843 Vietnamese 0x042a").swapKeyVal()

s := DllCall("GetKeyboardLayoutList", "UInt", 0, "Ptr", 0)
l := Buffer(A_PtrSize * s)
s := DllCall("GetKeyboardLayoutList", "Int", s, "Int", l.ptr)
loop s {
  n := NumGet(l, A_PtrSize * (A_Index - 1), "UInt") & 0xFFFF
  ;logn dec2hex(n & 0xFFFF), 0
  if locale.Has(n)
    logn locale[n], 0
  else hint("fuck")
}

*/