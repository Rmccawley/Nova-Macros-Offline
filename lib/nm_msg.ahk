#Requires AutoHotkey v2.0

global txtNMMsg
nmMsg(nmMsg,time,rainbow:=1){
	WinGetPos &X,&Y,,,"Nova Macros Client"
	nfX := X
	nfY := Y + 500
	nmMsg "+ToolWindow -Caption +AlwaysOnTop"
	nmMsg.Color "Black"
	nmMsg.Font "s24 cWhite", "Press Start 2P"
	global txtNMMsg:= nmMsg.AddText("x24 y48 w1024 h60 +0x200 +Center +BackgroundTrans", % nmMsg%)
	nmMsg.Title:= "msgNovaMacros"
	nmMsg.Show "x%nfX% y%nfY% w1024 h159"
	WinSetTransColor "Black","msgNovaMacros"
	if(rainbow){
		Loop % time%{
			nmMsg "+cfb0505 +Redraw", txtNMMsg
			Sleep 100
			nmMsg "+cfb7607 +Redraw", txtNMMsg
			Sleep 100
			nmMsg "+cf4ea07 +Redraw", txtNMMsg
			Sleep 100
			nmMsg "+c61f205 +Redraw", txtNMMsg
			Sleep 100
			nmMsg "+c00f6cb +Redraw", txtNMMsg
			Sleep 100
		}
	}
	else{
		Sleep 1000 * time
	}
	nmMsg.Destroy
}