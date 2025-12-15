;figma hotkeys

;;WIDGETS
  fgWidgetMenu() {
    static f := "/figma/menu."
    static m := WidgetMenu(f "yaml", f "svg", f "css")
    m.Show()
  }

  #HotIf            fgMode()
    RButton::       fgWidgetMenu()

;;KEYS
  #HotIf            fgMode()
    ^vkC0::         fgTap("zoom to 100%") ;ctrl-`
    ^y::            fgTap("show outlines")
    ^!+v::          pasteWithoutFormatting()

    !c::            fgTap("pick color tool")
    !f::            fgTap("pen tool")
    !x::            fgTap("scale tool")

    ;resize to the opposite side
    ^!Up::          Send("{Up}^{Down}")
    ^!Down::        Send("{Down}^{Up}")
    ^!Left::        Send("{Left}^{Right}")
    ^!Right::       Send("{Right}^{Left}")
    ^!+Up::         Send("+{Up}+^{Down}")
    ^!+Down::       Send("+{Down}+^{Up}")
    ^!+Left::       Send("+{Left}+^{Right}")
    ^!+Right::      Send("+{Right}+^{Left}")

    F1::            getTapTime()
    ~F1 up::        (getTapTime("up") < 250) and fgAction()

;;MOUSE
  #HotIf            fgMode()
    ;selection
    #LButton::      fgTap("deep select")
    #RButton::      fgTap("collapse layers")
    #WheelUp::      fgTap("select parent")
    #WheelDown::    fgTap("select children")
    CapsLock & Tab::fgTap("minimize ui")

    ^WheelUp::      fgTap("bring forward")
    ^WheelDown::    fgTap("send backward")
    +^WheelUp::     fgTap("bring to front")
    +^WheelDown::   fgTap("send to back")

    +RButton::      { ;figma menu
                      CoordMode("Mouse", "Window")
                      Click(50, 80)
                      Sleep(100)
                      Click(200, 220)
                    }

    ~MButton::      fgZeroValue()
    MButton up::    fgZeroValue("up") ;zero input value
