#NoEnv
#SingleInstance, Force
SetBatchLines, -1
#NoTrayIcon
SetWorkingDir C:\Program Files\obs-studio\bin\64bit

global Executable := "obs64.exe"

IfWinExist, ahk_exe %Executable%
{
	WinActivate, ahk_exe %Executable%
}
else
{
	Run, C:\Program Files\obs-studio\bin\64bit\obs64.exe
}