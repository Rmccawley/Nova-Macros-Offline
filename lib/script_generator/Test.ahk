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
MainWindow.Show()
return

Create(GuiCtrlObj, Info){
    newGui:= Gui()
    newGUi.Show()
    return
}