;@Ahk2Exe-SetName 로다 플러그인
;@Ahk2Exe-SetDescription 팟플레이어 플러그인
;@Ahk2Exe-SetVersion 0.3.2
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플러그인
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력
Class Entry
{
	As(Type := "User")
	{
		this.Admin()
		this.Common()
		If (Type == "User")
			this.User()
		Else If (Type == "Dev")
			this.Dev()
	}

	Admin()
	{
		If !(A_IsAdmin) {
			If (A_IsCompiled)
				DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? "Ptr" : "UInt"), 0, "Str", "RunAs", "Str", A_ScriptFullPath, "Str", "" , "Str", A_WorkingDir, "Int", 1)
			Else
				DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? "Ptr" : "UInt"), 0, "Str", "RunAs", "Str", A_AhkPath, "Str", """" . A_ScriptFullPath . """" . A_Space . "", "Str", A_WorkingDir, "Int", 1)
			ExitApp
		}
	}
	
	Common() 
	{
		#NoEnv ;Changed to Default for new AutoHotkey v2
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