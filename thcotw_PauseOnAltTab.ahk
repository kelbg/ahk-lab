; Pauses the game on Alt+Tab
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%

gameName := "theHunter: Call of the Wild"
gameProcess := "theHunterCotW_F.exe"
gameWindow := "ahk_exe " . gameProcess
WinGet, scriptWindow

Menu, Tray, NoStandard
Menu, Tray, Add, % "Resume game", ResumeGame
Menu, Tray, Add, % "Pause game", SuspendGame
Menu, Tray, Default, % "Resume game"
Menu, Tray, Add
Menu, Tray, Standard

; Creates a taskbar button to resume the game
Gui, +LastFound
Gui, Show, NoActivate, % "Resume Game - " . gameName

ResumeGameOnWindowActivation:
	WinWaitActive, % scriptWindow
	; Prevents infinite window activation loop
	WinMinimize, % scriptWindow

	ResumeGame()
	Gosub, ResumeGameOnWindowActivation
Return

~!Tab::
	If (!WinActive(gameWindow))
		Return

	KeyWait, Alt

	SuspendGame()
Return

SuspendGame()
{
	global
	Menu, Tray, Icon, % A_AhkPath, 4, 1
	Menu, Tray, Tip, % "Game paused - double click to resume"

	Run, % "nircmd suspendprocess " . gameProcess, , Hide
}

ResumeGame()
{
	global
	Menu, Tray, Icon, % A_AhkPath, 1, 1
	Menu, Tray, Tip, % "Game is running"

	Run, % "nircmd resumeprocess " . gameProcess, , Hide
	Sleep, 300
	WinActivate, % gameWindow
}
