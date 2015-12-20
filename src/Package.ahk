;@Ahk2Exe-SetName 로다 플러그인
;@Ahk2Exe-SetDescription 팟플레이어 플러그인
;@Ahk2Exe-SetVersion 0.3.2
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플러그인
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력

Entry.As("User")
global Resizer 		:= DynaCall("MoveWindow", ["tiiiii", 1, 2, 3, 4, 5], _dHwnd := "", _dX := "", _dY := "", _dW := "", _dH := "", True)
global pVersion		:= "0.3.2"
global RsrcPath 	:= A_Temp . "\LodaPlugin\"
global jXon		:= JSON.Load("https://goo.gl/z0b7GM",, True)
global ParsePos 	:= {"PD": jXon.parse["Position_PD"]
			, "Title": jXon.parse["Position_Title"]
			, "TwitchPos": jXon.parse["Position_Twitch"]
			, "TwitchPD": jXon.parse["Position_TwitchPD"]}
global __Noti 		:= new CleanNotify("로다 플러그인", "팟플레이어 애드온`n" , (A_ScreenWidth / 3) + 10, (A_ScreenHeight / 6) - 10, "vc hc", "P")
global __Main		:= new LodaPlugin()
global __GaGa 		:= new Browser("가가라이브 채팅", "http://goo.gl/zlBZPF")
__Main.RegisterCloseCallback(Func("CloseCallback"))
Win.Activate("ahk_id " . __Main.hPlugin)
Return

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
#Include <Install>
#Include <DaumPotPlayer>
#Include <Entry>
#Include <LodaPlugin>