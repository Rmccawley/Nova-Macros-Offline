;Notice: This document has been modified from the original work by Rmccawley 
#Requires AutoHotkey v2.0

#SingleInstance Force

global WindowsKeyCheckBox, Edt1HotKey, Edt2Edit
global buttonName := "0"
global buttonPath := A_ScriptDir "\..\..\" buttonName ".ahk"
global delay:= ""
global Modifiers:= ""
MainWindow := 0

MainWindow := Gui()
; MainWindow "+hwndHw"
MainWindow.BackColor:= 44444444
MainWindow.SetFont "s14 cffff00", "TAhoma"
Edt1HotKey:= MainWindow.AddHotkey("W280 x-990 y6")
Edt2Edit:= MainWindow.AddEdit("x10 y6 w280 Background00ffff", "None") ;.OnEvent("Change", Edt2)
MainWindow.SetFont "s10 c000000", "TAhoma"
MainWindow.SetFont "Bold"
WindowsKeyCheckBox:= MainWindow.AddCheckBox("x16 y48 w190 h23", "Windows Key Pressed") ;.OnEvent("Click", ToggleWindowsKey)
MainWindow.AddButton("x200 y104 w95 h30", "APPLY").OnEvent("Click", Create)
MainWindow.AddText("x16 y80 w90 h23 +0x200", "Custom Key:")
MainWindow.SetFont("s10 cffff00", "TAhoma")
customKeyEdit:= MainWindow.AddEdit("x110 y80 w120 h21") ;.OnEvent("Change", customKey) ; Custom Key
MainWindow.SetFont("s10 c000000", "TAhoma")
MainWindow.AddText("x16 y112 w70 h23 +0x200", "Delay (s):")
MainWindow.SetFont("s10 cffff00", "TAhoma")
delay:= MainWindow.AddEdit("x90 y112 w47 h21 +Number") ; Delay
MainWindow.Title:= "Generate Macro"
MainWindow.Show("w300 h142")

Edt1HotKey.Focus()
;~ OnMessage(0x133, "Focus_Hk") ; Auto Focus Hotkey Field
;~ SetTimer, FcEdt, 250
return

Focus_Hk() {
    Edt1HotKey.Focus()
}

customKey(){
    mCustomKey:= customKeyEdit
    Edt2Edit % mCustomKey%
    Edt1HotKey % mCustomKey%
    return
}

;~ FcEdt(){
    ;~ if !WinActive("ahk_id " Hw)
        ;~ GuiCrtl Focus, Edt2
;~ return
;~}

Edt2(){
    focusedControl:= ControlGetFocus("A")
    if(focusedControl := "Edit1"){
        Edt1HotKey.Focus()
    }
    return
}

Edt1(){
    if Edt1HotKey
        Edt2Edit.Edt2 % Edt1HotKey%
    else Edt2Edit.Edt2 "None"
    return
}

; ToggleWindowsKey(){
;     global WindowsKeyCheckBox := !WindowsKeyCheckBox
;     return
; }

Create(GuiCtrlObj, Info){
    if FileExist(buttonPath){
		;OnMessage(0x44, OnMsgBox)
		OverwriteFile:= MsgBox("This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!", "Overwrite?", 0x34)
		;OnMessage(0x44, "")

		If OverwriteFile "Yes"{
			Trigger()
		}
	}
	else{
		Trigger()
	}
    return
}

Trigger()
{
    MainWindow.Submit(0)
    Key := SubStr(Edt1HotKey.Text:=, StrLen(Edt1HotKey.Text:=), 1)
    if(Key := "+"){
        EdtNoPlusKey:= SubStr(Edt1HotKey.Text:=, -1)
        plusKey := 1
    }
    else{
        plusKey := 0
    }
    if(!plusKey){
        plus := InStr(Edt1HotKey.Text:=,"+",0,0)
        accent := InStr(Edt1HotKey.Text:=,"^",0,0)
        exclamation := InStr(Edt1HotKey.Text:=,"!",0,0)
        if(plus > accent && plus > exclamation){
            global Modifiers := SubStr(Edt1HotKey.Text:=, 1, plus)
        }
        else if(accent > plus && accent > exclamation){
            global Modifiers := SubStr(Edt1HotKey.Text:=, 1, accent)
        }
        else if(exclamation > accent && exclamation > plus){
            global Modifiers := SubStr(Edt1HotKey.Text:=, 1, exclamation)
        }
        if(plus := 0 && accent := 0 && exclamation := 0 && WindowsKey := 0){
            areModifiers := 0
        }else{
            areModifiers := 1
        }
        StrReplace Key, Edt1HotKey.Text:=, %Modifiers%,,,"All"
        Key := "{%Key%}"
    }
    else{
        plus := InStr(
        EdtNoPlusKey,"+",0,1,)
        accent := InStr(EdtNoPlusKey,"^",0,1,)
        exclamation := InStr(EdtNoPlusKey,"!",0,1,)
        if(plus > accent && plus > exclamation){
            global Modifiers := SubStr(EdtNoPlusKey, 1, plus)
        }
        else if(accent > plus && accent > exclamation){
            global Modifiers := SubStr(EdtNoPlusKey, 1, accent)
        }
        else if(exclamation > accent && exclamation > plus){
            global Modifiers := SubStr(EdtNoPlusKey, 1, exclamation)
        }
        if(plus := 0 && accent := 0 && exclamation := 0 && WindowsKey := 0){
            areModifiers := 0
        }else{
            areModifiers := 1
        }
        Key := "+"
    }
    
    strModifiersDown := ""
    strModifiersUp := ""
    if(Instr(Modifiers, "!")){
        alt := 1
        strModifiersDown := strModifiersDown "{Alt Down}"
        strModifiersUp := strModifiersUp "{Alt Up}"
    }
    else{
        alt := 0
    }
    if(Instr(Modifiers, "^")){
        control := 1
        strModifiersDown := strModifiersDown "{Control Down}"
        strModifiersUp := strModifiersUp "{Control Up}"
    }
    else{
        control := 0
    }
    if(Instr(Modifiers, "+")){
        shift := 1
        strModifiersDown := strModifiersDown "{Shift Down}"
        strModifiersUp := strModifiersUp "{Shift Up}"
    }
    else{
        shift := 0
    }
    if(WindowsKeyCheckBox){
        strModifiersDown := strModifiersDown "{LWin Down}"
        strModifiersUp := strModifiersUp "{LWin Up}"
    }
    if(delay != ""){
        global delay := "Sleep " delay*1000
    }
    if(!areModifiers){
		src := "
		(Ltrim
            #NoTrayIcon
            #SingleInstance Force
            
            %delay%
            Send(%Key%)
        )"
    }
    else{
        src := "
		(Ltrim
            #NoTrayIcon
            #SingleInstance Force
            
            %delay%
            Send %strModifiersDown%
            Sleep(30)
            Send %Key%
            Sleep(30)
            Send %strModifiersUp%
            Sleep(30)
        )"
    }
    FileDelete(buttonPath)
	FileAppend(src, buttonPath)
	ExitApp
}

GuiClose(){
	ExitApp
}