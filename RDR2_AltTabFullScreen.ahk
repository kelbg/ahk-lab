; Switches RDR2 to fullscreen when the game window gains focus
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, force
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu, Tray, Tip, % "RDR2 Alt Tab Fullscreen Fix"
Menu, Tray, Icon, % "res\rdr2_alt_tab.png"

gameWindow := "ahk_exe RDR2.exe"

FullscreenWhenWinActive:
    ; Switches to fullscreen when the game window gains focus
    WinWaitActive, % gameWindow
    Send !{Enter}
    Sleep, 3000 ; Small delay while the game switches to fullscreen

    ; Runs the subroutine again when the user tabs out of the game
    WinWaitNotActive, % gameWindow
    Gosub, FullscreenWhenWinActive
return
