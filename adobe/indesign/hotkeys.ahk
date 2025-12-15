;adobe indesign hotkeys

;;WIDGETS
  idWidgetMenu() {
    static f := "/adobe/indesign/menu."
    static m := WidgetMenu(f "yaml", f "svg")
    m.Show()
  }

  #HotIf            idMode()
    RButton up::    idWidgetMenu()

;;KEYS
  #HotIf            idMode()
    ~LAlt::         Send("{Blind}{" A_MenuMaskKey "}") ;disable menu on single alt pressed

    #WheelUp::      Send("!{PgUp}") ;prev page
    #WheelDown::    Send("!{PgDn}") ;next page

;;MOUSE
  #HotIf            idMode()
    MButton::       mouse("Space", "LButton") ;pan
    WheelUp::       Send("!{WheelUp}") ;zoom in
    WheelDown::     Send("!{WheelDown}") ;zoom out
