;adobe indesign functions

;;INIT
  id                := { app: Map(), pid: 0 }

  id.confPath       := dirName(A_LineFile)
  id.scriptsPath    := id.confPath "\scripts"
  id.dict           := { comreg: YAML.parse(FileRead(
                      id.confPath "\dicts\comreg.yaml"
                    ), 0) }

  SetTimer(idInit, 1000) ;indesign instances prefs watcher

;;FUNCTIONS

idInit() {
  if !WinActive("ahk_exe InDesign.exe")
  or WinExist("ahk_class com.adobe.AdobeSplashKit.GraphicWindowClass") {
    return
  }

  try {
    id.pid := WinGetPID("A")
  } catch {
    return
  } else {
    if id.app.Has(id.pid) {
      return
    }
  }

  id.app[id.pid] := { active: false }

  ;forget the prefs of closed instances of indesign
  pids := pidList("ahk_exe InDesign.exe")
  id.app.keys().map(k => (pids.includes(k) or id.app.delete(k)))

  info("Reading ID Prefs...")
  p := {
    active: true,
    ver:    "",
    comVer: "",
    progID: "",
  }

  exePath := ProcessGetPath(id.pid)
  p.ver := FileGetVersion(exePath)

  ;checking com reg
  p.comVer := verClosest(id.dict.comreg.keys(), p.ver)
  if p.comVer {
    comRegValid := false

    key := id.dict.comreg[p.comVer]
    p.progID := key["progid"]
    clsid := getClsIdFromProgId(p.progID)
    if clsid = "{" key["clsid"] "}" {
      regPath := RegRead("HKCR\CLSID\{" key["clsid"] "}\LocalServer32",, false)
      if regPath and InStr(regPath, exePath) {
        comRegValid := true
      }
    }

    if !comRegValid {
      msg := "
      (LTrim Join`s
        Can't find COM keys for the active Indesign instance in the registry.
        These are necessary for launching the Indesign scripts.
        To fix it please grant access in the next pop-up system window.
      )"

      if MsgBox(msg, "Attention", "OKCancel Iconi Owner" WinGetID("A")) = "OK" {
        if runAhkFileAsAdmin(
          id.confPath "\idComReg.ahk",
          true, "InDesign Application", exePath,
          key["progid"], key["clsid"], key["typelib"]
        ) {
          return err(
            "Can't write COM keys into registry`nTaptapkey is disabled"
          )
        }
      } else {
        return err("Taptapkey has been disabled by the user")
      }
    }
  } else {
    return err(
      "Can't find current ID ver (" p.ver ") in the 'comreg.yaml'`n"
      . "Taptapkey is disabled"
    )
  }

  id.app[id.pid] := p
  info("Reading ID Prefs.`nDone")
}

idMode(title := "") {
  if !IsSpace(title) {
    title .= " "
  }
  return WinActive(title "ahk_exe InDesign.exe")
     and isMouseOn("active app")
     and !isWinActive("modal")
     and !isMouseOn("screen's top edge")
}

idPasteApng() {
  if saveClipPngAlpha() {
    psRunScript("file > place temp clip")
    return "Paste transparent image"
  } else {
    err("Can't find transparent image in the clipboard")
  }
}

idRunMenu(args*) => idRunScript("menu",, args*)

idRunScript(script, waitReturn := false, arguments*) {
  scriptPath := StrReplace(script, " > ", "\")

  if !(FileExist(fileName := id.scriptsPath "\" scriptPath ".js")
    or FileExist(fileName .= "x")
    or FileExist(fileName := scriptPath)
  ) {
    err("Can't find script file:`n" script)

  } else {
    hk(A_ThisFunc "`n" script)
    progID := id.app[id.pid].progID
    return runAhkFile(
      id.confPath "\idRunScript.ahk", waitReturn,
      progID, fileName, arguments*
    )
  }
}