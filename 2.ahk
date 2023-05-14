;Notice: This document has been modified from the original work by Rmccawley 

#SingleInstance Force
#NoTrayIcon
SetWorkingDir "C:\Windows\System32"

global Executable := "mspaint.exe"

If WinExist(ahk_exe %Executable%)
{
	WinActivate ahk_exe %Executable%
}
else
{
	Run "C:\Windows\System32\mspaint.exe"
}