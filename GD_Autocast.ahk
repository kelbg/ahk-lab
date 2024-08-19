; Autocasts spells on Grim Dawn
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#Warn
#SingleInstance, Force
#InstallKeybdHook
; #MaxThreadsPerHotkey, 5

; ===============================================
; Initialization
; ===============================================
; Adds menu item on top of the default ones
Menu, Tray, NoStandard
Menu, Tray, Add, % "Active", ToggleActive
Menu, Tray, Add, ; Separator
Menu, Tray, Standard
SetWorkingDir, % A_ScriptDir
SendMode Input

spellHotkey := 7
interval := 16 * 1000 ; In milliseconds
gameWindow := "ahk_class Grim Dawn"
pauseOnWindowInactive := false
resumeOnWindowInactive := false
isActive := false

SetTrayMenuActive(false)

SetTimer, DetectWindowState, -1
; ===============================================

Autocast:
    if WinActive(gameWindow)
        Send, % spellHotkey
return

DetectWindowState:
	; a key event before any hotkeys start working
	WinWaitActive, % gameWindow
	Send, {Pause} ; Pause/Break Key - Not used in game

	if (resumeOnWindowInactive)
		SetActive(true)
    
	WinWaitNotActive, % gameWindow

	if (pauseOnWindowInactive)
		SetActive(false)
    
    Gosub, DetectWindowState
return

ToggleActive:
    isActive ? SetActive(false) : SetActive(true)
return

; Fake pause
SetActive(value)
{
    global
    if (isActive == value)
        return
    
    if (value)
    {
        SetTimer, Autocast, % interval
        SetTrayMenuActive(true)
    }
    else
    {
        SetTimer, Autocast, Off
        SetTrayMenuActive(false)
    }
    
    ToggleActiveBeep()
    isActive := value
}

SetTrayMenuActive(state)
{
    global
    if (state)
    {
        Menu, Tray, Icon, % "res/gd.png"
        Menu, Tray, Check, % "Active"
    }
    else
    {
        Menu, Tray, Icon, % "res/gd_pause.png"
        Menu, Tray, Uncheck, % "Active"
    }

    Menu, Tray, Tip, % Format("Grim Dawn Autocast (Key: {1} - {2})"
                        , spellHotkey, state ? "ACTIVE" : "INACTIVE")
}

ToggleActiveBeep()
{
    global
    freq := 400, duration := 200
	
	if (isActive)
	{
        SoundBeep, freq, duration / 2
        SoundBeep, freq, duration / 2	
	}
    else
		SoundBeep, freq, duration
}

~Tab::
    if % WinActive(gameWindow)
		SetTimer, ToggleActive, -1

return
