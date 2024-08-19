; Repeats a hotkey with a specified delay when a certain window is active
; Often used to autocast spells in games
; ⚠️ Old version of SimpleSpellAutocast.ahk. Requires AHK v1.1

; ================================ Directives =================================
#NoEnv
#Persistent
#SingleInstance, Force
; =============================================================================
; 
; ================================= Globals ===================================
profile := "res\SimpleSpellAutocast.ini"
beepFreq := 400
beepDuration := 200
currentGame := ""
timers := {}
isActive := false
manualOverride := false
startTime := A_TickCount ; Debugging
; =============================================================================
; 
; ============================== Initialization ===============================
SendMode Input
SetWorkingDir %A_ScriptDir%
LoadSettings()
DetectActiveGame()
; =============================================================================
; 
Toggle:
    if (!WinActive("ahk_exe " . currentGame))
        return

    SetActive(!isActive)
    manualOverride := !manualOverride
return

LoadSettings()
{
    global
    IniRead, recastDelay, % profile, % "Settings", % "RecastDelay"
    IniRead, reenableOnTabIn, % profile, % "Settings", % "ReenableOnTabIn"

    IniRead, ToggleHotkey, % profile, % "Settings", % "ToggleHotkey"
    Hotkey, % ToggleHotkey, Toggle, Off
}

DetectActiveGame()
{
    global currentGame, profile

    IniRead, games, % profile
    Loop, Parse, games, `n
    {
        if (!WinExist("ahk_exe " . A_LoopField))
            Continue

        currentGame := A_LoopField
        SetActive(true)
        MonitorGameWindowState()
        Break
    }
}

MonitorGameWindowState()
{
    global
    Loop
    {
        if (reenableOnTabIn && !manualOverride)
        {
            WinWaitActive, % "ahk_exe " . currentGame
            SetActive(true)
        }

        WinWaitNotActive, % "ahk_exe " . currentGame
        SetActive(false)
    }
}

SetupHotkeys()
{
    global profile, currentGame

    IniRead, keys, % profile, % currentGame
    Loop, Parse, keys, `n
    {
        kvp := StrSplit(A_LoopField, "=")
        key := kvp[1]
        duration := kvp[2]

        NewHotkeyTimer(key, duration)
    }
}

NewHotkeyTimer(key, duration)
{
    global
    newTimer := Func("Recast").Bind(key)
    SetTimer, % newTimer, % (duration * 1000) + recastDelay
    timers[key] := newTimer
}

Recast(key)
{
    global
    ToolTip, % "Fake sending " . key . " - Time: " . Round((A_TickCount - startTime) / 1000, 1) . "s"
}

SetActive(value)
{
    global

    if (value == isActive)
        return

    if (!value)
    {
        StopTimers()
        SoundBeep, beepFreq, beepDuration / 2
        SoundBeep, beepFreq, beepDuration / 2
        isActive := false
        UpdateTrayIcon()
        return
    }

    SetupHotkeys()
    SoundBeep, beepFreq, beepDuration
    isActive := true
    UpdateTrayIcon()
}

UpdateTrayIcon()
{
    global currentGame, isActive
    txt := ""
    icon := ""

    if (isActive)
    {
        txt := Format("Game: {} Enabled", currentGame)
        icon := 1
    }
    else
    {
        txt := Format("Game: {} Disabled", currentGame)
        icon := 4
    }

    Menu, Tray, Tip, % txt
    Menu, Tray, Icon, % A_AhkPath, % icon
}

StopTimers()
{
    global timers
    for key, timer in timers
        SetTimer, % timer, Off

    timers = {}
}
