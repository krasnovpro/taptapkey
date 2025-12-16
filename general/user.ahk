;user settings

/* Use it as example for your own user settings */

ttk.tap := { layout: "English", restore: false }
ttk.hint := { conf: { opacity: 80, time: 10, font: "Consolas" } }

ttk.capsLockEnable := false
ttk.widgetDebug := false

;;ADOBE ILLUSTRATOR
  aiDelObjBelowTop() {
    hint("Select & hide,`nSelect & delete,`nUnhide all")
    Click()
    z() => Sleep(300)
    z(), aiRunMenu("Object > Hide > Selection")
    z(), Click()
    z(), Send("{Delete}")
    z(), aiRunMenu("Object > Show All")
  }

  aiIsolate(arg) {
    switch arg, 0 {
      default:      err(A_ThisFunc ". Wrong argument: " arg)
      case "hover": Send("^{Click}")
                    Sleep(50)
                    aiRunMenu("Object > Isolate > Begin Isolation")
      case "begin": aiRunMenu("Object > Isolate > Begin Isolation")
      case "end":   aiRunMenu("Object > Isolate > End Isolation")
      case "up":    aiRunMenu("Object > Isolate > Isolate Parent Object")
      case "down":  aiRunMenu("Select > Deselect")
                    Send("!{Click}")
                    Sleep(50), Send("{Click}")
                    Sleep(50), Send("{Click}")
    }
  }

  #HotIf            WinActive("ahk_exe Illustrator.exe")
    ~RShift::       ;workaround for layout switching bug, that hangs illustrator
    ~LShift::
    ~*RShift up::
    ~*LShift up::   return

  ;hotkeys
  #HotIf            aiMode("main")
    !Space::        aiRunScript("object > zoom > selected")
    !y::            aiRunMenu("View > Pixel Preview")
    !r::            aiRunScript("object > rename")
    !d::            aiRunScript("object > duplicate")
    !a::            aiDelObjBelowTop()

  ; #HotIf            WinActive("ahk_exe Illustrator.exe") and GetKeyState("LButton")
  ;   ^u::            aiRunMenu("View > Smart Guides"), hint("toggle smart guides")

  ;combos
  #HotIf                      aiMode("main")
                              ttk.hint.xbutton1 := "isolate:`n"
    ~XButton1::               hint(ttk.hint.xbutton1, ttk.hint.conf)
    XButton1 up::             hint()

                              ttk.hint.xbutton1 .= "<  hover ...begin`n"
    XButton1 & LButton::      aiIsolate(isTaps() = 1 ? "hover" : "begin")

                              ttk.hint.xbutton1 .= ">  end`n"
    XButton1 & RButton::      aiIsolate("end")

                              ttk.hint.xbutton1 .= "^  up`n"
    XButton1 & WheelUp::      aiIsolate("up")

                              ttk.hint.xbutton1 .= "v  down`n`n"
    XButton1 & WheelDown::    aiIsolate("down")

                              ttk.hint.xbutton1 .= "_   zoom ...locate`n"
    XButton1 & Space::        isTaps() = 1
                              ? aiRunScript("object > zoom > selected")
                              : aiRunAction("select - locate object")

                              ttk.hint.xbutton1 .= "e  del under top`n"
    XButton1 & e::            aiDelObjBelowTop()

                              ttk.hint.xbutton1 .= "d  duplicate`n"
    XButton1 & d::            aiRunScript("object > duplicate")

                              ttk.hint.xbutton1 .= "r   rename`n"
    XButton1 & r::            aiRunScript("object > rename")

                              ttk.hint.xbutton1 .= "s   toggl sel by path`n"
    XButton1 & s::            aiRunScript("prefs > toggle > select by path only", "waitReturn")

                              ttk.hint.xbutton1 .= "x   del`n"
    XButton1 & x::            Send("{Delete}"), hk("Delete")


                              ttk.hint.xbutton2 := "select:`n"
    ~XButton2::               hint(ttk.hint.xbutton2, ttk.hint.conf)
    XButton2 up::             hint()

                              ttk.hint.xbutton2 .= "<  inv2`n"
    XButton2 & LButton::      aiRunAction("select - inverse inverse")

                              ttk.hint.xbutton2 .= ">  +++`n"
    XButton2 & RButton::      aiRunScript("select > selection plus")

                              ttk.hint.xbutton2 .= "↑  · · ·`n"
    XButton2 & WheelUp::      aiRunScript("select > anchors > only")

                              ttk.hint.xbutton2 .= "↓  −−−`n"
    XButton2 & WheelDown::    aiRunScript("select > selection paths")

  #HotIf            aiMode("app")
    !f::            ;fix for main menu hotkeys (english version)
    !e::            ;with non-latin keyboard layout
    !o::
    !t::
    !c::
    !v::
    !w::
    !h::            tap("{Blind}" ThisHotkey)

    !q::            tap("{Blind}!o" (isTaps() = 1 ? "" : "p{Enter}")) ;object, *longtap: object\path
    !s::            tap("{Blind}!s" (isTaps() = 1 ? "" : "o")) ;select, *longtap: select\object

  #HotIf            aiMode("main")
    +1::            ;fix for tool hotkeys (english version)
    +2::            ;with non-latin keyboard layout
    +3::
    +4::
    +5::
    +6::
    +7::
    +8::
    +9::
    +0::
    +-::
    +=::
    +\::
    +vkBA::
    +vkBC::
    +vkBE::
    +vkBF::
    +vkDB::
    +vkDD::
    +vkDE::
    +vkC0::         tap("+{" Substr(ThisHotkey, 2) "}")

    vkBA::
    vkBC::
    vkBE::
    vkBF::
    vkDB::
    vkDD::
    vkDE::          tap("{" ThisHotkey "}")

    ;selection
    !0::            aiSelection("clear") ;clear selection
    !1::
    !2::
    !3::
    !4::
    !5::
    !6::
    !7::
    !8::
    !9::            { ;load selection, *longtap: save selection
                      splitHotkey(ThisHotkey, &key)
                      conf := { hint: [ ["load selection *" key],
                                        ["save selection *" key], ] }
                      if isTaps(, conf) = 1 {
                        tap("!s" key)
                        hk("Load selection *" key)
                      } else {
                        aiSelection("save", key)
                      }
                    }

;;ADOBE INDESIGN

  idPreview() {
    if isTaps() = 1 {
      if toggle("idScreen") {
        tap("^!{F12}")
        hk("Screen mode: preview")
      } else {
        tap("!{F12}")
        hk("Screen mode: normal")
      }
    } else {
      if toggle("idDisplay") {
        tap("!^h")
        hk("Display performance: high quality")
      } else {
        tap("!^z")
        hk("Display performance: preview")
      }
    }
  }

  #HotIf            idMode()
    !f::            ;fix for main menu hotkeys (english version)
    !e::            ;with non-latin keyboard layout
    !l::
    !t::
    !o::
    !a::
    !v::
    !w::
    !h::            tap("{Blind}" ThisHotkey)
    !q::            tap("{Blind}!o") ;object menu

  ;hotkeys
  #HotIf            idMode()
    !z::            idRunMenu("Show Hidden Characters")
    ^y::            idPreview() ;screen: preview/normal, *longtap: display: high/preview

;;ADOBE PHOTOSHOP
  #HotIf            psMode()
    !f::            ;fix for main menu hotkeys (english version)
    !e::            ;with non-latin keyboard layout
    !i::
    !l::
    !y::
    !d::
    !s::
    !t::
    !v::
    !w::
    !h::            tap("{Blind}" ThisHotkey)
    !g::            tap("{Blind}!i")
    !a::            tap("{Blind}!l")

;;WINDOWS
  winAhkMenu() {
    static m

    if !IsSet(m) {
      ahkHelp     := "autohotkey.chm"
      codeTester  := '"' A_AhkPath '" "lib\CodeQuickTester\CodeQuickTester.ahk"'
      debugVars   := '"' A_AhkPath '" "lib\DebugVars\DebugVars.ahk"'
      debugView   := "lib\debugviewpp.exe"
      winSpy      := '"' A_AhkPath '" "lib\WindowSpy.ahk"'

      toggleWidgetDebug() {
        ttk.widgetDebug := !ttk.widgetDebug
        hint("Winget Debug is " (ttk.widgetDebug ? "On" : "Off"))
      }

      m := Menu()
      m.Add("&Code Tester"    , (*) => Run(codeTester))
      m.Add("Autohotkey H&elp", (*) => Run(ahkHelp))
      m.Add()
      m.Add("&Debug Vars"     , (*) => Run(debugVars))
      m.Add("Debug &View"     , (*) => Run(debugView))
      m.Add("Debug Widge&ts"  , (*) => toggleWidgetDebug())
      m.Add("&WinSpy"         , (*) => Run(winSpy))
      m.Add()
      m.Add("&Suspend Hotkeys", (*) => Suspend())
      m.Add("&Reload Script"  , (*) => Reload())
    }
    m.Show()
  }

  ;combos
  #HotIf
    #SuspendExempt  1
    CapsLock & Escape:: winAhkMenu() ;autohotkey service funcs
    #SuspendExempt  0

    CapsLock & Insert:: winWindow("always on top")
    CapsLock & Delete:: winWindow(GetKeyState("Control") ? "ghost" : "opacity")

    ; CapsLock & WheelUp::   Send("#+{Up}")   ;multimonitor: move up
    ; CapsLock & WheelDown:: Send("#+{Down}") ;multimonitor: move down
    CapsLock & LButton:: Send("#+{Left}")   ;multimonitor: move left
    CapsLock & RButton:: Send("#+{Right}")  ;multimonitor: move right
    CapsLock & MButton:: { ;move/resize window
                      switch {
                        default:
                          winWindow("move")

                        case GetKeyState("Ctrl"):
                          winWindow("resize")

                        case GetKeyState("Alt"):
                          winWindow("resize symmetric")
                      }
                    }

  ;keyboard layouts
  #HotIf
    ~*RShift::
    ~*LShift::      winLayout()
    ~*RShift up::   winLayout("Russian", "English")
    ~*LShift up::   winLayout("English", "Russian")

  ;window control
  #HotIf
    *^Tab::         { ;ctrl-tab → alt-tab
                      shift := GetKeyState("Shift") ? "+" : ""
                      Send("{Alt down}" shift "{Tab}")
                      SetTimer(() => (KeyWait("Control"), Send("{Alt up}")), -100)
                    }

    *!Tab::         { ;alt-tab → ctrl-tab
                      shift := GetKeyState("Shift") ? "+" : ""
                      Send("{Control down}" shift "{Tab}")
                      SetTimer(() => (KeyWait("Alt"), Send("{Control up}")), -100)
                    }

    ; <#WheelUp::     ShiftAltTab
    ; <#WheelDown::   AltTab
    ; <#RButton::     #Tab

    ; #`::            { ;toggle windows terminal
    ;                   a := "ahk_exe " (t := "WindowsTerminal.exe")
    ;                   if WinExist(a) {
    ;                     if WinActive(a) {
    ;                       WinMinimize(a)
    ;                     } else {
    ;                       WinActivate(a)
    ;                     }
    ;                   } else {
    ;                     Run(t)
    ;                   }
    ;                 }

  #HotIf            isMouseOn("screen's top edge")
    *LButton::      Send("#{Tab}") ;show tasklist

  #HotIf            isMouseOn("taskbar")
    *WheelUp::      ;cycle active app windows
    *WheelDown::    try WinActivateBottom("ahk_exe" WinGetProcessName("A"))

  #HotIf            isMouseOn("screen's top edge")
    *WheelUp::      { ;switch desktop ;shift- move active app to desktop
                      switch {
                        default:
                          Send("#^{Left}")

                        case GetKeyState("Shift"):
                          winAppToDesktop("Left")
                      }
                    }
    *WheelDown::    { ;switch desktop ;shift- move active app to desktop
                      switch {
                        default:
                          Send("#^{Right}")

                        case GetKeyState("Shift"):
                          winAppToDesktop("Right")
                      }
                    }

  #HotIf            isWinActive("modal:files")
                    or WinActive("ahk_class bridge14")
    !Space::        winChangeDir("total") ;open totalcmd active folder in files dialog

  #HotIf            WinActive("ahk_exe cmd.exe")
                    or WinActive("ahk_exe powershell.exe")
    ^w::            WinClose("A")


  ;layout independent punctuation
  #HotIf
    CapsLock & vkDB::Send(GetKeyState("Shift") ? "{{}" : "{[}")
    CapsLock & vkDD::Send(GetKeyState("Shift") ? "{}}" : "{]}")
    CapsLock & vkBA::Send(GetKeyState("Shift") ? "{:}" : "{;}")
    CapsLock & vkDE::Send(GetKeyState("Shift") ? '{"}' : "{'}")
    CapsLock & vkDC::Send(GetKeyState("Shift") ? "{|}" : "{\}")
    CapsLock & vkBC::Send(GetKeyState("Shift") ? "{<}" : "{,}")
    CapsLock & vkBE::Send(GetKeyState("Shift") ? "{>}" : "{.}")
    CapsLock & vkBF::Send(GetKeyState("Shift") ? "{?}" : "{/}")
    CapsLock & vkC0::Send(GetKeyState("Shift") ? "{~}" : "{``}")

  ; ;close all apps on double escape, except those listed in the loop
  ; #HotIf            !WinActive("ahk_group dontclose")
  ;                   loop Parse "browser chrome firefox", " " {
  ;                     GroupAdd("dontclose", "ahk_exe " A_LoopField ".exe")
  ;                   }
  ;   ~Escape::       { ;escape, escape - closes all other apps
  ;                     if (A_PriorHotKey = ThisHotKey)
  ;                     and (A_TimeSincePriorHotkey < 250) {
  ;                       try WinClose("A")
  ;                     }
  ;                   }

  ; ;turning on the keyboard layout locking for certain apps
  ; ttk.lockLayout := Map(
  ;   "harmonypremium" , "English"
  ;   "houdinifx"      , "English"
  ;   "moi"            , "English"
  ;   "plasticity"     , "English"
  ; )
  ; winToggleLockKeyboardLayout()
