; AHK Version ..: 1.1.32.0 (Unicode 32-bit)
; OS Version ...: Windows 10 (Previous versions tested working on Win7)
;@Ahk2Exe-SetName Nova Macros Client Offline
;@Ahk2Exe-SetDescription Nova Macros for local TouchScreen
;@Ahk2Exe-SetVersion 2.7-offline
;@Ahk2Exe-SetCopyright Copyright (c) 2020`, elModo7
;@Ahk2Exe-SetOrigFilename Nova Macros Client Offline.exe
; INITIALIZE
; *******************************
#NoEnv
#Persistent
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
CoordMode,Mouse,Screen
#Include, <nm_msg>
global IsVisible = true
global InFolder := MoveMouseOnButtonPress := MiniClient := AlwaysVisible := SendAltTabOnButtonPress := false
global Variable, Valor, PreviousValue, RegisteredPrograms, AssociatedPages, DualButtons, ButtonFolder, FolderPage, PathEditorScripts, ExtensionScripts, ActiveButton, ButtonAPress, windowHandler
global VariableChangeImage = 0
global Button1Path, Button2Path, Button3Path, Button4Path, Button5Path, Button6Path, Button7Path, Button8Path, Button9Path, Button1Path0, Button1Path1, Button1Path2, Button1Path3, Button1Path4, Button1Path5
global DualButtonsStates := []
global feedbackExecution := []
global PageNumber := ProgressLoadingIcons := 0
global MsgBoxBtn1, MsgBoxBtn2, MsgBoxBtn3, MsgBoxBtn4
global Screen_Half_X := A_ScreenWidth / 2
global Screen_Half_Y := A_ScreenHeight / 2
global ClientVersion := "2.7 Offline"
FileCreateDir, conf

if(!FileExist("./conf/ProgramPages.txt"))
{
	FileAppend, obs64.exe|explorer.exe|chrome.exe`n, ./conf/ProgramPages.txt
	FileAppend, 0|3|1, ./conf/ProgramPages.txt
}

;~ Load Programs associated with pages
NumberLoop := 1
Loop, read, ./conf/ProgramPages.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumberLoop == "1")
	{
	    RegisteredProgramsRead := LineArray1
	}
	else if(NumberLoop == "2")
	{
		AssociatedPagesRead := LineArray1
	}
	NumberLoop++
}
StringSplit, RegisteredPrograms, RegisteredProgramsRead, |, ; I create the RegisteredPrograms array from the RegisteredProgramsRead string, separating elements by complus, RegisteredPrograms0 contains the element count, and RegisteredPrograms1, RegisteredPrograms2... are the fields of the array
StringSplit, AssociatedPages, AssociatedPagesRead, |,
global RegisteredPrograms0

if(!FileExist("./conf/FolderButtons.txt"))
{
	FileAppend, 6|7`n, ./conf/FolderButtons.txt
	FileAppend, UtilesStream|SoundsOBS, ./conf/FolderButtons.txt
}

;~ Load Buttons associated with folders
NumberLoop := 1
Loop, read, ./conf/FolderButtons.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumberLoop == "1")
	{
	    ButtonsFoldersRead := LineArray1
	}
	else if(NumberLoop == "2")
	{
		FoldersButtonsRead := LineArray1
	}
	NumberLoop++
}
StringSplit, ButtonsFolders, ButtonsFoldersRead, |,
StringSplit, FoldersButtons, FoldersButtonsRead, |,
global ButtonsFolders0

if(!FileExist("./conf/DualButtons.txt"))
{
	FileAppend, 4|5`n, ./conf/DualButtons.txt
	FileAppend, 4Enabled|5Enabled, ./conf/DualButtons.txt
}

;~ Load Dual Buttons
NumberLoop := 1
Loop, read, ./conf/DualButtons.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumberLoop == "1")
	{
	    DualButtonsRead := LineArray1
	}
	else if(NumberLoop == "2")
	{
		DualActionsRead := LineArray1
	}
	NumberLoop++
}
StringSplit, DualButtons, DualButtonsRead, |,
StringSplit, DualActionsRead, DualActionsRead, |,
global DualButtons0

; Set the dual buttons to 0
i = 1
while(i <= DualButtons0)
{
	DualButtonsStates.Push(0)
	i++
}

if(!FileExist("./conf/ExtensionScripts.txt"))
{
	; Extension Scripts
	InputBox, ExtensionScripts, Button Script EXT, Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`., , 500, 145,,,,,ahk
	if ExtensionScripts =
		MsgBox, Couldn't retrieve the extension!
	else
	{
		FileDelete, ./conf/ExtensionScripts.txt
		FileAppend, %ExtensionScripts%`n, ./conf/ExtensionScripts.txt
	}
}
else
{
	if(ExtensionScripts = "")
	{
		FileReadLine,ExtensionScripts,./conf/ExtensionScripts.txt,1
	}
}

; TRAY MENU
; *******************************
Menu, tray, NoStandard
Menu, tray, add, Hide, ToggleHide
Menu, tray, add, Set Editor Path, ChangeEditorPath
Menu, tray, add
Menu, tray, add, Exit, Exit

; GENERIC CONTEXT MENU
; *******************************
Menu GenericContextMenu, Add, Always on Top, AlwaysVisible
Menu GenericContextMenu, UnCheck, Always on Top
Menu GenericContextMenu, Add, Center Mouse after Activation, MoveMouseToggleButtonPress
Menu GenericContextMenu, UnCheck, Center Mouse after Activation
Menu GenericContextMenu, Add, Send Alt+Tab after Activation, SendAltTabOnToggleButtonPress
Menu GenericContextMenu, UnCheck, Send Alt+Tab after Activation
Menu GenericContextMenu, Add, Progressive Icon Loading, ProgressLoadingIconsToggle
Menu GenericContextMenu, UnCheck, Progressive Icon Loading
Menu GenericContextMenu, Add, Mini Client, ChangeDimensionsClient
Menu GenericContextMenu, UnCheck, Mini Client

; CONTEXT MENU BUTTONS
; *******************************
Menu scriptGenerator, Add, Run File, ScriptGenerator_RunFile
Menu scriptGenerator, Icon, Run File, shell32.dll, 25
Menu scriptGenerator, Add, Run Cmd, ScriptGenerator_RunCmd
Menu scriptGenerator, Icon, Run Cmd, imageres.dll, 263
Menu scriptGenerator, Add, Send Text, ScriptGenerator_SendText
Menu scriptGenerator, Icon, Send Text, shell32.dll, 71
Menu scriptGenerator, Add, Hotkey - Macro, ScriptGenerator_Hotkey
Menu scriptGenerator, Icon, Hotkey - Macro, imageres.dll, 174
Menu MultimediaFunctions, Add, Play / Pause, ScriptGenerator_Multimedia_PlayPause
Menu MultimediaFunctions, Icon, Play / Pause, imageres.dll, 62
Menu MultimediaFunctions, Add, Stop, ScriptGenerator_Multimedia_Stop
Menu MultimediaFunctions, Icon, Stop, imageres.dll, 62
Menu MultimediaFunctions, Add, Previous, ScriptGenerator_Multimedia_Previous
Menu MultimediaFunctions, Icon, Previous, imageres.dll, 62
Menu MultimediaFunctions, Add, Next, ScriptGenerator_Multimedia_Next
Menu MultimediaFunctions, Icon, Next, imageres.dll, 62
Menu MultimediaFunctions, Add, Volume +, ScriptGenerator_Multimedia_MoreVolume
Menu MultimediaFunctions, Icon, Volume +, imageres.dll, 62
Menu MultimediaFunctions, Add, Volume -, ScriptGenerator_Multimedia_LessVolume
Menu MultimediaFunctions, Icon, Volume -, imageres.dll, 62
Menu MultimediaFunctions, Add, Mute / Unmute, ScriptGenerator_Multimedia_Mute
Menu MultimediaFunctions, Icon, Mute / Unmute, imageres.dll, 62
Menu QuickActionsMenu, Add, Close Window, ScriptGenerator_QuickActions_CloseWindow
Menu QuickActionsMenu, Icon, Close Window, imageres.dll, 236
Menu QuickActionsMenu, Add, Maximize Window, ScriptGenerator_QuickActions_Maximize
Menu QuickActionsMenu, Icon, Maximize Window, imageres.dll, 287
Menu QuickActionsMenu, Add, Minimize Window, ScriptGenerator_QuickActions_Minimize
Menu QuickActionsMenu, Icon, Minimize Window, imageres.dll, 17
Menu QuickActionsMenu, Add, Show Desktop, ScriptGenerator_QuickActions_ShowDesktop
Menu QuickActionsMenu, Icon, Show Desktop, imageres.dll, 106
Menu QuickActionsMenu, Add, New Explorer Window, ScriptGenerator_QuickActions_NewExplorer
Menu QuickActionsMenu, Icon, New Explorer Window, imageres.dll, 5
Menu QuickActionsMenu, Add, New Folder, ScriptGenerator_QuickActions_NewFolder
Menu QuickActionsMenu, Icon, New Folder, shell32.dll, 280
Menu QuickActionsMenu, Add, Quick Rename File, ScriptGenerator_QuickActions_QuickRename
Menu QuickActionsMenu, Icon, Quick Rename File, shell32.dll, 134
Menu QuickActionsMenu, Add, Lock PC, ScriptGenerator_QuickActions_LockPC
Menu QuickActionsMenu, Icon, Lock PC, shell32.dll, 45
Menu QuickActionsMenu, Add, Shutdown PC, ScriptGenerator_QuickActions_Shutdown
Menu QuickActionsMenu, Icon, Shutdown PC, shell32.dll, 28
Menu QuickActionsMenu, Add, System Info, ScriptGenerator_QuickActions_SystemInfo
Menu QuickActionsMenu, Icon, System Info, shell32.dll, 24
Menu QuickActionsMenu, Add, System FULL Info, ScriptGenerator_QuickActions_FullSystemInfo
Menu QuickActionsMenu, Icon, System FULL Info, shell32.dll, 22
Menu QuickActionsMenu, Add, cmd.exe, ScriptGenerator_QuickActions_Cmd
Menu QuickActionsMenu, Icon, cmd.exe, imageres.dll, 263
Menu QuickActionsMenu, Add, PowerShell, ScriptGenerator_QuickActions_PowerShell
Menu QuickActionsMenu, Icon, PowerShell, imageres.dll, 312
Menu QuickActionsMenu, Add, Take Screenshot, ScriptGenerator_QuickActions_ScreenShot
Menu QuickActionsMenu, Icon, Take Screenshot, imageres.dll, 68
Menu QuickActionsMenu, Add, Snip img from screen, ScriptGenerator_QuickActions_SnipImage
Menu QuickActionsMenu, Icon, Snip img from screen, imageres.dll, 17
Menu QuickActionsMenu, Add, Windows Gaming Panel, ScriptGenerator_QuickActions_GamePanel
Menu QuickActionsMenu, Icon, Windows Gaming Panel, imageres.dll, 305
Menu WebBrowserCommands, Add, Next Tab, ScriptGenerator_WebBrowser_NextTab
Menu WebBrowserCommands, Icon, Next Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Previous Tab, ScriptGenerator_WebBrowser_PreviousTab
Menu WebBrowserCommands, Icon, Previous Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, New Tab, ScriptGenerator_WebBrowser_NewTab
Menu WebBrowserCommands, Icon, New Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, New Window, ScriptGenerator_WebBrowser_NewWindow
Menu WebBrowserCommands, Icon, New Window, shell32.dll, 15
Menu WebBrowserCommands, Add, Close Tab, ScriptGenerator_WebBrowser_CloseTab
Menu WebBrowserCommands, Icon, Close Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Restore Closed Tab, ScriptGenerator_WebBrowser_RestoreTab
Menu WebBrowserCommands, Icon, Restore Closed Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Chrome Private Window (NEW), ScriptGenerator_WebBrowser_ChromePrivWindow
Menu WebBrowserCommands, Icon, Chrome Private Window (NEW), shell32.dll, 15
Menu FunctionKeysMenu, Add, F13, ScriptGenerator_FunctionKeys_F13
Menu FunctionKeysMenu, Icon, F13, imageres.dll, 174
Menu FunctionKeysMenu, Add, F14, ScriptGenerator_FunctionKeys_F14
Menu FunctionKeysMenu, Icon, F14, imageres.dll, 174
Menu FunctionKeysMenu, Add, F15, ScriptGenerator_FunctionKeys_F15
Menu FunctionKeysMenu, Icon, F15, imageres.dll, 174
Menu FunctionKeysMenu, Add, F16, ScriptGenerator_FunctionKeys_F16
Menu FunctionKeysMenu, Icon, F16, imageres.dll, 174
Menu FunctionKeysMenu, Add, F17, ScriptGenerator_FunctionKeys_F17
Menu FunctionKeysMenu, Icon, F17, imageres.dll, 174
Menu FunctionKeysMenu, Add, F18, ScriptGenerator_FunctionKeys_F18
Menu FunctionKeysMenu, Icon, F18, imageres.dll, 174
Menu FunctionKeysMenu, Add, F19, ScriptGenerator_FunctionKeys_F19
Menu FunctionKeysMenu, Icon, F19, imageres.dll, 174
Menu FunctionKeysMenu, Add, F20, ScriptGenerator_FunctionKeys_F20
Menu FunctionKeysMenu, Icon, F20, imageres.dll, 174
Menu FunctionKeysMenu, Add, F21, ScriptGenerator_FunctionKeys_F21
Menu FunctionKeysMenu, Icon, F21, imageres.dll, 174
Menu FunctionKeysMenu, Add, F22, ScriptGenerator_FunctionKeys_F22
Menu FunctionKeysMenu, Icon, F22, imageres.dll, 174
Menu FunctionKeysMenu, Add, F23, ScriptGenerator_FunctionKeys_F23
Menu FunctionKeysMenu, Icon, F23, imageres.dll, 174
Menu FunctionKeysMenu, Add, F24, ScriptGenerator_FunctionKeys_F24
Menu FunctionKeysMenu, Icon, F24, imageres.dll, 174
Menu scriptGenerator, Add, Multimedia, :MultimediaFunctions
Menu scriptGenerator, Icon, Multimedia, imageres.dll, 19
Menu scriptGenerator, Add, Web Browser, :WebBrowserCommands
Menu scriptGenerator, Icon, Web Browser, shell32.dll, 221
Menu scriptGenerator, Add, Quick Actions, :QuickActionsMenu
Menu scriptGenerator, Icon, Quick Actions, imageres.dll, 293
Menu scriptGenerator, Add, Hidden Function Keys (F13-F24), :FunctionKeysMenu
Menu scriptGenerator, Icon, Hidden Function Keys (F13-F24), imageres.dll, 174

Menu ContextMenu, Add, Edit Script`tShift + Click, GuiEditScript
Menu ContextMenu, Default, Edit Script`tShift + Click
Menu ContextMenu, Icon, Edit Script`tShift + Click, shell32.dll, 85
Menu ContextMenu, Add, Script Generator`tAlt + Right Click, :scriptGenerator
Menu ContextMenu, Icon, Script Generator`tAlt + Right Click, shell32.dll, 22
Menu ContextMenu, Add, Change/Del Image`tCtrl + Shift + Click, GuiChangeImageButton
Menu ContextMenu, Icon, Change/Del Image`tCtrl + Shift + Click, shell32.dll, 142
Menu ContextMenu, Add, Button Name`tCtrl + Click, GuiInfoButton
Menu ContextMenu, Icon, Button Name`tCtrl + Click, shell32.dll, 24
Menu ContextMenu, Add, Create Folder Button, CreateFolderButton
Menu ContextMenu, Icon, Create Folder Button, shell32.dll, 280
Menu ContextMenu, Add, Delete Folder Button, DeleteFolderButton
Menu ContextMenu, Icon, Delete Folder Button, shell32.dll, 235
Menu ContextMenu, Add, Delete Button Function, DeleteButtonFunction
Menu ContextMenu, Icon, Delete Button Function, shell32.dll, 132

; GUI
; *******************************
Gui, Color, 282828
Gui -Caption +LastFound +ToolWindow +HwndwindowHandler +E0x02000000 +E0x00080000 +AlwaysOnTop
; Row1
Gui Add, Picture, +BackgroundTrans gButton1 vButton1, resources\img\1.png
Gui Add, Picture, +BackgroundTrans gButton2 vButton2, resources\img\2.png
Gui Add, Picture, +BackgroundTrans gButton3 vButton3, resources\img\3.png
Gui Add, Picture, +BackgroundTrans gButton4 vButton4, resources\img\4.png
Gui Add, Picture, +BackgroundTrans gButton5 vButton5, resources\img\5.png
; Row2
Gui Add, Picture, +BackgroundTrans gButton6 vButton6, resources\img\6.png
Gui Add, Picture, +BackgroundTrans gButton7 vButton7, resources\img\7.png
Gui Add, Picture, +BackgroundTrans gButton8 vButton8, resources\img\8.png
Gui Add, Picture, +BackgroundTrans gButton9 vButton9, resources\img\9.png
Gui Add, Picture, +BackgroundTrans gButton10 vButton10, resources\img\10.png
; Row3
Gui Add, Picture, +BackgroundTrans gButton11 vButton11, resources\img\11.png
Gui Add, Picture, +BackgroundTrans gButton12 vButton12, resources\img\12.png
Gui Add, Picture, +BackgroundTrans gButton13 vButton13, resources\img\13.png
Gui Add, Picture, +BackgroundTrans gButton14 vButton14, resources\img\14.png
Gui Add, Picture, +BackgroundTrans gButton15 vButton15, resources\img\15.png
; Backgrounds Activations Buttons
Gui Add, Picture, vActivate1 Hidden x120 y40 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate2 Hidden x280 y40 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate3 Hidden x440 y40 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate4 Hidden x600 y40 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate5 Hidden x760 y40 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate6 Hidden x120 y220 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate7 Hidden x280 y220 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate8 Hidden x440 y220 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate9 Hidden x600 y220 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate10 Hidden x760 y220 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate11 Hidden x120 y400 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate12 Hidden x280 y400 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate13 Hidden x440 y400 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate14 Hidden x600 y400 w150 h150,resources\img\FondoActivation.png
Gui Add, Picture, vActivate15 Hidden x760 y400 w150 h150,resources\img\FondoActivation.png
; Buttons Page
Gui Add, Picture, +BackgroundTrans gRightPage vRightPage x910 y240 w130 h130, resources\img\RightPage.png
Gui Add, Picture, +BackgroundTrans gLeftPage vLeftPage x0 y240 w130 h130, resources\img\LeftPage.png
; Background and sections move
Gui Add, Picture, x0 y0 w1024 h600, resources\img\background.jpg
Gui, Add, Text, x0 y0 w1024 h50 cWhite Center GMoveWindow vMoveWindowUp, ; Move Ventana de arriba
Gui, Add, Text, x0 y570 w1024 h50 cWhite Center GMoveWindow vMoveWindowDown, ; Move Ventana de abajo
SetPage(0)
Gui Show, w1024 h600, Nova Macros Client
Return

; LABELS BUTTONS AND GENERAL FUNCTIONS
; *******************************
Show:
if WinExist("Nova Macros Client"){
	WinHide, Nova Macros Client
}
Return

ToggleHide:
if IsVisible
{
	WinHide, Nova Macros Client
	Menu, tray, Rename, Hide, Show
	IsVisible = 0
}
else
{
	WinShow, Nova Macros Client
	WinActivate, Nova Macros Client
	Menu, tray, Rename, Show, Hide
	IsVisible = 1
}
Return

GuiContextMenu:
	if GetKeyState("Alt")
		scriptGen := 1
	else
		scriptGen := 0
	if A_GuiControl In Button1,Button2,Button3,Button4,Button5,Button6,Button7,Button8,Button9,Button10,Button11,Button12,Button13,Button14,Button15
	{
		StringReplace, ButtonAPress, A_GuiControl, button,
		if(InFolder)
			ActiveButton := ButtonFolder 15*FolderPage+ButtonAPress
		else
			ActiveButton := 15*PageNumber+ButtonAPress
		if (scriptGen)
		{
			KeyWait, Alt,
			Menu scriptGenerator, Show
		}
		else
		{
			Menu ContextMenu, Show
		}
	}
	else
		Menu GenericContextMenu, Show
return

GuiEditScript:
	EditScriptButton(ActiveButton)
return

GuiChangeImageButton:
	SetImageButton(ActiveButton)
return

GuiInfoButton:
	MsgBox,,Button ID, Clicked button Id is: %ActiveButton%
return

ScriptGenerator_RunFile:
	Run, "lib\script_generator\RunFile.ahk" %ActiveButton%
return

ScriptGenerator_RunCmd:
	Run, "lib\script_generator\RunCmd.ahk" %ActiveButton%
return

ScriptGenerator_SendText:
	Run, "lib\script_generator\SendTextBlock.ahk" %ActiveButton%
return

ScriptGenerator_Hotkey:
	Run, "lib\script_generator\HotkeyCreator.ahk" %ActiveButton%
return

ScriptGenerator_Multimedia_PlayPause:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_PlayPause.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_Stop:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Stop.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_Next:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Next.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_Previous:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Previous.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_MoreVolume:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_MoreVolume.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_LessVolume:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_LessVolume.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_Multimedia_Mute:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Mute.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F13:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F13.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F14:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F14.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F15:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F15.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F16:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F16.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F17:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F17.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F18:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F18.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F19:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F19.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F20:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F20.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F21:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F21.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F22:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F22.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F23:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F23.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_FunctionKeys_F24:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F24.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_NextTab:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NextTab.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_PreviousTab:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_PreviousTab.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_NewTab:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewTab.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_NewWindow:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewWindow.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_CloseTab:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_CloseTab.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_RestoreTab:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_RestoreTab.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_WebBrowser_ChromePrivWindow:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_ChromePrivWindow.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_CloseWindow:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_CloseWindow.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_Maximize:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Maximize.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_Minimize:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Minimize.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_ShowDesktop:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ShowDesktop.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_NewExplorer:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewExplorer.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_NewFolder:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewFolder.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_QuickRename:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_QuickRename.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_LockPC:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_LockPC.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_Shutdown:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Shutdown.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_SystemInfo:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SystemInfo.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_FullSystemInfo:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_FullSystemInfo.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_Cmd:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Cmd.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_PowerShell:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_PowerShell.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_ScreenShot:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ScreenShot.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_SnipImage:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SnipImage.ahk,%ActiveButton%.ahk,1
return

ScriptGenerator_QuickActions_GamePanel:
	if(ButtonExists())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_GamePanel.ahk,%ActiveButton%.ahk,1
return

NotImplemented:
	MsgBox, Not implemented
return

ButtonExists()
{
	buttonPath := "" ActiveButton ".ahk"
	if FileExist(buttonPath)
	{
		OnMessage(0x44, "OnMsgBox")
		MsgBoxBtn1 = Overwrite
		MsgBoxBtn2 = Cancel
		MsgBox 0x34, Overwrite?, This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			return 1
		}else{
			return 0
		}
	}
	else
	{
		return 1
	}
}

AlwaysVisible:
	if(AlwaysVisible)
	{
		WinSet, AlwaysOnTop, Off, A
		AlwaysVisible := 0
		Menu GenericContextMenu, UnCheck, Always on Top
	}
	else
	{
		WinSet, AlwaysOnTop, , A
		AlwaysVisible := 1
		Menu GenericContextMenu, Check, Always on Top
	}
return

MoveMouseToggleButtonPress:
	if(MoveMouseOnButtonPress)
	{
		MoveMouseOnButtonPress := 0
		Menu GenericContextMenu, UnCheck, Center Mouse after Activation
	}
	else
	{
		MoveMouseOnButtonPress := 1
		Menu GenericContextMenu, Check, Center Mouse after Activation
	}
return

SendAltTabOnToggleButtonPress:
	if(SendAltTabOnButtonPress)
	{
		SendAltTabOnButtonPress := 0
		Menu GenericContextMenu, UnCheck, Send Alt+Tab after Activation
	}
	else
	{
		SendAltTabOnButtonPress := 1
		Menu GenericContextMenu, Check, Send Alt+Tab after Activation
	}
return

ProgressLoadingIconsToggle:
	if(ProgressLoadingIcons)
	{
		ProgressLoadingIcons := 0
		Menu GenericContextMenu, UnCheck, Progressive Icon Loading
	}
	else
	{
		ProgressLoadingIcons := 1
		Menu GenericContextMenu, Check, Progressive Icon Loading
	}
return
 
ChangeDimensionsClient:
if(!ProgressLoadingIcons)
	DllCall("LockWindowUpdate", "UInt", windowHandler)
if MiniClient
{
	Menu, GenericContextMenu, Rename, Normal Client, Mini Client
	MiniClient = 0
	GuiControl, MoveDraw, Activate1, x120 y40 w150 h150
	GuiControl, MoveDraw, Activate2, x280 y40 w150 h150
	GuiControl, MoveDraw, Activate3, x440 y40 w150 h150
	GuiControl, MoveDraw, Activate4, x600 y40 w150 h150
	GuiControl, MoveDraw, Activate5, x760 y40 w150 h150
	GuiControl, MoveDraw, Activate6, x120 y220 w150 h150
	GuiControl, MoveDraw, Activate7, x280 y220 w150 h150
	GuiControl, MoveDraw, Activate8, x440 y220 w150 h150
	GuiControl, MoveDraw, Activate9, x600 y220 w150 h150
	GuiControl, MoveDraw, Activate10, x760 y220 w150 h150
	GuiControl, MoveDraw, Activate11, x120 y400 w150 h150
	GuiControl, MoveDraw, Activate12, x280 y400 w150 h150
	GuiControl, MoveDraw, Activate13, x440 y400 w150 h150
	GuiControl, MoveDraw, Activate14, x600 y400 w150 h150
	GuiControl, MoveDraw, Activate15, x760 y400 w150 h150
	GuiControl, MoveDraw, LeftPage, x0 y230 w130 h130
	GuiControl, MoveDraw, RightPage, x910 y230 w130 h130
	GuiControl, MoveDraw, MoveWindowUp, x0 y0 w1024 h50
	GuiControl, MoveDraw, MoveWindowDown, x0 y570 w1024 h50
	Gui Show, w1024 h600, Nova Macros Client
}
else
{
	Menu, GenericContextMenu, Rename, Mini Client, Normal Client
	MiniClient = 1
	GuiControl, MoveDraw, Activate1, x54 y14 w59 h59
	GuiControl, MoveDraw, Activate2, x110 y14 w59 h59
	GuiControl, MoveDraw, Activate3, x166 y14 w59 h59
	GuiControl, MoveDraw, Activate4, x222 y14 w59 h59
	GuiControl, MoveDraw, Activate5, x278 y14 w59 h59
	GuiControl, MoveDraw, Activate6, x54 y70 w59 h59
	GuiControl, MoveDraw, Activate7, x110 y70 w59 h59
	GuiControl, MoveDraw, Activate8, x166 y70 w59 h59
	GuiControl, MoveDraw, Activate9, x222 y70 w59 h59
	GuiControl, MoveDraw, Activate10, x278 y70 w59 h59
	GuiControl, MoveDraw, Activate11, x54 y126 w59 h59
	GuiControl, MoveDraw, Activate12, x110 y126 w59 h59
	GuiControl, MoveDraw, Activate13, x166 y126 w59 h59
	GuiControl, MoveDraw, Activate14, x222 y126 w59 h59
	GuiControl, MoveDraw, Activate15, x278 y126 w59 h59
	GuiControl, MoveDraw, LeftPage, x0 y75 w49 h49
	GuiControl, MoveDraw, RightPage, x340 y75 w49 h49
	GuiControl, MoveDraw, MoveWindowUp, x-8 y0 w413 h23
	GuiControl, MoveDraw, MoveWindowDown, x0 y187 w401 h23
	Gui, Show, w385 h200, Nova Macros Client
}
DllCall("LockWindowUpdate", "UInt", 0)
if(InFolder)
{
	SetFolderPage(ButtonFolder, FolderPage)
}
else
{
	SetPage(PageNumber)
}
Return

MoveWindow:
PostMessage, 0xA1, 2,,, A 
Return

Button1:
PressButton(1)
return

Button2:
PressButton(2)
return

Button3:
PressButton(3)
return

Button4:
PressButton(4)
return

Button5:
PressButton(5)
return

Button6:
PressButton(6)
return

Button7:
PressButton(7)
return

Button8:
PressButton(8)
return

Button9:
PressButton(9)
return

Button10:
PressButton(10)
return

Button11:
PressButton(11)
return

Button12:
PressButton(12)
return

Button13:
PressButton(13)
return

Button14:
PressButton(14)
return

Button15:
PressButton(15)
return

PressButton(ButtonAPress)
{
	if(MoveMouseOnButtonPress)
		MouseMove, %Screen_Half_X%, %Screen_Half_Y%, 0
	AltTab()
	; Button Logic
	if(InFolder)
	{
		if(ButtonAPress != 15)
		{
			IdButton := ButtonFolder 15*FolderPage+ButtonAPress
			if GetKeyState("Control")
			{
				if GetKeyState("Shift")
				{
					SetImageButton(IdButton)
					return
				}
				MsgBox,,Button ID, Clicked button Id is: %IdButton%
				return
			}
			if GetKeyState("Alt")
			{
				;ChangeAlternativeImageButton(ButtonAPress, IdButton)
				return
			}
			if GetKeyState("Shift")
			{
				EditScriptButton(IdButton)
				return
			}
			i = 1
			while(i <= ButtonsFolders0)
			{
				ButtonIteration := ButtonsFolders%i%
				if(IdButton = ButtonIteration)
				{
					InFolder = 1
					ButtonFolder := FoldersButtons%i%
					global FolderPage := 0
					SetFolderPage(ButtonFolder, FolderPage)
					return
				}
				i++
			}
			j = 1
			while(j <= DualButtons0)
			{
				if(IdButton = DualButtons%j%)
				{
					if(DualButtonsStates[j] = 0)
					{
						IdVisual :=IdButton "Enabled"
						DualButtonsStates[j] := 1
					}
					else
					{
						IdVisual :=IdButton
						DualButtonsStates[j] := 0
					}
					Button%ButtonAPress% = 1
					ExecuteFunctionButton(ButtonAPress, IdVisual)
					return
				}
				j++
			}
			IdVisual := IdButton
			ExecuteFunctionButton(ButtonAPress, IdVisual)
		}
		else if (ButtonAPress = 15)
		{
			; Este es un caso especial ya que si está en carpeta siempre tiene el valor volver (salir fuera de la carpeta)
			IdButton := ButtonFolder 15*FolderPage+ButtonAPress
			SetPage(PageNumber)
			InFolder = 0
			FolderPage = 0
			return	
		}
	}
	else
	{
		IdButton := 15*PageNumber+ButtonAPress
		if GetKeyState("Control")
		{
			if GetKeyState("Shift")
			{
				SetImageButton(IdButton)
				return
			}
			MsgBox,,Button ID, Clicked button Id is: %IdButton%
			return
		}
		if GetKeyState("Alt")
		{
			;ChangeAlternativeImageButton(ButtonAPress, IdButton)
			return
		}
		if GetKeyState("Shift")
		{
			EditScriptButton(IdButton)
			return
		}
		i = 1
		while(i <= ButtonsFolders0)
		{
			ButtonIteration := ButtonsFolders%i%
			if(IdButton = ButtonIteration)
			{
				InFolder = 1
				ButtonFolder := FoldersButtons%i%
				global FolderPage := 0
				SetFolderPage(ButtonFolder, FolderPage)
				return
			}
			i++
		}
		j = 1
		while(j <= DualButtons0)
		{
			if(IdButton = DualButtons%j%)
			{
				if(DualButtonsStates[j] = 0)
				{
					IdVisual := IdButton "Enabled"
					DualButtonsStates[j] := 1
				}
				else
				{
					IdVisual := IdButton
					DualButtonsStates[j] := 0
				}
				Button%ButtonAPress% = 1
				ExecuteFunctionButton(ButtonAPress, IdVisual)
				return
			}
			j++
		}
		IdVisual := IdButton
		ExecuteFunctionButton(ButtonAPress, IdVisual)
	}
	Button%ButtonAPress% = 1
}

SetPage(PageNumber)
{
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	ButtonFolder := ""
	Button1Path := ButtonFolder 15*PageNumber+1 ".png"
	Button2Path := ButtonFolder 15*PageNumber+2 ".png"
	Button3Path := ButtonFolder 15*PageNumber+3 ".png"
	Button4Path := ButtonFolder 15*PageNumber+4 ".png"
	Button5Path := ButtonFolder 15*PageNumber+5 ".png"
	Button6Path := ButtonFolder 15*PageNumber+6 ".png"
	Button7Path := ButtonFolder 15*PageNumber+7 ".png"
	Button8Path := ButtonFolder 15*PageNumber+8 ".png"
	Button9Path := ButtonFolder 15*PageNumber+9 ".png"
	Button1Path0 := ButtonFolder 15*PageNumber+10 ".png"
	Button1Path1 := ButtonFolder 15*PageNumber+11 ".png"
	Button1Path2 := ButtonFolder 15*PageNumber+12 ".png"
	Button1Path3 := ButtonFolder 15*PageNumber+13 ".png"
	Button1Path4 := ButtonFolder 15*PageNumber+14 ".png"
	Button1Path5 := ButtonFolder 15*PageNumber+15 ".png"
	
	if(MiniClient)
	{
		RefreshMiniButtons()
	}
	else
	{
		RefreshButtons()
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

SetFolderPage(ButtonFolder, FolderPage)
{
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	Button1Path := ButtonFolder 15*FolderPage+1 ".png"
	Button2Path := ButtonFolder 15*FolderPage+2 ".png"
	Button3Path := ButtonFolder 15*FolderPage+3 ".png"
	Button4Path := ButtonFolder 15*FolderPage+4 ".png"
	Button5Path := ButtonFolder 15*FolderPage+5 ".png"
	Button6Path := ButtonFolder 15*FolderPage+6 ".png"
	Button7Path := ButtonFolder 15*FolderPage+7 ".png"
	Button8Path := ButtonFolder 15*FolderPage+8 ".png"
	Button9Path := ButtonFolder 15*FolderPage+9 ".png"
	Button1Path0 := ButtonFolder 15*FolderPage+10 ".png"
	Button1Path1 := ButtonFolder 15*FolderPage+11 ".png"
	Button1Path2 := ButtonFolder 15*FolderPage+12 ".png"
	Button1Path3 := ButtonFolder 15*FolderPage+13 ".png"
	Button1Path4 := ButtonFolder 15*FolderPage+14 ".png"
		
	if(MiniClient)
	{
		RefreshMiniButtons(true)
	}
	else
	{
		RefreshButtons(true)
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefreshButtons(isFolder = false)
{
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	GuiControl, Text, Button1, resources\img\%Button1Path%
	GuiControl, MoveDraw, Button1, x130 y50 w130 h130 ; When changing the path, you have to resize the button
	GuiControl, Text, Button2, resources\img\%Button2Path%
	GuiControl, MoveDraw, Button2, x290 y50 w130 h130
	GuiControl, Text, Button3, resources\img\%Button3Path%
	GuiControl, MoveDraw, Button3, x450 y50 w130 h130
	GuiControl, Text, Button4, resources\img\%Button4Path%
	GuiControl, MoveDraw, Button4, x610 y50 w130 h130
	GuiControl, Text, Button5, resources\img\%Button5Path%
	GuiControl, MoveDraw, Button5, x770 y50 w130 h130
	GuiControl, Text, Button6, resources\img\%Button6Path%
	GuiControl, MoveDraw, Button6, x130 w130 y230 h130
	GuiControl, Text, Button7, resources\img\%Button7Path%
	GuiControl, MoveDraw, Button7, x290 w130 y230 h130
	GuiControl, Text, Button8, resources\img\%Button8Path%
	GuiControl, MoveDraw, Button8, x450 w130 y230 h130
	GuiControl, Text, Button9, resources\img\%Button9Path%
	GuiControl, MoveDraw, Button9, x610 w130 y230 h130
	GuiControl, Text, Button10, resources\img\%Button1Path0%
	GuiControl, MoveDraw, Button10, x770 y230 w130 h130
	GuiControl, Text, Button11, resources\img\%Button1Path1%
	GuiControl, MoveDraw, Button11, x130 x130 y410 w130 h130
	GuiControl, Text, Button12, resources\img\%Button1Path2%
	GuiControl, MoveDraw, Button12, x290 y410 w130 h130
	GuiControl, Text, Button13, resources\img\%Button1Path3%
	GuiControl, MoveDraw, Button13, x450 y410 w130 h130
	GuiControl, Text, Button14, resources\img\%Button1Path4%
	GuiControl, MoveDraw, Button14, x610 y410 w130 h130
	if(isFolder)
	{
		GuiControl, Text, Button15, resources\img\Volver.png
		GuiControl, MoveDraw, Button15, x770 y410 w130 h130	
	}
	else
	{
		GuiControl, Text, Button15, resources\img\%Button1Path5%
		GuiControl, MoveDraw, Button15, x770 y410 w130 h130		
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefreshMiniButtons(isFolder = false)
{
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	GuiControl, Text, Button1, resources\img\%Button1Path%
	GuiControl, MoveDraw, Button1, x59 y19 w49 h49
	GuiControl, Text, Button2, resources\img\%Button2Path%
	GuiControl, MoveDraw, Button2, x115 y19 w49 h49
	GuiControl, Text, Button3, resources\img\%Button3Path%
	GuiControl, MoveDraw, Button3, x171 y19 w49 h49
	GuiControl, Text, Button4, resources\img\%Button4Path%
	GuiControl, MoveDraw, Button4, x227 y19 w49 h49
	GuiControl, Text, Button5, resources\img\%Button5Path%
	GuiControl, MoveDraw, Button5, x283 y19 w49 h49
	GuiControl, Text, Button6, resources\img\%Button6Path%
	GuiControl, MoveDraw, Button6, x59 y75 w49 h49
	GuiControl, Text, Button7, resources\img\%Button7Path%
	GuiControl, MoveDraw, Button7, x115 y75 w49 h49
	GuiControl, Text, Button8, resources\img\%Button8Path%
	GuiControl, MoveDraw, Button8, x171 y75 w49 h49
	GuiControl, Text, Button9, resources\img\%Button9Path%
	GuiControl, MoveDraw, Button9, x227 y75 w49 h49
	GuiControl, Text, Button10, resources\img\%Button1Path0%
	GuiControl, MoveDraw, Button10, x283 y75 w49 h49
	GuiControl, Text, Button11, resources\img\%Button1Path1%
	GuiControl, MoveDraw, Button11, x59 y131 w49 h49
	GuiControl, Text, Button12, resources\img\%Button1Path2%
	GuiControl, MoveDraw, Button12, x115 y131 w49 h49
	GuiControl, Text, Button13, resources\img\%Button1Path3%
	GuiControl, MoveDraw, Button13, x171 y131 w49 h49
	GuiControl, Text, Button14, resources\img\%Button1Path4%
	GuiControl, MoveDraw, Button14, x227 y131 w49 h49
	if(isFolder)
	{
		GuiControl, Text, Button15, resources\img\Volver.png
		GuiControl, MoveDraw, Button15, x283 y131 w49 h49
	}
	else
	{
		GuiControl, Text, Button15, resources\img\%Button1Path5%
		GuiControl, MoveDraw, Button15, x283 y131 w49 h49
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

LeftPage:
	if(MoveMouseOnButtonPress)
		MouseMove, %Screen_Half_X%, %Screen_Half_Y%, 0
	AltTab()
	if(InFolder)
	{
		if(FolderPage != 0)
		{
			if GetKeyState("Control")
			{
				if(FolderPage >= 10)
				{
					FolderPage := FolderPage - 10
					SetFolderPage(ButtonFolder, FolderPage)
				}
				return
			}
			FolderPage--
			SetFolderPage(ButtonFolder, FolderPage)
		}
	}
	else
	{
		if(PageNumber != 0)
		{
			if GetKeyState("Control")
			{
				if(PageNumber >= 10)
				{
					PageNumber := PageNumber - 10
					SetPage(PageNumber)
				}
			}
			else
			{
				PageNumber--
				SetPage(PageNumber)
			}
		}
	}
return

RightPage:
	if(MoveMouseOnButtonPress)
		MouseMove, %Screen_Half_X%, %Screen_Half_Y%, 0
	AltTab()
	if(InFolder)
	{
		if GetKeyState("Control")
		{
			FolderPage := FolderPage + 10
			SetFolderPage(ButtonFolder, FolderPage)
			return
		}
		FolderPage++
		SetFolderPage(ButtonFolder, FolderPage)
	}
	else
	{
		if GetKeyState("Control")
		{
			PageNumber := PageNumber + 10
		}
		else
		{
			PageNumber++
		}
		SetPage(PageNumber)
	}
return

SetImageButton(IdButton)
{
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Change Img
	MsgBoxBtn2 = Remove
	MsgBoxBtn3 = Cancel
	MsgBox 0x23, Change - Delete, Change Image or Remove Button?
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		FileSelectFile, ImagenASet, ,,,*.jpg; *.png; *.gif; *.jpeg; *.bmp; *.ico
		if ImagenASet =
			MsgBox, No image selected!
		else
		{
			FileCopy, %ImagenASet%, ./resources/img/%IdButton%.png, 1
		}
	} 
	Else IfMsgBox No, {
		FileDelete,./resources/img/%IdButton%.png
		OnMessage(0x44, "OnMsgBox")
		MsgBoxBtn1 = Delete
		MsgBoxBtn2 = Keep
		MsgBox 0x34, Overwrite?, This button has a macro file`, do you want to delete it?`n`nIts function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			FileDelete, %IdButton%.ahk
		}
	} 
	Else IfMsgBox Cancel, {
		return
	}	
	Sleep, 300
	if(InFolder)
	{
		SetFolderPage(ButtonFolder, FolderPage)
	}
	else
	{
		SetPage(PageNumber)	
	}
}

EditScriptButton(IdButton)
{
	if(!FileExist("./conf/ScriptEditorPath.txt") || !FileExist("./conf/ExtensionScripts.txt"))
	{
		MsgBox,,Script Editor, Select Script Editor Path
		gosub, ChangeEditorPath
	}
	else
	{
		if(PathEditorScripts = "")
		{
			FileReadLine,PathEditorScripts,./conf/ScriptEditorPath.txt,1
		}
		if(ExtensionScripts = "")
		{
			FileReadLine,ExtensionScripts,./conf/ExtensionScripts.txt,1
		}
		ScriptPath := "" IdButton "." ExtensionScripts ""
		if(!FileExist(ScriptPath))
		{
			FileAppend,,%ScriptPath%
		}
		Run, "%PathEditorScripts%" "%ScriptPath%"
	}
}

ChangeEditorPath:
; Path Editor
FileSelectFile, PathEditorScripts, ,,,*.exe
if PathEditorScripts =
	MsgBox, No executable selected!
else
{
	FileDelete, ./conf/ScriptEditorPath.txt
	FileAppend, %PathEditorScripts%`n, ./conf/ScriptEditorPath.txt
}
; Extension Scripts
InputBox, ExtensionScripts, Button Script EXT, Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`., , 500, 145,,,,,ahk
if ExtensionScripts =
	MsgBox, Couldn't retrieve the extension!
else
{
	FileDelete, ./conf/ExtensionScripts.txt
	FileAppend, %ExtensionScripts%`n, ./conf/ExtensionScripts.txt
}
return

GuiClose:
Exit:
	ExitApp

; HOTKEYS
; *******************************
~Right::
IfWinActive, Nova Macros Client
{
	gosub, RightPage
}
return

~Left::
IfWinActive, Nova Macros Client
{
	gosub, LeftPage
}
return

~^Right::
IfWinActive, Nova Macros Client
{
	gosub, RightPage ; Increase of 10 in 10
}
return

~^Left::
IfWinActive, Nova Macros Client
{
	gosub, LeftPage ; Decrease of 10 in 10
}
return

ExecuteFunctionButton(ButtonVisual, RunFile)
{
	Activation := "Activate" ButtonVisual
	GuiControl, Show, %Activation%
	try
	{
		Run, %RunFile%.%ExtensionScripts%
	}
	;ChangeAlternativeImageButton(ButtonVisual, RunFile)
	feedbackExecution.push(Activation)
	SetTimer, HideFeedbackExecution, 150
}

HideFeedbackExecution:
	if(feedbackExecution.length() = 1)
	{
		SetTimer, HideFeedbackExecution, Off
	}
	GuiControl, Hide, % feedbackExecution[1]
	feedbackExecution.remove(1)
return

ChangeAlternativeImageButton(ButtonVisual, NumberButton)
{ ; Deprecated, buttons will not have states at the moment
	ButtonPress := "Button" ButtonVisual
	if(VariableChangeImage = 0)
	{
		ImagePath := "resources\img\" NumberButton "Enabled.png"
		if FileExist(ImagePath)
		{
			GuiControl, Text, %ButtonPress%, %ImagePath%
			if(MiniClient)
			{
				GuiControl, MoveDraw, %ButtonPress%, w49 h49
			}
			else
			{
				GuiControl, MoveDraw, %ButtonPress%, w130 h130
			}
			VariableChangeImage := 1
		}
	}
	else
	{
		ImagePath := "resources\img\" NumberButton ".png"
		if FileExist(ImagePath)
		{
			GuiControl, Text, %ButtonPress%, %ImagePath%
			if(MiniClient)
			{
				GuiControl, MoveDraw, %ButtonPress%, w49 h49
			}
			else
			{
				GuiControl, MoveDraw, %ButtonPress%, w130 h130
			}
			VariableChangeImage := 0
		}
	}
	return
}

CreateFolderButton:
	InputBox, NewFolderName, Input Folder Name, Input the folder name WITHOUT spaces or weird symbols. Samples: (Programs`,GameFolder`,OBS_Buttons...)
	if(NewFolderName != "" && !Instr(NewFolderName, A_Space))
	{
		newFoldersButtons := "" ; Row 1: 1|5|25...
		newFoldersButtons := "" ; Row 2: OBS|Chrome|Prograplus...
		i = 1
		while(i <= ButtonsFolders0)
		{
			ButtonIteration := ButtonsFolders%i%
			ButtonFolder := FoldersButtons%i%
			newFoldersButtons := newFoldersButtons ButtonIteration "|"
			newFoldersButtons := newFoldersButtons ButtonFolder "|"
			i++
		}
		newFoldersButtons := newFoldersButtons ActiveButton
		newFoldersButtons := newFoldersButtons NewFolderName
		FileDelete, conf\FolderButtons.txt
		FileAppend, % newFoldersButtons "`n" newFoldersButtons, conf\FolderButtons.txt
		gosub, LoadButtonsFolder
	}
	else
	{
		MsgBox,,Error, Error while creating folder or cancelled.
	}
return

DeleteFolderButton:
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Delete
	MsgBoxBtn2 = Cancel
	MsgBox 0x34, Delete Folder?, If this button is a folder it may contain other buttons, delete it anyway?
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		newFoldersButtons := "" ; Row 1: 1|5|25...
		newFoldersButtons := "" ; Row 2: OBS|Chrome|Prograplus...
		i = 1
		while(i <= ButtonsFolders0)
		{
			ButtonIteration := ButtonsFolders%i%
			if(ActiveButton != ButtonIteration)
			{
				ButtonFolder := FoldersButtons%i%
				newFoldersButtons := newFoldersButtons ButtonIteration "|"
				newFoldersButtons := newFoldersButtons ButtonFolder "|"
			}
			i++
		}
		newFoldersButtons:=SubStr(newFoldersButtons,1,StrLen(newFoldersButtons)-1) ; Remove last |
		newFoldersButtons:=SubStr(newFoldersButtons,1,StrLen(newFoldersButtons)-1) ; Remove last |
		FileDelete, conf\FolderButtons.txt
		FileAppend, % newFoldersButtons "`n" newFoldersButtons, conf\FolderButtons.txt
		gosub, LoadButtonsFolder
	}else{
		return
	}	
return

DeleteButtonFunction:
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Delete
	MsgBoxBtn2 = Cancel
	MsgBox 0x34, Delete Function?, If this button has a function it will be deleted!
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		FileDelete, %ActiveButton%.ahk
	}
return

LoadButtonsFolder:
	;~ Load Buttons associated with folders
	NumberLoop := 1
	Loop, read, ./conf/FolderButtons.txt
	{
		StringSplit, LineArray, A_LoopReadLine, %A_Tab%
		if(NumberLoop == "1")
		{
			ButtonsFoldersRead := LineArray1
		}
		else if(NumberLoop == "2")
		{
			FoldersButtonsRead := LineArray1
		}
		NumberLoop++
	}
	StringSplit, ButtonsFolders, ButtonsFoldersRead, |,
	StringSplit, FoldersButtons, FoldersButtonsRead, |,
	global ButtonsFolders0
return

OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, % MsgBoxBtn1
        ControlSetText Button2, % MsgBoxBtn2
        ControlSetText Button3, % MsgBoxBtn3
        ControlSetText Button4, % MsgBoxBtn4
    }
}

AltTab(){
	global
	; Alt tab replacement, faster, less distracting
	if(SendAltTabOnButtonPress)
	{
		list := ""
		WinGet, id, list
		Loop, %id%
		{
			this_ID := id%A_Index%
			IfWinActive, ahk_id %this_ID%
				continue    
			WinGetTitle, title, ahk_id %this_ID%
			If (title = "")
				continue
			If (!IsWindow(WinExist("ahk_id" . this_ID))) 
				continue
			WinActivate, ahk_id %this_ID%, ,2
				break
		}
	}
}

; Check whether the target window is activation target
IsWindow(hWnd){
    WinGet, dwStyle, Style, ahk_id %hWnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
        return false
    }
    WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
    if (dwExStyle & 0x00000080) {
        return false
    }
    WinGetClass, szClass, ahk_id %hWnd%
    if (szClass = "TApplication") {
        return false
    }
    return true
}