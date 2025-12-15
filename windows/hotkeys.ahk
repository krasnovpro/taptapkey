;windows

;;WIDGETS
  winWidgetMenu() {
    static f := "/windows/menu."
    static m := WidgetMenu(f "yaml", f "svg")
    m.Show()
  }

  #HotIf
    CapsLock & F2:: winWidgetMenu()

;;KEYS
  ;menu navigation
  #HotIf            WinExist("ahk_class #32768")
                 or WinExist("ahk_class Xaml_WindowedPopupClass")
                 or WinExist("PopupHost ahk_class Microsoft.UI.Content.PopupWindowSiteBridge")

    WheelUp::       Send("{Up}")
    WheelDown::     Send("{Down}")

    +WheelUp::      Send("{Up 4}")
    +WheelDown::    Send("{Down 4}")

    CapsLock & WheelUp::      Send("{Escape}")
    CapsLock & WheelDown::    Send("{Enter}")

  #HotIf
    CapsLock::
    *CapsLock up::  capsLock()

    CapsLock & F1:: winCalculator()

    ~CapsLock & Pause:: { ;show active app ;ctrl- kill ;shift- kill all instances
                      switch {
                        default:
                          winAppKill("show")

                        case GetKeyState("Control"):
                          winAppKill("active")

                        case GetKeyState("Shift"):
                          winAppKill("all")
                      }
                    }

    CapsLock & PrintScreen:: winWindow("expand")

    ;left handed numpad
    CapsLock & 1::  blindSend("NumpadDiv")
    CapsLock & 2::  blindSend("NumpadMult")
    CapsLock & 3::  blindSend("NumpadSub")
    CapsLock & 4::  blindSend("NumpadAdd")

    CapsLock & q::  blindSend("Numpad7")
    CapsLock & w::  blindSend("Numpad8")
    CapsLock & e::  blindSend("Numpad9")
    CapsLock & r::  blindSend("NumpadEnter")

    CapsLock & a::  blindSend("Numpad4")
    CapsLock & s::  blindSend("Numpad5")
    CapsLock & d::  blindSend("Numpad6")
    CapsLock & f::  blindSend("BackSpace")
    CapsLock & g::  blindSend("Delete")

    CapsLock & z::  blindSend("Numpad1")
    CapsLock & x::  blindSend("Numpad2")
    CapsLock & c::  blindSend("Numpad3")
    CapsLock & v::  blindSend("Numpad0")
    CapsLock & b::  blindSend("Numpad.")

    CapsLock & t::  { ;toggle numlock
                      numState := !GetKeyState("NumLock", "T")
                      SetNumLockState(numState)
                      hk("NumLock " (numState ? "On" : "Off"))
                    }

    ;vim-like nav
    CapsLock & h::  blindSend("Left")
    CapsLock & j::  blindSend("Down")
    CapsLock & k::  blindSend("Up")
    CapsLock & l::  blindSend("Right")

    CapsLock & y::  blindSend("Home")
    CapsLock & u::  blindSend("PgDn")
    CapsLock & i::  blindSend("PgUp")
    CapsLock & o::  blindSend("End")
