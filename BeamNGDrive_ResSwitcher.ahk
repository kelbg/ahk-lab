; Switches BeamNG.Drive's resolution when the game window gains focus
; Configurable settings are defined in res/BNGDrive_ResSwitcher.ini
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, % "res/bngdrive_res_switcher.png",, 1
Menu, Tray, Tip, % "BeamNG.Drive Resolution Switcher"

settings := "res/BNGDrive_ResSwitcher.ini"
gameWindow := "ahk_exe BeamNG.drive.x64.exe"

IniRead, NativeResWidth, % settings, NativeResolution, Width
IniRead, NativeResHeight, % settings, NativeResolution, Height
IniRead, TargetResWidth, % settings, TargetResolution, Width
IniRead, TargetResHeight, % settings, TargetResolution, Height

SetTimer, ChangeResOnFocus, -1

ChangeResOnFocus:
	WinWaitActive, % gameWindow
	SetDisplayResolution(TargetResWidth, TargetResHeight)
	Sleep, 3000
	WinWaitNotActive, % gameWindow
	SetDisplayResolution(NativeResWidth, NativeResHeight)

	Gosub, ChangeResOnFocus
return

SetDisplayResolution(width, height)
{
	Run, nircmd setdisplay %width% %height% 32,, hide ; 32-bit color mode
}
