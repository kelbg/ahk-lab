; Repeats a hotkey with a specified delay when a certain window is active
; Often used to autocast spells in games

; #region |Directives|===================================================================
#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon
; #endregion

; #region |Auto-execute|=================================================================
Profile := "res\SimpleSpellAutocast.ini"	; Path to the config file
BeepFrequency := 400						; Frequency of the beep when toggling on/off
BeepDuration := 200							; Duration of each beep
IsActive := false							; Whether the script is active or not
ManualOverride := false 					; If toggled off, will stay off
Game := ""									; Game exe
GameList := []								; List of game exes
RecastDelay := 0							; Delay before each hotkey activation
ReenableOnTabIn := false					; Reenable when the game window is in focus
Timers := []								; Stores all hotkey timers

Initialize()
; #endregion

; #region |Functions|====================================================================
Initialize()
{
	global Game := GetActiveGame()
	global GameList:= GetGameList()
	SetTitleMatchMode("RegEx")
	LoadSettings()
	MonitorGameWindowState()
}

LoadSettings()
{
	global RecastDelay, ReenableOnTabIn
	RecastDelay := IniRead(Profile, "Settings", "RecastDelay")
	ReenableOnTabIn := IniRead(Profile, "Settings", "ReenableOnTabIn")
	Hotkey(IniRead(Profile, "Settings", "GlobalToggle"), GlobalToggle)
}

GlobalToggle(globalHotkey)
{
	global IsActive, Game, ManualOverride
	Game := GetActiveGame()
	ManualOverride := !ManualOverride

	if (IsActive) 
	{
		ToggleOFF()
		return
	}

	if (Game == "" || !WinActive("ahk_exe " . Game))
		return

	ToggleON()
}

MonitorGameWindowState()
{
	global GameList, ReenableOnTabIn, IsActive

	Loop
	{
		currentWindow := ""
		if (ReenableOnTabIn && !ManualOverride)
		{
			regex := "i)ahk_exe " . StrReplace(GameList, "`n", "|")
			WinWaitActive("ahk_exe " . regex)
			currentWindow := WinGetProcessName()
			if (!IsActive)
				ToggleON()
		}

		WinWaitNotActive("ahk_exe " . currentWindow)
		if (IsActive)
			ToggleOFF()
	}
}

; Returns the first game exe in the ini that is running
GetActiveGame()
{
	loop parse GetGameList(), "`n"
	{
		if WinActive("ahk_exe " . A_LoopField)
			return A_LoopField
	}
}

GetGameList()
{
	list := IniRead(Profile)
	; Remove first line (settings)
	list := Substr(list, InStr(list, "`n") + 1)
	return list
}

ToggleOFF()
{
	; Two beeps when turned OFF
	StopAllTimers()
	SoundBeep(BeepFrequency, BeepDuration / 2)
	SoundBeep(BeepFrequency, BeepDuration / 2)
	global IsActive := false
}

ToggleON()
{
	Global Game := GetActiveGame()
	if (Game == "")
	{
		MsgBox("⚠️ No active game found.`n`n Make sure you have a game running " 
			   "and that it has an autocast hotkey assigned (check INI file).")
		return
	}

	; One beep when turned ON
	SetupHotkeys(Game)
	SoundBeep(BeepFrequency, BeepDuration)
	global IsActive := true
}

NewHotkeyTimer(key, duration)
{
	global Timers
	newHotkeyTimer := {}
	newHotkeyTimer.func := Recast.Bind(key)
	newHotkeyTimer.duration := duration
	SetTimer(newHotkeyTimer.func, (duration * 1000) + RecastDelay)
	Timers.Push(newHotkeyTimer)
}

Recast(key)
{
	Send("{" key "}")
}

SetupHotkeys(game)
{
	global Profile
	spells := IniRead(Profile, game)
	loop parse spells, "`n"
	{
		kvp := StrSplit(A_LoopField, "=")
		key := kvp[1]
		duration := kvp[2]
		NewHotkeyTimer(key, duration)
	}
}

StopAllTimers()
{
	global Timers
	while Timers.Length > 0
		SetTimer(Timers.Pop().func, 0)
}
; #endregion
