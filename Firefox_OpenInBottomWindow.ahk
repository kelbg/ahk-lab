; Opens a URL from one Firefox window into another
; Version: 0.2 (Updated to AHK v2.0)

; #region |Directives|======================================
#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon
; #endregion

; #region |Auto-execute|====================================
clipboardContents := ""
maxTries := 20

^!P:: 
{
	if (WinGetCount("ahk_class MozillaWindowClass") <= 1 
		|| !WinActive("ahk_class MozillaWindowClass"))
		return

	if (GetCurrentTabURL() == "")
		return

	SwitchToBottomWindow()
	OpenURLInNewTab()
}

; #endregion

; #region |Functions|=======================================
GetCurrentTabURL()
{
	global
	Loop(maxTries)
	{
		Send "^l"
		Sleep(25)
		Send "^c"
		ClipWait(0.1)

		if (A_Clipboard != "")
			break
	}

	return A_Clipboard
}

SwitchToBottomWindow()
{
	
	Send "^w" ; Closes the current tab
	WinActivateBottom("ahk_class MozillaWindowClass")
}

OpenURLInNewTab()
{
	Send "^t" ; Opens a new tab
	Sleep(25)
	Send "^v" ; Pastes the URL from the clipboard
	Send "{Enter}"
}
; #endregion
