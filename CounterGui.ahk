; Displays a counter and a timer that resets whenever the counter changes
; Saves settings in res/CounterGui.ini
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force

; Adds menu item on top of the default ones
Menu, Tray, NoStandard
Menu, Tray, Add, % "Reset counter", ResetCounter
Menu, Tray, Add, % "Reset timer", ResetReminderTimer
Menu, Tray, Add, % "Hide window", HideWindow
Menu, Tray, Add, ; Separator
Menu, Tray, Standard

SendMode Input
SetWorkingDir %A_ScriptDir%

global winTitle := "CounterGui" 
global iniPath := % "res\" . winTitle . ".ini"
global counter := 0
global timerStart := A_TickCount
global timeLeft := 0
global timeLeftFormatted := "00:00"
transparency := 128
textColor := "EF271B"
reminderTimer := 15 * 1000 * 60
blinkPeriod := 600

GetLastCount()

Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Font, s14
Gui, Add, Button, gModCounter w20 h20 ym y15, 🔽
Gui, Font, s24 c%textColor%, Arial
Gui, Add, Text, vCounterText w33 ym center, % counter
Gui, Font, s9 cefefef
Gui, Add, Text, vReminderText y+0, % timeLeftFormatted
Gui, Font, s14
Gui, Add, Button, gModCounter w20 h20 ym y15, 🔼
Gui, Color, 111111
Gui, Show, % GetWindowPos() NoActivate, % winTitle

WinSet, Transparent, % transparency, % winTitle
WinSet, TransColor, 111111 %transparency%, % winTitle

; From https://autohotkey.com/board/topic/148363-how-my-gui-can-be-dragged-without-titlebar/
OnMessage(0x201, "WM_LBUTTONDOWN")

SetTimer, Reminder, % reminderTimer
SetTimer, UpdateReminder, 1000

Gosub, UpdateReminder
Return

ModCounter()
{
	Switch A_GuiControl
	{
		Case "🔽":
			counter--
		Case "🔼":
			counter++
	}

	GuiControl, , CounterText, % counter
	SaveLastCount()
	ResetReminderTimer()
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
	Gui, +LastFound
	Checkhwnd := WinExist()
	if hwnd = %Checkhwnd%
	{
		PostMessage, 0xA1, 2

		KeyWait, LButton
		SaveWindowPos()
	}
}

GetLastCount()
{
	If (FileExist(iniPath))
	{
		IniRead, counter, % iniPath, counter, lastCount
	}
}

SaveLastCount()
{
	IniWrite, % counter, % iniPath, counter, lastCount
}

ResetCounter()
{
	counter = 0
	GuiControl, , CounterText, % counter
	SaveLastCount()
	ResetReminderTimer()
}

GetWindowPos()
{
	If (FileExist(iniPath))
	{
		IniRead, winX, % iniPath, position, x
		IniRead, winY, % iniPath, position, y
		Return % "X" . winX . " Y" . winY
	} 
	Else
	{
		Return center
	}
}

SaveWindowPos()
{
	WinGetPos, winX, winY, , , % winTitle
	IniWrite, % winX, % iniPath, position, x
	IniWrite, % winY, % iniPath, position, y
}

ResetReminderTimer()
{
	SetTimer, TimerBlink, Off
	SetTimer, Reminder, On
	timerStart := A_TickCount
}

HideWindow()
{
	If (WinExist(winTitle))
		Gui, Hide
	Else
		Gui, Show

	Menu, Tray, ToggleCheck, % "Hide window"
}

Reminder:
	SetTimer, TimerBlink, % blinkPeriod * 2
	SetTimer, Reminder, Off
Return

TimerBlink:
		GuiControl, Hide, CounterText
		Sleep, % blinkPeriod
		GuiControl, Show, CounterText
Return

UpdateReminder:
	timeLeft := % -(A_TickCount - reminderTimer - timerStart) / 1000
	timeLeftFormatted := Format("{:02}:{:02} ", Max(Floor(timeLeft / 60), 0), Max(Mod(Floor(timeLeft), 60), 0))
	GuiControl, , ReminderText, % timeLeftFormatted
	
	msg := "Count: " . counter . "`n" . "Reminder: " . timeLeftFormatted
	Menu, Tray, Tip, % msg
Return
