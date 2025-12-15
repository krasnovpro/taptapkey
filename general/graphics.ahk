;graphic apps settings

                    ;uniform mouse navigation:
                      ;MButton - pan
                      ;RButton - orbit
                      ;WheelUp/Down - zoom in/out

;;3d coat
  #HotIf            WinActive("ahk_exe 3DCoatGL64.exe")
    RButton::       mouse("Alt", "LButton") ;orbit (press with ctrl, for context menu)
    ~RButton & LButton:: { ;wacom pan
                      Send("{RButton up}")
                      Sleep(50)
                      Send("{MButton down}")
                      Sleep(50)
                      KeyWait("LButton")
                      Send("{MButton up}")
                    }

;;3d viewer
  #HotIf            WinActive("3D Viewer ahk_exe ApplicationFrameHost.exe")
    MButton::       mouse("RButton") ;pan
    RButton::       mouse("MButton") ;orbit

;;acrobat
  #HotIf            WinActive("ahk_exe Acrobat.exe") and !isWinActive("modal")
    RButton::       RButton
    RButton & WheelUp::   Send("+^{Tab}"), hint(Chr(0x23F4) " tab") ;tab: prev
    RButton & WheelDown:: Send("^{Tab}"), hint("tab " Chr(0x23F5)) ;tab: next

;;alias
  #HotIf            WinActive("ahk_exe alias.exe")
    MButton::       mouse("Alt", "Shift", "MButton") ;pan
    RButton::       mouse("Alt", "Shift", "LButton") ;orbit

;;blender
  #HotIf            WinActive("ahk_exe blender.exe")
    RButton::       mouse("Shift", "MButton") ;orbit
    CapsLock & WheelUp:: { ;select less ;shift- cycle workspaces
                      if GetKeyState("Shift") {
                        Send("^{PgUp}")
                      } else {
                        Send("^{NumpadSub}")
                      }
                    }

    CapsLock & WheelDown:: { ;select more ;shift- cycle workspaces
                      if GetKeyState("Shift") {
                        Send("^{PgDn}")
                      } else {
                        Send("^{NumpadAdd}")
                      }
                    }

    F1::            (isTaps(, { silent: true }) = 1) ? Send("{F9}") : passTap() ;redo last

    ; F1::            { ;pan
    ;                   Send("{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}")
    ;                 }

    ; F2::            { ;zoom
    ;                   Send("{Control down}{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}{Control up}")
    ;                 }

    ; F3::            { ;orbit
    ;                   Send("{Shift down}{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}{Shift up}")
    ;                 }

;;cacani
  #HotIf            WinActive("ahk_exe cacani_win8.exe")
    MButton::       mouse("Space", "LButton") ;pan

;;cascadeur
  #HotIf            WinActive("ahk_exe cascadeur.exe")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit
    WheelUp::       Send("!{WheelUp}") ;zoom in
    WheelDown::     Send("!{WheelDown}") ;zoom out

;;cinema 4d
  #HotIf            WinActive("ahk_exe CINEMA 4D.exe")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit

;;clavicula
  #HotIf            WinActive("ahk_exe CLAVICULA.exe")
    MButton::       mouse("RButton") ;pan
    RButton::       mouse("MButton") ;orbit

;;corel designer
  #HotIf            WinActive("Corel DESIGNER ahk_exe Designer.exe")
                    and !isWinActive("modal")
    !f::            ;main menu hotkeys (fix for non-latin keyboard layout)
    !e::
    !v::
    !l::
    !j::
    !c::
    !b::
    !x::
    !t::
    !o::
    !w::
    !h::            tap("{Blind}" ThisHotkey)

    ; +MButton::      tap("nn") ;navigator
    #v::            tap("!esp{Enter}") ;paste special (from ai)
    ^y::            { ;toggle outline/preview
                      if toggle("corelDesignerPreview") {
                        tap("!vw{Enter}")
                        hk("Outline")
                      } else {
                        tap("!ve")
                        hk("Preview")
                      }
                    }

  #HotIf            WinActive("Corel DESIGNER ahk_exe Designer.exe")
                    and !isWinActive("modal") and !isWinActive("input:focus")
    >^.::           tap("!oo{Enter}") ;preferences
    >^>!.::         tap("!ooz") ;keyboard shortcuts

    ^WheelUp::      Send("^{PgUp}"), hk("bring forward")
    ^WheelDown::    Send("^{PgDn}"), hk("send backward")
    +^WheelUp::     Send("+{PgUp}"), hk("bring to front")
    +^WheelDown::   Send("+{PgDn}"), hk("send to back")

;;dreamweaver
  #HotIf            WinActive("ahk_exe Dreamweaver.exe")
    !Tab::          tap("!vv") ;code/design
    !z::            tap("!vww") ;toggle word wrap
    >^.::           Send("^u") ;prefs

;;expression
  #HotIf            WinActive("Expression ahk_class EXPR3WndClass")
    MButton::       mouse("Space", "LButton") ;pan
    ^y::            { ;toggle outline/preview
                      if toggle("ExprDesigner") {
                        tap("/")
                        hk("Outline")
                      } else {
                        tap(",")
                        hk("Preview")
                      }
                    }

;;fbxreview
  #HotIf            WinActive("ahk_exe fbxreview.exe")
    RButton::       mouse("LButton") ;orbit
    Escape::        WinClose("A") ;close

;;fontlab
  #HotIf            WinActive("ahk_exe FontLabVI.exe")
    MButton::       mouse("Space", "LButton") ;pan
    WheelUp::       Send("^{WheelUp}") ;zoom in
    WheelDown::     Send("^{WheelDown}") ;zoom out
    $^w::           Send("^w")

;;formz
  #HotIf            WinActive("ahk_exe formZ.exe")
    RButton::       mouse("Control", "MButton") ;orbit

;;framer
  #HotIf            WinActive("ahk_exe framer.exe")
    WheelUp::       Send("^{WheelUp}") ;zoom in
    WheelDown::     Send("^{WheelDown}") ;zoom out
    F1::            tap("^k") ;quick actions

;;freecad
  #HotIf            WinActive("ahk_exe FreeCAD.exe")
    RButton::       mouse("MButton", "LButton") ;orbit

;;fusion 360
  #HotIf            WinActive("ahk_exe Fusion360.exe")
    F1::            Send("+1")

;;geomagic design
  #HotIf            WinActive("Geomagic Design X")
    MButton::       mouse("Control", "RButton") ;pan

;;godot
  #HotIf            WinActive("ahk_exe godot.exe")
    MButton::       mouse("Shift", "MButton") ;pan
    RButton::       mouse("MButton") ;orbit

;;hash animation master
  #HotIf            WinActive("ahk_exe Master_64.exe")
    RButton::       mouse("Shift", "MButton") ;orbit

;;harmony
  #HotIf            WinActive("ahk_exe HarmonyPremium.exe")
    MButton::       mouse("Space", "LButton") ;pan

;;houdini
  #HotIf            WinActive("ahk_group houdini")
                    and !GetKeyState("Space") and !GetKeyState("a")
                    loop Parse "houdini houdinifx houdinicore happrentice hindie", " " {
                      GroupAdd("houdini", "ahk_exe " A_LoopField ".exe")
                    }

    RButton::       mouse("Space", "LButton") or Send("{RButton up}") ;orbit
    ^w::            Send("!{F4}") ;close window
    #F1::           { ;open help in the browser
                      clip := ClipboardAll()
                      A_Clipboard := ""
                      tap("^l")
                      Sleep(200)
                      Send("^{Insert}")
                      Sleep(50)
                      if ClipWait(2) {
                        ; WinClose()
                        Run(A_Clipboard)
                      } else {
                        err("whoops...")
                      }
                      A_Clipboard := clip
                    }

;;inkscape
  #HotIf            WinActive("ahk_exe inkscape.exe")
    WheelUp::       Send("^{WheelUp}") ;zoom in
    WheelDown::     Send("^{WheelDown}") ;zoom out

;;irfanview
  #HotIf            WinActive("ahk_class IrfanView") and !isWinActive("modal")
    MButton::       mouse("RButton") or Send(wk("f")) ;pan/zoom
    /::             Send("^" wk("h")) ;zoom 100%

;;keyshot
  #HotIf            WinActive("ahk_exe keyshot.exe")
    RButton::       mouse("LButton") ;orbit

;;ldcad
  #HotIf            WinActive("ahk_exe LDCad64.exe")
    MButton::       mouse("Shift", "LButton") ;pan

;;lunacy
  #HotIf            WinActive("ahk_exe Lunacy.exe")
    ^vkC0::         ^0 ;ctrl-` - zoom 100%
    ; WheelUp::       ^WheelUp ;zoom in
    ; WheelDown::     ^WheelDown ;zoom out

    ; WheelUp::       { ;zoom in
    ;                   Send("{Control down}")
    ;                   Sleep(30)
    ;                   Send("{WheelUp}")
    ;                   Sleep(30)
    ;                   Send("{Control up}")
    ;                 }

    ; WheelDown::     { ;zoom out
    ;                   Send("{Control down}")
    ;                   Sleep(30)
    ;                   Send("{WheelDown}")
    ;                   Sleep(30)
    ;                   Send("{Control up}")
    ;                 }

    !^WheelUp::     Send("^]") ;bring forward
    !^WheelDown::   Send("^[") ;send backward
    +^WheelUp::     Send("^+]") ;bring to front
    +^WheelDown::   Send("^+[") ;send to back

;;meshlab
  #HotIf            WinActive("ahk_exe meshlab.exe")
    RButton::       mouse("Alt", "MButton") ;orbit
    WheelDown::     Send("{WheelUp}") ;zoom in
    WheelUp::       Send("{WheelDown}") ;zoom out

;;mischief
  #HotIf            WinActive("ahk_exe Mischief.exe") and !isWinActive("modal")
    F1::            tap("!hs{Enter}")
    MButton::       mouse("Space", "LButton") ;pan
    $^w::           Send("^w")

;;moi3d
  #HotIf            WinActive("ahk_exe MoI.exe")
    ; F1::            { ;pan
    ;                   Send("{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}")
    ;                 }

    ; F2::            { ;zoom
    ;                   Send("{Alt down}{RButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{RButton up}{Alt up}")
    ;                 }

    ; F3::            { ;orbit
    ;                   Send("{RButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{RButton up}")
    ;                 }

;;moho
  #HotIf            WinActive("ahk_exe moho.exe")
    MButton::       mouse("RButton") ;pan

;;nvil
  #HotIf            WinActive("ahk_exe NVil 1.0.exe")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit

;;paint.net
  #HotIf WinActive("ahk_exe paintdotnet.exe")
    WheelUp::       Send("^{WheelUp}") ;zoom in
    WheelDown::     Send("^{WheelDown}") ;zoom out
    ^WheelUp::      Send("{WheelUp}") ;scroll up
    ^WheelDown::    Send("{WheelDown}") ;scroll down

;;penpot desktop
  #HotIf            WinActive("ahk_exe Penpot Desktop.exe")
    !WheelUp::
    !WheelDown::
    WheelUp::
    WheelDown::     { ;swap zoom and scroll
                      sidebar := { left:350, right:300 }
                      splitHotkey(ThisHotkey, &key)
                      key := wk(key)
                      CoordMode("Mouse", "Window")
                      WinGetPos(, , &w, , "A")
                      MouseGetPos(&x, &y)
                      if (x < sidebar.left) or (x > w - sidebar.right) {
                        Send("{Blind}" key)
                      } else {
                        if GetKeyState("Alt") {
                          Send(key)
                        } else {
                          Send("{Control down}")
                          Sleep(0)
                          Send(key)
                          Sleep(0)
                          Send("{Control up}")
                        }
                      }
                    }

;;pixso
  #HotIf            WinActive("ahk_exe pixso.exe")
                    and isMouseOn("active app") and !isWinActive("modal")

    F1::            getTapTime()
    ~F1 up::        (getTapTime("up") < 250) and Send("^/")

    ^vkC0::         tap("^0") ;ctrl-` zoom to 100%

    !c::            tap("c") ;color tool
    !f::            tap("p") ;path tool
    !x::            tap("k") ;scale tool

;;plasticity
  #HotIf            (WinActive("ahk_exe plasticity.exe")
                      or WinActive("ahk_exe plasticity-beta.exe"))
                    and !isWinActive("modal")
    F1::            { ;go to nearest ortho
                      debug := false
                      x := 220
                      y := 65
                      WinGetClientPos(,, &w,, "A")
                      if debug {
                        MouseMove(w - x, y)
                      } else {
                        hwnd := WinGetID("A")
                        ControlClick(("x" w - x) (" y" y), hwnd)
                      }
                    }

    F2::            { ;export step
                      tap("^+e")
                      if WinWaitActive("ahk_class #32770",, 3) {
                        SendText("%temp%\1.stp`n")
                        if WinWaitActive("ahk_class #32770",, 1) {
                          Send("{Left}{Enter}")
                          hk("export step")
                        }
                      }
                    }

    F3::            { ;import step
                      tap("^+o")
                      if WinWaitActive("ahk_class #32770",, 3) {
                        SendText("%temp%\1.stp`n")
                        hk("import step")
                      }
                    }

    CapsLock & WheelUp::   Send("^z") ;undo
    CapsLock & WheelDown:: Send("!``") ;select adjacent

    ; F1::            { ;pan
    ;                   Send("{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}")
    ;                 }

    ; F2::            { ;zoom
    ;                   Send("{Shift down}{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}{Shift up}")
    ;                 }

    ; F3::            { ;orbit
    ;                   Send("{RButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{RButton up}")
    ;                 }

    ;hotstrings for rotation
    :*?:``1::180`n
    :*?:``2::90`n
    :*?:``3::45`n
    :*?:``4::30`n
    :*?:ё1::180`n
    :*?:ё2::90`n
    :*?:ё3::45`n
    :*?:ё4::30`n

;;rhino
  #HotIf            WinActive("ahk_exe Rhino.exe")
    F1::
    F2::
    F3::
    F4::
    F5::
    F6::
    F7::
    F8::
    F9::
    F10::
    F11::
    F12::           { ;multitaps
                      switch isTaps(, { silent: true }) {
                        case 1: ;short tap
                          Send("{" ThisHotkey "}")

                        case -1: ;long tap
                          Send("^{" ThisHotkey "}")

                        case 2: ;double tap
                          Send("^+{" ThisHotkey "}")

                        default:
                          Send("{LControl down}{LAlt down}"
                            . "{" ThisHotkey "}{LControl up}{LAlt up}")
                      }
                    }

    !q::            tap("{Blind}!l") ;tools
    !s::            (isTaps() = 1) ? tap("{Blind}!s") : tap("{Blind}!o") ;solid

    ; F1::            { ;pan
    ;                   Send("{MButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{MButton up}")
    ;                 }

    ; F2::            { ;zoom
    ;                   Send("{Alt down}{RButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{RButton up}{Alt up}")
    ;                 }

    ; F3::            { ;orbit
    ;                   Send("{RButton down}")
    ;                   KeyWait(ThisHotkey)
    ;                   Send("{RButton up}")
    ;                 }

                    /*
                      favorite commands:
                      '_Zoom s
                      '_Isolate
                      '_Unisolate
                      '_OneView _Enabled=Yes _Angle=44 _UpdateCPlane=Yes _ReturnCPlaneToTop=No
                          _ViewLabel=Yes _MaximizePerspective=Yes _EnterEnd
                      '_ToggleRightSidebar
                      '_PopupMenu
                      '_PopupPopular
                      '_-Export "%temp%\1.stp" _EnterEnd
                      '_-Import "%temp%\1.stp" _EnterEnd
                      '_SetDisplayMode "my view"
                    */

  #HotIf            WinActive("ahk_exe Rhino.exe")
                    and (WinActive("Find…")
                        or WinActive("Grasshopper Settings")
                        or WinActive("Control Knob Settings"))
    Escape::        WinClose("A")

  #HotIf            WinActive("Grasshopper ahk_exe Rhino.exe")
    MButton::       { ;pan
                      m := mouse("RButton")
                      Send("{Escape}")
                      if !m {
                        Send("{MButton}")
                      }
                    }

    ^WheelUp::      tap("^+f"), hk("Move Forwards")
    ^WheelDown::    tap("^+b"), hk("Move Backwards")
    +^WheelUp::     tap("^f"),  hk("Bring to Front")
    +^WheelDown::   tap("^b"),  hk("Put to Back")

  #HotIf            WinActive("MESH2SURFACE ahk_exe Rhino.exe")
    MButton::       mouse("Shift", "RButton") ;pan

  #HotIf            WinActive("Rhino Render ahk_exe Rhino.exe")
    F1::            { ;render preset
                      CoordMode("Mouse", "Window")
                      Click(50, 380)
                      Send("{Down 2}{Sleep 1000}{Enter}")
                      Click(150, 420)
                      Send(1.5)
                      Click(150, 450)
                      Send(1)
                      Sleep(1000)
                      Click(50, 65)
                      if WinWaitActive("ahk_class #32770", , 5) {
                        tap("^l")
                        Sleep(100)
                        Send("^a")
                        Sleep(100)
                        Send("{Text}" EnvGet("USERPROFILE") "\Downloads`n")
                        Sleep(50)
                        Send("!tp")
                        Sleep(50)
                        Send("!n1")
                      }
                    }

  #HotIf            WinActive("Sun Settings ahk_exe Rhino.exe")
    F1::            {
                      CoordMode("Mouse", "Window")
                      Click(40, 210)
                      if WinWaitActive("ahk_class #32770",, 2) {
                        sunScript := EnvGet("LocalAppData") "\Rhino\Scripts\rhino-sun.rsun`n"
                        tap("!n{Text}" sunScript)
                        if WinWaitActive("Sun Settings",, 2) {
                          Click(100, 445)
                        }
                      }
                    }

  #HotIf            WinActive("TRACE ahk_exe Rhino.exe")
    F1::            {
                      CoordMode("Mouse", "Window")
                      Click(110, 95)
                      Sleep(100)
                      tap("^a25")
                      Click(20, 45)
                      if WinWaitActive("ahk_class #32770",, 2) {
                        tap("1.png")
                      }
                    }

;;rive
  #HotIf            WinActive("ahk_exe Rive.exe")
    ; WheelUp::       Send("^{WheelUp}")   ;zoom in
    ; WheelDown::     Send("^{WheelDown}") ;zoom out
    ~MButton::      SetTimer((*) => Send("0{Enter}"), -100)

;;rocket3f
  #HotIf            WinActive("ahk_exe Rocket3F.exe")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit
    WheelUp::
    WheelDown::    { ;zoom
                      CoordMode("Pixel", "Screen")
                      if PixelGetColor(440, 20) = 0xF2F2F2 {
                        x := 455
                        if ThisHotkey = "WheelUp" {
                          y := 25
                        } else {
                          y := A_ScreenHeight - 5
                        }
                        ControlClick(("x" x) (" y" y), "A", , "Left", 10)
                      } else {
                        Send("{" ThisHotkey "}")
                      }
                    }

;;sculptris
  #HotIf            WinActive("ahk_exe Sculptris.exe")
    MButton::       mouse("Alt", "LButton") ;pan

;;shapr3d
  #HotIf            WinActive("Shapr3D ahk_exe ApplicationFrameHost.exe")
    ; MButton::       mouse("RButton") ;pan
    ; RButton::       mouse("Shift", "RButton") ;orbit

;;silo
  #HotIf            WinActive("ahk_exe Silo.exe")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit

;;sketchup
  #HotIf            (WinActive("ahk_exe SketchUp.exe")
                      or WinActive("ahk_exe SketchUp 2020.exe"))
                    and !isWinActive("modal")
    MButton::       mouse("Shift", "MButton") ;pan
    RButton::       mouse("Alt", "MButton") ;orbit
    F1::            { ;change scene, *longtap: scene delay 0
                      if isTaps() = -1 {
                        tap("!w{m 2}{Enter}")
                        win := "Model Info ahk_class #32770 ahk_exe SketchUp.exe"
                        if WinWaitActive(win, , 2) {
                          Send("{Tab}^{Home}{Tab}!e{Tab}0{Enter}")
                        }
                      } else {
                        Send("{PgUp}{PgDn}")
                      }
                    }

;;spaceclaim
  #HotIf            WinActive("ahk_exe SpaceClaim.exe") and !isWinActive("modal")
    ^+z::           Send("^y") ;redo
    $^y::           { ;toggle outline/preview
                      if toggle("scPreview") {
                        Send("!" wk("y"))
                        hk("Outline")
                      } else {
                        Send("!+" wk("y"))
                        hk("Preview")
                      }
                    }

    ^Space::        { ;toggle perspective/orthographic
                      if toggle("scPerspective") {
                        Send("!" wk("p"))
                        hk("Perspective")
                      } else {
                        Send("!" wk("o"))
                        hk("Orthographic")
                      }
                    }

    F2::            { ;export step
                      if isTaps() = -1 {
                        passTap()
                      } else {
                        tap("^+s")
                        if WinWaitActive("ahk_class #32770",, 5) {
                          Send("{Tab}" wk("s"))
                          Sleep(1000)
                          Send(wk("s"))
                          Sleep(1000)
                          Send(wk("s"))
                          Sleep(2000)
                          Send("+{Tab}")
                          SendText("%temp%\1.stp`n")
                          if WinWaitActive("ahk_class #32770",, 5) {
                            Send("{Enter}")
                            hk("export step")
                          }
                        }
                      }
                    }

    F3::            { ;import step
                      if isTaps() = -1 {
                        passTap()
                      } else {
                        tap("^o")
                        if WinWaitActive("ahk_class #32770", , 5) {
                          SendText("%temp%\1.stp`n")
                          hk("Import step")
                        }
                      }
                    }

    ; F1::            { ;go to nearest ortho
    ;                   Send("!" wk("o"))
    ;                   WinGetClientPos(,, &w, &h, "A")
    ;                   ControlClick(("x" w - 230) (" y100"), WinGetID("A"))
    ;                   hh (ThisHotkey, "go to nearest ortho")
    ;                 }

    ; <!F1::          { ;export 3dm
    ;                   Send("^+s")
    ;                   if WinWaitActive("ahk_class #32770", , 2) {
    ;                     tap("!n{Sleep 50}" A_Desktop "\curves")
    ;                     Sleep(50)
    ;                     tap("!t{r 1}")
    ;                     Sleep(100)
    ;                     Send("{Enter}")
    ;                   }
    ;                 }

    ; ^F1::           { ;export dxf
    ;                   Send("^+s")
    ;                   if WinWaitActive("ahk_class #32770", , 2) {
    ;                     tap("!n")
    ;                     Sleep(50)
    ;                     tap(A_Desktop "\curves")
    ;                     Sleep(50)
    ;                     tap("!t{a 6}")
    ;                     Sleep(100)
    ;                     Send("{Enter}")
    ;                   }
    ;                 }

    <!x::           (isTaps() = -1) ? Send("^+h") : Send("!h") ;isolate, *longtap: unisolate

  #HotIf            WinActive("ahk_exe SpaceClaimViewer.exe")
    Escape::        WinClose("A")

;;spine
  #HotIf            WinActive("ahk_exe Spine.exe")
    MButton::       mouse("RButton") ;pan
    RButton::       mouse("MButton")

;;spline
  #HotIf            WinActive("ahk_exe Spline.exe")
                    or WinActive("· Spline — Mozilla Firefox ahk_exe firefox.exe")
    MButton::       mouse("Space", "LButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit
    WheelUp::       Send("^{WheelUp}") ;zoom in
    WheelDown::     Send("^{WheelDown}") ;zoom out

;;stdu
  #HotIf            WinActive("ahk_exe STDUViewerApp.exe")
    F1::            { ;invert colors, *longtap: view settings
                      t := isTaps(, { silent: true })
                      tap("!vs")
                      if (t != -1) and WinWaitActive("View setting", , 1) {
                        ControlSetText("-20", "Edit2")
                        ControlSetChecked(-1, "Button1")
                        ControlSend("{Enter}", "Button3")
                      }
                    }

  #HotIf            WinActive("Manage Sessions ahk_exe STDUViewerApp.exe")
    Escape::        WinClose()

;;substance modeler
  #HotIf            WinActive("ahk_exe Adobe Substance 3D Modeler.exe")
                    and !isWinActive("modal")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit

;;substance painter
  #HotIf            WinActive("Substance Painter")
    MButton::       mouse("Alt", "MButton") ;pan
    RButton::       mouse("Alt", "LButton") ;orbit

;;xnview
  #HotIf            WinActive("ahk_exe xnview.exe")
    .::
    ?::              tap("!vr") ;real size zoom
    \::              tap("!va{Up}{Enter}") ;fit window to image
    >^.::            tap("!to") ;prefs

;;vexy lines
  #HotIf            WinActive("ahk_exe vexy lines.exe")
    MButton::       mouse("Space", "LButton") ;pan
    WheelUp::       Send("!{WheelUp}") ;zoom in
    WheelDown::     Send("!{WheelDown}") ;zoom out
    !WheelUp::      Send("{WheelUp}")
    !WheelDown::    Send("{WheelDown}")

;;wings 3d
  #HotIf            WinActive("Wings3D")
    MButton::       mouse("Shift", "MButton") ;pan
    RButton::       mouse("MButton") ;orbit

; ;;zbrush
;   #HotIf            WinActive("ahk_exe zbrush.exe")
;     ~MButton::      { ;pan
;                       Send("{Alt down}{RButton down}")
;                       KeyWait("MButton")
;                       Send("{RButton up}")
;                       Sleep(100)
;                       Send("{Alt up}")
;                     }