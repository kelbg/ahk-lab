; Displays additional info in the normal map view when holding down the Alt key in the game.

; #region |Directives|======================================
#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon
; #endregion

; #region |Auto-execute|====================================
InfoHotkey := "y"
GameWindow := "CivilizationV_DX11.exe"

~Alt::
{
	if !WinActive("ahk_exe" . GameWindow)
		return
	
	Send(InfoHotkey)

	KeyWait("Alt")
	if !WinActive("ahk_exe" . GameWindow)
		return

	Send(InfoHotkey)
}
; #endregion

; #region |Functions|=======================================

; #endregion
