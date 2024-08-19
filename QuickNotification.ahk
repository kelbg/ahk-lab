; Displays a notification in the system tray

; #region |Directives|======================================
#Requires AutoHotkey v2.0
#SingleInstance Force
; #endregion

; #region |Auto-execute|====================================
SetWorkingDir A_ScriptDir
default_duration := 5 * 1000

if (A_Args.Length < 1)
{
	MsgBox("Usage: QuickNotification.exe <message>")
	ExitApp()
}

ShowNotification(A_Args[1], 
				 A_Args.Length >= 2 ? A_Args[2] : "", 
				 A_Args.Length >= 3 ? A_Args[3] : default_duration)

; #endregion

; #region |Functions|=======================================
ShowNotification(text, title, duration)
{
	TrayTip text, title
	SetTimer () => TrayTip(), -duration

	; Wait for the notification to be displayed for the given duration before exiting
	Sleep(duration)
}
; #endregion
