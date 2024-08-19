; Retrieves login credentials from Bitwarden and enters them into the game with a hotkey.
; Allows switching between accounts by pressing CTRL+ALT+NUMPAD.
; Credentials are not saved to the disk. Account names must be defined in res\mtga_accs.ini
; Requires BW CLI to be installed.
; Version: 0.2 (Updated to AHK v2.0)

; #region |Directives|======================================
#Requires AutoHotkey v2.0
#SingleInstance
; #endregion

; #region |Auto-execute|====================================
accounts := []
sessionKey := ""

Persistent()
Initialize()
OnExit(LockVault)

~LControl & ~Alt::
~LAlt & ~Ctrl::
{
	if (!WinActive("ahk_exe MTGA.exe"))
		return

	while (GetKeyState("LCtrl", "P") || GetKeyState("LAlt", "P"))
	{
		for index, account in accounts
		{
			if (!GetKeyState("Numpad" . index, "P"))
				continue

			EnterLoginInfo(account)
			KeyWait("Ctrl")
			KeyWait("Alt")
		}
	}
}
; #endregion

; #region |Functions|=======================================
Initialize()
{
	TraySetIcon("res\MTGA_masahk.png")
	A_IconTip := "MTGA Account Switcher v0.2"

	LoadAccounts()
	Authenticate()
}

LoadAccounts()
{
	global
	accounts := StrSplit(IniRead("res\mtga_accs.ini", "accounts"), "`n")
}

PSColoredText(text, color)
{
	return Format("Write-Host '{1}' -ForegroundColor {2}", text, color)
}

Join(separator, params*) {
    for index, param in params
        str .= param . separator
    return SubStr(str, 1, -StrLen(separator))
}

ShowNotification(text, duration := 3000)
{
	; Clear previous notifications
	TrayTip()

	TrayTip("MTGA Account Switcher", text)
	SetTimer(TrayTip, -duration)
}

Authenticate()
{
	global
	commands := [
		PSColoredText("📝 MTGA Account Switcher v0.2", "green"),
		PSColoredText("⚠️ Authentication required (Bitwarden)", "yellow"),
		"bw unlock"
	]

	cmdOutput := RunWaitOutput("pwsh /c " . Join(" && ", commands*))

	RegExMatch(cmdOutput, "(?<=BW_SESSION=`").*?(?=`")", &bwSessionKey)

	if (bwSessionKey == "")
	{
		result := MsgBox("Authentication failed! Retry?", "MTGA Account Switcher v0.2", 5)
		if (result == "Retry")
			Reload()
		else
			ExitApp()
	}

	sessionKey := bwSessionKey[0]
	ShowNotification("Authentication successful")
	return true
}

RunWaitOutput(command, hidden := false)
{
	outputPath := Format("{1}\{2}", A_Temp, "maasout.tmp")
	RunWait(command . " > " . outputPath, , hidden ? "Hide" : "")
	Sleep(10)
	cmdOutput := FileRead(outputPath)
	FileDelete(outputPath)
	return cmdOutput
}

BWGetItem(id)
{
	global
	cmd := Format("bw get item {1} --session {2}", id, sessionKey)
	return RunWaitOutput("pwsh /c " . cmd, true)
}

EnterLoginInfo(id)
{
	item := BWGetItem(id)

	RegExMatch(item, "`"username`":`"(.*?)`"", &username)
	RegExMatch(item, "`"password`":`"(.*?)`"", &password)

	; Confirm MTGA window is active before entering login
	if (!WinActive("ahk_exe MTGA.exe"))
		return

	Send(username[1])
	Sleep(100)
	Send("{Tab}")
	Sleep(100)
	Send(password[1])
}

LockVault(ExitReason, ExitCode)
{
	RunWait("pwsh /c bw lock", , "Hide")
	ShowNotification("BW Vault locked")
}

; #endregion
