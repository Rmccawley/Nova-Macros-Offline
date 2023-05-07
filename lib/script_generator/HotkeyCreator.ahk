#NoEnv
#SingleInstance,Force
global WindowsKey, Edt1, Edt2
global buttonName = %0% 
global buttonPath := A_ScriptDir "\..\..\" buttonName ".ahk"
global delay
WindowsKey := 0

Gui, +hwndHw
Gui, Color, , 44444444
Gui, Font, s14 cffff00 TAhoma
Gui,Add,Hotkey, W280 x-990 y6 vEdt1 gEdt1 hwndHedt1
Gui,Add,Edit, x10 y6 w280 gEdt2 vEdt2 hwndHedt2 Background00ffff, None
Gui, Font, s10 c000000 TAhoma
Gui Font, Bold
Gui Add, CheckBox, x16 y48 w190 h23 gWindowsKey vWindowsKey, Windows Key Pressed
Gui Add, Button, x200 y104 w95 h30 gCreate, APPLY
Gui Add, Text, x16 y80 w90 h23 +0x200, Custom Key:
Gui, Font, s10 cffff00 TAhoma
Gui Add, Edit, vcustomKey gcustomKey x110 y80 w120 h21 ; Custom Key
Gui, Font, s10 c000000 TAhoma
Gui Add, Text, x16 y112 w70 h23 +0x200, Delay (s):
Gui, Font, s10 cffff00 TAhoma
Gui Add, Edit, vdelay x90 y112 w47 h21 +Number ; Delay
Gui,Show, w300 h142, Generate Macro

GuiControl, Focus, Edt1
;~ OnMessage(0x133, "Focus_Hk") ; Auto Focus Hotkey Field
;~ SetTimer, FcEdt, 250
return

Focus_Hk() {
    GuiControl, Focus, Edt1
}

customKey:
    GuiControlGet, customKey,,customKey
    GuiControl,,Edt2, % customKey
    GuiControl,,Edt1, % customKey
return

;~ FcEdt:
    ;~ if !WinActive("ahk_id " Hw)
        ;~ GuiControl, Focus, Edt2
;~ return

Edt2:
    ControlGetFocus, focusedControl, A
    if(focusedControl = "Edit1")
    {
        GuiControl, Focus, Edt1
    }
return

Edt1:
    GuiControlGet, Ehk,, Edt1
    StringUpper, Ehk, Ehk , T
    Ehk:=StrReplace(Ehk, "`+", "Shift + "), Ehk:=StrReplace(Ehk, "`!", "Alt + "), Ehk:=StrReplace(Ehk, "`^", "Ctrl + ")
    if Ehk
        GuiControl,, Edt2, % Ehk
    else GuiControl,, Edt2, None
Return

WindowsKey:
    WindowsKey := !WindowsKey
return

Create:
    if FileExist(buttonPath)
	{
		OnMessage(0x44, "OnMsgBox")
		MsgBox 0x34, Overwrite?, This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			Trigger()
		}
	}
	else
	{
		Trigger()
	}
return

Trigger()
{
    Gui, Submit, NoHide
    Key := SubStr(Edt1, StrLen(Edt1), 1)
    if(Key = "+")
    {
        StringTrimRight, EdtNoPlusKey, Edt, 1
        plusKey := 1
    }
    else
    {
        plusKey := 0
    }
    if(!plusKey)
    {
        plus := InStr(Edt1,"+",0,0)
        accent := InStr(Edt1,"^",0,0)
        exclamation := InStr(Edt1,"!",0,0)
        if(plus > accent && plus > exclamation)
        {
            Modifiers := SubStr(Edt1, 1, plus)
        }
        else if(accent > plus && accent > exclamation)
        {
            Modifiers := SubStr(Edt1, 1, accent)
        }
        else if(exclamation > accent && exclamation > plus)
        {
            Modifiers := SubStr(Edt1, 1, exclamation)
        }
        if(plus = 0 && accent = 0 && exclamation = 0 && WindowsKey = 0)
        {
            areModifiers := 0
        }else
        {
            areModifiers := 1
        }
        StringReplace, Key, Edt1, %Modifiers%,,All
        Key = {%Key%}
    }
    else
    {
        plus := InStr(EdtNoPlusKey,"+",0,0)
        accent := InStr(EdtNoPlusKey,"^",0,0)
        exclamation := InStr(EdtNoPlusKey,"!",0,0)
        if(plus > accent && plus > exclamation)
        {
            Modifiers := SubStr(EdtNoPlusKey, 1, plus)
        }
        else if(accent > plus && accent > exclamation)
        {
            Modifiers := SubStr(EdtNoPlusKey, 1, accent)
        }
        else if(exclamation > accent && exclamation > plus)
        {
            Modifiers := SubStr(EdtNoPlusKey, 1, exclamation)
        }
        if(plus = 0 && accent = 0 && exclamation = 0 && WindowsKey = 0)
        {
            areModifiers := 0
        }else
        {
            areModifiers := 1
        }
        Key := "+"
    }
    
    strModifiersDown := ""
    strModifiersUp := ""
    if(Instr(Modifiers, "!"))
    {
        alt := 1
        strModifiersDown := strModifiersDown "{Alt Down}"
        strModifiersUp := strModifiersUp "{Alt Up}"
    }
    else
    {
        alt := 0
    }
    if(Instr(Modifiers, "^"))
    {
        control := 1
        strModifiersDown := strModifiersDown "{Control Down}"
        strModifiersUp := strModifiersUp "{Control Up}"
    }
    else
    {
        control := 0
    }
    if(Instr(Modifiers, "+"))
    {
        shift := 1
        strModifiersDown := strModifiersDown "{Shift Down}"
        strModifiersUp := strModifiersUp "{Shift Up}"
    }
    else
    {
        shift := 0
    }
    if(WindowsKey)
    {
        strModifiersDown := strModifiersDown "{LWin Down}"
        strModifiersUp := strModifiersUp "{LWin Up}"
    }
    if(delay != "")
    {
        delay := "Sleep, " delay*1000
    }
    if(!areModifiers)
    {
		src =
		(Ltrim
            #NoEnv
            #SingleInstance, Force
            SetBatchLines, -1
            #NoTrayIcon
            %delay%
            Send, %Key%
        )
    }
    else
    {
        src =
		(Ltrim
            #NoEnv
            #SingleInstance, Force
            SetBatchLines, -1
            #NoTrayIcon
            %delay%
            Send, %strModifiersDown%
            Sleep, 30
            Send, %Key%
            Sleep, 30
            Send, %strModifiersUp%
            Sleep, 30
        )
    }
    FileDelete, % buttonPath
	FileAppend, %src%, % buttonPath
	ExitApp
}

GuiClose:
	ExitApp