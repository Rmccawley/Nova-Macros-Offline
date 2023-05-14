;Notice: This document has been modified from the original work by Rmccawley 
#Requires AutoHotkey v2.0
#warn
#SingleInstance Force

global buttonName := "0"
global buttonPath := A_ScriptDir "\..\..\" buttonName ".ahk"
global keyDuration, keyDelay, textVar, sendInputControl, sendRawControl, sendEventControl, instantPaste, modoSend

MainWindow:= Gui()
MainWindow.SetFont "Bold"
MainWindow.SetFont
textVar:= MainWindow.AddEdit(" x8 y8 w603 h315")
sendRawControl:= MainWindow.AddRadio("x8 y336 w360 h23 Checked", "SendRaw (Fast - Recommended for short text)")
sendInputControl:= MainWindow.AddRadio("x8 y360 w360 h23", "SendInput (Fast - Recommended when text has no symbols)")
sendEventControl:= MainWindow.AddRadio("x8 y408 w260 h23", "SendEvent (Not Recommended)")
instantPaste:= MainWindow.AddRadio("x8 y384 w379 h23", "Send Clipboard (Fastest - Recommended for long text)")
MainWindow.AddButton("x480 y408 w123 h33", "APPLY").OnEvent("Click", createMacro)
MainWindow.AddGroupBox("x8 y440 597 h84", "SendEvent/SendRaw Options   (ONLY work on SendEvent & SendRaw Mode)")
MainWindow.AddText("x16 y464 w73 h23 +0x200", "Key Delay:")
MainWindow.AddText("x16 y488 w72 h23 +0x200", "Press duration:")
keyDelay:= MainWindow.AddEdit("x88 y464 w120 h21", 0)
keyDuration:= MainWindow.AddEdit("x88 y488 w120 h21", 0)
MainWindow.AddText("x216 y464 w73 h23 +0x200", "ms")
MainWindow.AddText("x216 y488 w73 h23 +0x200", "ms")

MainWindow.Title:= "Text Block"
MainWindow.Show "w619 h549"
return

createMacro(GuiCtrlObj, Info){
	MainWindow.Submit(0)
	if(sendInputControl.Value){
		global modoSend := "SendInput"
	}
	else if(sendRawControl.Value){
		global modoSend := "SendRaw"
	}
	else if(sendEventControl.Value){
		global modoSend := "SendEvent"
	}
	if(textVar = ""){
		MsgBox("There is no text to send!", "Error", 0x10)
		return
	}
	if FileExist(buttonPath){
		;OnMessage(0x44, OnMsgBox)
		DoesFileExist:= MsgBox("This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!", "Overwrite?", 0x1)
		;OnMessage(0x44, "")
		If DoesFileExist "Yes"{
			Trigger()
		}
	}
	else{
		Trigger()
	}
	return
}

Trigger(){
	if(!instantPaste.Value){
		src := "
		(

#SingleInstance Force
#NoTrayIcon
SetKeyDelay, %keyDelay%, %keyDuration%
text =
`(
%textVar%
`)
%modoSend%, `% text
				)"
	}
	else{
		src := "
		(

#SingleInstance Force
#NoTrayIcon
Clipboard =
`(
%textVar%
`)
Sleep 500
Send, {LControl Down}v{LControl Up}
		)"
	}
	FileDelete buttonPath
	FileAppend src, buttonPath
	ExitApp
}

GuiEscape:
GuiClose:
    ExitApp
	
OnMsgBox(){
    DetectHiddenWindows "On"
    ProcessExist
    ; If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)){
    ;     ControlSetText "Overwrite", Button1
    ;     ControlSetText "CANCEL", Button2
    ; }
}