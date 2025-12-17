;adobe illustrator functions

;;INIT
  ai                := { app: Map(0, {active: false}), pid: 0 }

  ai.toggleWhileDrag:= true
  ai.gdiCheck       := true
  ai.showHint       := true
  ai.remindToSave   := 3 ;minutes
  ai.tapLayout      := "English"

  ai.confPath       := dirName(A_LineFile)
  ai.scriptsPath    := ai.confPath "\scripts"
  ai.actionsPath    := ai.confPath "\scripts\actions"

  ai.dict           := {}
  for k in StrSplit("comreg langs keys menus tools units", " ") {
    dictFileName := ai.confPath "\dicts\" k ".yaml"
    ai.dict.%k% := YAML.parse(FileRead(dictFileName))
    if (k = "menus") or (k = "tools") {
      ai.dict.%k%["cmds"] := ai.dict.%k%["items"].swapKeyVal()
    }
  }

  SetTimer(aiInit, 1000) ;illustrator instance prefs watcher

;;FUNCTIONS

ai3d(action, option := "") {
  ;action: axis fix
  ;action: focus input
  ;action: surface, option: up|down
  ;action: extrude|revolve|rotate, option: left|right|top|bottom

  static directions := ["left", "right", "top", "bottom"]

  focusInput() {
    title := WinGetTitle("A")
    switch {
      case InStr(title, aiLocale("3D Extrude & Bevel Options")):
        ControlFocus("Edit9", "A")
        return 3

      case InStr(title, aiLocale("3D Revolve Options")):
        ControlFocus("Edit7", "A")
        return 4

      case InStr(title, aiLocale("3D Rotate Options")):
        ControlFocus("Edit10", "A")
        return 1

      default:
        return 0
    }
  }

  switch action, 0 {
    default:
      err(A_ThisFunc " wrong action arg: '" action "'")
      return

    case "focus input":
      if focusInput() {
        hk("Focus input")
      }
      return

    case "surface":
      tabs := focusInput()
      if tabs {
        Send("{Tab " tabs "}{" option "}")
        hk("Surface " option)
      }
      return

    case "axis fix":
      ControlFocus("Edit12", "A")
      input := ControlGetText("Edit12", "A")
      input := RegExReplace(input, decSeparator() ".*")
      input := RegExReplace(input, "[° ]")
      selectLine()
      tap(input wk(decSeparator()) "2644")
      hk("Vertical isometric axis fix")
      return

    case "extrude":
      if WinExist(aiLocale("3D Extrude & Bevel Options") " ahk_pid " ai.pid) {
        WinActivate()
      } else {
        aiRunMenu("Effect > 3D and Materials > "
          . "3D (Classic) > Extrude & Bevel (Classic)...")
      }

    case "revolve":
      if WinExist(aiLocale("3D Revolve Options") " ahk_pid " ai.pid) {
        WinActivate()
      } else {
        aiRunMenu("Effect > 3D and Materials > "
          . "3D (Classic) > Revolve (Classic)...")
      }

    case "rotate":
      if WinExist(aiLocale("3D Rotate Options") " ahk_pid " ai.pid) {
        WinActivate()
      } else {
        aiRunMenu("Effect > 3D and Materials > "
          . "3D (Classic) > Rotate (Classic)...")
      }
  }

  if !directions.includes(option) {
    err("Wrong direction argument in " A_ThisFunc ":`n" option)
    return
  }

  activeFocus := ControlGetFocus("A") or ControlGetHwnd("Edit9", "A")
  rotationX := ControlGetHwnd("Edit13", "A")
  ControlFocus(rotationX)

  ;go to position preset
  Send("+{Tab}")
  Sleep(50)
  Send("{End}")

  steps := directions.Length - directions.indexOf(option)
  loop steps {
    Sleep(50)
    Send("{Up}")
  }

  ControlFocus(activeFocus)
  hk("Set " option " projection")
}

aiBackup() {
  archiver := '"' A_InitialWorkingDir '\lib\7z.exe"'
  options  := 'a -tzip -ssw -mmt=8'
  from     := ai.app[ai.pid].prefsPath
  to       := A_MyDocuments
  ver      := ai.app[ai.pid].ver
  date     := FormatTime(, "yyyy.MM.dd")
  zip      := '"' to '\illustrator_' ver '_' date '.zip" '
  list     := '-ir-m@"' ai.confPath '\backup.txt"'
  Run(archiver " " options " " zip " " list, from)
}

aiClickCpanel(item) {
  static items := [
    "transform",
    "fillColor",
    "strokeColor",
    "strokeWidth",
    "strokeUp",
    "strokeDown"
  ]
  cpl := ai.app[ai.pid].cpl

  movePopup() {
    if WinWaitActive("Title",, 2) {
      m := mousePos("get")
      WinMove(m.x + 10, m.y + 10,,, "A")
    }
  }

  clickControl() {
    if WinExist("Title ahk_class #32770 ahk_pid " ai.pid) {
      ControlClick("x" x " y" y, cpl["id"],,,, "Pos")
      Sleep(50)
      ControlClick("x" x " y" y, cpl["id"],,,, "Pos")
    } else {
      ControlClick("x" x " y" y, cpl["id"],,,, "Pos")
    }
  }

  if !aiGetCplId(ai.app[ai.pid].id)
  or !aiInitCpl(item) {
    return
  }

  if !items.includes(item) {
    err("Invalid argument: " item)
  }

  mousePos("push")
  switch item, 0 {
    case "transform":
      try {
        x := cpl["x"].Location.x - cpl["root"].Location.x
        y := cpl["x"].Location.y - cpl["root"].Location.y
        clickControl()
      } catch {
        x := cpl["transform"].Location.x - cpl["root"].Location.x
        y := cpl["transform"].Location.y - cpl["root"].Location.y
        clickControl()
      } finally {
        movePopup()
      }

    case "fillColor", "strokeColor", "strokeWidth":
      x := cpl[item].Location.x - cpl["root"].Location.x
      y := cpl[item].Location.y - cpl["root"].Location.y
      clickControl()
      movePopup()

    case "strokeUp", "strokeDown":
      yShift := aiUiScaling((item = "strokeDown") ? 15 : 5)
      xShift := aiUiScaling(15)
      x := cpl["strokeWidth"].BoundingRectangle.r - cpl["root"].Location.x + xShift
      y := cpl["strokeWidth"].BoundingRectangle.t - cpl["root"].Location.y + yShift
      ControlClick("x" x " y" y, cpl["id"],,,, "Pos")
  }
  mousePos("pop")
}

aiClickHome() {
  pos := "x" aiUiScaling(50) " y" aiUiScaling(20)
  ControlClick(pos, ai.app[ai.pid].id,,,, "Pos")
}

aiCopyAsSvg() {
  svg := A_Temp "\export.svg"
  success := false

  try FileDelete(svg)
  aiRunScript("file > export > selection as > svg")

  loop 20 {
    if FileExist(svg) {
      Run('cmd /c clip < "' A_Temp '\export.svg"',, "Hide")
      hk("Selection is copied`nto the clipboard as SVG")
      success := true
      break
    }
    Sleep(250)
  }

  if !success {
    err("Can't find '" svg "'")
  }
}

;check gdi handles
aiGdiCheck(threshold?) {
  try {
    hProcess := DllCall("OpenProcess", "Int",0x0400, "Int",0, "UInt",ai.pid, "Ptr")
    gdi := DllCall("GetGuiResources", "Int",hProcess, "Int",0)
    DllCall("CloseHandle", "Int",hProcess)

    if IsSet(threshold) {
      if gdi > threshold {
        osd(
          "Achtung! GDI handles are " gdi ".`n"
          . "Time to save files and relaunch Illustrator",
          { time: 5 }
        )
      }

    } else {
      info("GDI handles: " gdi)
    }
  } catch {
    if !IsSet(threshold) {
      err("Can't get GDI handles")
    }
  }
}

aiGetCplId(parentId) {
  docked := "OWL.ControlBarContainer1", win := "ahk_id " parentId
  floating := "ahk_class OWL.ControlBarContainer ahk_pid " ai.pid

  try {
    if ControlGetVisible(docked, win) {
      return ControlGetHwnd(docked, win)
    }
  } catch TargetError {
    if WinExist(floating) {
      return WinGetID(floating)
    }
  }

  err("Can't find Control Panel`nThis is required for Taptapkey")
}

aiInit() {
  winSplash := "ahk_class com.adobe.AdobeSplashKit.GraphicWindowClass"
  winDiagnostic := "Adobe Illustrator ahk_class #32770 ahk_exe Illustrator.exe"

  if !WinActive("ahk_exe Illustrator.exe")
  or WinExist(winSplash) {
    return
  }

  try {
    ai.pid := WinGetPID("A")
  } catch {
    return
  } else {
    if ai.app.Has(ai.pid) {
      return
    }
  }

  if WinActive(winDiagnostic)
  and WinGetList("ahk_pid " ai.pid).Length = 1 {
    ai.pid := 0
    return
  }

  ai.app[ai.pid] := { active: false }

  ;forget the prefs of closed instances of illustrator
  pids := pidList("ahk_exe illustrator.exe")
  ai.app.keys().map(k => (pids.includes(k) or ai.app.delete(k)))

  info("Reading AI Prefs...")
  p := {
    active:         true,
    appPath:        "",
    comVer:         "",
    cpl: Map(
      "id"          ,  0,
      "root"        , {},
      "title"       , { Name: "" },
      "fillColor"   , {},
      "strokeColor" , {},
      "strokeWidth" , {},
      "transform"   , {},
      "x"           , {},
    ),
    id:              0,
    keyboardMap:    {},
    kys: Map(
      "actions", Map("sets", Map(), "keys", Map()),
      "tools",   Map("cmds", Map(), "keys", Map()),
      "menus",   Map("cmds", Map(), "keys", Map()),
      "texts",   Map("cmds", Map(), "keys", Map()),
    ),
    kysPreset:       0,
    kysProfile:     "",
    locale:         "",
    pinchToZoom:    "",
    prefsPath:      "",
    progID:         "",
    ; uiColor:        "",
    uiScaling:       1,
    ver:            "",
  }

  ;getting viewport hwnd
  ; dhw := A_DetectHiddenWindows
  ; DetectHiddenWindows(1)
  ; p.id := WinGetId("ahk_pid " ai.pid)
  ; DetectHiddenWindows(dhw)
  try {
    aiTitle := "ahk_class illustrator ahk_exe Illustrator.exe ahk_pid "
    p.id := WinGetId(aiTitle ai.pid)
  } catch {
    return
  }

  exePath := ProcessGetPath(ai.pid)
  subPath := "\Support Files\Contents\Windows\Illustrator.exe"
  if InStr(exePath, subPath) {
    p.appPath := StrReplace(exePath, subPath)
  } else {
    return err("Can't determine the root path of app")
  }

  ;getting app version
  p.ver := FileGetVersion(exePath)
  log(A_ThisFunc "...")
  log(A_ThisFunc " > p.ver = " p.ver)

  ;checking com reg
  p.comVer := verClosest(ai.dict.comreg.keys(), p.ver)
  log(A_ThisFunc " > p.comVer = " p.comVer)

  if p.comVer {
    comRegValid := false

    ;checking for beta version
    productName := fileGetProductName(exePath)
    if (productName)
    and (SubStr(productName, StrLen(productName) - 5) = "(Beta)") {
      log(A_ThisFunc " > beta version found")
      if !ai.dict.comreg[p.comVer].Has("beta") {
        return err(
          "Can't find COM keys for beta version.`n"
          . "Taptapkey is disabled"
        )
      }
      key := ai.dict.comreg[p.comVer]["beta"]
    } else {
      key := ai.dict.comreg[p.comVer]
    }

    p.progID := key["progid"]
    clsid := getClsIdFromProgId(p.progID)
    log(A_ThisFunc " > clsid (reg) = " clsid)
    log(A_ThisFunc " > clsid (key) = {" key["clsid"] "}")

    if clsid = "{" key["clsid"] "}" {
      regPath := RegRead("HKCR\CLSID\{" key["clsid"] "}\LocalServer32",, false)
      log(A_ThisFunc " > regpath = " regPath)
      log(A_ThisFunc " > exepath = " exePath)

      if regPath and InStr(regPath, exePath) {
        comRegValid := true
      }
    }

    if !comRegValid {
      msg := "
      (LTrim Join`s
        Can't find COM keys for the active Illustrator instance in the registry.
        These are necessary for launching the Illustrator scripts.
        To fix it please grant access in the next pop-up system window.
      )"

      if MsgBox(msg, "Attention", "OKCancel Iconi Owner" p.id) = "OK" {
      ; if MsgBox(msg, "Attention", "OKCancel Iconi") = "OK" {
        if runAhkFileAsAdmin(
          ai.confPath "\aiComReg.ahk",
          true, "Adobe Illustrator", exePath,
          key["progid"], key["clsid"], key["typelib"]
        ) {
          return err(
            "Can't write COM keys into registry.`n"
            . "Taptapkey is disabled"
          )
        }
      } else {
        return err("Taptapkey has been disabled by the user")
      }
    }
  } else {
    return err(
      "Can't find current AI ver (" p.ver ") in the 'comreg.yaml'`n"
      . "Taptapkey is disabled"
    )
  }

  ;getting prefs
  prefsCode := FileRead(ai.scriptsPath "\prefs\get\main.jsx")
  prefsJson := aiRunCodeHere(prefsCode)
  prefsVars := YAML.parse(prefsJson)
  for k, v in prefsVars {
    p.%k% := v
  }

  ;legacy wheel zoom fix
  if VerCompare(p.ver, "<23") {
    p.pinchToZoom := "!"
  }

  ;getting locale
  if IsSpace(p.locale) {
    return err("Can't read locale.`nTaptapkey is disabled")
  } else if !ai.dict.langs.Has(p.locale) {
    return err(
      "Your locale (" p.locale ") is not supported.`n"
      . "Please contact the author.`nTaptapkey is disabled"
    )
  }

  ;getting prefs path
  p.prefsPath := Format(
    "{1}\Adobe\Adobe Illustrator {2} Settings\{3}\x64",
    A_AppData, StrSplit(p.ver, ".")[1], p.locale
  )

  ;setting gdi check
  if ai.gdiCheck {
    SetTimer(() {
      if WinActive("ahk_exe Illustrator.exe") {
        aiGdiCheck(9000)
      }
    }, 60000)
  }

  getActions()
  if getHotkeys() {
    setKeyboardMap()
    setSaveReminder()
    setToggleWhileDrag()
  }
  aiInitCpl(, &p)

  ;;funcs

  getActions() {
    try {
      prefsPath := p.prefsPath "\" aiLocale("Adobe Illustrator Prefs", &p)
      appPrefsContent := FileRead(prefsPath, "`n")
    } catch {

    } else {
      ;getting action sets
      pattern := "ims)\n\t/Action \{.*?\n\t\t/SavedSets \{(.*?)\n\t\t\}"
      if RegExMatch(appPrefsContent, pattern, &match) {
        pattern := "ims)^(\t+)/event-.*?\n\1\}\n?" ;trim all /event-Ns
        actionSets := RegExReplace(match[1], pattern)
        actionSets := aiPrefs2json(actionSets, "aia")
        actionSets := YAML.parse(actionSets)
        actionSets.forEach((setVals, setKey) {
          if InStr(setKey, "set-") {
            aiParseActions(&p.kys, setVals)
          }
        })
      }
    }
  }

  getHotkeys() {
    if p.kysPreset {
      kysFileName := Format(
        "{1}\Presets\{2}\{3}\{4}.kys",
        p.appPath,
        p.locale,
        aiLocale("Keyboard Shortcuts Folder", &p),
        p.kysProfile
      )
    } else {
      kysFileName := Format(
        "{1}\{2}.kys",
        p.prefsPath,
        p.kysProfile
      )
    }

    ;read kys from file
    if !FileExist(kysFileName) {
      err("Can't find kys:`n" kysFileName)
      return false
    }

    kys := FileRead(kysFileName, "`n")
    kys := aiPrefs2json(kys, "kys")
    kys := YAML.parse(kys)

    for section in ["Tools", "Menus"] {
      for cmd, val in kys[section] {

        context := StrLower(section)
        if (context = "menus") and (val["Context"] = 1) {
          context := "texts"
        }

        if val["Key"] { ;the hotkey is bound to a command
          if ai.dict.menus["substitutes"].Has(cmd) {
            cmd := ai.dict.menus["substitutes"][cmd]
          }
          p.kys[context]["cmds"][cmd] := val["Modifiers"] "{" val["Key"] "}"
          p.kys[context]["keys"][val["Modifiers"] val["Key"]] := cmd
        } else {
          p.kys[context]["cmds"][cmd] := "" ;command without hotkey
        }
      }
    }

    return true
  }

  ;make some menu toggles work while dragging
  setToggleWhileDrag() {
    if !ai.toggleWhileDrag {
      return
    }

    dragCondition := 'aiMode("app") and (GetKeyState("LButton") or GetKeyState("MButton"))'

    items := Map(
      "preview", "View > Outline-Preview",
      "Snapomatic on-off menu item", "View > Smart Guides"
    )

    for name, cmd in items {
      if (v := p.kys["menus"]["keys"].indexOf(name)).hasValue {
        HotIfWinActive("ahk_pid " ai.pid) and HotIf(dragCondition)
        Hotkey(v.value, ((cmd, *) => aiRunMenu(cmd)).Bind(cmd))
      }
    }
  }

  setSaveReminder() {
    if ai.remindToSave {
      for k in ["save", "saveas"] {
        if (v := p.kys["menus"]["keys"].indexOf(k)).hasValue {
          HotIfWinActive("ahk_pid " ai.pid) and HotIf('aiMode("app")')
          Hotkey("~" v.value, ((k, *) => aiRemindToSave(k)).Bind(k))
        }
      }
    }
  }

  setKeyboardMap() {
    getIcon(context, v) {
      switch context, 0 {
        case "actions":
          return "#window/actions"

        case "menus":
          if SubStr(v, 1, 6) = "window" {
            v := StrLower(v)
            v := StrReplace(v, " > ", "\")
            v := StrReplace(v, " ", "_")
            return "#" v
          }

        case "texts":
          icon := ai.dict.menus["items"][v]
          if (SubStr(icon, 1, 1) = "~") {
            return "#" StrLower(icon)
          }

        case "tools":
          return "#tools/" StrLower(StrReplace(v, " ", "_"))
      }
    }

    sections := [
      {
        keys:       p.kys["texts"]["keys"],
        cmds:       ai.dict.menus["cmds"],
        title:      v => ai.dict.menus["cmds"][v],
        icon:       v => getIcon("texts", v),
        action:     v => ["aiRunMenu", ai.dict.menus["cmds"][v]],
        context:    "texts",
      }, {
        keys:       p.kys["tools"]["keys"],
        cmds:       ai.dict.tools["cmds"],
        title:      v => ai.dict.tools["cmds"][v],
        icon:       v => getIcon("tools", v),
        action:     v => ["aiSelectTool", ai.dict.tools["cmds"][v]],
        context:    "main",
      }, {
        keys:       p.kys["menus"]["keys"],
        cmds:       ai.dict.menus["cmds"],
        title:      v => ai.dict.menus["cmds"][v],
        icon:       v => getIcon("menus", v),
        action:     v => ["aiRunMenu", ai.dict.menus["cmds"][v]],
        context:    "main",
      }, {
        keys:       p.kys["actions"]["keys"],
        cmds:       "actions",
        title:      v => (v["name"] " (" v["set"] ")"),
        icon:       v => getIcon("actions", v),
        action:     v => ["aiRunAction", v["name"], v["set"]],
        context:    "main",
      }
    ]

    keyMap := Map("main", Map(), "texts", Map())
    for section in sections {
      for k, v in section.keys {
        if section.cmds = "actions" or section.cmds.Has(v) {
          splitHotkey(k, &key, &mods, "verb")
          mods := StrReplace(mods, "-", "")
          key := GetKeyName(key)
          title := section.title.Call(v)
          icon := section.icon.Call(title)
          action := section.action.Call(v)
          val := Map("title", title, "icon", icon, "action", action)
          if !keyMap[section.context].Has(mods) {
            keyMap[section.context].Set(mods, Map())
          }
          keyMap[section.context][mods].Set(key, val)
        }
      }
    }

    fileWrite(YAML.Stringify(keyMap, 0), ai.confPath "\keyboard.json")

    f := "/adobe/illustrator/"
    p.keyboardMap := WidgetWindow(
      f "keyboard.html", f "menu.svg", , "center", "center"
    )
    p.keyboardMap.Hide()
  }

  ;init successful
  ai.app[ai.pid] := p
  info("Reading AI Prefs.`nDone")
}

aiInitCpl(item := "", &app := ai.app[ai.pid]) {
  uiaType := "UIA.IUIAutomationElement"

  if VerCompare(app.ver, "<26") {
    return false
    ;2022 doesn't have UIA cplName, disabling cpl functions
  }

  if VerCompare(app.ver, "<28") {
    cplName := "ObjectTypeLabel"
  } else {
    cplName := aiLocale("Object Type", &app)
  }

  if !app.cpl["id"] {
    app.cpl["id"] := aiGetCplId(app.id)
  }

  if app.cpl["id"] {
    if setCpanel() {
      switch item, 0 {
        default:
          err("Wrong item: '" item "'")

        case "":
          return true

        case "all":
          return setTitle()
             and setStroke()
             and setColors()
             and setTransform()

        case "title":
          return setTitle()

        case "fillColor", "strokeColor":
          return setColors()

        case "strokeWidth", "strokeUp", "strokeDown":
          return setStroke()

        case "transform":
          return setTransform()
      }
    }
  }

  ;funcs

  setCpanel() {
    if Type(app.cpl["root"]) = uiaType {
      return true
    }

    try {
      app.cpl["root"] := UIA.ElementFromHandle(app.cpl["id"])
    } catch {
      err("Can't get Control Panel UIA object")
    } else {
      return true
    }
  }

  setTitle() {
    if Type(app.cpl["title"]) = uiaType {
      return true
    }

    try {
      app.cpl["title"] := UIA.TreeWalkerTrue.GetFirstChildElement(
        app.cpl["root"].FindElement({ Name: cplName })
      )
    } catch {
      err("Can't find 'Object Type' on the Control Panel")
    } else {
      return true
    }
  }

  setStroke() {
    if Type(app.cpl["strokeWidth"]) = uiaType {
      return true
    }

    try {
      app.cpl["strokeWidth"] := app.cpl["root"]
      .FindElement({ Name: aiLocale("Stroke") ":" })
    } catch {
      err("Can't find 'Stroke' on the Control Panel")
    } else {
      return true
    }
  }

  setColors() {
    if Type(app.cpl["fillColor"]) = uiaType {
      return true
    }

    try {
      fills := app.cpl["root"].FindAll(
        { Name: aiLocale("Colors") }
      )
    } catch {
      err("Can't find 'Fill/Stroke Color' on the Control Panel")
    } else {
      if fills.Length >= 3 {
        app.cpl["fillColor"] := fills[1]
        app.cpl["strokeColor"] := fills[3]
        return true
      }
    }
  }

  setTransform() {
    if (Type(app.cpl["x"]) = uiaType)
    or (Type(app.cpl["transform"]) = uiaType) {
      return true
    }

    try {
      app.cpl["x"] := app.cpl["root"].FindElement({ Name: "X:" })
    } catch {
      try {
        app.cpl["transform"] := app.cpl["root"].FindElement(
          { Name: aiLocale("Transform") }
        )
      } catch {
        err("Can't find 'Transform' on the Control Panel")
      }
    } else {
      return true
    }
  }
}

;eval expressions in input field
aiInputEval() {
  clip := ClipboardAll()
  A_Clipboard := ""
  Send("{Home}+{End}+{Delete}")
  if ClipWait(1) {
    input := A_Clipboard
    if decSeparator() = "," {
      input := StrReplace(input, ",", ".")
    }
    input := RegExReplace(input, "(px|pt|p|in|ft|ft_in|yd|mm|cm|m)")
    A_Clipboard := jsCalc(input)
    Send("+{Insert}")
    Sleep(300)
    hk("Eval input")
  } else {
    err("Can't evail input")
  }
  A_Clipboard := clip
}

aiInputFocus(args*) {
  for v in args {
    if ControlGetVisible("Edit" v, "A") {
      ControlFocus("Edit" v, "A")
    }
  }
}

;syncronize two input field of modal window
aiInputSync(args*) {
  ; pairs - map of input pairs indexes,
  ; which may be synced: Edit4, Edit5 = Map(4, 5)
  if Mod(args.Length, 2) {
    err("The number of arguments must be even")
    return
  }

  pairs := Map(args*)
  for k, v in pairs.swapKeyVal() {
    pairs[k] := v
  }

  id := ControlGetFocus("A")
  try {
    name := ControlGetClassNN(id)
  } catch {
    name := ""
  }

  if !IsSpace(name)
  and (SubStr(name, 1, 4) = "Edit")
  and pairs.Has(index := Integer(SubStr(name, 5, 1))) {
    try {
      sibling := "Edit" pairs[index]
      ControlSetText(ControlGetText(id), sibling, "A")
      ControlFocus(sibling, "A")
      Send("{Tab}")
      Sleep(100)
      ControlFocus(id)
      return sibling " = " name
    }
  }
}

aiLegacyZoom(action) {
  switch action, 0 {
    case "in":
      Send("{LAlt down}")
      Sleep(30)
      Send("{WheelUp}")
      Sleep(30)
      Send("{LAlt up}")

   case "out":
      Send("{LAlt down}")
      Sleep(30)
      Send("{WheelDown}")
      Sleep(30)
      Send("{LAlt up}")
  }
}

aiLoadActionSet(set, fileName?) {
  content := ""
  if IsSet(fileName) {
    filePath := ai.actionsPath "\" fileName ".aia"
  } else {
    filePath := ai.actionsPath "\" set ".aia"
  }

  if !FileExist(filePath) {
    err("Can't find action set file:`n" filePath)
    return false

  } else {
    info("Loading Action set '" set "'`n" "Wait a bit...")

    success := aiRunScript(
      "actions > load", true, false, jsEscape(set), jsEscape(filePath)
    )

    if success {
      setVals := FileRead(filePath, "`n")
      if IsSpace(setVals) {
        err("Can't read action set file:`n" filePath)
        return false

      } else {
        setVals := aiPrefs2json(setVals, "aia")
        setVals := YAML.parse(setVals)
        aiParseActions(&ai.app[ai.pid].kys, setVals)
        info("Action set '" set "' loaded")
        return true
      }
    }
  }
}

;alias to the locale literal array
aiLocale(prop, &obj := ai.app[ai.pid]) {
  if ai.pid {
    if obj.HasOwnProp("locale") {
      locales := ai.dict.langs[obj.locale]
      if locales.Has(prop) {
        prop := locales[prop]
      } else {
        err("Locale prop '" prop "'`nnot found in langs.yaml (" obj.locale ")")
      }
    ; } else {
    ;   err("Can't find 'locale' property in obj (prop: '" prop "')")
    }
  }
  return prop
}

;checking conditions for hotkeys
aiMode(mode := "", title := "") {
  ;document: OWL.DocumentWindow
  ;n8ive input: OWL.Palette1

  ;preliminary checks
  if !WinActive("ahk_exe Illustrator.exe")
  or WinExist("ahk_class com.adobe.AdobeSplashKit.GraphicWindowClass") ;splash
  or !ai.pid
  or (ai.app.Has(ai.pid)
      and ai.app[ai.pid].HasOwnProp("active")
      and !ai.app[ai.pid].active
  ) {
    return false
  }

  CoordMode("Mouse", "Screen")
  CoordMode("Pixel", "Screen")

  switch mode, 0 {
    default:
      err("Invalid mode:`n" mode)
      return false

    case "app":
      return !isIt("menu")
         and !isIt("modal")

    case "dropdown":
      return isIt("dropdown")

    case "dropdown:floating":
      return !isIt("menu")
         and !isIt("modal")
         and !isIt("controls:hover")
          or isIt("dropdown")

    case "dropdown:exist":
      return WinExist("Title ahk_class #32770 ahk_pid " ai.pid)

    case "input":
      return (isIt("input") or isIt("palette"))
         and !isIt("menu")
         and !isIt("modal:files")
        ;  and (isIt("modal") or isIt("dropdown"))

    case "input:hover":
      return isIt("input:hover")

    case "main":
      return isMouseOn("active app")
         and !GetKeyState("LButton")
         and !isIt("menu")
         and !isIt("modal")
         and !isIt("texts")
         and !isIt("input")
         and !isIt("input:hover")
         and !isIt("palette")
         and !isIt("presentation")
         and !isIt("plugin:n8ive")

    case "modal":
      return isIt("modal", title)

    case "modal:files":
      return isIt("modal:files")

    case "modal:outside":
      return isIt(
               "modal",
               "^(?!(" aiLocale("Discover")
               . "|" aiLocale("Insert Menu Item")
               . "|Ai Command Palette))"
             )
         and !isIt("popup")
         and isMouseOn("active app")
         and !isMouseOn("active window")

    case "modal:preview":
      return isIt("modal", "^(?!" aiLocale("Discover") ")")
         and isMouseOn("active app")

    case "texts":
      return isIt("texts")

    case "ver=cs": ;legacy
      return (SubStr(WinGetProcessPath("A"), 36, 2) = "cs")
         and !isIt("input:hover")

    case "ver<25":
      return !isIt("menu")
         and !isIt("modal")
         and !isIt("input:hover")
         and VerCompare(appGetVer(), "<25")

    case "ver<25.3":
      return !isIt("menu")
         and !isIt("modal")
         and VerCompare(appGetVer(), "<25.3")

    case "ver<26":
      return !isIt("menu")
         and !isIt("modal")
         and !isIt("input:hover")
         and VerCompare(appGetVer(), "<26")

    case "ver<28.3":
      return !isIt("menu")
         and !isIt("modal")
         and VerCompare(appGetVer(), "<28.3")

    case "*wheel":
      return (!isIt("menu")
              or !isIt("modal")
              or isWinActive("dropdown"))
         and isIt("input")
         and !isIt("popup")
         and !isIt("modal:files")

    case "*widget":
      ;TODO: exclude mouse hover over status bar
      return isMouseOn("active app")
         and !GetKeyState("LButton")
         and !isIt("menu")
         and !isIt("modal")
         and !isIt("controls:hover")
         and !isIt("dropdown")
         and !isIt("popup")
         and !isIt("richtooltip")
  }

  isIt(what, title := "") {
    switch what, 0 {
      default:
        err("Wrong isIt condition: '" what "'")

      case "controls:hover":
        MouseGetPos(,, &winID, &controlID)

        try {
          classNN := ControlGetClassNN(controlID)
        } catch {
          classNN := ""
        }

        try {
          ahkClass := WinGetClass(winID)
        } catch {
          ahkClass := ""
        }

        return (ahkClass = "OWL.Dock")
            or (ahkClass = "OWL.FrameDrawer")
            or (ahkClass = "OWL.ControlBarContainer")
            or InStr(classNN, "OWL.ApplicationBar")
            or InStr(classNN, "OWL.MenuBar")
            or InStr(classNN, "OWL.TabGroup")

      case "dropdown":
        return isWinActive("dropdown")

      case "input":
        return isWinActive("input")

      case "input:hover":
        return isWinActive("input:hover")

      case "menu":
        return isWinActive("menu")

      case "modal":
        return (isWinActive("modal") or isIt("plugin:astute"))
           and isWinActive("regex", title)
           and !isIt("dropdown")
           and !isIt("popup")

      case "modal:files":
        winControls := WinGetControls("A")
        return isWinActive("modal")
           and winControls.includes("ToolbarWindow323")

      case "palette":
        try {
          classNN := ControlGetClassNN(ControlGetFocus("A"))
        } catch {

        } else {
          return InStr(classNN, "OWL.Palette")
        }

      case "plugin:astute":
        return isWinActive("regex", "ahk_class ^AGDMStdClass")

      ; case "plugin:astute:popup":
      ;   return isIt("plugin:astute") and isIt("popup")
      ;     and isMouseOn("active app") and !isMouseOn("active window")

      case "plugin:n8ive":
        return WinActive("ahk_class H-SMILE-FRAME-DC")

      case "popup":
        return (isWinActive("popup") and !isIt("richtooltip"))
            or (isIt("plugin:astute") and IsSpace(WinGetTitle("A")))

      case "presentation":
        try {
          classNN := ControlGetClassNN(ControlGetFocus("A"))
        } catch {

        } else {
          return (classNN = "DroverLord - Window Class8")
        }

      case "richtooltip":
        toolTipTitle := "OS_PopupWindow ahk_exe Illustrator.exe"
        toolTipText := "OS_GIFPLAYER"
        return isWinActive("popup")
           and WinGetList(toolTipTitle, toolTipText).Length

      case "texts":
        return aiInitCpl("title")
           and (ai.app[ai.pid].cpl["title"].Name = aiLocale("Characters"))
    }
  }
}

aiNudge(precision, direction) {
  static arrows := StrMap("up ⏶ down ⏷ left ⏴ right ⏵")
  static precisions := StrSplit("0.01 0.1 1 10", " ")
  static nudgeActionSet := "taptapkey nudges"

  direction := StrLower(direction)
  if !arrows.Has(direction) {
    err("Wrong nudge direction:`n" direction)
    return
  }

  if !precisions.includes(precision) {
    err("Wrong precision:`n" precision)
    return
  }

  arrow := arrows[direction]

  if (precision = 1) {
    aiTap("{" direction "}", arrow "×1")
    return
  }

  if (precision = 10) {
    aiTap("{Shift down}{" direction "}{Shift up}", arrow "×10")
    return
  }

  if !ai.app[ai.pid].kys["actions"]["sets"].Has(nudgeActionSet) {
    aiSetUnits("nudge", "mm")
  }

  action := "nudge - " precision " " direction
  if aiRunAction(action, nudgeActionSet, true, false) {
    hk(arrow "×" precision)
  }

  static win := "ahk_class #32770 ahk_exe Illustrator.exe"
  if WinWait(win,, 0.3) {
    WinActivate(win)
    if WinGetTitle("A") = "Adobe Illustrator" {
      WinClose(win)
      hk("Please, select something")
    }
  }
}

aiOpenDocumentDir() {
  path := aiRunScript("file > get document path", true)
  if path {
    Run('explorer.exe /select,"' path '"')
  }
}

aiOpenPdfPresetsDir() {
  dir := EnvGet("AppData") "\Adobe\Adobe PDF\Settings"
  if DirExist(dir) {
    Run('explorer.exe "' dir '"')
  } else {
    err("Can't find PDF-presets dir")
  }
}

aiOpenPrefsDir(subDir := "") {
  dir := ai.app[ai.pid].prefsPath
  if !IsSpace(subDir) and DirExist(dir "\" subDir) {
    Run('explorer.exe /select,"' dir "\" subDir '"')
  } else {
    Run('explorer.exe "' dir '"')
  }
  hk("Open '" dir "'")
}

;same as aiRunMenu("View > Outline-Preview")
aiOutlinePreview(*) {
  SetTimer(() {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(1)
    PostMessage(0x111, 30,,, "A")
    DetectHiddenWindows(dhw)
  }, -50)
}

aiParseActions(&obj, list) {
  actions := Map()

  setName := list["name"]
  for key, val in list {
    if InStr(key, "action-") {
      actionName := val["name"]
      shortcut := val["keyIndex"]

      actions.Set(actionName, shortcut)
      if shortcut {
        shortcut := StrReplace(StrReplace(shortcut, "{"), "}")
        obj["actions"]["keys"].Set(shortcut, Map())
        obj["actions"]["keys"][shortcut].Set("name", actionName, "set", setName)
      }
    }
  }
  obj["actions"]["sets"].Set(setName, actions)
}

;paste alpha png from clipboard
aiPasteApng() {
  if saveClipPngAlpha() {
    aiRunScript("file > place temp clip")
    return "Paste transparent image"
  } else {
    err("Can't find transparent image in the clipboard")
  }
}

;load data from prefs file to the var
aiPrefs2json(result, confType := "") {
  confType := StrLower(confType)
  if !["aia", "kys", ""].includes(confType) {
    err(A_ThisFunc ". Wrong config type:" confType)
    return
  }

  keyPattern := "m)^([\s\t]*)/((?:\\ |[^\s])+)(?: |$)(.*)$"
  hexValuePattern := "\[\s*(\d+)\s*([\da-fA-F\s]+?)\]"

  result := RegExReplace(result, keyPattern, parseKey)
  result := RegExReplace(result, hexValuePattern, decodeHexValue)
  result := RegExReplace(result, "m)}$", "},") ;comma after the closing brace
  result := "{`n" result "`n}"
  return result

  ;funcs

  parseKey(match) {
    indent := match[1]
    key := match[2]
    key := StrReplace(key, "\ ", " ")
    key := StrReplace(key, "\", "\\")
    value := Trim(match[3])

    ;value is not object or hex data
    if (value != "{") and (SubStr(value, 1, 1) != "[") {

      switch confType, 0 {
        case "aia": ;process action keycodes
          switch key, 0 {
            case "keyIndex":
              if ai.dict.keys[confType].Has(value) {
                value := ai.dict.keys[confType][value]
              } else {
                err(A_ThisFunc ". Unknown aia keyCode: " value)
              }
          }

        case "kys": ;process kys profile keycodes
          switch key, 0 {
            case "key":
              if ai.dict.keys[confType].Has(value) {
                value := ai.dict.keys[confType][value]
                value := vk(value, "soft") ;convert sensitive key to it's vk code
                value := StrReplace(value, "\", "\\") ;escape backslash
              } else {
                err(A_ThisFunc ". Unknown kys keyCode: " value)
              }

            case "modifiers":
              value := ((value & 128) ? "!" : "")
                     . ((value &  64) ? "^" : "")
                     . ((value &  32) ? "+" : "")
          }
      }

      if !IsNumber(value) {
        value := '"' value '"'
      }
      value .= ","
    }

    return indent '"' key '": ' value
  }

  decodeHexValue(match) {
    length := match[1] * 2
    value := RegExReplace(match[2], "[\s\t\n\r]+")

    if StrLen(value) = length {
      value := hex2utf8(value)
    } else {
      err(A_ThisFunc ". Invalid parsing value length in:`n" match[0])
    }

    return '"' value '",'
  }
}

aiRemindToSave(cmd) {
  notify() {
    static oldTickCount := A_TickCount
    static interval := ai.remindToSave * 60000
    if aiMode("app") and (A_TickCount - oldTickCount >= interval) {
      osd("Time to save?", { opacity: 50 })
      oldTickCount := A_TickCount
    }
  }

  if ai.remindToSave {
    SetTimer(notify, 0)
    SetTimer(notify, -1)
    SetTimer(notify, 20000)
  }
}

aiRunAction(action, set := "", mustSelected := false, useHotkey := false) {
  static msg := "Please reload the action set or restart"
  . " Illustrator, if the set already loaded"

  if IsSpace(set) {
    set := "taptapkey"
  }

  actionSets := ai.app[ai.pid].kys["actions"]["sets"]

  if !actionSets.Has(set) {
    if FileExist(ai.actionsPath "\" set ".aia") {
      if !aiLoadActionSet(set) {
        err("Can't find action '" action "' in the set: '" set "' set.`n" msg)
        return false
      }
    } else {
      err("The action set '" set "' not found.`n" msg)
      return false
    }
  }

  if !actionSets[set].Has(action) {
    err("Can't find action '" action "' in the '" set "' set.`n" msg)
  } else {
    actionKey := actionSets[set][action]
    if useHotkey and actionKey {
      BlockInput(1)
      Send("{Blind!^+#}" actionKey)
      BlockInput(0)
    } else {
      if mustSelected {
        condition := "if (app.documents.length > 0 && "
        . "app.activeDocument.selection.length > 0) "
      } else {
        condition := ""
      }
      code := "app.doScript('" jsEscape(action) "', '" jsEscape(set) "');"
      aiRunCodeHere(condition code)
    }
    (ai.showHint) and hk(A_ThisFunc "`n" action ",`n" set, A_ThisHotkey)
    return true
  }
}

;run js code in separated process
aiRunCode(code, waitReturn := false) {
  wrapper := 'ComObject("{}").DoJavaScript("`n(`n{}`n)")'
  progId := ai.app[ai.pid].progID
  return runAhkCode(Format(wrapper, progId, code), waitReturn)
}

;run js code in this process
aiRunCodeHere(code) {
  static com := Map()
  ver := FileGetVersion(ProcessGetPath(ai.pid))
  comVer := verClosest(ai.dict.comreg.keys(), ver)

  if !com.Has(ai.pid) {
    try {
      com[ai.pid] := ComObject(ai.dict.comreg[comVer]["progid"])
    } catch Any as e {
      infoBox(
        "Can't get COM object. Please contact the developer`n---`n"
        . e.Message "`n" e.What "`n" e.Extra
      )
    }
  }
  return com[ai.pid].DoJavaScript(code)
}

aiRunFile(file) => Run('"' WinGetProcessPath("A") '" "' file '"')

aiRunMenu(item) {
  if InStr(item, " > ") { ;item is submenu
    if ai.dict.menus["items"].Has(item) { ;check submenu command in dict
      command := ai.dict.menus["items"][item]
    } else {
      err("Can't find the menu item in the dict:`n" item)
      return
    }
  } else {
    if ai.dict.menus["cmds"].Has(item) {
      command := item ;item is real command, without " > "
    } else {
      err("Can't find the menu command in the dict:`n" item)
      return
    }
  }

  ;check the modified commands list
  if ai.dict.menus["changes"].Has(command) {
    ;TODO: watch this
    aiVer := ai.app[ai.pid].ver? ?? 0

    for v in ai.dict.menus["changes"][command] {
      minVer := v.Has("minVer") ? v["minVer"] : 1
      maxVer := v.Has("maxVer") ? v["maxVer"] : 99
      if VerCompare(aiVer, ">=" minVer) and VerCompare(aiVer, "<=" maxVer) {
        command := v["command"]
        break
      }
    }
  }

  if command == false {
    err(item "`nis not supported by your AI version")
  } else {
    if ai.dict.menus["bugs"].includes(command) {
      err("The '" item "' cannot be runned due to a PARM error.")
    } else {
      code := "try {app.executeMenuCommand('" command "')} catch (e) {throw e}"
      aiRunCode(code)
      (ai.showHint) and hk(A_ThisFunc "`n" item)
    }
  }
}

;call menu, wait modal window, move it to the mouse
aiRunMenuAtMouse(item, title, x := 0, y := 0, waitTimeout := 3) {
  aiRunMenu(item)
  if WinWaitActive(title,, waitTimeout) {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    WinMove(mx + x, my + y)
  }
}

aiRunScript(script, waitReturn := false, showHint := unset, arguments*) {
  ;TODO: try to prevent sending enter from script
  scriptPath := StrReplace(script, " > ", "\")

  if !(FileExist(fileName := ai.scriptsPath "\" scriptPath ".js")
    or FileExist(fileName .= "x")
    or FileExist(fileName := scriptPath)
  ) {
    err("Can't find script file:`n" script)
    return
  }

  ; if InStr(fileName, "_action.js") {
  ;   result := aiRunFile(fileName)
  ; } else {
    result := runAhkFile(
      ai.confPath "\aiRunScript.ahk", waitReturn,
      ai.app[ai.pid].progID, fileName, arguments*
    )
  ; }

  if (isSet(showHint) ? showHint : ai.showHint) {
    hk(A_ThisFunc "`n" script (waitReturn ? "`n" result : ""))
  }

  if waitReturn {
    return result
  }
}

aiSelection(action, item := "") {
  ;TODO: l10n
  ;action: save/load/clear; item: 1..9
  static prefix := "*&"
  static iterations := 20
  static waitTimeout := 4
  static winEditSelection := "Edit Selection ahk_exe Illustrator.exe"
  static winSaveSelection := "Save Selection ahk_exe Illustrator.exe"
  static delay := 70

  active := ""

  dhw := A_DetectHiddenWindows
  DetectHiddenWindows(1)
  BlockInput(1)

  aiRunMenu("Select > Edit Selection...")

  if !WinWaitActive(winEditSelection,, waitTimeout) {
    err("Editing selection`n" item)
  } else {
    Send("+{Tab}")
    switch action, 0 {
      case "clear":
        while !IsSpace(ControlGetText("Edit1", "A")) {
          Send("!" wk("d"))
        }
        Send("{Enter}")
        hk("All selections are deleted")

      case "save":
        loop iterations {
          if IsSpace(active := ControlGetText("Edit1", "A")) {
            break
          } else {
            if active = prefix item {
              Send("!" wk("d"))
              Sleep(delay)
              Send("{Tab 3}")
              Sleep(delay)
              Send("{Down}")
            } else {
              Send("{Down}")
            }
          }
        }
        Send("{Enter}")

        aiRunMenu("Select > Save Selection...")
        if WinWaitActive(winSaveSelection,, waitTimeout) {
          Send(prefix item "{Enter}")
          hk("Save selection`n" item)
        } else {
          err("Saving selection`n" item)
        }
    }
  }

  DetectHiddenWindows(dhw)
  BlockInput(0)
}

aiSetUnits(section, units) {
  z(times := 1) => Sleep(200 * times)
  split(arg) => StrSplit(arg, " ")
  apply() {
    try {
      ok := UIA.ElementFromHandle(WinGetID("A"))
      .FindElement([{ Name: aiLocale("OK") }])
    } catch {
      Send("{Enter}")
    } else {
      ok.GetCurrentPattern("LegacyIAccessible").DoDefaultAction()
    }
  }

  waitTimeout := 4
  nudgeActionSet := "taptapkey nudges"

  winPreferences := aiLocale("Preferences") " ahk_pid " ai.pid
  winDocumentSetup := aiLocale("Document Setup") " ahk_pid " ai.pid

  prefsSearch := VerCompare(ai.app[ai.pid].ver, ">=29.7") ;search field added
  legacy := VerCompare(ai.app[ai.pid].ver, "<24.3") ;units order changed
  asian := ["ja", "ko", "zh"].includes(SubStr(ai.app[ai.pid].locale, 1, 2))

  u := {}

  if legacy {
    u.general := split("pt p in mm cm px")
    u.stroke  := split("pt p in mm cm px")
  } else {
    u.general := split("px pt p in ft ft_in yd mm cm m")
    u.stroke  := split("px pt p in mm cm")
  }
  u.type      := split("pt in mm px")

  if asian {
    if legacy {
      u.general.InsertAt(6, "H")
      u.stroke.InsertAt(6, "H")
    } else {
      u.general.InsertAt(4, "H")
      u.stroke.InsertAt(4, "H")
    }
    u.type.InsertAt(4, "H")
  }

  i := {}
  i.general := u.general.indexOf(units) - 1

  switch section, 0 {
    default:
      err(A_ThisFunc ": " section ". Wrong section name")
      return

    case "all":
      aiSetUnits("document", units)
      aiSetUnits("general", units)
      aiSetUnits("nudge", units)

    case "document":
      if i.general = -1 {
        err(A_ThisFunc ":" section ". Units '" units "' not found")
        return
      }

      aiRunMenu("File > Document Setup...")
      if WinWaitActive(winDocumentSetup,, waitTimeout) {
        z(4)
        tap("{Home}{Down " i.general "}")
        apply()

      } else {
        err("Can't find Document Setup window")
        return
      }

    case "general":
      if i.general = -1 {
        err(A_ThisFunc ":" section ". Units '" units "' not found")
        return
      }

      item := ai.dict.units[units]

      aiRunMenu("Edit > Preferences > Units...")
      if WinWaitActive(winPreferences,, waitTimeout) {
        i.stroke := u.stroke.indexOf(item["stroke"]) - 1
        i.type := (u.type.indexOf(item["type"]) or 1) - 1
        i.eatype := item.Has("eatype")
          ? (u.type.indexOf(item["eatype"]) or 1) - 1
          : i.type
        z(4)

        ;units
        z(), tap("{Home}{Down " i.general "}")
        z(), tap("{Tab}{Home}{Down " i.stroke "}")
        z(), tap("{Tab}{Home}{Down " i.type "}")
        if asian {
          z(), tap("{Tab}{Home}{Down " i.eatype "}")
        }

        ;guides & grid
        z(), tap("{Tab " (2 + prefsSearch) "}{Down}")
        z(), tap("{Tab 7}" item["grid"])
        z(), tap("{Tab}" item["subdiv"])
        z(), tap("{Tab " (3 + prefsSearch) "}{Up 4}")

        ;general
        z(), tap("{Tab 3}" item["inc"])
        z(), tap("{Tab 2}" item["corner"])

        apply()
      } else {
        err("Can't find Preferences window")
        return
      }

    case "grid":
      aiRunMenu("Edit > Preferences > Guides & Grid...")
      if WinWaitActive(winPreferences,, waitTimeout) {
        units := StrSplit(units, ",").map(v => Trim(v))
        z(), tap(units[1])

        if units.Has(2) {
          z(), tap("{Tab}" units[2])
        }

        apply()

      } else {
        err("Can't find Preferences window")
        return
      }

    case "increment":
      aiRunMenu("Edit > Preferences > General...")
      if WinWaitActive(winPreferences,, waitTimeout) {
        z(), tap("{Tab}+{Tab}" units)
        apply()

      } else {
        err("Can't find Preferences window")
        return
      }

    case "nudge":
      if VerCompare(ai.app[ai.pid].ver, "<26") {
        fileSet := nudgeActionSet " v25 " units
      } else {
        fileSet := nudgeActionSet " " units
      }

      if !aiLoadActionSet(nudgeActionSet, fileSet) {
        err("Can't load nudge action set: '" fileSet ".aia'")
        return
      }
  }

  hk(A_ThisFunc "`n" section " " units)
}

aiShowKeyboardMap() {
  if ai.app[ai.pid].hasOwnProp("keyboardMap") {
    SetTimer((*) => ai.app[ai.pid].keyboardMap.Show(), -150)
  }
}

aiTap(keys, msg?) {
  tap(, ai.tapLayout)
  blind := "{Blind!^+#}"
  ; blind := ""
  ControlSend(blind keys,, ai.app[ai.pid].id)
  hk(msg ?? keys)
}

aiTogglePreview() {
  try {
    UIA.ElementFromHandle(WinGetID("A"))
    .FindElement([{ Name: aiLocale("Preview") }])
    .GetCurrentPattern("LegacyIAccessible").DoDefaultAction()
    hk("Toggle Preview")
  }
}

aiSelectTool(tool) {
  if ai.dict.tools["items"].Has(tool) {
    command := ai.dict.tools["items"][tool]
  } else if ai.app[ai.pid].kys["tools"]["cmds"].Has(tool) {
    command := tool
  } else {
    err("Wrong tool name:`n" tool)
    return
  }

  if VerCompare(ai.app[ai.pid].ver, "<24")
    or ai.dict.tools["bugs"].includes(command) {
    ;select tool with hotkey
    k := ai.app[ai.pid].kys["tools"]["cmds"][command]

    if !IsSpace(k) {
      splitHotkey(k, &key, &mods)
      if InStr(mods, "+") {
        aiTap("{Shift down}")
        Sleep(50)
      }
      aiTap(key, A_ThisFunc "`n" tool)
      if InStr(mods, "+") {
        Sleep(50)
        aiTap("{Shift up}")
      }
      ; aiLogTool(command)
    } else {
      err("The tool '" tool "'`nis not associated with a hotkey")
    }

  } else {
    ;select tool with script
    aiRunCode("try {app.selectTool('" command "')} catch (e) {};")
    ; aiLogTool(command)
    (ai.showHint) and hk(A_ThisFunc "`n" tool)
  }
}

aiLogTool(tool) {
  static maxItems := 10

  if !ai.HasOwnProp("toolsHistory") {
    ai.toolsHistory := []
    ai.toolsHistoryPath := ai.confPath "\toolsHistory.txt"
  }

  if !ai.dict.tools.err.indexOf(tool) {
    if alreadyUsed := ai.toolsHistory.indexOf(tool) {
      ai.toolsHistory.RemoveAt(alreadyUsed)
    }

    ai.toolsHistory.InsertAt(1, tool)
    if ai.toolsHistory.Length > maxItems {
      ai.toolsHistory.RemoveAt(maxItems + 1, ai.toolsHistory.Length - maxItems)
    }

    try fileWrite(ai.toolsHistory.join("`n"), ai.toolsHistoryPath)
  }
}

aiUiScaling(dimension) {
  factor := ai.app[ai.pid].uiScaling ?? 1
  return Integer(factor * dimension)
}

aiUnhideOthers() {
  aiRunMenu("Object > Show All")
  aiRunMenu("Select > Inverse")
}