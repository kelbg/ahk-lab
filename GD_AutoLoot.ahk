; Enables auto looting of items in Grim Dawn
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, % "res/gd.png",, 1
Menu, Tray, Tip, % "Grim Dawn Autoloot Hotkey"
SendMode Input

InGamePickupLootKey := "F"
InGameMoveKey := "A"
gameWindow := "ahk_class Grim Dawn"

SetTimer, SuspendWhenNotInGame, -1

^+T::
	KeyWait, Shift

	Loop, 100
	{
		Input, keyPressed, L1 V T0.05, {LControl}{LAlt}{LShift}{LWin}{Esc}
		if (ErrorLevel != "Timeout")
			Break

		Send, {%InGameMoveKey% down}
		Sleep, 1
		Send, {%InGameMoveKey% up}
		Send, % InGamePickupLootKey
	}

Return

SuspendWhenNotInGame:
	Loop
	{
		WinWaitActive, % gameWindow
		Suspend, Off
		WinWaitNotActive, % gameWindow
		Suspend, On
	}
Return
