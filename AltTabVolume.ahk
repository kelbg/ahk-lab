; Changes the volume of an app when tabbing in/out of it
; Configurable settings are defined in res/AltTabVolume.ini

; |Directives|==============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; |Auto-execute|============================================
Initialize()

loop
{
    SetVolumeOnFocusChange()
}

; |Functions|===============================================
Initialize()
{
    global
    ConfigFile := "res/AltTabVolume.ini"
    AppWindow := "ahk_exe" . IniRead(ConfigFile, "Settings", "Executable")
    InAppVolume := IniRead(ConfigFile, "Settings", "InAppVolume")
    KeyDelay := IniRead(ConfigFile, "Settings", "KeyDelay")
    PersistentVolume := IniReadBool(ConfigFile, "Settings", "PersistentVolume")
    PreviousVolume := 0

    UpdatePreviousVolume()
}

UpdatePreviousVolume()
{
    global PreviousVolume := Round(SoundGetVolume())
}

SetVolumeOnFocusChange()
{
    WinWaitActive(AppWindow)
    UpdatePreviousVolume()
    SetSystemVolume(InAppVolume)

    WinWaitNotActive(AppWindow)
    ; Waits for Alt to be released when alt tabbing so that further
    ; key presses don't interrupt the alt tab process
    KeyWait("Alt", "L")
    ; Did not tab out of the window	
    if (WinActive(AppWindow))
        return

    SaveCurrentInAppVolume()
    SetSystemVolume(PreviousVolume)
}

SetSystemVolume(targetVolume)
{

    while (Round(SoundGetVolume()) > targetVolume)
    {
        Send("{Volume_Down}")
        Sleep(KeyDelay)
    }

    while (Round(SoundGetVolume()) < targetVolume)
    {
        Send("{Volume_Up}")
        Sleep(KeyDelay)
    }
}

SaveCurrentInAppVolume()
{
    if (!PersistentVolume)
        return

    currentVolume := Round(SoundGetVolume())
    IniWrite(currentVolume, ConfigFile, "Settings", "InAppVolume")
    global InAppVolume := currentVolume
}

IniReadBool(iniFile, section, key)
{
    value := IniRead(iniFile, section, key)

    ; The value may not be a number
    try return value >= 1

    return StrLower(value) == "true"
}
