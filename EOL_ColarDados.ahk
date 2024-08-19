; Permite colar dados em uma janela do sistema EOL
; ⚠️ Requer AHK v1.1

#NoEnv
#Persistent
#SingleInstance, Force

SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

~^v::
	If (WinActive("Escola OnLine - Secretaria Municipal de Educação"))
	{
		ToolTip, % "EOL: Colando '" . Clipboard . "'..."
		SendRaw, % Clipboard
		SetTimer, ClearToolTip, -2000
		Return
	}
Return

ClearToolTip:
	ToolTip
Return
