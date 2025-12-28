;Copyright (c) 2018-2025 Oleg Kransov @krasnovpro

/* Taptapkey is a set of hotkeys, widgets,
   and menus that streamline everyday tasks
   for designers and other Windows users. */

#Requires AutoHotkey v2.1-a
#SingleInstance Ignore

A_IconTip := "Taptapkey`nv1.7.17"
A_MaxHotkeysPerInterval := 333
A_MenuMaskKey := "vkE8"

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

hint(A_IconTip " loaded")
