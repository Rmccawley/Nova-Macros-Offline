;Notice: This document has been modified from the original work by Rmccawley 

#Requires AutoHotkey v2.0

#SingleInstance Force
#NoTrayIcon
SetWorkingDir "C:\Program Files\obs-studio\bin\64bit"

global Executable := "obs64.exe"

If WinExist("ahk_exe" Executable)
{
	WinActivate ("ahk_exe" Executable)
}
else
{
	Run "C:\Program Files\obs-studio\bin\64bit\obs64.exe"
}