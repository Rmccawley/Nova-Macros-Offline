; AHK Version ..: 1.1.32.0 (Unicode 32-bit)
; OS Version ...: Windows 10 (Previous versions tested working on Win7)
;@Ahk2Exe-SetName "Nova Macros Client" Offline
;@Ahk2Exe-SetDescription Nova Macros for local TouchScreen
;@Ahk2Exe-SetVersion 2.7-offline
;@Ahk2Exe-SetCopyright Copyright (c) 2023`, Rmccawley
;@Ahk2Exe-SetOrigFilename "Nova Macros Client" Offline.exe
;Notice: This document has been modified from the original work by Rmccawley 
; INITIALIZE
; *******************************
#Requires AutoHotkey v2.0
#warn all,off

Persistent
#SingleInstance
SetWorkingDir A_ScriptDir
DetectHiddenWindows True
CoordMode "Mouse", "Screen"
#Include <nm_msg>
global IsVisible := true
global InFolder := MoveMouseOnButtonPress := MiniClient := AlwaysVisible := SendAltTabOnButtonPress := false
global Variable, Valor, PreviousValue, RegisteredPrograms, AssociatedPages, DualButtons, ButtonFolder, FolderPage, PathEditorScripts, ExtensionScripts, ActiveButton, ButtonPressed, windowHandler
global VariableChangeImage := 0
global Button1Path, Button2Path, Button3Path, Button4Path, Button5Path, Button6Path, Button7Path, Button8Path, Button9Path, Button1Path0, Button1Path1, Button1Path2, Button1Path3, Button1Path4, Button1Path5
global DualButtonsStates := []
global feedbackExecution := []
global PageNumber := ProgressLoadingIcons := 0
global MsgBoxBtn1, MsgBoxBtn2, MsgBoxBtn3, MsgBoxBtn4
global Screen_Half_X := A_ScreenWidth / 2
global Screen_Half_Y := A_ScreenHeight / 2
global ClientVersion := "2.7 Offline"
DirCreate "conf"

if(!FileExist("./conf/ProgramPages.txt")){
	FileAppend "obs64.exe|explorer.exe|chrome.exe`n", "./conf/ProgramPages.txt"
	FileAppend 0|3|1, "./conf/ProgramPages.txt"
}

;~ Load Programs associated with pages
NumberLoop := 1
Loop read, "./conf/ProgramPages.txt"
{
    LineArray1:= StrSplit(A_LoopReadLine, A_Tab)[1]
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
RegisteredPrograms:= StrSplit(RegisteredProgramsRead, "|") ; I create the RegisteredPrograms array from the RegisteredProgramsRead string, separating elements by complus, RegisteredPrograms0 contains the element count, and RegisteredPrograms1, RegisteredPrograms2... are the fields of the array
AssociatedPages:= StrSplit(AssociatedPagesRead, "|")
global RegisteredPrograms0:= 0

if(!FileExist("./conf/FolderButtons.txt")){
	FileAppend "6|7`n", "./conf/FolderButtons.txt"
	FileAppend "UtilesStream|SoundsOBS", "./conf/FolderButtons.txt"
}

;~ Load Buttons associated with folders
NumberLoop := 1
Loop read, "./conf/FolderButtons.txt"{
    StrSplit(LineArray1, A_LoopReadLine, A_Tab)
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
ButtonsFolders:= StrSplit(ButtonsFoldersRead, "|")
FoldersButtons:= StrSplit(FoldersButtonsRead, "|")
global ButtonsFolders0 := 0

if(!FileExist("./conf/DualButtons.txt")){
	FileAppend "4|5`n", "./conf/DualButtons.txt"
	FileAppend "4Enabled|5Enabled", "./conf/DualButtons.txt"
}

;~ Load Dual Buttons
NumberLoop := 1
Loop read, "./conf/DualButtons.txt"
{
    StrSplit(LineArray1, A_LoopReadLine, A_Tab)
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
DualButtons:= StrSplit(DualButtonsRead, "|")
DualActionsRead:= StrSplit(DualActionsRead, "|")
global DualButtons0:= 0 ; Set the dual buttons to 0

i := 1
while(i <= DualButtons0){
	DualButtonsStates.Push(0)
	i++
}

if(!FileExist("./conf/ExtensionScripts.txt")){
	; Extension Scripts
	InputBox("Button Script EXT, Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`.", ExtensionScripts, "W500 H145","ahk")
	if ExtensionScripts{
		MsgBox "Couldn't retrieve the extension!"
	}
	else{
		FileDelete "./conf/ExtensionScripts.txt"
		FileAppend("%ExtensionScripts%`n", "./conf/ExtensionScripts.txt")
	}
}
else{
	if(ExtensionScripts := "")
	{
		; ExtensionScripts:= FileReadLine("./conf/ExtensionScripts.txt",1)
	}
}

; TRAY MENU
; *******************************
tray:= Menu()
tray.add("Hide", ToggleHide)
tray.add("Set Editor Path", ChangeEditorPath)
tray.add

; GENERIC CONTEXT MENU
; *******************************
GenericContextMenu:= Menu()
GenericContextMenu.Add("Always on Top", ToggleAlwaysVisible)
GenericContextMenu.UnCheck("Always on Top")
GenericContextMenu.Add("Center Mouse after Activation", MoveMouseToggleButtonPress)
GenericContextMenu.UnCheck("Center Mouse after Activation")
GenericContextMenu.Add("Send Alt+Tab after Activation", SendAltTabOnToggleButtonPress)
GenericContextMenu.UnCheck("Send Alt+Tab after Activation")
GenericContextMenu.Add("Progressive Icon Loading", ProgressLoadingIconsToggle)
GenericContextMenu.UnCheck("Progressive Icon Loading")
GenericContextMenu.Add("Mini Client", ChangeDimensionsClient)
GenericContextMenu.UnCheck("Mini Client")

; CONTEXT MENU BUTTONS
; *******************************
scriptGenerator:= Menu()
scriptGenerator.Add("Run File", ScriptGenerator_RunFile)
scriptGenerator.SetIcon("Run File", "shell32.dll", 25)
scriptGenerator.Add("Run Cmd", ScriptGenerator_RunCmd)
scriptGenerator.SetIcon("Run Cmd", "imageres.dll", 263)
scriptGenerator.Add("Send Text", ScriptGenerator_SendText)
scriptGenerator.SetIcon("Send Text", "shell32.dll", 71)
scriptGenerator.Add("Hotkey - Macro", ScriptGenerator_Hotkey)
scriptGenerator.SetIcon("Hotkey - Macro", "imageres.dll", 174)

MultimediaFunctions:= Menu()
MultimediaFunctions.Add("Play / Pause", ScriptGenerator_Multimedia_PlayPause)
MultimediaFunctions.SetIcon("Play / Pause", "imageres.dll", 62)
MultimediaFunctions.Add("Stop", ScriptGenerator_Multimedia_Stop)
MultimediaFunctions.SetIcon("Stop", "imageres.dll", 62)
MultimediaFunctions.Add("Previous", ScriptGenerator_Multimedia_Previous)
MultimediaFunctions.SetIcon("Previous", "imageres.dll", 62)
MultimediaFunctions.Add("Next", ScriptGenerator_Multimedia_Next)
MultimediaFunctions.SetIcon("Next", "imageres.dll", 62)
MultimediaFunctions.Add("Volume +", ScriptGenerator_Multimedia_MoreVolume)
MultimediaFunctions.SetIcon("Volume +", "imageres.dll", 62)
MultimediaFunctions.Add("Volume -", ScriptGenerator_Multimedia_LessVolume)
MultimediaFunctions.SetIcon("Volume -", "imageres.dll", 62)
MultimediaFunctions.Add("Mute / Unmute", ScriptGenerator_Multimedia_Mute)
MultimediaFunctions.SetIcon("Mute / Unmute", "imageres.dll", 62)

QuickActionsMenu:= Menu()
QuickActionsMenu.Add("Close Window", ScriptGenerator_QuickActions_CloseWindow)
QuickActionsMenu.SetIcon("Close Window", "imageres.dll", 236)
QuickActionsMenu.Add("Maximize Window", ScriptGenerator_QuickActions_Maximize)
QuickActionsMenu.SetIcon("Maximize Window", "imageres.dll", 287)
QuickActionsMenu.Add("Minimize Window", ScriptGenerator_QuickActions_Minimize)
QuickActionsMenu.SetIcon("Minimize Window", "imageres.dll", 17)
QuickActionsMenu.Add("Show Desktop", ScriptGenerator_QuickActions_ShowDesktop)
QuickActionsMenu.SetIcon("Show Desktop", "imageres.dll", 106)
QuickActionsMenu.Add("New Explorer Window", ScriptGenerator_QuickActions_NewExplorer)
QuickActionsMenu.SetIcon("New Explorer Window", "imageres.dll", 5)
QuickActionsMenu.Add("New Folder", ScriptGenerator_QuickActions_NewFolder)
QuickActionsMenu.SetIcon("New Folder", "shell32.dll", 280)
QuickActionsMenu.Add("Quick Rename File", ScriptGenerator_QuickActions_QuickRename)
QuickActionsMenu.SetIcon("Quick Rename File", "shell32.dll", 134)
QuickActionsMenu.Add("Lock PC", ScriptGenerator_QuickActions_LockPC)
QuickActionsMenu.SetIcon("Lock PC", "shell32.dll", 45)
QuickActionsMenu.Add("Shutdown PC", ScriptGenerator_QuickActions_Shutdown)
QuickActionsMenu.SetIcon("Shutdown PC", "shell32.dll", 28)
QuickActionsMenu.Add("System Info", ScriptGenerator_QuickActions_SystemInfo)
QuickActionsMenu.SetIcon("System Info", "shell32.dll", 24)
QuickActionsMenu.Add("System FULL Info", ScriptGenerator_QuickActions_FullSystemInfo)
QuickActionsMenu.SetIcon("System FULL Info", "shell32.dll", 22)
QuickActionsMenu.Add("cmd.exe", ScriptGenerator_QuickActions_Cmd)
QuickActionsMenu.SetIcon("cmd.exe", "imageres.dll", 263)
QuickActionsMenu.Add("PowerShell", ScriptGenerator_QuickActions_PowerShell)
QuickActionsMenu.SetIcon("PowerShell", "imageres.dll", 312)
QuickActionsMenu.Add("Take Screenshot", ScriptGenerator_QuickActions_ScreenShot)
QuickActionsMenu.SetIcon("Take Screenshot", "imageres.dll", 68)
QuickActionsMenu.Add("Snip img from screen", ScriptGenerator_QuickActions_SnipImage)
QuickActionsMenu.SetIcon("Snip img from screen", "imageres.dll", 17)
QuickActionsMenu.Add("Windows Gaming Panel", ScriptGenerator_QuickActions_GamePanel)
QuickActionsMenu.SetIcon("Windows Gaming Panel", "imageres.dll", 305)

WebBrowserCommands:= Menu()
WebBrowserCommands.Add("Next Tab", ScriptGenerator_WebBrowser_NextTab)
WebBrowserCommands.SetIcon("Next Tab", "shell32.dll", 15)
WebBrowserCommands.Add("Previous Tab", ScriptGenerator_WebBrowser_PreviousTab)
WebBrowserCommands.SetIcon("Previous Tab", "shell32.dll", 15)
WebBrowserCommands.Add("New Tab", ScriptGenerator_WebBrowser_NewTab)
WebBrowserCommands.SetIcon("New Tab", "shell32.dll", 15)
WebBrowserCommands.Add("New Window", ScriptGenerator_WebBrowser_NewWindow)
WebBrowserCommands.SetIcon("New Window", "shell32.dll", 15)
WebBrowserCommands.Add("Close Tab", ScriptGenerator_WebBrowser_CloseTab)
WebBrowserCommands.SetIcon("Close Tab", "shell32.dll", 15)
WebBrowserCommands.Add("Restore Closed Tab", ScriptGenerator_WebBrowser_RestoreTab)
WebBrowserCommands.SetIcon("Restore Closed Tab", "shell32.dll", 15)
WebBrowserCommands.Add("Chrome Private Window (NEW)", ScriptGenerator_WebBrowser_ChromePrivWindow)
WebBrowserCommands.SetIcon("Chrome Private Window (NEW)", "shell32.dll", 15)

FunctionKeysMenu:= Menu()
FunctionKeysMenu.Add("F13", ScriptGenerator_FunctionKeys_F13)
FunctionKeysMenu.SetIcon("F13", "imageres.dll", 174)
FunctionKeysMenu.Add("F14", ScriptGenerator_FunctionKeys_F14)
FunctionKeysMenu.SetIcon("F14", "imageres.dll", 174)
FunctionKeysMenu.Add("F15", ScriptGenerator_FunctionKeys_F15)
FunctionKeysMenu.SetIcon("F15", "imageres.dll", 174)
FunctionKeysMenu.Add("F16", ScriptGenerator_FunctionKeys_F16)
FunctionKeysMenu.SetIcon("F16", "imageres.dll", 174)
FunctionKeysMenu.Add("F17", ScriptGenerator_FunctionKeys_F17)
FunctionKeysMenu.SetIcon("F17", "imageres.dll", 174)
FunctionKeysMenu.Add("F18", ScriptGenerator_FunctionKeys_F18)
FunctionKeysMenu.SetIcon("F18", "imageres.dll", 174)
FunctionKeysMenu.Add("F19", ScriptGenerator_FunctionKeys_F19)
FunctionKeysMenu.SetIcon("F19", "imageres.dll", 174)
FunctionKeysMenu.Add("F20", ScriptGenerator_FunctionKeys_F20)
FunctionKeysMenu.SetIcon("F20", "imageres.dll", 174)
FunctionKeysMenu.Add("F21", ScriptGenerator_FunctionKeys_F21)
FunctionKeysMenu.SetIcon("F21", "imageres.dll", 174)
FunctionKeysMenu.Add("F22", ScriptGenerator_FunctionKeys_F22)
FunctionKeysMenu.SetIcon("F22", "imageres.dll", 174)
FunctionKeysMenu.Add("F23", ScriptGenerator_FunctionKeys_F23)
FunctionKeysMenu.SetIcon("F23", "imageres.dll", 174)
FunctionKeysMenu.Add("F24", ScriptGenerator_FunctionKeys_F24)
FunctionKeysMenu.SetIcon("F24", "imageres.dll", 174)

scriptGenerator.Add("Multimedia", MultimediaFunctions)
scriptGenerator.SetIcon("Multimedia", "imageres.dll", 19)
scriptGenerator.Add("Web Browser", WebBrowserCommands)
scriptGenerator.SetIcon("Web Browser", "shell32.dll", 221)
scriptGenerator.Add("Quick Actions", QuickActionsMenu)
scriptGenerator.SetIcon("Quick Actions", "imageres.dll", 293)
scriptGenerator.Add("Hidden Function Keys (F13-F24)", FunctionKeysMenu)
scriptGenerator.SetIcon("Hidden Function Keys (F13-F24)", "imageres.dll", 174)

ContextMenu:= Menu()
ContextMenu.Add("Edit Script`tShift + Click", GuiEditScript)
ContextMenu.SetIcon("Edit Script`tShift + Click", "shell32.dll", 85)
ContextMenu.Add("Script Generator`tAlt + Right Click", scriptGenerator)
ContextMenu.SetIcon("Script Generator`tAlt + Right Click", "shell32.dll", 22)
ContextMenu.Add("Change/Del Image`tCtrl + Shift + Click", GuiChangeImageButton)
ContextMenu.SetIcon("Change/Del Image`tCtrl + Shift + Click", "shell32.dll", 142)
ContextMenu.Add("Button Name`tCtrl + Click", GuiInfoButton)
ContextMenu.SetIcon("Button Name`tCtrl + Click", "shell32.dll", 24)
ContextMenu.Add("Create Folder Button", CreateFolderButton)
ContextMenu.SetIcon("Create Folder Button", "shell32.dll", 280)
ContextMenu.Add("Delete Folder Button", DeleteFolderButton)
ContextMenu.SetIcon("Delete Folder Button", "shell32.dll", 235)
ContextMenu.Add("Delete Button Function", DeleteButtonFunction)
ContextMenu.SetIcon("Delete Button Function", "shell32.dll", 132)

; GUI
; *******************************
MainWindow:= Gui()
MainWindow.BackColor:= 282828
MainWindow.Opt("+LastFound +ToolWindow +E0x02000000 +E0x00080000")
; Row1
Button1Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\1.png")
Button1Picture.OnEvent("Click", PressButton)
Button2Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\2.png")
Button2Picture.OnEvent("Click", PressButton)
Button3Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\3.png")
Button3Picture.OnEvent("Click", PressButton)
Button4Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\4.png")
Button4Picture.OnEvent("Click", PressButton)
Button5Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\5.png")
Button5Picture.OnEvent("Click", PressButton)
; Row2
Button6Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\6.png")
Button6Picture.OnEvent("Click", PressButton)
Button7Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\7.png")
Button7Picture.OnEvent("Click", PressButton)
Button8Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\8.png")
Button8Picture.OnEvent("Click", PressButton)
Button9Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\9.png")
Button9Picture.OnEvent("Click", PressButton)
Button10Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\10.png")
Button10Picture.OnEvent("Click", PressButton)
; Row3
Button11Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\11.png")
Button11Picture.OnEvent("Click", PressButton)
Button12Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\12.png")
Button12Picture.OnEvent("Click", PressButton)
Button13Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\13.png")
Button13Picture.OnEvent("Click", PressButton)
Button14Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\14.png")
Button14Picture.OnEvent("Click", PressButton)
Button15Picture:= MainWindow.AddPicture("+BackgroundTrans", "resources\img\15.png")
Button15Picture.OnEvent("Click", PressButton)
; Backgrounds Activations Buttons
; Activate1:= MainWindow.AddPicture("Hidden x120 y40 w150 h150", "resources\img\FondoActivation.png")
; Activate2:= MainWindow.AddPicture("Hidden x280 y40 w150 h150", "resources\img\FondoActivation.png")
; Activate3:= MainWindow.AddPicture("Hidden x440 y40 w150 h150", "resources\img\FondoActivation.png")
; Activate4:= MainWindow.AddPicture("Hidden x600 y40 w150 h150", "resources\img\FondoActivation.png")
; Activate5:= MainWindow.AddPicture("Hidden x760 y40 w150 h150", "resources\img\FondoActivation.png")
; Activate6:= MainWindow.AddPicture("Hidden x120 y220 w150 h150", "resources\img\FondoActivation.png")
; Activate7:= MainWindow.AddPicture("Hidden x280 y220 w150 h150", "resources\img\FondoActivation.png")
; Activate8:= MainWindow.AddPicture("Hidden x440 y220 w150 h150", "resources\img\FondoActivation.png")
; Activate9:= MainWindow.AddPicture("Hidden x600 y220 w150 h150", "resources\img\FondoActivation.png")
; Activate10:= MainWindow.AddPicture("Hidden x760 y220 w150 h150", "resources\img\FondoActivation.png")
; Activate11:= MainWindow.AddPicture("Hidden x120 y400 w150 h150", "resources\img\FondoActivation.png")
; Activate12:= MainWindow.AddPicture("Hidden x280 y400 w150 h150", "resources\img\FondoActivation.png")
; Activate13:= MainWindow.AddPicture("Hidden x440 y400 w150 h150", "resources\img\FondoActivation.png")
; Activate14:= MainWindow.AddPicture("Hidden x600 y400 w150 h150", "resources\img\FondoActivation.png")
; Activate15:= MainWindow.AddPicture("Hidden x760 y400 w150 h150", "resources\img\FondoActivation.png")
; Buttons Page
RightPagePicture:= MainWindow.AddPicture("+BackgroundTrans x910 y240 w130 h130", "resources\img\RightPage.png").OnEvent("Click", RightPage)
LeftPagePicture:= MainWindow.AddPicture("+BackgroundTrans x0 y240 w130 h130", "resources\img\LeftPage.png").OnEvent("Click", LeftPage)
; Background and sections move
MainWindow.AddPicture("x0 y0 w1024 h600", "resources\img\background.jpg")
MoveWindowUp:= MainWindow.AddText("x0 y0 w1024 h50 cWhite Center ", "").OnEvent("Click", MoveWindow) ; Move window up
MoveWindowDown:= MainWindow.AddText("x0 y570 w1024 h50 cWhite Center ", "").OnEvent("Click", MoveWindow) ; Move window down
SetPage(0)
MainWindow.Title:= "Nova Macros Client"
MainWindow.Show("w1024 h600")
return

; LABELS BUTTONS AND GENERAL FUNCTIONS
; *******************************
Show(){
	if WinExist("Nova Macros Client"){
		WinHide "Nova Macros Client"
	}
	return
}

ToggleHide(*){
	if IsVisible{
		WinHide "Nova Macros Client"
		tray.Rename("Hide", "Show")
		global IsVisible:= 0
	}
	else{
		WinShow "Nova Macros Client"
		WinActivate "Nova Macros Client"
		tray.Rename("Show", "Hide")
		global IsVisible:= 1
	}
	return
}

; GuiContextMenu(){
; 	if GetKeyState("Alt")
; 		scriptGen := 1
; 	else
; 		scriptGen := 0

; 	if A_GuiControl In (Button1,Button2,Button3,Button4,Button5,Button6,Button7,Button8,Button9,Button10,Button11,Button12,Button13,Button14,Button15){
; 		ButtonPressed:= StrReplace(A_GuiControl button,) TODO
; 		if (InFolder){
; 			ActiveButton := ButtonFolder 15*FolderPage+ButtonPressed
; 		}
; 		else{
; 			ActiveButton := 15*PageNumber+ButtonPressed
; 		}
; 		if (scriptGen){
; 			KeyWait "{Alt}"
; 			scriptGenerator Show
; 		}
; 		else{
; 			ContextMenu Show
; 		}
; 	}
; 	else{
; 		GenericContextMenu.Add(Show)
; 	}
; 	return
; }

GuiEditScript(*){
	EditScriptButton(ActiveButton)
	return
}

GuiChangeImageButton(*){
	SetImageButton(ActiveButton)
	return
}

GuiInfoButton(*){
	MsgBox("Clicked button Id is: " . ActiveButton, "Button ID")
	return
}

ScriptGenerator_RunFile(*){
	Run "lib\script_generator\RunFile.ahk" %ActiveButton%
	return
}

ScriptGenerator_RunCmd(*){
	Run "lib\script_generator\RunCmd.ahk" %ActiveButton%
	return
}

ScriptGenerator_SendText(*){
	Run "lib\script_generator\SendTextBlock.ahk" %ActiveButton%
	return
}

ScriptGenerator_Hotkey(*){
	Run "lib\script_generator\HotkeyCreator.ahk" %ActiveButton%
	return
}

ScriptGenerator_Multimedia_PlayPause(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_PlayPause.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_Multimedia_Stop(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Stop.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_Multimedia_Next(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Next.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_Multimedia_Previous(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Previous.ahk", ActiveButton ".ahk",1)
	return
}

ScriptGenerator_Multimedia_MoreVolume(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_MoreVolume.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_Multimedia_LessVolume(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_LessVolume.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_Multimedia_Mute(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Mute.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F13(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F13.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F14(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F14.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F15(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F15.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F16(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F16.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F17(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F17.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F18(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F18.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F19(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F19.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F20(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F20.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F21(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F21.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F22(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F22.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F23(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F23.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_FunctionKeys_F24(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F24.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_NextTab(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NextTab.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_PreviousTab(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_PreviousTab.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_NewTab(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewTab.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_NewWindow(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewWindow.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_CloseTab(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_CloseTab.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_RestoreTab(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_RestoreTab.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_WebBrowser_ChromePrivWindow(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_ChromePrivWindow.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_CloseWindow(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_CloseWindow.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_Maximize(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Maximize.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_Minimize(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Minimize.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_ShowDesktop(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ShowDesktop.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_NewExplorer(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewExplorer.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_NewFolder(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewFolder.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_QuickRename(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_QuickRename.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_LockPC(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_LockPC.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_Shutdown(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Shutdown.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_SystemInfo(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SystemInfo.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_FullSystemInfo(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_FullSystemInfo.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_Cmd(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Cmd.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_PowerShell(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_PowerShell.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_ScreenShot(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ScreenShot.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_SnipImage(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SnipImage.ahk", ActiveButton . ".ahk",1)
	return
}

ScriptGenerator_QuickActions_GamePanel(*){
	if(ButtonExists())
		FileCopy("lib\script_generator\code_snippets\ScriptGenerator_QuickActions_GamePanel.ahk", ActiveButton . ".ahk",1)
	return
}

NotImplemented(){
	MsgBox Not "implemented"
return
}

ButtonExists(){
	buttonPath := "" ActiveButton ".ahk"
	if FileExist(buttonPath){
		OnMessage(0x44, "OnMsgBox")
		Global MsgBoxBtn1 := "Overwrite"
		Global MsgBoxBtn2 := "Cancel"
		ButtonExists:= MsgBox("This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!", "Overwrite?", 0x34)
		OnMessage(0x44, "")

		If ButtonExists "Yes"{
			return 1
		}else{
			return 0
		}
	}
	else{
		return 1
	}
}

ToggleAlwaysVisible(*){
	if(AlwaysVisible){
		WinSetAlwaysOnTop False, "A"
		AlwaysVisible := 0
		GenericContextMenu.UnCheck("Always on Top")
	}
	else{
		WinSetAlwaysOnTop , "A"
		AlwaysVisible := 1
		GenericContextMenu.Check("Always on Top")
	}
	return
}

MoveMouseToggleButtonPress(*){
	if(MoveMouseOnButtonPress){
		MoveMouseOnButtonPress := 0
		GenericContextMenu.UnCheck("Center Mouse after Activation")
	}
	else{
		MoveMouseOnButtonPress := 1
		GenericContextMenu.Check("Center Mouse after Activation")
	}
	return
}

SendAltTabOnToggleButtonPress(*){
	if(SendAltTabOnButtonPress){
		SendAltTabOnButtonPress := 0
		GenericContextMenu.UnCheck("Send Alt+Tab after Activation")
	}
	else{
		SendAltTabOnButtonPress := 1
		GenericContextMenu.AddCheck("Send Alt+Tab after Activation")
	}
	return
}

ProgressLoadingIconsToggle(*){
	if(ProgressLoadingIcons){
		ProgressLoadingIcons := 0
		GenericContextMenu.UnCheck("Progressive Icon Loading")
	}
	else{
		ProgressLoadingIcons := 1
		GenericContextMenu.AddCheck("Progressive Icon Loading")
	}
	return
}
 
ChangeDimensionsClient(*){
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	if MiniClient{
		GenericContextMenu.Rename("Normal Client", "Mini Client")
		MiniClient := 0
		; Activate1.Move(120, 40, 150, 150)
		; Activate2.Move(280, 40, 150, 150)
		; Activate3.Move(440, 40, 150, 150)
		; Activate4.Move(600, 40, 150, 150)
		; Activate5.Move(760, 40, 150, 150)
		; Activate6.Move(120, 220, 150, 150)
		; Activate7.Move(280, 220, 150, 150)
		; Activate8.Move(440, 220, 150, 150)
		; Activate9.Move(600, 220, 150, 150)
		; Activate10.Move(760, 220, 150, 150)
		; Activate11.Move(120, 400, 150, 150)
		; Activate12.Move(280, 400, 150, 150)
		; Activate13.Move(440, 400, 150, 150)
		; Activate14.Move(600, 400, 150, 150)
		; Activate15.Move(760, 400, 150, 150)
		LeftPage.Move(0 230, 130, 130)
		RightPage.Move(910, 230, 130, 130)
		MoveWindowUp.Move(0, 0, 1024, 50)
		MoveWindowDown.Move(0, 570, 1024, 50)
		MainWindow.Title:= "Nova Macros Client"
		MainWindow.Show("w1024 h600")
	}
	else{
		GenericContextMenu.Rename("Mini Client", "Normal Client")
		MiniClient := 1
		; Activate1.Move(54, 14, 59, 59)
		; Activate2.Move(110, 14, 59, 59)
		; Activate3.Move(166, 14, 59, 59)
		; Activate4.Move(222, 14, 59, 59)
		; Activate5.Move(278, 14, 59, 59)
		; Activate6.Move(54, 70, 59, 59)
		; Activate7.Move(110, 70, 59, 59)
		; Activate8.Move(166, 70, 59, 59)
		; Activate9.Move(222, 70, 59, 59)
		; Activate10.Move(278, 70, 59, 59)
		; Activate11.Move(54, 126, 59, 59)
		; Activate12.Move(110, 126, 59, 59)
		; Activate13.Move(166, 126, 59, 59)
		; Activate14.Move(222, 126, 59, 59)
		; Activate15.Move(278, 126, 59, 59)
		LeftPage.Move(0, 75, 49, 49)
		RightPage.Move(340, 75, 49, 49)
		MoveWindowUp.Move(-8, 0, 413, 23)
		MoveWindowDown.Move(0, 187, 401, 23)
		MainWindow.Title:= "Nova Macros Client"
		MainWindow.Show("w385 h200")
	}
	DllCall("LockWindowUpdate", "UInt", 0)
	if(InFolder){
		SetFolderPage(ButtonFolder, FolderPage)
	}
	else{
		SetPage(PageNumber)
	}
	return
}

MoveWindow(*){
	PostMessage(0xA1, 2,,, "A")
	return
}

PressButton(ButtonPressed, Info){
	if(MoveMouseOnButtonPress)
		MouseMove(%Screen_Half_X%, %Screen_Half_Y%, 0)
	AltTab()
	; Button Logic
	if(InFolder){
		if(ButtonPressed != 15){
			IdButton := ButtonFolder 15*FolderPage+ButtonPressed
			;Show button ID
			if GetKeyState("Control"){ 
				if GetKeyState("Shift"){
					SetImageButton(ButtonPressed.Name)
					return
				}
				MsgBox("Clicked button Id is: " . ButtonPressed.Name, "Button ID")
				return
			}
			if GetKeyState("Alt"){
				;ChangeAlternativeImageButton(ButtonPressed, ButtonPressed.Name)
				return
			}
			;Edit script tied to button
			if GetKeyState("Shift"){
				EditScriptButton(ButtonPressed.Name)
				return
			}
			; 
			i := 1
			while(i <= ButtonsFolders0){
				ButtonIteration := ButtonsFolders%i%
				if(ButtonPressed.Name = ButtonIteration){
					global InFolder := 1
					ButtonFolder := FoldersButtons%i%
					global FolderPage := 0
					SetFolderPage(ButtonFolder, FolderPage)
					return
				}
				i++
			}
			j := 1
			while(j <= DualButtons0){
				if(ButtonPressed.Name = DualButtons%j%){
					if(DualButtonsStates[j] := 0){
						IdVisual :=ButtonPressed.Name "Enabled"
						DualButtonsStates[j] := 1
					}
					else{
						IdVisual :=ButtonPressed.Name
						DualButtonsStates[j] := 0
					}
					Button%ButtonPressed% := 1
					ExecuteFunctionButton(ButtonPressed, IdVisual)
					return
				}
				j++
			}
			IdVisual := ButtonPressed.Name
			ExecuteFunctionButton(ButtonPressed, IdVisual)
		}
		else if (ButtonPressed := 15){
; This is a special case since if it is in a folder it always has the value return (exit outside the folder).
			ButtonPressed.Name := ButtonFolder 15*FolderPage+ButtonPressed
			SetPage(PageNumber)
			global InFolder := 0
			FolderPage := 0
			return	
		}
	}
	else{
		IdButton := 15*PageNumber+ButtonPressed
		if GetKeyState("Control"){
			if GetKeyState("Shift"){
				SetImageButton(ButtonPressed.Name)
				return
			}
			MsgBox("Clicked button Id is: " . ButtonPressed.Name ,"Button ID")
			return
		}
		if GetKeyState("Alt"){
			;ChangeAlternativeImageButton(ButtonPressed, ButtonPressed.Name)
			return
		}
		if GetKeyState("Shift"){
			EditScriptButton(ButtonPressed.Name)
			return
		}
		; Index though folders
		i := 1
		while(i <= ButtonsFolders0){
			ButtonIteration := ButtonsFolders%i%
			if(ButtonPressed.Name = ButtonIteration){
				global InFolder := 1
				ButtonFolder := FoldersButtons%i%
				global FolderPage := 0
				SetFolderPage(ButtonFolder, FolderPage)
				return
			}
			i++
		}
		j := 1
		while(j <= DualButtons0){
			if(IdButton = DualButtons%j%){
				if(DualButtonsStates[j] := 0){
					IdVisual := ButtonPressed.Name "Enabled"
					DualButtonsStates[j] := 1
				}
				else{
					IdVisual := ButtonPressed.Name
					DualButtonsStates[j] := 0
				}
				Button%ButtonPressed% := 1
				ExecuteFunctionButton(ButtonPressed, IdVisual)
				return
			}
			j++
		}
		IdVisual := ButtonPressed.Name
		ExecuteFunctionButton(ButtonPressed, IdVisual)
	}
	Button%ButtonPressed% := 1
}

SetPage(PageNumber){
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", MainWindow.Hwnd)
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
	
	if(MiniClient){
		RefreshMiniButtons()
	}
	else{
		RefreshButtons()
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

SetFolderPage(ButtonFolder, FolderPage){
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
		
	if(MiniClient){
		RefreshMiniButtons(true)
	}
	else{
		RefreshButtons(true)
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefreshButtons(isFolder := false){
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", MainWindow.Hwnd)
	Button1Picture.Text:= "resources\img\%Button1Path%"
	Button1Picture.Move(130, 50, 130, 130) ; When changing the path, you have to resize the button
	Button2Picture.Text:= "resources\img\%Button2Path%"
	Button2Picture.Move(290, 50, 130, 130)
	Button3Picture.Text:= "resources\img\%Button3Path%"
	Button3Picture.Move(450, 50, 130, 130)
	Button4Picture.Text:= "resources\img\%Button4Path%"
	Button4Picture.Move(610, 50, 130, 130)
	Button5Picture.Text:= "resources\img\%Button5Path%"
	Button5Picture.Move(770, 50, 130, 130)
	Button6Picture.Text:= "resources\img\%Button6Path%"
	Button6Picture.Move(130, 130, 230, 130)
	Button7Picture.Text:= "resources\img\%Button7Path%"
	Button7Picture.Move(290, 130, 230, 130)
	Button8Picture.Text:= "resources\img\%Button8Path%"
	Button8Picture.Move(450, 130, 230, 130)
	Button9Picture.Text:= "resources\img\%Button9Path%"
	Button9Picture.Move(610, 130, 230, 130)
	Button10Picture.Text:= "resources\img\%Button1Path0%"
	Button10Picture.Move(770, 230, 130, 130)
	Button11Picture.Text:= "resources\img\%Button1Path1%"
	Button11Picture.Move(130, 130, 410, 130)
	Button12Picture.Text:= "resources\img\%Button1Path2%"
	Button12Picture.Move(290, 410, 130, 130)
	Button13Picture.Text:= "resources\img\%Button1Path3%"
	Button13Picture.Move(450, 410, 130, 130)
	Button14Picture.Text:= "resources\img\%Button1Path4%"
	Button14Picture.Move(610, 410, 130, 130)
	if(isFolder){
		Button15Picture.Text:= "resources\img\Volver.png"
		Button15Picture.Move(770, 410, 130, 130)	
	}
	else{
		Button15Picture.Text:= "resources\img\%Button1Path5%"
		Button15Picture.Move(770, 410, 130, 130)	
	}
	WinRedraw(MainWindow.Title)
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefreshMiniButtons(isFolder := false){
	global
	if(!ProgressLoadingIcons)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	Button1Picture.Text:= "resources\img\%Button1Path%"
	Button1.Move(59, 19, 49, 49)
	Button2Picture.Text:= "resources\img\%Button2Path%"
	Button2.Move(115, 19, 49, 49)
	Button3Picture.Text:= "resources\img\%Button3Path%"
	Button3.Move(171, 19, 49, 49)
	Button4Picture.Text:= "resources\img\%Button4Path%"
	Button4.Move(227, 19, 49, 49)
	Button5Picture.Text:= "resources\img\%Button5Path%"
	Button5.Move(283, 19, 49, 49)
	Button6Picture.Text:= "resources\img\%Button6Path%"
	Button6.Move(59, 75, 49, 49)
	Button7Picture.Text:= "resources\img\%Button7Path%"
	Button7.Move(115, 75, 49, 49)
	Button8Picture.Text:= "resources\img\%Button8Path%"
	Button8.Move(171, 75, 49, 49)
	Button9Picture.Text:= "resources\img\%Button9Path%"
	Button9.Move(227, 75, 49, 49)
	Button10Picture.Text:= "resources\img\%Button1Path0%"
	Button10.Move(283, 75, 49, 49)
	Button11Picture.Text:= "resources\img\%Button1Path1%"
	Button11.Move(59, 131, 49, 49)
	Button12Picture.Text:= "resources\img\%Button1Path2%"
	Button12.Move(115, 131, 49, 49)
	Button13Picture.Text:= "resources\img\%Button1Path3%"
	Button13.Move(171, 131, 49, 49)
	Button14Picture.Text:= "resources\img\%Button1Path4%"
	Button14.Move(227, 131, 49, 49)
	if(isFolder){
		Button15Picture.Text:= "resources\img\Volver.png"
		Button15.Move(283, 131, 49, 49)
	}
	else{
		Button15Picture.Text:= "resources\img\%Button1Path5%"
		Button15.Move(283, 131, 49, 49)
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

LeftPage(*){
	if(MoveMouseOnButtonPress)
		MouseMove %Screen_Half_X%, %Screen_Half_Y%, 0
	AltTab()
	if(InFolder){
		if(FolderPage != 0){
			if GetKeyState("Control"){
				if(FolderPage >= 10){
					FolderPage := FolderPage - 10
					SetFolderPage(ButtonFolder, FolderPage)
				}
				return
			}
			FolderPage--
			SetFolderPage(ButtonFolder, FolderPage)
		}
	}
	else{
		if(PageNumber != 0){
			if GetKeyState("Control"){
				if(PageNumber >= 10){
					PageNumber := PageNumber - 10
					SetPage(PageNumber)
				}
			}
			else{
				PageNumber--
				SetPage(PageNumber)
			}
		}
	}
	return
}

RightPage(*){
	if(MoveMouseOnButtonPress){
		MouseMove %Screen_Half_X%, %Screen_Half_Y%, 0
	}
	AltTab()
	if(InFolder){
		if GetKeyState("Control"){
			FolderPage := FolderPage + 10
			SetFolderPage(ButtonFolder, FolderPage)
			return
		}
		FolderPage++
		SetFolderPage(ButtonFolder, FolderPage)
	}
	else{
		if GetKeyState("Control"){
			PageNumber := PageNumber + 10
		}
		else{
			PageNumber++
		}
		SetPage(PageNumber)
	}
	return
}

SetImageButton(IdButton){
	OnMessage(0x44, "OnMsgBox")
	Global MsgBoxBtn1 := "Change Img"
	Global MsgBoxBtn2 := "Remove"
	Global MsgBoxBtn3 := "Cancel"
	SetImage:= MsgBox("Change Image or Remove Button?", "Change - Delete", 0x23)
	OnMessage(0x44, "")

	If SetImage "Yes"{
		ImagenASet:= FileSelect(,"*.jpg; *.png; *.gif; *.jpeg; *.bmp; *.ico")
		if ImagenASet {
			MsgBox("No image selected!")
		}
		else{
			FileCopy(%ImagenASet%, "./resources/img/%IdButton%.png", 1)
		}
	} 
	Else If SetImage "No"{
		FileDelete "./resources/img/%IdButton%.png"
		OnMessage(0x44, "OnMsgBox")
		Global MsgBoxBtn1 := "Delete"
		Global MsgBoxBtn2 := "Keep"
		MsgBox("This button has a macro file`, do you want to delete it?`n`nIts function will be lost!", "Overwrite?", 0x34) 
		OnMessage(0x44, "")

		If SetImage "Yes"{
			FileDelete %IdButton%.ahk
		}
	} 
	Else If SetImage "Cancel"{
		return
	}
	Sleep 300
	if(InFolder){
		SetFolderPage(ButtonFolder, FolderPage)
	}
	else{
		SetPage(PageNumber)	
	}
}

EditScriptButton(IdButton){
	if(!FileExist("./conf/ScriptEditorPath.txt") || !FileExist("./conf/ExtensionScripts.txt")){
		MsgBox("Select Script Editor Path", "Script Editor")
		ChangeEditorPath
	}
	else{
		if(PathEditorScripts := ""){
			; FileReadLine PathEditorScripts,"./conf/ScriptEditorPath.txt",1
		}
		if(ExtensionScripts := ""){
			; FileReadLine ExtensionScripts,"./conf/ExtensionScripts.txt",1
		}
		ScriptPath := "" IdButton "." ExtensionScripts ""
		if(!FileExist(ScriptPath)){
			FileAppend "",%ScriptPath%
		}
		Run "%PathEditorScripts%" "%ScriptPath%"
	}
}

ChangeEditorPath(*){
	; Path Editor
	FileSelect(, PathEditorScripts,,"*.exe")
	if PathEditorScripts{
		MsgBox "No executable selected!"
	}	
	else{
		FileDelete "./conf/ScriptEditorPath.txt"
		FileAppend "%PathEditorScripts%`n", "./conf/ScriptEditorPath.txt"
	}
	; Extension Scripts
	ExtensionScripts:= InputBox("Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`.", "Button Script EXT", "W500 H145", "ahk")
	if ExtensionScripts{
		MsgBox "Couldn't retrieve the extension!"
	}
	else{
		FileDelete "./conf/ExtensionScripts.txt"
		FileAppend "%ExtensionScripts%`n", "./conf/ExtensionScripts.txt"
	}
	return
}

GuiClose(){
	Exit(*){
		ExitApp
	}
	; HOTKEYS
	; *******************************
	Hotkey "~Right"
}

~Left::{
	If WinActive("Nova Macros Client"){
		LeftPage
	}
	return
}

~^Right::{
	If WinActive("Nova Macros Client"){
		RightPage ; Increase of 10 in 10
	}
	return
}

~^Left::{
	If WinActive("Nova Macros Client"){
		LeftPage ; Decrease of 10 in 10
	}
	return
}

ExecuteFunctionButton(ButtonVisual, RunFile){
	Activation := "Activate" . ButtonVisual
	RunFile.Title(Activation)
	RunFile.Show 
	try{
		Run(%RunFile%.%ExtensionScripts%)
	}
	;ChangeAlternativeImageButton(ButtonVisual, RunFile)
	feedbackExecution.push(Activation)
	SetTimer HideFeedbackExecution, 150
}

HideFeedbackExecution(){
	if(feedbackExecution.length() = 1){
		SetTimer HideFeedbackExecution, "Off"
	}
	% feedbackExecution[1]%.Hide()
	feedbackExecution.remove(1)
	return
}

ChangeAlternativeImageButton(ButtonVisual, NumberButton){ 
	; Deprecated, buttons will not have states at the moment
	ButtonPress := "Button" ButtonVisual
	if(VariableChangeImage := 0){
		ImagePath := "resources\img\" NumberButton "Enabled.png"
		if FileExist(ImagePath){
			%ButtonPress%.Text:= %ImagePath%
			if(MiniClient){
				%ButtonPress%.Move(, 49, 49)
			}
			else{
				%ButtonPress%.Move(, 130, 130)
			}
			VariableChangeImage := 1
		}
	}
	else{
		ImagePath := "resources\img\" NumberButton ".png"
		if FileExist(ImagePath){
			%ButtonPress%.Text:= %ImagePath%
			if(MiniClient){
				%ButtonPress%.Move(, 49, 49)
			}
			else{
				%ButtonPress%.Move(, 130, 130)
			}
			VariableChangeImage := 0
		}
	}
	return
}

CreateFolderButton(*){
	NewFolderName:= InputBox("Input the folder name WITHOUT spaces or weird symbols. Samples: (Programs`,GameFolder`,OBS_Buttons...)", "Input Folder Name")
	if(NewFolderName != "" && !Instr(NewFolderName, A_Space)){
		newFolderButtons := "" ; Row 1: 1|5|25...
		newFolderButtons := "" ; Row 2: OBS|Chrome|Prograplus...
		; Index though all current folder buttons
		i := 1
		while(i <= ButtonsFolders0){
			ButtonIteration := ButtonsFolders%i%
			ButtonFolder := FoldersButtons%i%
			newFolderButtons := newFolderButtons . ButtonIteration . "|"
			newFolderButtons := newFolderButtons . ButtonFolder . "|"
			i++
		}
		; Add new folder buttons to end of config
		newFolderButtons := newFolderButtons . ActiveButton
		newFolderButtons := newFolderButtons . NewFolderName
		; Replace folder buttons config file with new one containing new folder buttons
		FileDelete "conf\FolderButtons.txt"
		FileAppend % newFolderButtons% "`n" newFolderButtons, "conf\FolderButtons.txt"
		LoadButtonsFolder ; Reload folder buttons
	}
	else{
		MsgBox "Error while creating folder or cancelled.", "Error"
	}
	return
}

DeleteFolderButton(*){
	OnMessage(0x44, "OnMsgBox")
	Global MsgBoxBtn1 := "Delete"
	Global MsgBoxBtn2 := "Cancel"
	DeleteFolder:= MsgBox("If this button is a folder it may contain other buttons, delete it anyway?", "Delete Folder?", 0x34) 
	OnMessage(0x44, "")

	If DeleteFolder "Yes"{
		newFolderButtons := "" ; Row 1: 1|5|25...
		newFolderButtons := "" ; Row 2: OBS|Chrome|Prograplus...
		; Index though all current folder buttons
		i := 1
		while(i <= ButtonsFolders0){
			ButtonIteration := ButtonsFolders%i%
			; Add all folder buttons but the selected button to the list
			if(ActiveButton != ButtonIteration){
				ButtonFolder := FoldersButtons%i%
				newFolderButtons := newFolderButtons ButtonIteration "|"
				newFolderButtons := newFolderButtons ButtonFolder "|"
			}
			i++
		}
		newFolderButton:=SubStr(newFolderButtons,1,StrLen(newFolderButtons)-1) ; Remove last "|"
		newFolderButton:=SubStr(newFolderButtons,1,StrLen(newFolderButtons)-1) ; Remove last "|"
		; Replace folder buttons config file with new one containing all folder buttons but the selected one
		FileDelete "conf\FolderButtons.txt"
		FileAppend % newFolderButton% "`n" newFolderButton, "conf\FolderButtons.txt"
		LoadButtonsFolder ; Reload folder buttons
	}else{
		return
	}	
	return
}

DeleteButtonFunction(*){
	OnMessage(0x44, "OnMsgBox")
	Global MsgBoxBtn1 := "Delete"
	Global MsgBoxBtn2 := "Cancel"
	DeleteButton:= MsgBox("If this button has a function it will be deleted!", "Delete Function?", 0x34)
	OnMessage(0x44, "")

	If DeleteButton "Yes"{
		FileDelete(%ActiveButton%.ahk)
	}
	return
}

LoadButtonsFolder(){
	;~ Load Buttons associated with folders
	NumberLoop := 1
	Loop read, "./conf/FolderButtons.txt"
	{
		StrSplit(LineArray1, A_LoopReadLine, A_Tab)
		if(NumberLoop == "1"){
			ButtonsFoldersRead := LineArray1
		}
		else if(NumberLoop == "2"){
			FoldersButtonsRead := LineArray1
		}
		NumberLoop++
	}
	ButtonsFolders:= StrSplit(ButtonsFoldersRead, "|")
	FoldersButtons:= StrSplit(FoldersButtonsRead, "|")
	global ButtonsFolders0
	return
}

OnMsgBox(){
    DetectHiddenWindows "On"
    ProcessExist
    If (WinExist("ahk_class #32770 ahk_pid ")){
        ControlSetText Button1, % MsgBoxBtn1%
        ControlSetText Button2, % MsgBoxBtn2%
        ControlSetText Button3, % MsgBoxBtn3%
        ControlSetText Button4, % MsgBoxBtn4%
    }
}

AltTab(){
	global
	; Alt tab replacement, faster, less distracting
	if(SendAltTabOnButtonPress){
		list := ""
		id:= WinGetID(list)
		Loop %id%{
			this_ID := id%A_Index%
			If WinActive("ahk_id" %this_ID%)
				continue    
			WinGetTitle title, "ahk_id" %this_ID%
			If (title := "")
				continue
			If (!IsWindow(WinExist("ahk_id" . this_ID))) 
				continue
			WinActivate "ahk_id" %this_ID%, ,2
				break
		}
	}
}

; Check whether the target window is activation target
IsWindow(hWnd){
   	dwStyle:= WinGetStyle("Style", "ahk_id" %hWnd%)
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)){
        return false
    }
    dwExStyle:= WinGetExStyle("ExStyle", "ahk_id" %hWnd%)
    if (dwExStyle & 0x00000080){
        return false
    }
    WinGetClass(szClass, "ahk_id" %hWnd%)
    if (szClass := "TApplication"){
        return false
    }
    return true
}