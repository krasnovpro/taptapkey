;Copyright (c) 2018-2026 Oleg Kransov @krasnovpro

/* Taptapkey is a set of hotkeys, widgets,
   and menus that streamline everyday tasks
   for designers and other Windows users. */

#Requires AutoHotkey v2.1-a
#SingleInstance Ignore

FileEncoding("UTF-8")
InstallKeybdHook(true)
InstallMouseHook(true)
Persistent(true)
SetCapsLockState("AlwaysOff")
SetDefaultMouseSpeed(0)
SetMouseDelay(-1)
SetWinDelay(-1)

setTrayMenu()

#Include <ComVar>
#Include <Promise>
#Include <WebView2>
#Include <YAML>
#Include <UIA>
#Include <Enumerable>
#Include <TaptapkeyFuncs>
#Include settings.ahk

A_IconTip := "Taptapkey " (ttk.ver := "v1.7.19")
A_MaxHotkeysPerInterval := 333
A_MenuMaskKey := "vkE8"

hint(A_IconTip " loaded")
checkForTaptapkeyUpdate()
