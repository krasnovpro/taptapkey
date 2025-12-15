;adobe photoshop hotkeys

;;KEYS
  #HotIf            psMode()
    ~LAlt::         Send("{Blind}{" A_MenuMaskKey "}") ;disable menu on single alt pressed
    ^!v::           idPasteApng()

  #HotIf            psMode("Vanishing Point")
    Escape::        (isTaps() = -1) and Send("{Escape}") ;*longtap: close vanishing point

;;MOUSE
  #HotIf            psMode()
    MButton::       mouse("Space", "LButton") ;pan
    ^WheelUp::      Send("^]"), hk("bring forward")
    ^WheelDown::    Send("^["), hk("send backward")
    +^WheelUp::     Send("{Blind}+^]"), hk("bring to front")
    +^WheelDown::   Send("{Blind}+^["), hk("send to back")