; Toggles the MTGA Helper overlay
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, % "res/MTGA_alt_tab.png"
Menu, Tray, Tip, % "MTGA Helper Overlay Toggle"

Loop
{
	WinWaitActive, ahk_exe MTGA.exe
	KeyWait, Alt, L

	Process, Exist, MTGAHelper.Tracker.WPF.exe
	If (ErrorLevel == 0)
	{
		MsgBox, "Warning: MTGA Helper is not running."
		Pause
		Continue
	}

	SetTrackerWindow("show")

	WinWaitNotActive, ahk_exe MTGA.exe
	KeyWait, Alt, L

	If (WinActive("ahk_exe MTGAHelper.Tracker.WPF.exe"))
		Continue

	SetTrackerWindow("hide")
}

SetTrackerWindow(cmd)
{
	Run, nircmd win %cmd% title "MTGAHelper"
}