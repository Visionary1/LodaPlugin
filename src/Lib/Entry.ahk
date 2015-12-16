;@Ahk2Exe-SetName 로다 플러그인
;@Ahk2Exe-SetDescription 팟플레이어 플러그인
;@Ahk2Exe-SetVersion 0.1.3
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플러그인
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력
class Entry
{
	As(Type) 
	{
		this.Common()
		Next := ObjBindMethod(this, Type)
		%Next%()
	}
	
	Common() 
	{
		;#NoEnv ;커스텀 오토핫키에서 Default 설정으로 바꿈
		#SingleInstance Off
		SetKeyDelay, 20, 10
		SetWinDelay, 0
		SetControlDelay, 0
		;SetBatchLines, -1
		ComObjError(False)
		Menu, Tray, NoStandard
		ShowGa := Func("ShowGa"), Terminate := Func("Terminate")
		Menu, Tray, Add, 가가라이브 채팅, % ShowGa
		Menu, Tray, Add,
		Menu, Tray, Add, 종료하기, % Terminate
	}
	
	User() 
	{
		#KeyHistory 0
		ListLines Off
	}
	
	Dev() 
	{
		;#Warn
	}
}