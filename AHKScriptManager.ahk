; AHK Script Manager v0.1 by kelbg (https://github.com/kelbg)
; Settings are stored in res/AHKScriptManager.ini
; This code is licensed under the MIT license. See LICENSE for details.

; #region |Directives|======================================
#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon
; #endregion

; #region |Auto-execute|====================================
Initialize()

~Down::
{
	ScrollList(GetVisibleListBox(), 1)
}

~Up::
{
	ScrollList(GetVisibleListBox(), -1)
}

~Enter::
{
	TriggerMainActionOnCurrentList()
}

~Delete::
{
	if (CurrentTab() == Default.RunningScriptsTab)
		TriggerMainActionOnCurrentList()
}
; #endregion

; #region |Functions|=======================================

Initialize()
{
	global
	DetectHiddenWindows(True)
	CreateDefaultSettings()
	LoadSettings()

	if (!StartMinimized)
		MainGUI()

	CloseWindowOnMinimize()
}

CreateDefaultSettings()
{
	global Default := Object()
	{
		Default.CurrentVersion := "0.1"
		Default.ConfigFile := "res/AHKScriptManager.ini"
		Default.GUIWindow := A_ScriptName . " ahk_class AutoHotkeyGUI"
		Default.MainGUIHotkey := "!+W"
		Default.StartMinimized := True
		Default.ScriptsFolder := A_ScriptDir
		Default.Editor := GetDefaultEditor()
		Default.ScriptsFolderTab := 1
		Default.RunningScriptsTab := 2
	}
}

LoadSettings()
{
	global
	ConfigFile := Default.ConfigFile
	GUIWindow := Default.GUIWindow
	Editor := Default.Editor

	if (!FileExist(ConfigFile))
		CreteConfigFile()

	ScriptsFolder := IniRead(ConfigFile, "Settings", "ScriptsFolder")
	MainGUIHotkey := IniRead(ConfigFile, "Settings", "MainGUIHotkey")
	StartMinimized := StrLower(IniRead(ConfigFile, "Settings", "StartMinimized")) == "true" ? True : False

	ScriptsFolderCache := GetScriptsInFolder(ScriptsFolder)
	RunningScriptsCache := GetRunningScripts()
	SetMainGUIHotkey(MainGUIHotkey)
}

CreteConfigFile()
{
	; Write default settings to config file
	IniWrite(Format("`"{1}`"", A_ScriptDir), ConfigFile, "Settings", "ScriptsFolder")
	IniWrite(MainGUIHotkey, ConfigFile, "Settings", "MainGUIHotkey")
	IniWrite(StartMinimized, ConfigFile, "Settings", "StartMinimized")
}

CloseWindowOnMinimize()
{
	loop
	{
		WinWaitNotActive(GUIWindow)

		if (WinExist(GUIWindow) && WinGetMinMax(GUIWindow) == -1)
			WinClose(GUIWindow)

		WinWaitActive(GUIWindow)
	}
}

GetRunningScripts()
{
	output := []
	runningScripts := WinGetList("ahk_class AutoHotkey")

	for script in runningScripts
	{
		RegExMatch(WinGetTitle(script), ".*(?= - AutoHotkey [v0-9\.]+)", &scriptPath)
		output.Push(scriptPath[0])
	}

	global RunningScriptsCache := output
	return output
}

GetScriptsInFolder(path)
{
	output := ""
	scripts := []

	loop files path . "\*.ahk"
		scripts.Push(A_LoopFileName)

	global ScriptsFolderCache := scripts
	return scripts
}

ChooseNewScriptsFolder()
{
	newFolder := DirSelect()
	if newFolder != ""
	{
		global ScriptsFolder := newFolder
		IniWrite(Format("`"{1}`"", ScriptsFolder), ConfigFile, "Settings", "ScriptsFolder")
	}

	return ScriptsFolder
}

GetDefaultEditor()
{
	RegExMatch(RegRead("HKCR\AutoHotkeyScript\Shell\Edit\Command"), "(?<=`")[^`"]*", &path)
	return path[0]
}

EditScript(filePath)
{
	Run(Format("{1} `"{2}`"", Editor, filePath))
}

SetMainGUIHotkey(newHotkey)
{
	global

	; Ignores incomplete hotkeys (modifiers only)
	if (!RegExMatch(newHotkey, "[^#!\+\^]+"))
		return

	Hotkey(newHotkey, (*) => MainGUI(), "On")

	if (MainGUIHotkey == newHotkey)
		return

	; Must remove previous hotkey
	Hotkey(MainGUIHotkey, "Off")
	MainGUIHotkey := newHotkey

	IniWrite(MainGUIHotkey, ConfigFile, "Settings", "MainGUIHotkey")
}

MainGUI()
{
	; Ensures that only one window is open at a time
	if (WinExist(GUIWindow))
		WinClose(GUIWindow)

	guiParams := Object()
	{
		guiParams.width := 450
		guiParams.numRows := 10
		guiParams.rowHeight := 17
		guiParams.groupPadding := 10
		guiParams.filterMargin := 20
		guiParams.filterOffsetX := 10
		guiParams.filterOffsetY := 15
		guiParams.listBoxOffsetX := 0
		guiParams.listBoxOffsetY := 25
		guiParams.mainButtonOffsetY := 10
	}

	mainGUI := Gui()
	mainGUI.SetFont("", "Verdana")
	global Tabs := mainGUI.AddTab3("x0 y0", ["Launch", "Running", "Settings"])
	mainGUI.SetFont("", "Segoe UI Emoji")

	Tabs.UseTab("Launch")
	CreateLaunchTab(mainGUI, Tabs, guiParams)
	Tabs.UseTab("Running")
	CreateRunningScriptsTab(mainGUI, Tabs, guiParams)
	Tabs.UseTab("Settings")
	CreateSettingsTab(mainGUI, Tabs, guiParams)
	CreateStatusBar(mainGUI, Tabs)

	mainGUI.Show("AutoSize")
	return mainGUI
}

CreateLaunchTab(gui, tabs, params)
{
	filePath := ""

	gui.AddGroupBox(Format("w{1} h{2}", params.width,
		params.groupPadding + params.filterMargin + params.numRows * params.rowHeight),
		Format("Scripts found in {1}", ScriptsFolder))

	filterFolder := gui.AddEdit(Format("xp+{1} yp+{2} w{3}",
		params.filterOffsetX,
		params.filterOffsetY,
		params.width - params.filterMargin))

	filterFolder.OnEvent("Change", (*) => Refresh(ListFolder,
		FilterByRegex(ScriptsFolderCache, "i)" . filterFolder.Text)))
	filterFolder.OnEvent("Change", (*) => ListFolder.Choose(
		Min(1, ControlGetItems(ListFolder).Length)))
	
	filterFolder.OnEvent("Change", (*) => filePath := Format(
		"{1}\{2}", ScriptsFolder, ListFolder.Text))

	global ListFolder := gui.AddListBox(
		Format("wp+{1} yp+{2} R{3}",
			params.listBoxOffsetX,
			params.listBoxOffsetY,
			params.numRows),
		GetScriptsInFolder(ScriptsFolder))

	ListFolder.OnEvent("Change", (*) => filePath := Format(
		"{1}\{2}", ScriptsFolder, ListFolder.Text))
	ListFolder.OnEvent("DoubleClick", (*) => Run(filePath))

	; Selects the first item if there is at least one
	ListFolder.Choose(Min(1, ControlGetItems(ListFolder).Length))

	btnRun := gui.AddButton("y+" . params.mainButtonOffsetY, "▶️ Run Script")
	btnRun.OnEvent("Click", (*) => Run(filePath))

	btnEdit := gui.AddButton("yp", "🔧 Edit Script")
	btnEdit.OnEvent("Click", (*) => EditScript(filePath))
}

CreateRunningScriptsTab(gui, tabs, params)
{
	gui.AddGroupBox(Format("w{1} h{2}", params.width,
		params.groupPadding + params.filterMargin + params.numRows * params.rowHeight),
		"Scripts currently running")

	filterRunning := gui.AddEdit(Format("xp+{1} yp+{2} w{3}",
		params.filterOffsetX,
		params.filterOffsetY,
		params.width - params.filterMargin))

	filterRunning.OnEvent("Change", (*) => Refresh(ListRunning,
		FilterByRegex(RunningScriptsCache, "i)" . filterRunning.Text)))
	filterRunning.OnEvent("Change", (*) => ListRunning.Choose(
		Min(1, ControlGetItems(ListRunning).Length)))

	global ListRunning := gui.AddListBox(
		Format("wp+{1} yp+{2} R{3}",
			params.listBoxOffsetX,
			params.listBoxOffsetY,
			params.numRows),
		GetRunningScripts())

	ListRunning.OnEvent("DoubleClick", (*) => WinClose(ListRunning.Text))
	ListRunning.OnEvent("DoubleClick", (*) => Refresh(ListRunning, GetRunningScripts()))

	ListRunning.Choose(Min(1, ControlGetItems(ListRunning).Length))

	btnTerminate := gui.AddButton("y+" . params.mainButtonOffsetY, "✖️ Terminate")
	btnTerminate.OnEvent("Click", (*) => WinClose(ListRunning.Text))
	btnTerminate.OnEvent("Click", (*) => Refresh(ListRunning, GetRunningScripts()))

	btnRefresh := gui.AddButton("yp", "🔄️ Refresh")
	btnRefresh.OnEvent("Click", (*) => Refresh(ListRunning, GetRunningScripts()))
}

CreateSettingsTab(gui, tabs, params)
{
	gui.AddGroupBox(Format("w{1} R5", params.width), "Settings")
	gui.AddText("xp+10 yp+20", "Scripts Folder Location:")
	btnFolder := gui.AddButton("", "📁")
	labelPath := gui.AddEdit(Format("xp+30 yp w{1} ReadOnly", params.width - 50), ScriptsFolder)
	btnFolder.OnEvent("Click", (*) => ControlSetText(ChooseNewScriptsFolder(), labelPath))
	btnFolder.OnEvent("Click", (*) => Refresh(ListFolder, GetScriptsInFolder(ScriptsFolder)))
	btnFolder.OnEvent("Click", (*) => ControlSetText(
		Format("Scripts found in {1}", labelPath.text), "Button1",
		GUIWindow))
	gui.AddText("xp-30 yp+30", "Window activation hotkey: ")
	newHotkey := gui.AddHotkey("xp yp+20 w160", MainGUIHotkey)
	newHotkey.OnEvent("Change", (*) => SetMainGUIHotkey(newHotkey.value))
	btnResetHotkey := gui.AddButton("x+5 yp", "Reset to default")
	btnResetHotkey.OnEvent("Click", (*) => SetMainGUIHotkey(Default.MainGUIHotkey))
	btnResetHotkey.OnEvent("Click", (*) => newHotkey.Value := Default.MainGUIHotkey)
}

CreateStatusBar(gui, tabs)
{
	sb := gui.AddStatusBar("", GetStatusBarText())
	tabs.OnEvent("Change", (*) => sb.SetText(GetStatusBarText()))
}


Refresh(listbox, items)
{
	listbox.Delete()
	listbox.Add(items)
}

FilterByRegex(arr, regex)
{
	matches := []
	for item in arr
	{
		try ; If the regex is invalid, it will simply return an empty array, which is fine
			if (RegExMatch(item, regex))
				matches.Push(item)
	}

	return matches
}

GetStatusBarText()
{
	tab := Tabs.Value
	if (tab == Default.ScriptsFolderTab)
		return Format("Total scripts: {1}", ScriptsFolderCache.Length)

	if (tab == Default.RunningScriptsTab)
		return Format("Scripts currently running: {1}", RunningScriptsCache.Length)

	return Format("AutoHotkey Script Manager v{1} by kelbg", Default.CurrentVersion)
}

; Only returns the _first_ visible listbox
GetVisibleListBox()
{
	if (!WinActive(GUIWindow))
		return

	for listbox in FilterByRegex(WinGetControls(GUIWindow), "ListBox")
	{
		if ControlGetVisible(listbox, GUIWindow)
			return listbox
	}

	return ""
}

; Allows scrolling through a listbox even when it's not in focus
ScrollList(list, amount)
{
	if (!WinActive(GUIWindow) || list == "")
		return

	length := ControlGetItems(list, GUIWindow).Length
	if (length == 0)
		return ; Nothing to scroll

	if (ControlGetFocus(GUIWindow) == ControlGetHwnd(list, GUIWindow))
		return ; Listbox already has focus

	if list == ListFolder.ClassNN
		list := ListFolder
	else if list == ListRunning.ClassNN
		list := ListRunning
	else
	{
		MsgBox("ListBox '" . list . "' not found")
		return
	}

	; Clamps the index so that it's within the range of the listbox (1-length)
	index := ControlGetIndex(list, GUIWindow)
	list.Choose(Min(Max(1, index + amount), length))
}

TriggerMainActionOnCurrentList()
{
	if (!WinActive(GUIWindow))
		return

	; MsgBox("Current tab: " . CurrentTab())
	if (CurrentTab() == Default.ScriptsFolderTab)
		ControlClick("Button2") ; Button "Run Script" - Runs the selected script
	else if (CurrentTab() == Default.RunningScriptsTab)
		ControlClick("Button5") ; Button "Terminate" - Kills the selected script
}

CurrentTab()
{
	if (!WinActive(GUIWindow))
		return

	return Tabs.Value
}
; #endregion
