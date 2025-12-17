;adobe illustrator hotkeys

;;WIDGETS
  aiWidgetFuncs(ThisHotkey := "", parentPid := ai.pid) {
    static f := "/adobe/illustrator/funcs."
    static m := WidgetFuncs(f "yaml", f "svg", f "css", -25, -80, 6, 3)
    m.Show(ThisHotkey, parentPid)
  }

  aiWidgetMenu() {
    static f := "/adobe/illustrator/menu"
    static m := WidgetMenu(f ".yaml", f ".svg", f ".css", f ".help")
    toggleStates := aiRunScript("prefs > get > states", true, false)
    m.Show(toggleStates)
  }

  aiWidgetMenuFavorites() {
    static f := "/adobe/illustrator/menu"
    static m := WidgetMenu(f "Favorites.yaml", f ".svg", f ".css", f ".help")
    m.Show()
  }

                    ;for ai.toggleWhileDrag
  #HotIf            aiMode("app") and (GetKeyState("LButton") or GetKeyState("MButton"))

  #HotIf            aiMode("*widget")
    CapsLock::      getTapTime(), capsLock()
    ~CapsLock up::  (getTapTime("up") > 200) ? capsLock() : aiWidgetFuncs("CapsLock")

    RButton::       aiWidgetMenu()
    F1::            isTaps() = 1 ? aiWidgetMenuFavorites() : passTap()

;;KEYS
  #HotIf            aiMode("app")
    ~LAlt::         Send("{Blind}{" A_MenuMaskKey "}") ;disable menu on single alt pressed

  #HotIf            aiMode("input")
    !Space::        aiInputEval()

  #HotIf            aiMode("input") and !aiMode("dropdown:floating")
    ^Delete::       deleteWord("Right")
    ^BackSpace::    deleteWord("Left")

  #HotIf            aiMode("texts")
    Escape::        Escape
    ^Delete::       deleteWord("Right")
    ^BackSpace::    deleteWord("Left")
    >+Space::       Send("{U+00A0}"), hk("nbsp") ;RShift-Space - non-breaking space
    >^>+Space::     aiRunScript("type > nbsp") ;RControl-RShift-Space - no break

  #HotIf            aiMode("ver<28.3")
    ^+b::           aiRunScript("type > style > bold")
    ^+i::           aiRunScript("type > style > italic")
    ^+u::           aiRunScript("type > style > underline")

  #HotIf            aiMode("ver<25.3")
    !^v::           pasteWithoutFormatting()

  #HotIf            aiMode("main")
    Escape::        { ;deselect
                      static first
                      aiRunMenu("Select > Deselect")
                      if isSet(first) {
                        hk()
                      } else {
                        first := false
                        hk("Deselect`n`nPress Shift-Escape`nfor native Escape")
                      }
                    }

    ;nudge
    ^Up::           aiNudge( "0.1", "Up")
    ^Down::         aiNudge( "0.1", "Down")
    ^Left::         aiNudge( "0.1", "Left")
    ^Right::        aiNudge( "0.1", "Right")

    !^Up::          aiNudge("0.01", "Up")
    !^Down::        aiNudge("0.01", "Down")
    !^Left::        aiNudge("0.01", "Left")
    !^Right::       aiNudge("0.01", "Right")

;;MOUSE
  #HotIf            aiMode("input:hover")
    ~MButton::      Send("{Click 3}"), getTapTime() ;select input value
    MButton up::    (getTapTime("up") > 250) and Send("0{Enter}") ;*longtap: zero input value

  #HotIf            aiMode("dropdown:floating")
    +RButton::      { ;fill color panel, *longtap: stroke color panel
                      conf := { hint: [["fill color"], ["stroke color"],] }
                      aiClickCpanel((isTaps(, conf) = 1)
                        ? "fillColor" : "strokeColor")
                    }

    +!RButton::     aiClickCpanel("transform")
    !RButton::      aiClickCpanel("strokeWidth")

  #HotIf            aiMode("dropdown:exist")
    ~MButton::      { ;move dropdown window to the mouse pos
                      mousePos("push")
                      m := mousePos("get")
                      offsetx := offsety := 0
                      WinMove(m.x + offsetx, m.y + offsety)
                      mousePos("pop")
                    }

  #HotIf            aiMode("ver=cs")
    WheelUp::       aiLegacyZoom("in")
    WheelDown::     aiLegacyZoom("out")

  #HotIf            aiMode("ver<26")
    WheelUp::       Send(ai.app[ai.pid].pinchToZoom "{WheelUp}")   ;zoom in
    WheelDown::     Send(ai.app[ai.pid].pinchToZoom "{WheelDown}") ;zoom out
    MButton::       mouse("Space", "LButton")                      ;pan

  #HotIf            aiMode("*wheel")
    *WheelUp::      Send("{Blind}{Up}")
    *WheelDown::    Send("{Blind}{Down}")

  #HotIf            aiMode("main")
                    ;arrange
    ^WheelUp::      aiRunMenu("Object > Arrange > Bring Forward")
    ^WheelDown::    aiRunMenu("Object > Arrange > Send Backward")
    +^WheelUp::     aiRunMenu("Object > Arrange > Bring to Front")
    +^WheelDown::   aiRunMenu("Object > Arrange > Send to Back")
    +WheelUp::      aiRunScript("object > arrange > bring in front of")
    +WheelDown::    aiRunScript("object > arrange > send behind")

                    ;stroke width
    *!WheelUp::     aiClickCpanel("strokeUp")
    *!WheelDown::   aiClickCpanel("strokeDown")

;;MODAL
  #HotIf            aiMode("modal:outside")
    LButton::       WinGetTitle("A") and (Send("{Enter}"), hk("Enter"))
    RButton::       WinGetTitle("A") and (Send("{Escape}"), hk("Escape"))

  #HotIf            aiMode("modal:preview")
    MButton::       aiTogglePreview()

  #HotIf            aiMode("dropdown")
    F1::            { ;click to the ≡ menu
                      CoordMode("Mouse", "Client")
                      mousePos("push")
                      WinGetClientPos(, , &w, , "A")
                      Click(w - 10, 5)
                      Sleep(100)
                      mousePos("pop")
                    }

  #HotIf            aiMode("modal", aiLocale("Discover"))
    F1::            Send("{Escape}")

  #HotIf            aiMode("modal", aiLocale("Keyboard Shortcuts"))
    F1::            { ;select tools/menu commands
                      if isTaps() = 1 {
                        aiInputFocus(1)
                        key := (toggle("aiHotkeyPrefs") ? "Up" : "Down")
                        Send("+{Tab}{" key "}{Tab}")
                        hk("Select Tools/Menu commands")
                      } else {
                        passTap()
                      }
                    }

  #HotIf            aiMode("modal", aiLocale("Blend Options"))
    F1::            tap("!s{Up 2}{Down}"), hk("Spacing steps")

  #HotIf            aiMode("modal", aiLocale("Move"))
    F1::            aiInputFocus(4), hk("Focus horizontal")
    F2::            aiInputSync(3, 4), hk("Sync horizontal/vertical")

  #HotIf            aiMode("modal", aiLocale("Offset Path"))
    F1::            aiInputFocus(2), hk("Focus offset")

  #HotIf            aiMode("modal", aiLocale("Shape Options"))
    F1::            aiInputFocus(3, 5), hk("Focus width")
    F2::            aiInputSync(2, 3, 4, 5), hk("Sync width/height")

  #HotIf            aiMode("modal", aiLocale("Rectangle"))
    F1::            aiInputFocus(2), hk("Focus width")
    F2::            aiInputSync(1, 2), hk("Sync width/height")

  #HotIf            aiMode("modal", aiLocale("Star"))
    F1::            aiInputFocus(3), hk("Focus radius 1")
    F2::            aiInputSync(2, 3), hk("Sync radiuses")

  #HotIf            aiMode("modal", "(" aiLocale("Transform Each")
                                  . "|" aiLocale("Transform Effect") ")")
    F1::            aiInputFocus(6), hk("Focus scale horizontal")
    F2::            aiInputSync(3, 4, 5, 6), hk("Sync horizontal/vertical")

  ;3D
  #HotIf            aiMode("modal", "(" aiLocale("3D Extrude & Bevel Options")
                                  . "|" aiLocale("3D Revolve Options")
                                  . "|" aiLocale("3D Rotate Options") ")")
    F1::            getTapTime(), hint("
                    (LTrim
                      F1-W/A/S/D: set isometric direction
                      F1-WheelUp/Down: set surface
                      F1: focus input
                      F2: axis fix
                    )")
    ~F1 up::        hint(), (getTapTime("up") < 250) and ai3d("focus input")
    F1 & WheelUp::  ai3d("surface", "up")
    F1 & WheelDown::ai3d("surface", "down")
    F2::            ai3d("axis fix")

  #HotIf            aiMode("modal", aiLocale("3D Extrude & Bevel Options"))
    F1 & w::        ai3d("extrude", "top")
    F1 & a::        ai3d("extrude", "left")
    F1 & s::        ai3d("extrude", "bottom")
    F1 & d::        ai3d("extrude", "right")

  #HotIf            aiMode("modal", aiLocale("3D Revolve Options"))
    F1 & w::        ai3d("revolve", "top")
    F1 & a::        ai3d("revolve", "left")
    F1 & s::        ai3d("revolve", "bottom")
    F1 & d::        ai3d("revolve", "right")

  #HotIf            aiMode("modal", aiLocale("3D Rotate Options"))
    F1 & w::        ai3d("rotate", "top")
    F1 & a::        ai3d("rotate", "left")
    F1 & s::        ai3d("rotate", "bottom")
    F1 & d::        ai3d("rotate", "right")

  #HotIf            aiMode("modal", "^(?!" aiLocale("Keyboard Shortcuts") ")")
                    and !aiMode("modal:files")
    F1::            aiInputFocus(1, 2), hk("Focus primary")
    F2::            aiInputSync(1, 2), hk("Sync primary/secondary")

  ; ;it seems to be ok without these hotkeys
  ; #HotIf            aiMode("plugin:astute:popup")
  ;   LButton::       ;astute modal popup close
  ;   RButton::       Send("{Escape}")
