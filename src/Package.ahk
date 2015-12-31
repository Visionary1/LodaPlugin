﻿;@Ahk2Exe-SetName 로다 플러그인
;@Ahk2Exe-SetDescription 팟플레이어 플러그인
;@Ahk2Exe-SetVersion 0.3.7
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플러그인
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력

FileCreateDir, % A_Temp . "\LodaPlugin\"
FileInstall, Resource\Resource.zip, % A_Temp . "\LodaPlugin\LodaPlugin.zip"
#SingleInstance Off
#KeyHistory 0
SetKeyDelay, 20, 10
SetWinDelay, 0
SetControlDelay, 0
ListLines Off
;SetBatchLines, -1
ComObjError(False)
Menu, Tray, NoStandard
ShowGa := Func("ShowGa"), Terminate := Func("Terminate")
Menu, Tray, Add, 가가라이브 채팅, % ShowGa
Menu, Tray, Add,
Menu, Tray, Add, 종료하기, % Terminate

If !FileExist(A_Temp . "\LodaPlugin\PD.png") {
	zip := new ZipFile(A_Temp . "\LodaPlugin\LodaPlugin.zip")
	zip.Unpack("", A_Temp . "\LodaPlugin\")
	zip := ""
}

global Resizer 		:= DynaCall("MoveWindow", ["tiiiii", 1, 2, 3, 4, 5], _dHwnd := "", _dX := "", _dY := "", _dW := "", _dH := "", True)
global pVersion		:= "0.3.7"
global RsrcPath 	:= A_Temp . "\LodaPlugin\"
global jXon		:= JSON.Load("https://goo.gl/z0b7GM",, True)
global ParsePos 	:= {"PD": jXon.parse["Position_PD"]
			, "Title": jXon.parse["Position_Title"]
			, "TwitchPos": jXon.parse["Position_Twitch"]
			, "TwitchPD": jXon.parse["Position_TwitchPD"]}
global __Noti 		:= new CleanNotify("로다 플러그인", "팟플레이어 애드온`n" , (A_ScreenWidth / 3) + 10, (A_ScreenHeight / 6) - 10, "vc hc", "P")
global __Main		:= new LodaPlugin()
global __GaGa 		:= new Browser("가가라이브 채팅", "http://goo.gl/zlBZPF")
__Main.RegisterCloseCallback(Func("Destruction"))
Win.Top(__Main.hPlugin)
Return

Destruction() {
	Critical
	If FileExist(RsrcPath . "hosts") {
		FileRead, Backup, % RsrcPath . "hosts"
		FileRead, Recent, C:\Windows\System32\Drivers\etc\hosts
		If (Backup != Recent)
			FileOpen("C:\Windows\System32\Drivers\etc\hosts", "w", "UTF-8").Write(Backup).Close()
	}
	
	DllCall("CoUninitialize")
	ExitApp
}

Terminate() {
	If WinExist("ahk_id " . __Noti.hNotify)
		Destruction()
	Else
		Win.Kill(__Main.PotPlayer["Hwnd"])
}

ShowGa() {
	__GaGa.Show()
}

#Include <Functor>
#Include <Browser>
#Include <CleanNotify>
#Include <MsgBox>
#Include <JSON>
#Include <Input>
#Include <WinEvents>
#Include <Win>
#Include <SetWinEventHook>
#Include <TVClose>
#Include <Thread>
#Include <Zip>
#Include <DaumPotPlayer>
#Include <LodaPlugin>
;#Include <ExecScript>