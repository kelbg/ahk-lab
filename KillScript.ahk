; =========================================================
; Pass a script name as a parameter to kill it.
; Usage: Autohotkey.exe <PathToThisScript> <TargetScript>
; =========================================================
#SingleInstance
#NoTrayIcon

DetectHiddenWindows, On
SetTitleMatchMode, 2
WinClose %1% ahk_class AutoHotkey
