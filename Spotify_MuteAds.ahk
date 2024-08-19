; Mutes Spotify when it detects an ad playing.
; ⚠️ Requires AHK v1.1, nircmd

#NoEnv
#Persistent
#SingleInstance, Force

SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, RegEx
global tryToSkip := true

; Wait until Spotify is up and running
If not (WinExist("ahk_exe Spotify.exe"))
{
	Menu, Tray, Tip, % "Waiting for Spotify to start"
	WinWait, ahk_exe Spotify.exe
	Sleep, 3000
}

UpdateTray(0)

SetTimer, ReloadWhenSpotifyIsClosed, 5000

Loop
{
	WinWait, i)^Spotify$|^Advertisement$ ahk_exe Spotify.exe

	Run, nircmd muteappvolume Spotify.exe 1, , Hide
	UpdateTray(1)

	If (tryToSkip) 
		SetTimer, TrySkipAd, 2000

	WinWait, - ahk_exe Spotify.exe

	If (tryToSkip) 
		SetTimer, TrySkipAd, Off
	
	Run, nircmd muteappvolume Spotify.exe 0, , Hide
	UpdateTray(0)
}

TrySkipAd:
	Send, {Media_Next}
Return

UpdateTray(state)
{
	If (state == 0)
	{
		msg := "Waiting for an ad"
		trayIcon := "res/Spotify_MuteAds_wait.png"
	}
	Else If (state == 1)
	{
		msg := "An ad is currently playing"
		trayIcon := "res/Spotify_MuteAds_ad.png"
	}

	Menu, Tray, Tip, % msg
	Menu, Tray, Icon, % trayIcon
}

ReloadWhenSpotifyIsClosed:
	If not (WinExist("ahk_exe Spotify.exe"))
		Reload
Return
