;any apps settings

;;windows help
  #HotIf            WinActive("ahk_exe hh.exe")
                    or WinActive("ahk_exe chars.exe")
    ^a::            { ;select all
                      hwnd := ControlGetFocus("A")
                      if ControlGetClassNN(hwnd) ~= "^Edit\d+" {
                        selectLine()
                      } else {
                        Send("^" wk("a"))
                      }
                    }

;;ahk debug vars
  #HotIf            WinActive("DebugVars.ahk ahk_class AutoHotkeyGUI")
                    or WinActive("CodeQuickTester ahk_class AutoHotkeyGUI")
                    or WinActive("Inspector ahk_class AutoHotkeyGUI")
    F1::
    F2::
    F3::            { ;resize the window to 1/3 of the screen
                      vertThird := SubStr(ThisHotkey, 2, 1) - 1
                      x := 5 + ((A_ScreenWidth - 10) // 3) * vertThird
                      y := 40
                      w := A_ScreenWidth // 3
                      h := A_ScreenHeight - 90
                      WinMove(x, y, w, h)
                    }

;;browsers
  #HotIf            WinActive("ahk_group browsers") and !isWinActive("modal")
                    (() {
                      browserList := "
                      (
                        brave
                        browser
                        chrome
                        comet
                        firefox
                        msedge
                        opera
                        vivaldi
                      )"
                      loop Parse browserList, "`n" {
                        GroupAdd("browsers", "ahk_exe " A_LoopField ".exe")
                      }
                    })()
    F1::            isTaps() = 1 ? Send("^" wk("t")) : passTap() ;tab: new, *longtap: send F1

    ~LButton & RButton:: { ;tab close, *longtap: tab reopen
                      conf := { hint: [[Chr(0x26CC) " tab"],
                                      [Chr(0x2B6F) " tab"]] }
                      if isTaps(, conf) = 1 {
                        Send("^" wk("w"))
                      } else {
                        Send("^+" wk("t"))
                      }
                    }

    XButton1::XButton1
    XButton1 & LButton:: { ;switch active tab to another browser
                      static f := "/general/browsers."
                      static m := WidgetMenu(f "yaml", f "svg")
                      m.Show()
                    }

                    switchBrowser(path, *) {
                      realPath := expandEnvVars(path)

                      if !FileExist(realPath) {
                        err("Can't find '" path "'")
                        return
                      }

                      clip := ClipboardAll()
                      A_Clipboard := ""
                      Send("^" wk("l"))
                      Sleep(500)
                      Send("^" wk("a"))
                      Send("{Control down}")
                      Sleep(0)
                      Send("{Insert}")
                      Sleep(0)
                      Send("{Control up}")
                      if ClipWait(4) {
                        Run('"' realPath '" "' A_Clipboard '"')
                        Send("^{F4}")
                      }
                      A_Clipboard := clip
                    }

    XButton1 & WheelUp::   Send("^{PgUp}"), hk(Chr(0x23F4) " tab") ;tab: prev
    XButton1 & WheelDown:: Send("^{PgDn}"), hk("tab " Chr(0x23F5)) ;tab: next

  #HotIf            WinActive("ahk_exe firefox.exe") and !isWinActive("modal")
    >^. up::        { ;prefs
                      Send("^" wk("t"))
                      Sleep(100)
                      SendText("about:preferences`n")
                    }

    *>!.::          { ;logins
                      Send("{Blind!}^" wk("t"))
                      Sleep(100)
                      SendText("about:logins`n")
                    }

;;cudatext
  #HotIf            WinActive("ahk_exe cudatext.exe")
    Escape::        WinClose("A")

;;debugview
  #HotIf            WinActive("ahk_exe debugviewpp.exe")
    F1::            tap("!ot") ;always on top

;;eagle mode
  #HotIf            WinActive("ahk_exe eaglemode.exe")
    !Space::        {
                      switch isTaps() {
                        default: Send("{Home}")
                        case 1:  Send("!{Home}")
                        case 2:  Send("+!{Home}")
                      }
                    }

;;excel
  #HotIf            WinActive("ahk_exe excel.exe")
    ^a::            selectLine()

;;explorer
  #HotIf            WinActive("ahk_class CabinetWClass ahk_exe explorer.exe")
                    or (isWinActive("modal")
                        and (WinGetControls("A").includes("ToolbarWindow323")
                          or WinGetControls("A").includes("ToolbarWindow321"))
                    ) and !isWinActive("dropdown")
    ^h::            { ;toggle hidden files
                      key := "HKCU\SOFTWARE\Microsoft\Windows"
                        . "\CurrentVersion\Explorer\Advanced"
                      if RegRead(key, "Hidden") = 2 {
                        RegWrite(1, "REG_DWORD", key, "Hidden")
                        msg := "show"
                      } else {
                        RegWrite(2, "REG_DWORD", key, "Hidden")
                        msg := "hide"
                      }
                      Sleep(200)
                      Send("{F5}")
                      hk(msg " hidden files")
                    }

    ^q::            Send("!" wk("p")), hk("toggle preview")

    !q::            { ;focus on quick access
                      waitTap()
                      win := "SysTreeView321"
                      ControlFocus(win, "A")
                      ControlSend("{Down}{Sleep 0}{Up}{Sleep 0}{Home}", win, "A")
                    }

    ^Delete::       deleteWord("Right")
    ^BackSpace::    deleteWord("Left")

;;filepilot
  #HotIf            WinActive("ahk_exe FPilot.exe")
    F1::            tap("^+p") ;commands
    ^g::            Send("{Escape 2}{F4}") ;goto
    ^f::            tap("{Escape 2}{F4}{Sleep 50}favorites`n") ;goto favorites

;;miro
  #HotIf            WinActive("ahk_exe Miro.exe")
    *^WheelUp::     Send("{PgUp}")
    *^WheelDown::   Send("{PgDn}")

;;notepad
  #HotIf            WinActive("ahk_exe notepad.exe")
    !z::            { ;toggle word wrap
                      path := WinGetProcessPath("A")
                      ver := FileGetVersion(path)
                      if VerCompare(ver, ">10") {
                        tap("!v")
                        Sleep(100)
                        tap("w")
                      } else {
                        tap("!ow")
                      }
                      hk("word wrap")
                    }

;;reverso
  #HotIf            WinActive("ahk_exe Reverso.exe")
    ~Escape::       {
                      if (A_PriorHotKey = ThisHotKey)
                      and (A_TimeSincePriorHotkey < 250) {
                        CoordMode("Mouse", "Window")
                        WinGetPos(, , &w)
                        ControlClick(("x" w - 10) (" y" 10))
                      }
                    }

;;sharex
  #HotIf            WinActive("ShareX - Optical character recognition")
    F1::            { ;translate ocr text
                      static qTranslate := "c:\bin\doc\QTranslate\QTranslate.exe"

                      ControlClick("Copy all", "A")
                      WinClose("ShareX - Optical character recognition")
                      Sleep(100)
                      A_Clipboard := RegExReplace(A_Clipboard, "\r\n", " ")
                      Run(qTranslate)
                      if WinWaitActive("ahk_exe qtranslate.exe", , 3) {
                        ControlSetText(A_Clipboard, "RICHEDIT50W1")
                      }
                      hk("translate ocr text")
                    }

;;telegram
  #HotIf            WinActive("ahk_exe Telegram.exe") and !isWinActive("modal")
    F1::            { ;funcs
                      ;if mouse cursor on the:
                      ;  reply icon - open replies
                      ;  own message - edit
                      ;  incoming message - pin
                      ;  *longtap: reply
                      t := isTaps()
                      Send("{RButton}{Down" (t = -1 ? " 2" : "") "}{Enter}")
                    }

;;terminal
  #HotIf            WinActive("ahk_exe WindowsTerminal.exe")
    F1::            (isTaps() = 1) ? Send("^+" wk("p")) : passTap() ;command panel, *longtap: F1

;;total
  #HotIf            WinActive("ahk_class TTOTAL_CMD")
    F11::           Send((toggle("tcFullScreen") ? "" : "!") "{F11}") ;toggle fullscreen
                      ;you need to bind cm_Maximize to F11, cm_Restore to !F11
    ^+n::           Send("+{F6}{Left}\{Left}") ;move selected files into new folder
    !f::            ;main menu hotkeys (fix for non-latin keyboard layout)
    !m::
    !c::
    !n::
    !w::
    !o::
    !s::            tap("{Blind}" ThisHotkey)

  #HotIf            WinActive("Total Commander ahk_class TNASTYNAGSCREEN")
    Space::         Send(ControlGetText(WinActive("ahk_exe totalcmd.exe") ? "TPanel2" : "Window4"))

  #HotIf            WinActive("ahk_class TTOTAL_CMD")
                    or WinActive("ahk_exe LinkEditor.exe")
                    or WinActive("ahk_class TFindFile ahk_exe totalcmd.exe")
                    or WinActive("ahk_class TFindFile ahk_exe totalcmd64.exe")
                    or WinActive("ahk_class TCOMBOINPUT ahk_exe totalcmd.exe")
                    or WinActive("ahk_class TCOMBOINPUT ahk_exe totalcmd64.exe")
                    or WinActive("ahk_class TSEARCHTEXT ahk_exe totalcmd.exe")
                    or WinActive("ahk_class TSEARCHTEXT ahk_exe totalcmd64.exe")
    ^Delete::       deleteWord("Right")
    ^BackSpace::    deleteWord("Left")

  #HotIf            WinActive("ahk_class TLister ahk_exe totalcmd.exe")
                    or WinActive("ahk_class TLister ahk_exe totalcmd64.exe")
    F2::            { ;switch viewer: multimedia/explorer
                      tap("!o")
                      Sleep(50)
                      Send(toggle("totalLister") ? "4" : "8")
                    }

  #HotIf            WinActive("Lister (codeviewer) ahk_class TLister ahk_exe totalcmd.exe")
                    or WinActive("Lister (codeviewer) ahk_class TLister ahk_exe totalcmd64.exe")
    !x::            Send("{F4}"), hk("toggle read-only")
    !z::            tap("!w"), hk("word wrap")
    ^a::            Send("^{Home}+^{End}") ;select all

;;vlc
  #HotIf            WinActive("ahk_exe vlc.exe")
    !Enter::        Send("!" wk(StrSplit("wf")*)) ;fullscreen
    !z::            Send("!" wk(StrSplit("leo")*)) ;speed 100%
    !x::            Send("!" wk(StrSplit("le")*) "{Down 3}{Enter}") ;speed-
    !c::            Send("!" wk(StrSplit("le")*) "{Down}{Enter}") ;speed+
    !+x::           Send("!" wk(StrSplit("lew")*)) ;speed--
    !+c::           Send("!" wk(StrSplit("lef")*)) ;speed++

;;msoffice
  #HotIf            WinActive("ahk_group msoffice") and !isWinActive("modal")
                    loop Parse "winword powerpnt excel", " " {
                      GroupAdd("msoffice", "ahk_exe " A_LoopField ".exe")
                    }

    !^v::           {
                      clip := ClipboardAll()
                      A_Clipboard := A_Clipboard
                      Send("+{Insert}")
                      Sleep(200)
                      A_Clipboard := clip
                      hk("paste text without formatting")
                    }